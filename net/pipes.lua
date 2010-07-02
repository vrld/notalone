Pipe = {}
Pipe.__index = Pipe

local function strip_newline(s)
	if not s then return end
	-- asume newline!
	return string.sub(s, 1,-2)
end

function Pipe.new()
	return setmetatable({}, Pipe)
end

function Pipe:send(str)
	self[#self+1] = str
end

function Pipe:receive()
	if #self > 0 then
		return table.remove(self, 1)
	end
	return nil
end

function Pipe:gettext()
	local text
	while true do
		text = self:receive()
		if text then return text end
		coroutine.yield()
	end
end

NetPipe = {}
NetPipe.__index = NetPipe

local socket = require "socket"

function NetPipe.new(port, addr)
	local udp = assert(socket.udp())

	if addr then
		assert(udp:setpeername(addr, port))
    else
        assert(udp:setsockname("*", port)) -- bind self to port
	end

	udp:settimeout(0) -- non blocking receive
	return setmetatable({udp = udp}, NetPipe)
end

function NetPipe:send(str, addr, port)
	print(str)
	if addr and port then
		return assert(self.udp:sendto(str, addr, port))
	end
	return assert(self.udp:send(str))
end

function NetPipe:receive()
	return strip_newline(self.udp:receive())
end

function NetPipe:gettext()
	local text
	while true do
		text = self:receive()
		if text then print(text) return text end
		coroutine.yield()
	end
end

function NetPipe:receive_and_bind()
	local what, addr, port = self.udp:receivefrom()
	if what and addr and port then
		assert(self.udp:setpeername(addr, port))
	end
	return strip_newline(what)
end

function NetPipe:unbind()
	assert(self.udp:setpeername("*"))
end

function NetPipe:close()
	self.stop = true
	self.udp:close()
end
