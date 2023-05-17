local conv2d = require("conv2d")
local effect = require("effect")

local sharpen = {}
sharpen.__index = sharpen
setmetatable(sharpen, effect)

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function sharpen.new(amount)
    local self = effect.new()
    setmetatable(self, sharpen)

    self.conv = conv2d.new({-amount, 1 + 2 * amount, -amount}, false)

    return self
end

return sharpen
