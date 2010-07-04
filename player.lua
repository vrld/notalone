require "util/vector"
require "trail"

player = {
	age         = 0,
	lifespan    = 30,
	startpos    = vector(0,0),
	pos         = vector(0,0),
	dir         = vector(1,0),
	keydelay    = 0,
	lifes       = 0,
	ondie       = function(lifes) end,
	onmove      = function(pos, direction) end
}
function player.init(start, lifespan)
	assert(start, "start position must be supplied")
	player.startpos = start:clone()
	player.lifespan = lifespan or 45
	player.lifes = 0

	player.reset()
end

function player.reset()
	player.pos = player.startpos:clone()
	player.age = 0
	player.lifes = player.lifes + 1
	player.trail = Trail(player.pixelpos())
end

function player.pixelpos()
	return vector(player.pos.x - .5, player.pos.y - .5) * TILESIZE
end

function player.draw()
	love.graphics.setColor(0,180,60)
	love.graphics.rectangle('fill', (player.pos.x-1)*TILESIZE, (player.pos.y-1)*TILESIZE, TILESIZE, TILESIZE)
end

local n, keydelay = 1, 0
function player.update(dt)
	player.age = player.age + dt

	if player.age > player.lifespan then
		player.ondie()
		return
	end

	if keydelay <= 0 then
		local dir
		if love.keyboard.isDown('up') then
			dir = vector(0,-1)
		elseif love.keyboard.isDown('down') then
			dir = vector(0,1)
		elseif love.keyboard.isDown('left') then
			dir = vector(-1,0)
		elseif love.keyboard.isDown('right') then
			dir = vector(1,0)
		else
			return
		end
		player.onmove(player.pos, dir)

		keydelay = .15
	else
		keydelay = keydelay - dt
	end
end
