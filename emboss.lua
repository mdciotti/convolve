local conv2d = require("conv2d")
local effect = require("effect")

local emboss = {}
emboss.__index = emboss
setmetatable(emboss, effect)

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function emboss.new(amount)
    local self = effect.new()
    setmetatable(self, emboss)

    self.conv = conv2d.new({amount, amount, -amount}, false)

    return self
end

return emboss
