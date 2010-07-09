local function strip_newline(s)
	if not s then return end
	-- asume newline!
	return string.sub(s, 1,-2)
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
		if text then return text end
		coroutine.yield()
	end
end

function NetPipe:receivefrom()
	local what, addr, port = self.udp:receivefrom()
	return strip_newline(what), addr, port
end

function NetPipe:bind(addr, port)
	assert(self.udp:setpeername(addr, port))
end

function NetPipe:unbind()
	assert(self.udp:setpeername("*"))
end

function NetPipe:close()
	self.stop = true
	self.udp:close()
end
