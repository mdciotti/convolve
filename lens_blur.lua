local kernel = require("kernel")
local convolve_op = require("convolve_op")
local effect = require("effect")

local lens_blur = {}
lens_blur.__index = lens_blur
setmetatable(lens_blur, effect)

function poly(n, theta)
    return 1 - math.cos(math.pi / n) / math.cos(theta - 2 * math.pi / n * math.floor((n * theta + math.pi) / (2 * math.pi)))
end

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function lens_blur.new(radius)
    local self = {}
    setmetatable(self, lens_blur)

    self.size = 2*radius
    self.weights = {}
    local intensity = 1 / (self.size * self.size)

    -- Create circular PSF (point source function) kernel
    for y = 0, self.size-1 do
        for x = 0, self.size-1 do
            local dx = x - radius
            local dy = y - radius
            local dd = dx*dx + dy*dy
            -- local rp = radius/2 + poly(5, math.atan2(dy, dx))
            local wi = y * self.size + x + 1
            -- if dd < rp*rp then
            --     self.weights[wi] = intensity
            -- else
            --     self.weights[wi] = 0
            -- end
            if dd < radius*radius - 64 then
                self.weights[wi] = 0.8*intensity
            elseif dd < radius*radius - 9 then
                self.weights[wi] = 1.5*intensity
            else
                self.weights[wi] = 0
            end
        end
    end

    -- local str = ""
    -- for x, v in ipairs(self.weights) do
    --     str = str .. ", " .. v
    -- end
    -- print(str)

    -- Create square convolution kernel
    local k = kernel.new(self.size, self.size, self.weights)
    self.conv = convolve_op.new(k)

    return self
end

return lens_blur
