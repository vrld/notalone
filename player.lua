require "util/vector"
require "trail"

player = {
	age         = 0,
	lifespan    = 30,
	startpos    = vector(0,0),
	pos         = vector(0,0),
	dir         = vector(1,0),
	seen        = {min=vector(0,0),max=vector(0,0)},
	zoom        = 10,
	keydelay    = 0,
	lifes       = 0,
	ondie       = function(lifes) end,
	onmove      = function(pos, direction) end
}
function player.init(level, start, lifespan)
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
	player.seen.min = player.pos - vector(1,1)
	player.seen.max = player.pos + vector(1,1)
	player.zoom = 10

	player.trail = Trail(player.pixelpos())
end

function player.pixelpos()
	return player.pos * TILESIZE - .5 * vector(TILESIZE,TILESIZE)
end

function player.draw()
	love.graphics.setColor(0,180,60)
	love.graphics.rectangle('fill', (player.pos.x-1)*TILESIZE, (player.pos.y-1)*TILESIZE, TILESIZE, TILESIZE)

	player.trail:draw()
end

local n, keydelay = 1, 0
function player.update(dt, level)
	player.age = player.age + dt

	-- die
	if player.age > player.lifespan then
		player.lifespan = player.lifespan + 5
		level:unsee()
		player.reset()
		level:see(player.pos,1)
	end

	if keydelay <= 0 then
		local pospre = player.pos:clone()
		if love.keyboard.isDown('up') then
			player.dir = vector(0,-1)
		elseif love.keyboard.isDown('down') then
			player.dir = vector(0,1)
		elseif love.keyboard.isDown('left') then
			player.dir = vector(-1,0)
		elseif love.keyboard.isDown('right') then
			player.dir = vector(1,0)
		else
			return
		end
		player.pos = player.pos + player.dir
		if level.grid[player.pos.y][player.pos.x] == 0 then
			player.pos = pospre
			return
		end
		player.trail:add(player.pixelpos())

		level:see(player.pos)
		-- update zoom range -- TODO: to fog range!
		player.seen.min.x = math.min(player.seen.min.x, player.pos.x-2)
		player.seen.min.y = math.min(player.seen.min.y, player.pos.y-2)
		player.seen.max.x = math.max(player.seen.max.x, player.pos.x+2)
		player.seen.max.y = math.max(player.seen.max.y, player.pos.y+2)
		local delta = (player.seen.max - player.seen.min) * TILESIZE
		delta = math.min(love.graphics.getWidth()/delta.x, love.graphics.getHeight()/delta.y)
		player.zoom = math.min(delta, 8)

		-- place footsteps
		keydelay = .15
	else
		keydelay = keydelay - dt
	end
end
