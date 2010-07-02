require "gamestate"
require "net/pipes"
require "net/protocol"
require "gui/dialog"

Gamestate.mortem = Gamestate.new()
local st = Gamestate.mortem

local substate, world, pipe

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
	assert(coroutine.resume(self.handshake, Mortem.pipe))
	if coroutine.status(self.handshake) == "dead" then
		substate = get_world
	end
end

function get_world:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(string.format("Getting world..."),100,100)
end

function get_world:update(dt)
	world = assert(coroutine.resume(self.getworld))
	if coroutine.status(self.getworld) == "dead" then
		print(world)
		substate = play
	end
end

-- play state
local keydelay = 0
function play:update(dt)
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
	fog:draw()
	items:draw()
	player:draw()
	camera:postdraw()
	time:draw()
end

-- parent state
function st:enter(pre, ip, port)
	Mortem.pipe = NetPipe.new(port, ip)
	love.graphics.setBackgroundColor(0,0,0)
	substate = connect

	connect.handshake = coroutine.create(Mortem.handshake)
	get_world.getworld = coroutine.create(Mortem.getworld)
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
