require "net/pipes"
require "gamestate"
require "net/protocol"
require "gui/dialog"

Gamestate.mortem = Gamestate.new()
local st = Gamestate.mortem

local substate, world, pipe, camera

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
	-- TODO: get exit
	world, start = assert(coroutine.resume(self.getworld))
	if coroutine.status(self.getworld) == "dead" then
		player.init(start, 20) -- TODO: life and stuff
		camera = Camera.new(player.pixelpos(),1)
		substate = play
	end
end

-- play state
local keydelay, time = 0,1
function play:update(dt)
	local message = getMessage(Deus.pipe)
	if message then
		if message[1] == "tempus" then -- time update
            time = tonumber(message[2])
		elseif message[1] == "rumpas" then -- die
			player.die()
		elseif message[1] == "signum" then
			local pos = vector(tonumber(message[2]), tonumber(message[3]))
			local item = wrapDraw(love.graphics.newImage('images/'..message[4]..'.png'))
			Items.add(item, pos)
		end
	end

	if keydelay <= 0 then
		keydelay = .15

		if love.keyboard.isDown('up') then
			player:moveUp()
		elseif love.keyboard.isDown('down') then
			player:moveDown()
		end
		if love.keyboard.isDown('left') then
			player:moveLeft()
		elseif love.keyboard.isDown('right') then
			player:moveRight()
		end

	else
		keydelay = keydelay - dt
	end
end

function play:draw()
	camera:predraw()
	level:draw()
	level:drawFog()
	Items.draw(level.seen)
	player.draw()
	camera:postdraw()

	local barwith = love.graphics.getWidth() - 20
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle('fill', 10, 10, barwith, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 10, 10, time*barwith, 7)
end

-- parent state
function st:enter(pre, ip, port)
	Mortem.pipe = NetPipe.new(port, ip)
	love.graphics.setBackgroundColor(0,0,0)
	substate = connect

	connect.handshake = coroutine.create(Mortem.handshake)
	get_world.getworld = coroutine.create(Mortem.getworld)

	function player.ondie()
		level:unsee()
		player.reset()
		level:see(player.pos,1)
		Mortem.move(player.pos:unpack())
	end

	function player.onmove(pos, direction)
		local newpos = pos + direction
		if grid[newpos.y][newpos.x] == 0 then
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
