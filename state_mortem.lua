require "gamestate"
require "pipes"
require "protocol"
require "dialog"

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
		local dlg = Dialog.new(vector.new(400,300))
		local btn = Button.new("OK", dlg.center + vector.new(0,100), vector.new(100,40))
		function btn:onClick()
			dlg:close()
			Gamestate.switch(state_title)
		end

		function dlg:draw()
			love.graphics.print("Error occured:", dlg.pos.x + 10, dlg.pos.y + 30)
			love.graphics.printf(error, dlg.pos.x + 15, dlg.pos.y + 60, 285)
			btn:draw()
		end

		function dlg:update(dt)
			btn:update(dt)
		end

		dlg:open()
	end
end

function st:mousereleased(x,y,btn)
	if substate.mousereleased then
		substate:mousereleased(x,y,btn)
	end
end
