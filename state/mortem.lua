--
-- message to future me:
-- THIS IS UGLY AS FUCK. I AM SORRY!
-- THE DEADLINE IS TO BLAME! o_O
--
Gamestate.mortem = Gamestate.new()
local st = Gamestate.mortem

local substate, world, camera, level

local connect = {alpha = 155, t = 0}
local get_world = {}
local play = {}
local sequence = Sequence(scenes.highscores, scenes.credits, scenes.title)
local time, lastaction = 0, 0
function connect:draw()
	sequence:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill', 240, 557, 318, 27)
	love.graphics.setColor(255,255,255,150 + math.sin(time) * 50)
	love.graphics.print('waiting for other player', (800 - 311) / 2, 580)
end

function connect:update(dt)
	sequence:update(dt)
	assert(coroutine.resume(self.handshake, dt))
	if coroutine.status(self.handshake) == "dead" then
		substate = get_world
		time = 0
	end
end

function get_world:draw()
	sequence:draw()
	love.graphics.setColor(255,255,255)
	if time > 5 then
		local font = fonts[30]
		local height = love.graphics.getHeight('sending world')
		love.graphics.setColor(255,255,255)
		love.graphics.print('getting world', (800 - 172) / 2, 580)
		local str = "other side not responding"
		love.graphics.setColor(255,255,255,150)
		love.graphics.print(str, (800 - font:getWidth(str)) / 2, 590 - 2 * height)
		str = "press 1 to abort"
		love.graphics.print(str, (800 - font:getWidth(str)) / 2, 590 - height)
	else
		love.graphics.print('getting world', (800 - 172) / 2, 580)
	end
end

function get_world:update(dt)
	sequence:update(dt)
	local status
	status, world, start,exit = assert(coroutine.resume(self.getworld))
	if coroutine.status(self.getworld) == "dead" then
		local exitanim = newAnimation(love.graphics.newImage('images/exit.png'), 32, 32, .15, 0)
		Items.clear()
		Trails.clear()

		Items.add(exitanim, exit)
		player.init(start, 30) -- TODO: life and stuff
		level = Level.new(world)
		level:see(start, 3)
		camera = Camera.new(player.pixelpos(),1)
		substate = play
		love.audio.stop()
		ingame_playlist:shuffle()
		ingame_playlist:play()

		local diesound = love.sound.newSoundData('sound/die.ogg')
		function player.ondie()
			playsound(diesound)
			level:unsee()
			player.reset()
			level:see(player.pos,1)
			Mortem.move(player.pos:unpack())
		end

		function player.onmove(pos, direction)
			local newpos = pos + direction
			if world[newpos.y][newpos.x] == 0 then
				return
			end

			player.pos = newpos
			player.trail:add(player.pixelpos())
			level:see(newpos)
			Mortem.move(newpos:unpack())
		end
		lastaction = time
	elseif time > 5 and love.keyboard.isDown(keys.start) then
		Gamestate.switch(Gamestate.title_mortem)
	end
end

-- play state
local keydelay, time, time_since_last_ping = 0,1,0
function play:update(dt)
	time_since_last_ping = time_since_last_ping + dt
	ingame_playlist:update(dt)
	player.age = player.age + dt
	Items.update(dt)

	local message = getMessage(Mortem.pipe)
	while message do
		if message[1] == "tempus" then -- time update
			player.age = tonumber(message[2])
			player.lifespan = tonumber(message[3])
			send_ping(Mortem.pipe)
			time_since_last_ping = 0
		elseif message[1] == "rumpas" then -- die
			player.ondie()
		elseif message[1] == "signum" then
			local pos = vector(tonumber(message[2]), tonumber(message[3]))
			local img = love.graphics.newImage('images/'..message[4]..'.png')
			img:setFilter('nearest', 'nearest')
			local item = wrapDraw(img)
			Items.add(item, pos)
		elseif message[1] == "fossa" then
			level.grid[tonumber(message[2])][tonumber(message[3])] = 1
		elseif message[1] == "egressus" then
			Gamestate.switch(Gamestate.score, level, tonumber(message[2]), camera)
			return
		elseif message[1] == "removeo" then
			local pos = vector(tonumber(message[2]), tonumber(message[3]))
			Items.remove(Items.find(pos))
		end
		message = getMessage(Mortem.pipe)
		lastaction = time
	end

	-- INPUT
	player.update(dt)

	-- update camera zoom
	local min,max = level.seen.min, level.seen.max
	local center = ((max - min) / 2 + min) * TILESIZE - vector(TILESIZE/2, TILESIZE/2)
	camera.pos = camera.pos - (camera.pos - (.75 * center + .25 * player.pixelpos())) * dt * 10
	camera.zoom = camera.zoom - (camera.zoom - level.zoom) * dt * 10

	Trails.update(dt)

	if (time_since_last_ping > 5 and love.keyboard.isDown(keys.start)) then
		Gamestate.switch(Gamestate.title_mortem)
	end
end

function play:draw()
	camera:predraw()
	level:draw(camera)
	level:drawFog(camera)
	Trails.draw()
	Items.draw(level.seen)
	player.draw()
	camera:postdraw()

	local barwith = love.graphics.getWidth() - 80
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle('fill', 70, 10, barwith, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 70, 10, (1 - player.age / player.lifespan) * barwith, 7)
	love.graphics.print('life:', 10, 19)

	if time_since_last_ping > 5 then
		local font = fonts[30]
		local str = "Lost connection to other player"
		local w, h = font:getWidth(str), font:getHeight(str)
		love.graphics.setColor(0,0,0,180)
		love.graphics.rectangle('fill', 390 - w / 2, 290 - h, w + 20, h + 40)
		love.graphics.setColor(255,255,255)

		love.graphics.print(str, (800 - w) / 2, (600 - h) / 2)
		str = "press 1 to abort"
		local w = font:getWidth(str)
		love.graphics.print(str, (800 - w) / 2, (600 - h) / 2 + h)
	end
end

-- parent state
function st:enter(pre, ip, port)
	sequence.current:enter()
	self.ip = ip
	self.port = port
	if Mortem.pipe then
		Mortem.pipe.udp:close()
	end
	Mortem.pipe = NetPipe.new(port, ip)
	love.graphics.setBackgroundColor(0,0,0)
	substate = connect

	connect.handshake = coroutine.create(Mortem.handshake)
	get_world.getworld = coroutine.create(Mortem.getworld)

	love.graphics.setFont(fonts[30])

	time_since_last_ping = 0
end

function st:leave()
	ingame_playlist:stop()
end

function st:draw()
	substate:draw()
end

function st:update(dt)
	time = time + dt
	local all_ok, error = pcall(function() substate:update(dt) end)
	if not all_ok then
		Gamestate.switch(Gamestate.title_mortem)
	end

	if time - lastaction > 15 then
		Gamestate.switch(Gamestate.title_mortem)
	end
end

function st:mousereleased(x,y,btn)
	if substate.mousereleased then
		substate:mousereleased(x,y,btn)
	end
end

function st:keypressed(key,unicode)
	lastaction = time
end
