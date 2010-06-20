require "pipes"

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
	return skip_start(s, unpack(tbl))
end

Deus = {}
Mortem = {}

function Deus.handshake(pipe)
	local pipe = Deus.pipe
	assert(pipe, "Give me a pipe, please!")

	local text
	repeat
		text = pipe:receive_and_bind()
		coroutine.yield()
	until text == "Pater Noster"
	pipe:send("qui es in caelis")
end

function Mortem.handshake()
	local pipe = Mortem.pipe
	assert(pipe, "Give me a pipe, please!")

	local text
	pipe:send("Pater Noster")
	text = pipe:gettext()
	return text == "qui es in caelis"
end

function Deus.sendworld(world)
	local pipe = Deus.pipe
	assert(pipe, "Give me a pipe, please!")

	pipe:send("And thus I made the world:%d:%d", #world, #world[1])
	local params = pipe:gettext():split(":")
	if params[1] ~= "Amen" or tonumber(#world) ~= params[2] or tonumber(#world[1]) ~= params[3] then
		pipe:send("ERROR: wrong world coordiantes")
		return false
	end

	for i,row in ipairs(world) do
		local checksum = row_checksum(row)
		pipe:send(string.format("row:%d:%s:end", i, table.concat(row, ":")))
		params = pipe:gettext():split(":")
		if params[1] == "Amen" and checksum ~= tonumber(params[2]) then
			pipe:send("No, stupid")
		elseif params[1] == "ERROR" then
			return false, "Protocol error: "..params[2]
		else
			return false, "Protocol error: strange reply when sending world"
		end
	end

	pipe:send("And I saw it was good")
	local checksum = world_checksum(world)
	params = pipe:gettext():split(":")
	if params[1] == "Amen" and tonumber(params[2]) ~= checksum then
		pipe:send("ERROR: wrong checksum!")
		return false, "Wrong checksum"
	elseif params[1] ~= "Amen" then
		pipe:send("ERROR: cannot understand your gibberish")
		return false, "Protocol error: strange reply when receiving world checksum"
	end
	pipe:send("Amen")
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
			if firstline and text:sub(4) ~= "row:" then
				pipe:send("ERROR: row expected")
				return false, "wrong row format"
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
	pipe:send(string.format("Amen:%s:%s", params[2], params[3]))
	text = pipe:gettext()
	if text ~= "Amen" then return false, text end

	local w, h = tonumber(params[2]), tonumber(params[3])
	local world, row, gotten, n = {}, {}, 0

	repeat
		row = assert(getrow())
		n = row[1]
		row = subtable(row, 2)
		pipe:send(string.format("Amen:%d", row_checksum(row)))
		text = pipe:gettext()
		if text == "Amen" then
			gotten = gotten + 1
			world[n] = row
		elseif text ~= "No, stupid" then
			return false, text
		end
	until gotten == h

	if pipe:gettext() ~= "And I saw it was good" then
		pipe:send("ERROR: World overflow")
		return false, "world overflow"
	end

	pipe:send(string.format("Amen:%d", world_checksum(world)))
	text = pipe:gettext()
	if text == "Amen" then -- success!
		return world
	elseif text:sub(1,5) == "ERROR" then
		return false, text
	end

	return false, "Protocol error: Strange response on world checksum"
end

function Mortem.move(x, y)
	local pipe = Mortem.pipe
	assert(pipe, "Give me a pipe, please!")

	pipe:send(string.format("moveo:%s:%s", x, y))
end

function Deus.sendClock(t)
	local pipe = Deus.pipe
	assert(pipe, "Give me a pipe, please!")
	pipe:send(string.format("tempus:%s",t))
end

function Deus.addDecal(x, y, decal)
	local pipe = Deus.pipe
	assert(pipe, "Give me a pipe, please!")
	pipe:send(string.format("signum:%s:%s:%s", x,y, decal))
end

function getMessage(pipe)
	local text = pipe:receive()
	if not text then return end
	return text:split(":")
end
