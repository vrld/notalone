local playlist = {}
playlist.__index = playlist

function Playlist(...)
	local p = setmetatable({songs={}, list = {}}, playlist)
	p:clear()
	p:add(...)
	return p
end

function playlist:addSong(file, ...)
	if not file then return end
	if not self.songs[file] then
		self.songs[file] = love.audio.newSource(file, 'stream')
	end
	self:addSong(...)
end

function playlist:clear()
	self.list = {}
end

function playlist:add(file, ...)
	if not file then return end
	self:addSong(file)
	self.list[#self.list+1] = self.songs[file]
	if not self.current then self.current = 1 end
	self:add(...)
end

function playlist:play()
	love.audio.play(self.list[self.current])
end

function playlist:stop()
	love.audio.stop(self.list[self.current])
end

function playlist:update(dt)
	if self.list[self.current]:isStopped() then
		self.current = self.current + 1
		if self.current > #self.list then
			self.current = 1
		end
	end
end

function playlist:shuffle()
	table.sort(self.list, function() return math.random() < .5 end)
end
