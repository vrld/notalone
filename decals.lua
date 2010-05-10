require "vector"

Decals = {items = {}}
function Decals.add(img, life, pos, rot, scale)
	local img = love.graphics.newImage(img)
	Decals.items[img] = {
		life = life,
		time = 0,
		pos = pos,
		rot = rot or 0,
		scale = scale or 1
	}
end

function Decals.update(dt)
	for d, pl in pairs(Decals.items) do
		pl.time = pl.time + dt
		if pl.time >= pl.life then
			Decals.items[d] = nil
		end
	end
end

function Decals.draw()
	for d, pl in pairs(Decals.items) do
		love.graphics.setColor(255,255,255, (1 - pl.time / pl.life) * 255)
		love.graphics.draw(d, pl.pos.x, pl.pos.y, pl.rot,
			pl.scale, pl.scale, d:getWidth()/2, d:getHeight()/2)
	end
end
