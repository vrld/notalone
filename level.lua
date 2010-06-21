Level = {tiles = {wall = {}, ground = {}}}
Level.__index = Level

function Level.init()
	Level.tiles.ground[1] = love.image.newImageData('images/ground0.png')
	Level.tiles.ground[2] = Level.tiles.ground[1]
	Level.tiles.ground[3] = Level.tiles.ground[1]
	Level.tiles.ground[4] = Level.tiles.ground[1]
	Level.tiles.ground[5] = Level.tiles.ground[1]
	Level.tiles.ground[6] = love.image.newImageData('images/ground1.png')
	Level.tiles.ground[7] = love.image.newImageData('images/ground2.png')
	Level.tiles.grave     = love.image.newImageData('images/grave.png')
	Level.tiles.exit      = love.image.newImageData('images/exit.png')
	for i=0,15 do
		Level.tiles.wall[i] = love.image.newImageData(string.format('images/wall%02d.png', i))
	end
	Level.fog = love.graphics.newImage('images/fog2.png')
end

function Level.new(grid)
	local lvl = setmetatable({grid = grid, graves={}}, Level)
	lvl.fog = {}
	lvl.fog_accum = {}
	local h,w = #lvl.grid, #lvl.grid[1]
	for y=1,h do
		lvl.fog[y] = {}
		lvl.fog_accum[y] = {}
		for x=1,w do
			lvl.fog[y][x] = true
			lvl.fog_accum[y][x] = true
		end
	end
	return lvl
end

function Level:_tilenumber(x,y)
	local grid = self.grid
	local num = 0
	if grid[y-1] and grid[y-1][x] >= 1 then
		num = num + 1
	end
	if grid[y][x+1] and grid[y][x+1] >= 1 then
		num = num + 2
	end
	if grid[y+1] and grid[y+1][x] >= 1 then
		num = num + 4
	end
	if grid[y][x-1] and grid[y][x-1] >= 1 then
		num = num + 8
	end
	return num
end

function Level:render()
	local tiles = Level.tiles

	local w,h = #self.grid[1], #self.grid
	self.w, self.h = w,h
	self.pixels = {w = w*TILESIZE, h = h*TILESIZE}
	local imgdata = love.image.newImageData(w*TILESIZE,h*TILESIZE)

	-- level image
	local grid = self.grid
	for x=1,w do
		for y=1,h do
			local source = nil
			if grid[y][x] == 0 then
				source = tiles.wall[self:_tilenumber(x,y)]
            elseif grid[y][x] ==  2 then
				source = tiles.exit
            else
				source = tiles.ground[math.random(1,#tiles.ground)]
			end
			imgdata:paste(source, (x-1)*TILESIZE, (y-1)*TILESIZE, 0,0, TILESIZE,TILESIZE)
		end
	end

	-- postprocess
	for x,y in spatialrange(1,w-1, 0,h*TILESIZE-1) do
		local l,k = {imgdata:getPixel(x*TILESIZE-1,y)},{imgdata:getPixel(x*TILESIZE,y)}
		local r,g,b = (l[1]+k[1])/2, (l[2]+k[2])/2, (l[3]+k[3])/2
	end
	for y,x in spatialrange(1,h-1, 0,w*TILESIZE-1) do
		local l,r = {imgdata:getPixel(x,y*TILESIZE-1)},{imgdata:getPixel(x,y*TILESIZE)}
		local r,g,b = (l[1]+r[1])/2, (l[2]+r[2])/2, (l[3]+r[3])/2
		imgdata:setPixel(x,y*TILESIZE, r,g,b,255)
	end
	-- darken edges - TODO: refactor
	local F = 20
	for x = 0,w*TILESIZE-1 do
		for y = 0,F do
			local r,g,b = imgdata:getPixel(x,y)
			local f = y/F
			imgdata:setPixel(x,y,r * f, g * f, b * f, f*255)
		end
		for y = h*TILESIZE-F-1,h*TILESIZE-1 do
			local r,g,b = imgdata:getPixel(x,y)
			local f = (h*TILESIZE-1 - y)/F
			imgdata:setPixel(x,y,r * f, g * f, b * f, f*255)
		end
	end
	for y = 0,h*TILESIZE-1 do
		for x = 0,F do
			local r,g,b = imgdata:getPixel(x,y)
			local f = x/F
			imgdata:setPixel(x,y,r * f, g * f, b * f, f*255)
		end
		for x = w*TILESIZE-F-1,w*TILESIZE-1 do
			local r,g,b = imgdata:getPixel(x,y)
			local f = (w*TILESIZE-1 - x)/F
			imgdata:setPixel(x,y,r * f, g * f, b * f, f*255)
		end
	end

	return imgdata
end

function Level:updateFog(pos, dir, max, steps)
	local max = max or 3
	local steps = steps or 0
	local grid = self.grid
	if steps >= max then return end
	if grid[pos.y] and (not grid[pos.y][pos.x] or grid[pos.y][pos.x] == 0) then
		return
	end

	for i,k in spatialrange(-1,1, -1,1) do
		if self.fog[pos.y+i] then
			self.fog[pos.y+i][pos.x+k] = false
			self.fog_accum[pos.y+i][pos.x+k] = false
		end
	end

	self:updateFog(pos+dir, dir, max, steps + 1)
end

function Level:die(pos)
	self.graves[pos:clone()] = love.graphics.newImage(Level.tiles.grave)
	for y,x in spatialrange(1,self.h, 1,self.w) do
		self.fog[y][x] = true
	end
end

function Level:draw()
	if not self.img then
		self.img = love.graphics.newImage(self:render())
		self.img:setFilter('nearest', 'nearest')
	end

	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.img,TILESIZE,TILESIZE)
end

function Level:drawGraves()
	-- draw graves
	love.graphics.setColor(255,255,255)
	for pos,img in pairs(self.graves) do
		love.graphics.draw(img, (pos*32):unpack())
	end
end

-- draw fog
function Level:drawFog(bbx,bby,bbw,bbh)
    -- compute fog range to draw
    local floor, ceil, max, min = math.floor, math.ceil, math.max, math.min
    local x1 = max(bbx and floor(bbx / TILESIZE) - 1 or 0, 1)
    local y1 = max(bby and floor(bby / TILESIZE) - 1 or 0, 1)
    local x2 = min(bbw and x1 + ceil(bbw / TILESIZE) + 1 or math.huge, #self.fog[1])
    local y2 = min(bbh and y1 + ceil(bbh / TILESIZE) + 1 or math.huge, #self.fog)

	love.graphics.setColor(255,255,255)
	local shift = vector.new(TILESIZE, TILESIZE) / 2
	local pos
	--for y,x in spatialrange(1,#self.fog, 1,#self.fog[1]) do
	for y,x in spatialrange(y1,y2, x1,x2) do
		if self.fog[y][x] then
			math.randomseed(self.pixels.w * self.pixels.h + x * y)
			pos = vector.new(x,y) * TILESIZE + shift
            for i = 1,3 do
                local s = math.random() * .4 + .8
                love.graphics.draw(Level.fog, 
                    pos.x + math.random(-16,16), pos.y + math.random(-16,16), 
                    math.random()*math.pi,
                    2,2, 16,16)
            end
		end
	end
end
