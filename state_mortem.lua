require "gamestate"
require "pipes"
require "protocol"

state_mortem = Gamestate.new()
local st = state_mortem

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
	assert(coroutine.resume(self.handshake, Deus.pipe))
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

function st:enter()
	Deus.pipe = NetPipe.new(12345, "127.0.0.1")
	love.graphics.setBackgroundColor(0,0,0)
	world = Maze.new(40,30)
	substate = connect

	connect.handshake = coroutine.create(Mortem.handshake)
	get_world.getworld = coroutine.create(Mortem.getworld)
end

function st:draw()
	substate:draw()
end

function st:update(dt)
	substate:update(dt)
end

function st:mousereleased(x,y,btn)
	if substate.mousereleased then
		substate:mousereleased(x,y,btn)
	end
end
