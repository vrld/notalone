require "vector"

player = {
	age         = 0,
	lifespan    = 30,
	startpos    = vector(0,0),
	pos         = vector(0,0),
	dir         = vector(1,0),
	seen        = {min=vector(0,0),max=vector(0,0)},
	zoom        = 10,
	keydelay    = 0,
	ref_level   = nil,
	lifes       = 0,
}
function player.init(level, start, lifespan)
	player.ref_level = level.grid
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
end

function player.pixelpos()
	return player.pos * TILESIZE + vector(16,16)
end

function player.draw()
	love.graphics.setColor(0,180,60)
	love.graphics.rectangle('fill', player.pos.x*TILESIZE, player.pos.y*TILESIZE, TILESIZE, TILESIZE)
end

local n = 1
function stepsprite()
	n = n % 2 + 1
	return string.format("images/footsteps%d.png", n)
end

function player.update(dt, level)
	player.age = player.age + dt

	-- spawn offspring, sort of
	local frac = player.age / player.lifespan
	if frac > .6 and frac < .7 then
		player.startpos = player.pos
	end

	-- die
	if player.age > player.lifespan then
		player.lifespan = player.lifespan + 5
		level:die(player.pos)
		player.reset()
		level:updateFog(player.pos,vector(0,0),1)
	end

	if player.keydelay <= 0 then
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
		if player.ref_level[player.pos.y][player.pos.x] == 0 then
			player.pos = pospre
			return
		end

		level:updateFog(player.pos, player.dir)
		-- update zoom range -- TODO: to fog range!
		player.seen.min.x = math.min(player.seen.min.x, player.pos.x-2)
		player.seen.min.y = math.min(player.seen.min.y, player.pos.y-2)
		player.seen.max.x = math.max(player.seen.max.x, player.pos.x+2)
		player.seen.max.y = math.max(player.seen.max.y, player.pos.y+2)
		local delta = (player.seen.max - player.seen.min) * TILESIZE
		delta = math.min(love.graphics.getWidth()/delta.x, love.graphics.getHeight()/delta.y)
		player.zoom = math.min(delta, 8)

		-- place footsteps
		local phi = 0
		if player.dir.x == -1 then phi = math.pi end
		if player.dir.y ==  1 then phi = math.pi/2 end
		if player.dir.y == -1 then phi = math.pi* 3/2 end

		Decals.add(stepsprite(), 120, pospre*TILESIZE + vector(16,16), phi, .8, 160)
		player.keydelay = .15
	else
		player.keydelay = player.keydelay - dt
	end
end
