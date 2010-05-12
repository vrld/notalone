player = {
	age         = 0,
	lifespan    = 30,
	startpos    = vector.new(0,0),
	pos         = vector.new(0,0),
	dir         = vector.new(1,0),
	seen        = {min=vector.new(0,0),max=vector.new(0,0)},
	zoom        = 10,
	carried     = nil,
	sprite      = nil,
	keydelay    = 0,
	path_decal  = love.image.newImageData(10,10),
	ref_level   = nil
}
function player.init(level, start, lifespan)
	player.ref_level = level.grid
	assert(start, "start position must be supplied")
	player.startpos = start:clone()
	player.lifespan = lifespan or 45

	-- TODO: nicer sprite
	for x = 0,9 do
		for y = 0,9 do
			player.path_decal:setPixel(x,y, 100,0,0,255)
		end
	end

	player.reset()
end

function player.reset()
	player.pos = player.startpos:clone()
	player.age = 0
	player.seen.min = player.pos:clone()
	player.seen.max = player.pos:clone()
	player.zoom = 10
end

function player.pixelpos()
	return player.pos * TILESIZE + vector.new(16,16)
end

function player.draw()
	love.graphics.setColor(0,180,60)
	love.graphics.rectangle('fill', player.pos.x*TILESIZE, player.pos.y*TILESIZE, TILESIZE, TILESIZE)
end

function player.update(dt, level)
	player.age = player.age + dt
	-- die
	if player.age > player.lifespan then
		level:die(player.pos)
		player.reset()
        level:updateFog(player.pos,vector.new(0,0),1)
	end

	if player.keydelay <= 0 then
		local pospre = player.pos:clone()
		if love.keyboard.isDown('up') then
			player.dir = vector.new(0,-1)
		elseif love.keyboard.isDown('down') then
			player.dir = vector.new(0,1)
		elseif love.keyboard.isDown('left') then
			player.dir = vector.new(-1,0)
		elseif love.keyboard.isDown('right') then
			player.dir = vector.new(1,0)
		else
			return
		end
		player.pos = player.pos + player.dir
		if player.ref_level[player.pos.y][player.pos.x] == 0 then
			player.pos = pospre
			return
		end

		level:updateFog(player.pos, player.dir)
		-- update zoom range
		player.seen.min.x = math.min(player.seen.min.x, player.pos.x)
		player.seen.min.y = math.min(player.seen.min.y, player.pos.y)
		player.seen.max.x = math.max(player.seen.max.x, player.pos.x)
		player.seen.max.y = math.max(player.seen.max.y, player.pos.y)
		local delta = player.seen.max - player.seen.min
		delta = math.max(delta.x, delta.y, delta:len())
		player.zoom = math.max(10 - delta, 1)

		Decals.add(player.path_decal, 45, pospre*TILESIZE + vector.new(16,16))
		player.keydelay = .15
	else
		player.keydelay = player.keydelay - dt
	end
end
