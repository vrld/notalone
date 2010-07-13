local sequence = {}
sequence.__index = sequence

function Sequence(...)
	local seq = setmetatable({}, sequence)
	seq.scenes = {}
	seq.looping = true
	seq:add(...)
	return seq
end

function sequence:add(scene, ...)
	if not scene then return end
	self.scenes[#self.scenes+1] = scene
	if not self.current then
		self.current = self.scenes[1]
		self.curnum = 1
	end
	self:add(...)
end

function sequence:scene(k)
	if self.current then
		self.current:leave()
	end
	self.curnum = k
	self.current = self.scenes[k]
	if self.current then
		self.current.time = 0
		self.current:enter()
	end
end

function sequence:isFinished()
	return self.current == nil
end

function sequence:rewind()
	self:scene(1)
end

function sequence:nextScene()
	self:scene(self.curnum + 1)
	if self:isFinished() and self.looping then
		self:rewind()
	end
end

function sequence:draw()
	self.current:draw()
end

function sequence:update(dt)
	self.current:update(dt)
	self.current.time = self.current.time + dt
	if self.current:isFinished() then
		self:nextScene()
	end
end

local scene = {}
scene.__index = scene

function Scene(length)
	return setmetatable({time = 0, length = length, update = function() end, enter = function() end, leave = function() end}, scene)
end

function scene:isFinished()
	return self.time >= self.length
end
