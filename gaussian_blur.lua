local conv2d = require("conv2d")
local effect = require("effect")

local gaussian_blur = {}
gaussian_blur.__index = gaussian_blur
setmetatable(gaussian_blur, effect)

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function gaussian_blur.new(radius, offset, edges)
    local self = effect.new()
    setmetatable(self, gaussian_blur)

    self.blur_radius = radius
    self.blur_offset = offset
    self.edges = edges
    
    local size = self.blur_radius * 2 * self.blur_offset + 1
    local weights = {}

    -- Sample 1D Gaussian function at pixel locations
    for i = 1, size do
        local x = (i - 1) - self.blur_radius * self.blur_offset
        weights[i] = gaussian_1D(self.blur_radius, x)
    end

    self.conv = conv2d.new(weights, true)

    return self
end

--------------------------------------------------------------------------------
-- Calculates the value of a Gaussian distribution at a given point.
-- @param sigma the standard deviation of the Gaussian distribution
-- @param x the point at which to calculate the value
-- @return the value of the Gaussian distribution at point x

function gaussian_1D(sigma, x)
    local two_sigma_sq = 2.0 * sigma * sigma
    local pi = math.pi
    return math.exp(-x * x / two_sigma_sq) / math.sqrt(two_sigma_sq * pi)
end

return gaussian_blur
