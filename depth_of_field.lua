local effect = require("effect")

local depth_of_field = {}
depth_of_field.__index = depth_of_field
setmetatable(depth_of_field, effect)

--------------------------------------------------------------------------------
-- Creates a GLSL shader via templating to compute a convolution with the given
-- kernel size and weights.
-- @param w the kernel width
-- @param h the kernel height
-- @param weights the table of weight data in this kernel (one-dimensional)

function make_shader(w, h, weights)
    local n = w * h

    -- Stringify weight list
    local list = "" .. weights[1]
    for i = 2, #weights do
        list = list .. ", " .. weights[i]
    end

    return string.format([[#ifdef PIXEL
const int width = %d;
const int height = %d;
const float weights[%d] = float[%d](%s);
const float g = 1.0;
int hw = (width - 1) / 2;
int hh = (height - 1) / 2;

uniform float tex_w;
uniform float tex_h;
uniform Image depth_map;
uniform float focal_plane;
uniform float depth_of_field;

float d(float x)
{
    return 0.2 * (1.0 / (1.0 - x) - 1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 sum = vec4(0.0, 0.0, 0.0, 1.0);
    float weight, scale;
    vec2 offset;
    float depth = Texel(depth_map, texture_coords).r;
    // float scale = abs(depth - focal_plane) / depth_of_field;
    // return vec4(vec3(scale), 1.0);
    // float dist = (1.0/(1.0 + focal_plane)) * abs(depth - focal_plane) - depth_of_field;
    float dist = (1.0/(1.0 + focal_plane)) * abs(depth - focal_plane) - depth_of_field;
    return vec4(dist < 0.0 ? 1.0 : dist);
    return dist < 0.0 ? Texel(texture, texture_coords) : vec4(1.0);
    if (scale <= 1.0) return Texel(texture, texture_coords);

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            weight = weights[y * width + x];
            offset.x = scale * (x - hw) / tex_w;
            offset.y = scale * (y - hh) / tex_h;
            sum += weight * Texel(texture, texture_coords + offset);
        }
    }

    return vec4(sum.rgb, 1.0);
}
#endif
]], w, h, n, n, list)
end

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function depth_of_field.new(radius, depth_map)
    local self = {}
    setmetatable(self, depth_of_field)

    self.depth_map = depth_map

    self.size = 2*radius
    self.weights = {}
    local intensity = 1 / (self.size * self.size)

    -- Create circular PSF (point source function) kernel
    for y = 0, self.size-1 do
        for x = 0, self.size-1 do
            local dx = x - radius
            local dy = y - radius
            local dd = dx*dx + dy*dy
            local wi = y * self.size + x + 1
            if dd < radius*radius - 64 then
                self.weights[wi] = 0.8*intensity
            elseif dd < radius*radius - 9 then
                self.weights[wi] = 1.5*intensity
            else
                self.weights[wi] = 0
            end
        end
    end

    -- Create square convolution kernel
    local source = make_shader(self.size, self.size, self.weights)
    self.shader = love.graphics.newShader(source)

    return self
end

--------------------------------------------------------------------------------
-- Applies the convolution filter on the source buffer.
-- @param src the source buffer
-- @param dst the destination buffer

function depth_of_field:filter(src, dst)
    love.graphics.setCanvas(dst)
    love.graphics.setShader(self.shader)
    self.shader:send("tex_w", src:getWidth())
    self.shader:send("tex_h", src:getHeight())
    self.shader:send("depth_map", self.depth_map)
    self.shader:send("focal_plane", love.mouse.getX() / src:getWidth())
    self.shader:send("depth_of_field", 0.1)
    -- self.shader:send("src", src)

    -- Note: usually you should set the color to white before drawing textures
    -- but the current shader discards this color information anyway.
    -- love.graphics.setColor(255, 255, 255, 255)

    -- Calculate offset if sizes are different (src will be centered in dst)
    local ox = (dst:getWidth() - src:getWidth()) / 2
    local oy = (dst:getHeight() - src:getHeight()) / 2

    -- Note: cannot use rectangles to draw texture data! Instead we can either
    -- draw a mesh (and pass the texture as a uniform) or the texture itself
    -- love.graphics.draw(self.mesh)
    love.graphics.draw(src, ox, oy)

    love.graphics.setShader()
    love.graphics.setCanvas()
end

--------------------------------------------------------------------------------
-- A helper function which generates a blurred background of the screen
-- before the modal window is drawn on top.
-- @param src the source screen buffer to blur
-- @return the resultant blurred screen buffer

function depth_of_field:apply(src)
    self.result = love.graphics.newCanvas(src:getDimensions())
    self:filter(src, self.result)
    return self.result
end

return depth_of_field
