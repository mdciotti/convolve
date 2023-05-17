local conv2d = require("conv2d")
local effect = require("effect")

local edge_detect = {}
edge_detect.__index = edge_detect
setmetatable(edge_detect, effect)

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function edge_detect.new(amount)
    local self = effect.new()
    setmetatable(self, edge_detect)

    self.conv = conv2d.new({amount, -2 * amount, amount}, false)

    return self
end

return edge_detect
