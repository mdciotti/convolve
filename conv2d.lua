local kernel = require("kernel")
local convolve_op = require("convolve_op")

local conv2d = {}
conv2d.__index = conv2d

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function conv2d.new(weights, normalize)
    local self = {}
    setmetatable(self, conv2d)

    self.size = #weights

    self.edges = 'constant'
    self.edge_constant = {0, 0, 0, 0}
    self.normalize = normalize
    self.weights = weights
    self.channels = { r = true, g = true, b = true, a = true }

    if self.normalize then
        -- Normalize to maintain sum = 1
        local sum = 0
        for i, w in ipairs(self.weights) do
            sum = sum + self.weights[i]
        end
        for i, w in ipairs(self.weights) do
            self.weights[i] = self.weights[i] / sum
        end
    end

    -- Create two perpendicular convolution kernels
    local hkernel = kernel.new(1, self.size, weights)
    self.hconv = convolve_op.new(hkernel)

    local vkernel = kernel.new(self.size, 1, weights)
    self.vconv = convolve_op.new(vkernel)

    return self
end

--------------------------------------------------------------------------------
-- A helper function which generates a blurred background of the screen
-- before the modal window is drawn on top.
-- @param src the source screen buffer to blur
-- @return the resultant blurred screen buffer

function conv2d:filter(src, dst)

    local w = src:getWidth()
    local h = src:getHeight()

    local pad_buffer, hbuffer

    if self.edges == 'constant' then
        -- Calculate edge offset
        local pad = self.size - 1
        -- local pad = -10

        -- Create a temporary oversized buffer for proper edge effects
        pad_buffer = love.graphics.newCanvas(w + pad, h + pad)

        -- Draw src buffer to temporary oversized buffer
        love.graphics.setCanvas(pad_buffer)
        love.graphics.setColor(self.edge_constant)
        love.graphics.rectangle('fill', 0, 0, w + pad, h + pad)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(src, pad / 2, pad / 2)
        love.graphics.setCanvas()

        hbuffer = love.graphics.newCanvas(w, h + pad)
    elseif self.edges == 'extend' then
    elseif self.edges == 'wrap' then
    elseif self.edges == 'crop' then
    elseif self.edges == nil then
        hbuffer = love.graphics.newCanvas(w, h)
        pad_buffer = src
    end

    -- Apply blur in two passes: horizontal and vertical
    self.hconv:filter(pad_buffer, hbuffer)
    self.vconv:filter(hbuffer, dst)
end

return conv2d
