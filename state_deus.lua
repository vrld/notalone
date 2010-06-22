require "gamestate"
require "maze"
require "pipes"
require "protocol"

state_deus = Gamestate.new()
local st = state_deus

local substate, world, pipe

local wait_for_client = {alpha = 155, t = 0}
local send_world = {}
local play = {}
function wait_for_client:draw()
	love.graphics.setColor(255,255,255,self.alpha)
	love.graphics.print("Waiting for mortem",100,100)
end

function wait_for_client:update(dt)
	self.t = self.t + dt
	self.alpha = 155 + math.sin(self.t) * 100
	assert(coroutine.resume(self.handshake, Deus.pipe))
	if coroutine.status(self.handshake) == "dead" then
		substate = send_world
	end
end

function send_world:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(string.format("Sending world..."),100,100)
end

function send_world:update(dt)
	assert(coroutine.resume(self.sendworld, world))
	if coroutine.status(self.sendworld) == "dead" then
		substate = play
	end
end

function st:enter(pre, port, maze, start)
	Deus.pipe = NetPipe.new(port)
	love.graphics.setBackgroundColor(0,0,0)
	world = maze
	substate = wait_for_client

	wait_for_client.handshake = coroutine.create(Deus.handshake)
	send_world.sendworld = coroutine.create(Deus.sendworld)
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
