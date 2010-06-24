Camera = {}
Camera.__index = Camera
function Camera.new(pos, zoom)
	pos = pos or vector(love.graphics.getWidth(), love.graphics.getHeight()) / 2
	zoom = zoom or 1
	return setmetatable({pos = pos, zoom = zoom}, Camera)
end

function Camera:screencenter()
	return vector(love.graphics.getWidth(), love.graphics.getHeight()) / self.zoom / 2
end

function Camera:rect()
    local zw,zh = love.graphics.getWidth() / self.zoom, love.graphics.getHeight() / self.zoom
    return self.pos.x - zw/2, self.pos.y - zh/2, zw, zh
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
	return vector(love.mouse.getPosition()) + self.pos
end
