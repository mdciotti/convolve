local kernel = {}
kernel.__index = kernel

--------------------------------------------------------------------------------
-- Creates a discrete 2D convolution kernel.
-- @param width the width of this kernel
-- @param height the height of this kernel
-- @param weights the associated weight data at each location in the kernel

function kernel.new(width, height, weights)
    local self = {}
    setmetatable(self, kernel)

    if width * height ~= #weights then
    	error("kernel.new() requires that width * height == #weights")
    end

    self.width = width
    self.height = height
    self.weights = weights

    return self
end

return kernel
