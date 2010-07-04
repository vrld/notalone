require "util/vector"

local trail = {}
trail.__index = trail

local function subdivide(path, s, n)
	if n <= 0 then return path end

	local newpath = {}
	newpath[1] = path[1]
	for i = 2,#path-1 do
		local v, w = (path[i] - path[i-1]) * s, (path[i+1] - path[i]) * (1-s)
		newpath[#newpath+1] = path[i-1] + v
		newpath[#newpath+1] = path[i] + w
	end
	newpath[#newpath+1] = path[#path]

	return subdivide(newpath, s, n-1)
end

local function topoly(path)
	local poly = {}
	for _,v in ipairs(path) do
		poly[#poly+1] = v.x
		poly[#poly+1] = v.y
	end
	return poly
end

local function jitter(path, amount)
	local amount = amount or 3
	local lastv = vector(0,0)
	for i, v in ipairs(path) do
		math.randomseed(v.x * lastv.x + v.y * lastv.y)
		lastv = v
		path[i] = vector(v.x + math.random() * amount * 2 - amount,
						 v.y + math.random() * amount * 2 - amount)
	end
	return path
end

Trails = {}
local thetrails = {}
function Trails.add(t)
	thetrails[t] = t
end
function Trails.remove(t)
	thetrails[t] = nil
end
function Trails.update(dt)
	for t,_ in pairs(thetrails) do t:update(dt) end
end
function Trails.draw()
	for t,_ in pairs(thetrails) do t:draw() end
end
function Trails.clear()
	thetrails = {}
end

function Trail(pos, life, size)
	local t = setmetatable({pos, life = life or 20, size = size or 50}, trail)
	t.lifetime = t.life
	Trails.add(t)
	return t
end

function trail:add(pos)
	self.life = self.lifetime
	if #self < 2 then
		self[#self+1] = pos
		if #self == 2 then
			self.path = {self[1].x, self[1].y, self[2].x, self[2].y}
		end
		return
	end

	self[#self+1] = pos
	while #self > self.size do
		table.remove(self, 1)
	end
	self.path = topoly( jitter( subdivide(self, .8, 2) ) )
end

function trail:draw()
	if #self < 2 then return end
	love.graphics.setColor(255,60,50,200 * (self.life / self.lifetime))
	love.graphics.line(self.path)
end

function trail:update(dt)
	self.life = self.life - dt
	if self.life < 0 then
		Trails.remove(self)
	end
end
