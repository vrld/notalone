Camera = {}
Camera.__index = Camera
function Camera.new(pos, zoom)
	pos = pos or vector.new(love.graphics.getWidth(), love.graphics.getHeight()) / 2
	zoom = zoom or 1
	return setmetatable({pos = pos, zoom = zoom}, Camera)
end

function Camera:screencenter()
	return vector.new(love.graphics.getWidth(), love.graphics.getHeight()) / self.zoom / 2
end

function Camera:predraw()
	love.graphics.push()
	love.graphics.scale(self.zoom)
	local p = self.pos * -1 + self:screencenter()
	love.graphics.translate(p.x, p.y)
end

function Camera:postdraw()
	love.graphics.pop()
end

function Camera:mousepos()
	return vector.new(love.mouse.getPosition()) + self.pos
end
