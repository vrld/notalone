require "gamestate"
require "maze"
require "pipes"
require "protocol"
require "camera"

state_deus = Gamestate.new()
local st = state_deus

local substate, world, playerpos, level, pipe

local wait_for_client = {alpha = 155, t = 0}
local send_world = {}
local play = {cam = Camera.new(vector(0,0),1)}
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
	assert(coroutine.resume(self.sendworld, world, playerpos))
	if coroutine.status(self.sendworld) == "dead" then
		level = Level.new(world)
		camera = Camera.new(
			vector(#world[1]+2, #world+2) * TILESIZE / 2,
			math.min(love.graphics.getWidth()  / ((#world[1]+1)*TILESIZE),
					 love.graphics.getHeight() / ((#world+1)*TILESIZE)))
		substate = play
	end
end

local time, time_since_last_sync = 0,0
function play:update(dt)
	time = time + dt
	time_since_last_sync = time_since_last_sync + dt
	if time_since_last_sync > .5 then
		Deus.sendClock(time)
		time_since_last_sync = 0
	end

	local message = getMessage(Deus.pipe)
	if message and message[1] == "moveo" then
		playerpos = vector(tonumber(message[2]), tonumber(message[3]))
	end
end

function play:draw()
	camera:predraw()
	level:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', playerpos.x*TILESIZE, playerpos.y*TILESIZE, 32,32)
	camera:postdraw()
end

function st:enter(pre, port, maze, startpos)
	Deus.pipe = NetPipe.new(port)
	love.graphics.setBackgroundColor(0,0,0)
	world, playerpos = maze, startpos
	substate = wait_for_client

	wait_for_client.handshake = coroutine.create(Deus.handshake)
	send_world.sendworld = coroutine.create(Deus.sendworld)
end

function st:draw()
	substate:draw()
end

function st:update(dt)
	local all_ok, error = pcall(function() substate:update(dt) end)
	if not all_ok then
		MessageBox("Error occured", error, function() Gamestate.switch(state_title) end)
	end
end

function st:mousereleased(x,y,btn)
	if substate.mousereleased then
		substate:mousereleased(x,y,btn)
	end
end
