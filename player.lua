player = {
	age         = 0,
	lifespan    = 30,
	startpos    = vector(0,0),
	pos         = vector(0,0),
	dir         = vector(1,0),
	keydelay    = 0,
	lifes       = 0,
	ondie       = function(lifes) end,
	onmove      = function(pos, direction) end,
	frame       = 1,
}

local tilesets = {}
tilesets.walk_north = Tileset(love.graphics.newImage('images/walk_north.png'), 32, 32)
tilesets.walk_east  = Tileset(love.graphics.newImage('images/walk_east.png'),  32, 32)
tilesets.walk_south = Tileset(love.graphics.newImage('images/walk_south.png'), 32, 32)
tilesets.walk_west  = Tileset(love.graphics.newImage('images/walk_west.png'),  32, 32)
local current_set = tilesets.walk_north
function player.init(start, lifespan)
	assert(start, "start position must be supplied")
	player.startpos = start
	player.lifespan = lifespan or 45
	player.lifes = 0

	player.reset()
end

function player.reset()
	player.pos = player.startpos:clone()
	player.age = 0
	player.lifes = player.lifes + 1
	player.trail = Trail(player.pixelpos())

	player.frame = 1
end

function player.pixelpos()
	return vector(player.pos.x - .5, player.pos.y - .5) * TILESIZE
end

function player.draw()
	love.graphics.setColor(255,255,255)
	current_set:draw(player.frame, ((player.pos-vector(1,1))*TILESIZE):unpack())
end

function player.grow(dt)
	player.age = player.age + dt
	if player.age > player.lifespan then
		player.ondie()
		return
	end
end

function player.move(dir)
	if not dir then return end
	if dir == vector(0,-1) then
		current_set = tilesets.walk_north
	elseif dir == vector(0, 1) then
		current_set = tilesets.walk_south
	elseif dir == vector(-1,0) then
		current_set = tilesets.walk_west
	else
		current_set = tilesets.walk_east
	end
	player.frame = player.frame + 1
	if player.frame > 8 then player.frame = 1 end
	player.onmove(player.pos, dir)
end

local n, keydelay = 1, 0
function player.update(dt)
	if keydelay <= 0 then
		local dir
		if love.keyboard.isDown(keys.up) then
			dir = vector(0,-1)
			current_set = tilesets.walk_north
		elseif love.keyboard.isDown(keys.down) then
			dir = vector(0,1)
			current_set = tilesets.walk_south
		end
		if love.keyboard.isDown(keys.left) then
			dir = vector(-1,0)
			current_set = tilesets.walk_west
		elseif love.keyboard.isDown(keys.right) then
			dir = vector(1,0)
			current_set = tilesets.walk_east
		end

		if dir then
			player.frame = player.frame + 1
			if player.frame > 8 then player.frame = 1 end
			player.onmove(player.pos, dir)
		end

		keydelay = .15
	else
		keydelay = keydelay - dt
	end
end
