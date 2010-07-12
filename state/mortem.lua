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
function connect:draw()
	love.graphics.setColor(255,255,255,self.alpha)
	love.graphics.print("Connecting to server",100,100)
end

function connect:update(dt)
	self.t = self.t + dt
	self.alpha = 155 + math.sin(self.t) * 100
	assert(coroutine.resume(self.handshake, dt))
	if coroutine.status(self.handshake) == "dead" then
		substate = get_world
	end
end

function get_world:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(string.format("Getting world..."),100,100)
end

function get_world:update(dt)
	local status
	status, world, start = assert(coroutine.resume(self.getworld))
	if coroutine.status(self.getworld) == "dead" then
		player.init(start, 30) -- TODO: life and stuff
		level = Level.new(world)
		level:see(start, 3)
		camera = Camera.new(player.pixelpos(),1)
		substate = play
	end
end

-- play state
local keydelay, time = 0,1
function play:update(dt)
	player.age = player.age + dt

	local message = getMessage(Mortem.pipe)
	while message do
		if message[1] == "tempus" then -- time update
			player.age = tonumber(message[2])
			player.lifespan = tonumber(message[3])
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
	end

	-- INPUT
	if keydelay <= 0 then
		keydelay = .15

		if love.keyboard.isDown(keys.up) then
			player.onmove(player.pos, vector(0,-1))
		elseif love.keyboard.isDown(keys.down) then
			player.onmove(player.pos, vector(0, 1))
		end
		if love.keyboard.isDown(keys.left) then
			player.onmove(player.pos, vector(-1,0))
		elseif love.keyboard.isDown(keys.right) then
			player.onmove(player.pos, vector( 1,0))
		end

	else
		keydelay = keydelay - dt
	end

	-- update camera zoom
	local min,max = level.seen.min, level.seen.max
	local center = ((max - min) / 2 + min) * TILESIZE - vector(TILESIZE/2, TILESIZE/2)
	camera.pos = camera.pos - (camera.pos - (.75 * center + .25 * player.pixelpos())) * dt * 10
	camera.zoom = camera.zoom - (camera.zoom - level.zoom) * dt * 10

	Trails.update(dt)
end

function play:draw()
	camera:predraw()
	level:draw(camera)
	level:drawFog(camera)
	Trails.draw()
	Items.draw(level.seen)
	player.draw()
	camera:postdraw()

	local barwith = love.graphics.getWidth() - 60
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle('fill', 50, 10, barwith, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 50, 10, (1 - player.age / player.lifespan) * barwith, 7)
	love.graphics.print('life:', 10, 19)
end

-- parent state
function st:enter(pre, ip, port)
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

	Items.clear()
	Trails.clear()

	local diesound = love.sound.newSoundData('sound/maze_1_02.ogg')
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
end

function st:draw()
	substate:draw()
end

function st:update(dt)
	local all_ok, error = pcall(function() substate:update(dt) end)
	if not all_ok then
		MessageBox("Error occured", error, function() Gamestate.switch(Gamestate.title) end)
	end
end

function st:mousereleased(x,y,btn)
	if substate.mousereleased then
		substate:mousereleased(x,y,btn)
	end
end
