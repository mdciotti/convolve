local effect = {}
effect.__index = effect

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function effect.new(amount)
    local self = {}
    setmetatable(self, effect)

    self.conv = nil
    self.result = nil

    return self
end

--------------------------------------------------------------------------------
-- A helper function which generates a blurred background of the screen
-- before the modal window is drawn on top.
-- @param src the source screen buffer to blur
-- @return the resultant blurred screen buffer

function effect:apply(src)
    self.result = love.graphics.newCanvas(src:getDimensions())
    self.conv:filter(src, self.result)
    return self.result
end

return effect
