
local source, result, result2, depth_map
local effects = {}
local current_effect, current_effect2

effects['gaussian_blur'] = require('gaussian_blur')
effects['lens_blur'] = require('lens_blur')
effects['depth_of_field'] = require('depth_of_field')
-- effects['sharpen'] = require('sharpen')
-- effects['edge_detect'] = require('edge_detect')
-- effects['emboss'] = require('emboss')

function love.load()
	-- source = love.graphics.newImage("placeholder.jpg")
	-- source = love.graphics.newImage("newark.jpg")
	source = love.graphics.newImage("cube.jpg")
	depth_map = love.graphics.newImage("cube_depth.jpg")
	love.window.setTitle("Convolutional Image Filtering")
	love.window.setMode(source:getDimensions())
	-- set_effect('gaussian_blur', {8, 3})
	-- current_effect2 = effects['gaussian_blur'].new(8, 3)
	-- set_effect('lens_blur', {16})
	set_effect('depth_of_field', {16, depth_map})
	-- set_effect('sharpen', {1})
	-- set_effect('edge_detect', {2})
	-- set_effect('emboss', {1})
	print(tostring(love.graphics.isGammaCorrect()))
end

function love.filedropped(file)
	local path = file:getFilename()
	love.window.setTitle(path)
	local i = string.find(string.reverse(path), '/')
	local start = string.len(path) - i + 2
	local name = string.sub(path, start)
	source = love.graphics.newImage(name)
	love.window.setMode(source:getDimensions())
	apply_effect()
end

function set_effect(e, params)
	if effects[e] ~= nil then
		current_effect = effects[e].new(unpack(params))
		apply_effect()
	end
end

function apply_effect()
	if current_effect ~= nil and source ~= nil then
		love.graphics.push()
		love.graphics.setCanvas(result)
		love.graphics.clear()
		result = current_effect:apply(source)

		-- love.graphics.setCanvas(result2)
		-- love.graphics.clear()
		-- result2 = current_effect2:apply(source)
		love.graphics.setCanvas()
		love.graphics.pop()
	end
end

function love.update()
	apply_effect()
end

local swap = false

function love.mousepressed(x, y, button)
	swap = not swap
end

function love.draw()
	-- Set color to opaque white for drawing bitmaps
	love.graphics.setColor(255, 255, 255, 255)

	-- Draw source image
    if source ~= nil and not swap then
		love.graphics.draw(source)
		-- love.graphics.draw(result2)
	end

	-- Draw resultant image
	if result ~= nil and swap then
		love.graphics.draw(result)
	end
end
