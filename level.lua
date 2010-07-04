require "util/tileset"

Level = {tiles = {}}
Level.__index = Level

function Level.init()
	local walls = love.graphics.newImage('images/walls.png')
	walls:setFilter('nearest', 'nearest')
	Level.tiles.walls  = Tileset(walls, 32, 32)

	local ground = love.graphics.newImage('images/ground.png')
	ground:setFilter('nearest', 'nearest')
	Level.tiles.ground = Tileset(ground, 32, 32)

	Level.fog          = love.graphics.newImage('images/fog2.png')
	Level.fog:setFilter('nearest', 'nearest')
end

function Level.new(grid)
	local lvl = setmetatable({grid = grid}, Level)
	-- seen_accum -> what has been seen over a lifetime
	lvl.seen, lvl.seen_accum = {}, {}
	for y,x in spatialrange(1,#lvl.grid, 1,#lvl.grid[1]) do
		if not lvl.seen[y] then
			lvl.seen[y] = {}
			lvl.seen_accum[y] = {}
		end
		lvl.seen[y][x] = false
		lvl.seen_accum[y][x] = false
	end
	lvl.seen.min = vector(math.huge, math.huge)
	lvl.seen.max = vector(0,0)
	return lvl
end

function Level:_tilenumber(x,y)
	local grid = self.grid
	local num = 0
	if (grid[y-1] and grid[y-1][x] >= 1) or not grid[y-1] then
		num = num + 1
	end
	if (grid[y][x+1] and grid[y][x+1] >= 1) or not grid[y][x+1] then
		num = num + 2
	end
	if (grid[y+1] and grid[y+1][x] >= 1) or not grid[y+1] then
		num = num + 4
	end
	if (grid[y][x-1] and grid[y][x-1] >= 1) or not grid[y][x-1] then
		num = num + 8
	end
	return num
end

function Level:unsee()
	for y,x in spatialrange(1,#self.seen, 1,#self.seen[1]) do
		self.seen[y][x] = false
	end
	self.seen.min = vector(math.huge, math.huge)
	self.seen.max = vector(0,0)
end

function Level:see(pos, max, steps)
	local max = max or 3
	local steps = steps or 0
	local grid = self.grid
	if steps >= max then return end
	-- if we hit a wall, then return
	if grid[pos.y] and (not grid[pos.y][pos.x] or grid[pos.y][pos.x] == 0) then
		return
	end

	local seen, seen_accum = self.seen, self.seen_accum
	local _max, _min = math.max, math.min
	for i,k in spatialrange(-1,1, -1,1) do
		if seen[pos.y+i] and not seen[pos.y+i][pos.x+k] then
			seen[pos.y+i][pos.x+k] = true
			seen_accum[pos.y+i][pos.x+k] = true
			-- update seen bounding box
			seen.min.y = _min(pos.y+i, seen.min.y)
			seen.min.x = _min(pos.x+k, seen.min.x)
			seen.max.y = _max(pos.y+i, seen.max.y)
			seen.max.x = _max(pos.x+k, seen.max.x)
		end
	end
	local delta = (seen.max - seen.min) * TILESIZE
	delta = _min(love.graphics.getWidth()/delta.x, love.graphics.getHeight()/delta.y)
	self.zoom = _min(delta, 8)

	self:see(pos+vector( 1, 0), max, steps + 1)
	self:see(pos+vector( 0, 1), max, steps + 1)
	self:see(pos+vector(-1, 0), max, steps + 1)
	self:see(pos+vector( 0,-1), max, steps + 1)
end

function Level:draw(camera)
	local walls, ground = Level.tiles.walls, Level.tiles.ground
	local pos, source
	local grid = self.grid

	-- get bounding box of what to draw
	local floor, ceil, max, min = math.floor, math.ceil, math.max, math.min
	local bbx, bby, bbw, bbh = camera:rect()
	local x1 = max(bbx and floor(bbx / TILESIZE) or 1, 1)
	local y1 = max(bby and floor(bby / TILESIZE) or 1, 1)
	local x2 = min(bbw and x1 + ceil(bbw / TILESIZE) + 1 or math.huge, #self.seen[1])
	local y2 = min(bbh and y1 + ceil(bbh / TILESIZE) + 1 or math.huge, #self.seen)

	love.graphics.setColor(255,255,255)
	math.randomseed(#grid * #grid[1])
	for y,x in spatialrange(y1,y2, x1,x2) do
		if self.seen[y][x] then
			pos = vector(x-1,y-1) * TILESIZE
			if grid[y][x] == 0 then
				walls:draw(self:_tilenumber(x,y)+1, pos:unpack())
			else
				ground:draw(math.random(1, ground.count), pos:unpack())
			end
		end
	end
end

-- draw fog
function Level:drawFog(camera)
	local seen = self.seen

	-- compute fog range to draw
	local floor, ceil, max, min = math.floor, math.ceil, math.max, math.min
	local bbx, bby, bbw, bbh = camera:rect()
	local x1 = max(bbx and floor(bbx / TILESIZE) or 0, 1)
	local y1 = max(bby and floor(bby / TILESIZE) or 0, 1)
	local x2 = min(bbw and x1 + ceil(bbw / TILESIZE) + 2 or math.huge, #self.seen[1])
	local y2 = min(bbh and y1 + ceil(bbh / TILESIZE) + 2 or math.huge, #self.seen)

	love.graphics.setColor(255,255,255)
	local function needfog(x,y)
		return not seen[y][x] and (false
			or ((y > 1 and seen[y-1][x]) or y <= 1)
			or ((x > 1 and seen[y][x-1]) or x <= 1)
			or ((y < #seen and seen[y+1][x]) or y >= #seen)
			or ((x < #seen[1] and seen[y][x+1]) or x >= #seen[1]))
	end

	for y,x in spatialrange(y1,y2, x1,x2) do
		if needfog(x,y) then
			math.randomseed(#seen * #seen+1 + x * y)
			local pos = vector(x-.5,y-.5) * TILESIZE
			for i = 1,3 do
				local s = math.random() * .4 + .8
				love.graphics.draw(Level.fog,
					pos.x + math.random(-TILESIZE/2,TILESIZE/2), -- position
					pos.y + math.random(-TILESIZE/2,TILESIZE/2), -- position
					math.random()*math.pi, -- angle
					2,2, -- scale
					TILESIZE/2,TILESIZE/2) -- origin
			end
		end
	end
end
