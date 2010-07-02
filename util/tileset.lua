-- sort of dumbed down AnAL

local tileset = {}
tileset.__index = tileset

function Tileset(image, tilew, tileh)
	assert(image and tilew and tileh, "Need to provide image, width and height")
	local imgw, imgh = image:getWidth(), image:getHeight()
	local ts = {}
	ts.img = image
	ts.count = imgw / tilew * imgh / tileh
	ts.tiles = {}
	for i = 0, ts.count - 1 do
		local row = math.floor( i / imgw * tilew )
		local col = i % (imgw / tilew)
		ts.tiles[#ts.tiles+1] = love.graphics.newQuad(col * tilew, row * tileh, tilew, tileh, imgw, imgh)
	end

	return setmetatable(ts, tileset)
end

function tileset:draw(i, x, y, ang, sx, sy, ox, oy)
	assert(i > 0 and i <= self.count, "Cannot draw non existing tile.")
	love.graphics.drawq(self.img, self.tiles[i], x, y, ang, sx, sy, ox, oy)
end
