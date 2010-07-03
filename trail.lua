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

function Trail(pos)
	return setmetatable({pos}, trail)
end

function trail:add(pos)
	if #self < 2 then
		self[#self+1] = pos
		if #self == 2 then
			self.path = {self[1].x, self[1].y, self[2].x, self[2].y}
		end
		return
	end

	self[#self+1] = pos
	while #self > 40 do
		table.remove(self, 1)
	end
	self.path = topoly( jitter( subdivide(self, .8, 2) ) )
end

function trail:draw()
	if #self < 2 then return end
	love.graphics.setLine(3)
	love.graphics.setColor(255,60,50,200)
	love.graphics.line(self.path)
end
