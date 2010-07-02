require "net/pipes"

local function row_checksum(i, ...)
	if not i then return 0 end
	return i + row_checksum(...)
end

local function world_checksum(world)
	local sum = 0
	for _,r in pairs(world) do
		sum = sum + row_checksum(unpack(r))
	end
	return sum
end

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

local function subtable(tbl, startindex)
	local function skip_start(skip, v, ...)
		if skip > 1 then return skip_start(skip-1, ...) end
		return {v, ...}
	end
	return skip_start(startindex, unpack(tbl))
end

Deus = {}
Mortem = {}

function Deus.handshake(pipe)
	local pipe = Deus.pipe
	assert(pipe, "Give me a pipe, please!")

	local text
	while true do
		text = pipe:receive_and_bind()
		if text == "Pater Noster" then
			pipe:send("qui es in caelis\n")
			return
		end
		pipe:unbind()
		coroutine.yield()
	end
end

function Mortem.handshake()
	local pipe = Mortem.pipe
	assert(pipe, "Give me a pipe, please!")

	local text
	while true do
		pipe:send("Pater Noster\n")
		text = pipe:gettext()
		if text == "qui es in caelis\n" then
			return true
		end
	end
end

function Deus.sendworld(world, start)
	local pipe = Deus.pipe
	assert(pipe, "Give me a pipe, please!")

	pipe:send(string.format("And thus I made the world:%d:%d\n", #world, #world[1]))
	local params = pipe:gettext():split(":")
	if params[1] ~= "Amen" or #world ~= tonumber(params[2]) or #world[1] ~= tonumber(params[3]) then
		pipe:send("ERROR: wrong world coordiantes\n")
		error("Mortem is stupid")
	end

	local i = 1
	while i <= #world do
		local row = world[i]
		local checksum = row_checksum(unpack(row))
		pipe:send(string.format("row:%d:%s:end\n", i, table.concat(row, ":")))
		params = pipe:gettext():split(":")
		if params[1] == "Amen" then
			if checksum ~= tonumber(params[2]) then
				pipe:send("No, stupid\n")
			else
				pipe:send("Amen\n")
				i = i + 1
			end
		elseif params[1] == "ERROR" then
			error("Protocol error: \""..params[2].."\"")
		else
			pipe:send("ERROR: unknown gibberish\n")
			error("Protocol error: strange reply when sending world")
		end
	end

	pipe:send("And I saw it was good\n")
	local checksum = world_checksum(world)
	params = pipe:gettext():split(":")
	if params[1] == "Amen" and tonumber(params[2]) ~= checksum then
		pipe:send("ERROR: wrong checksum!\n")
		error("Wrong checksum")
	elseif params[1] ~= "Amen" then
		pipe:send("ERROR: cannot understand your gibberish\n")
		error("Protocol error: strange reply when receiving world checksum:\n'"..table.concat(params,":").."'")
	end
	pipe:send("Amen\n")

	-- world sent, send starting position
	pipe:send(string.format("On the next day, I made you:%s:%s\n", start.x, start.y))
	params = pipe:gettext():split(":")
	if params[1] == "Amen" and (tonumber(params[2]) ~= start.x or tonumber(params[3]) ~= start.y) then
		pipe:send("ERROR: wrong position\n")
		error("Wrong position: " .. params[2] .. ", " .. params[3])
	elseif params[1] ~= "Amen" then
		pipe:send("ERROR: cannot understand your gibberish\n")
		error("Protocol error: strange reply when receiving starting position confirmation:\n'"..table.concat(params,":").."'")
	end
	pipe:send("Amen\n")
	return true
end

function Mortem.getworld()
	local pipe = Mortem.pipe
	assert(pipe, "Give me a pipe, please!")

	local function getrow()
		local rows, text = {}
		local firstline = true
		while true do
			text = pipe:gettext()
			rows[#rows+1] = text
			if firstline and text:sub(1,4) ~= "row:" then
				pipe:send("ERROR: row expected\n")
				error("Wrong row format. got: '"..text.."'")
			elseif text:sub(-4) == ":end" then
				return table.concat(rows, ""):sub(5,-5):split(":")
			end
			coroutine.yield()
		end
	end

	-- local parameters
	local text, params = "", {}
	params = pipe:gettext():split(":")

	-- world header
	if params[1] ~= "And thus I made the world" then return false end
	pipe:send(string.format("Amen:%s:%s\n", params[2], params[3]))

	local h, w = tonumber(params[2]), tonumber(params[3])
	local world, row, gotten, n = {}, {}, 0

	repeat
		row = assert(getrow())
		n = row[1]
		row = subtable(row, 2)
		pipe:send(string.format("Amen:%d\n", row_checksum(unpack(row))))
		text = pipe:gettext()
		if text == "Amen" then
			gotten = gotten + 1
			world[n] = row
		elseif text ~= "No, stupid" then
			error(text)
		end
	until gotten == h

	if pipe:gettext() ~= "And I saw it was good" then
		pipe:send("ERROR: World overflow\n")
		error("world overflow")
	end

	pipe:send(string.format("Amen:%d\n", world_checksum(world)))
	text = pipe:gettext()
	if text ~= "Amen" then
		error("Protocol error: Strange response on world checksum: \n'"..text.."'")
	elseif text:sub(1,5) == "ERROR" then
		error("Protocol error: \n" .. text)
	end

	-- world received successfully. get starting position
	params = pipe:gettext():split(":")
	local start = vector(tonumber(params[2]), tonumber(params[3]))
	pipe:send(string.format("Amen:%s:%s\n", start.x, start.y))

	text = pipe:gettext()
	if text == "Amen" then
		return world, start
	end

	error("Protocol error: strange reply when receiving starting position: \n'"..table.concat(params,":").."'")
end

function Mortem.move(x, y)
	local pipe = Mortem.pipe
	assert(pipe, "Give me a pipe, please!")

	pipe:send(string.format("moveo:%s:%s\n", x, y))
end

function Deus.sendClock(t)
	local pipe = Deus.pipe
	assert(pipe, "Give me a pipe, please!")
	pipe:send(string.format("tempus:%s\n",t))
end

function Deus.addSign(x, y, decal)
	local pipe = Deus.pipe
	assert(pipe, "Give me a pipe, please!")
	pipe:send(string.format("signum:%s:%s:%s\n", x,y, decal))
end

function getMessage(pipe)
	local text = pipe:receive()
	if not text then return end
	return text:split(":")
end
