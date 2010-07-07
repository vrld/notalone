require "gamestate"
require "maze"
require "items"
require "net/pipes"
require "net/protocol"
require "util/camera"
require "gui/dialog"

Inventory = { selected = 1, items = {} }
-- circle selection in specified direction
function Inventory.select(direction)
	Inventory.selected = Inventory.selected - direction
	if Inventory.selected < 1 then
		Inventory.selected = #Inventory.items
	elseif Inventory.selected > #Inventory.items then
		Inventory.selected = 1
	end
end

function Inventory.add(item, ...)
	if not item then return end
	Inventory.items[#Inventory.items+1] = item
	Inventory.add(...)
end

function Inventory.remove(k)
	table.remove(Inventory.items, k)
end

function Inventory.draw()
	local ITEMSIZE, PADDING, SELECTIONSIZE = 32, 5, 40
	local scale = SELECTIONSIZE / ITEMSIZE
	local invsize = #Inventory.items * (ITEMSIZE + PADDING) + (SELECTIONSIZE - ITEMSIZE) - PADDING
	local x = (love.graphics.getWidth() - invsize) / 2
	for i,item in ipairs(Inventory.items) do
		if i == Inventory.selected then
			love.graphics.setColor(255,255,200)
			item.obj:draw(x, love.graphics.getHeight() - SELECTIONSIZE - PADDING, 0, scale, scale)
			x = x + SELECTIONSIZE + PADDING
		else
			love.graphics.setColor(255,255,255,150)
			item.obj:draw(x, love.graphics.getHeight() - ITEMSIZE - PADDING)
			x = x + ITEMSIZE + PADDING
		end
	end
end

Gamestate.deus = Gamestate.new()
local st = Gamestate.deus

local substate, world, playerpos, level, pipe
local camera

local wait_for_client = {alpha = 155, t = 0}
local send_world = {}
local play = {cam = Camera.new(vector(0,0),1)}
local selected_pos = vector(0,0)
--
-- handshake state
--
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
--
-- world sending state
--
function send_world:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(string.format("Sending world..."),100,100)
end

function send_world:update(dt)
	assert(coroutine.resume(self.sendworld, world, playerpos))
	if coroutine.status(self.sendworld) == "dead" then
		level = Level.new(world)
		substate = play
		selected_pos = vector(math.floor(#world[1]/2), math.floor(#world/2))
	end
end
--
-- play state
--
local time, time_since_last_sync = 0,0
local keydelay = 0
local min, max = math.min, math.max
local actions
actions = {
	modifier_none = {
		up = function()
			selected_pos.y = max(selected_pos.y - 1, 2)
		end,
		down = function()
			selected_pos.y = min(selected_pos.y + 1, #world-1)
		end,
		left = function()
			selected_pos.x = max(selected_pos.x - 1, 2)
		end,
		right = function()
			selected_pos.x = min(selected_pos.x + 1, #world[1]-1)
		end,
	},
	modifier_zoom = {
		up    = function() --[[ increase zoom level --]] end,
		down  = function() --[[ decrease zoom level --]] end,
		left  = function() Inventory.select(1) end,
		right = function() Inventory.select(-1) end,
	},
}

function play:update(dt)
	time = time + dt
	time_since_last_sync = time_since_last_sync + dt

    player.grow(dt)
	player.update(dt)

	if time_since_last_sync > .25 then
		Deus.sendClock(1 - player.lifespan / player.age)
		time_since_last_sync = 0
	end

	local message = getMessage(Deus.pipe)
	if message and message[1] == "moveo" then
		player.pos = vector(tonumber(message[2]), tonumber(message[3]))
	end

	Items.update(dt)

	if keydelay <= 0 then
		keydelay = .1

		local keyaction = actions.modifier_none
		if love.keyboard.isDown('a') then
			keyaction = actions.modifier_zoom
		end
		for key, fun in pairs(keyaction) do
			if love.keyboard.isDown(key) then
				fun()
			end
		end

		if love.keyboard.isDown('s') then
			Inventory.select(-1)
		end

		if love.keyboard.isDown('d') and level.grid[selected_pos.y][selected_pos.x] ~= 0 then
			local item = Inventory.items[Inventory.selected]
			Items.add(item.obj, selected_pos:clone())
			Deus.addSign(selected_pos.x, selected_pos.y, item.what)
			Inventory.remove(Inventory.selected)
			Inventory.select(1)
			keydelay = .2
		end

	else
		keydelay = keydelay - dt
	end
end

function play:draw()
	camera:predraw()
	level:draw(camera, true)
	player.draw()
	Items.draw()
	if level.grid[selected_pos.y][selected_pos.x] ~= 0 then
		love.graphics.setColor(0,255,100,200)
	else
		love.graphics.setColor(255,160,0,100)
	end
	love.graphics.rectangle('fill', (selected_pos.x-1)*TILESIZE, (selected_pos.y-1)*TILESIZE, 32,32)
	camera:postdraw()
	Inventory.draw()

	local barwith = love.graphics.getWidth() - 20
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle('fill', 10, 10, barwith, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 10, 10, (1 - player.age / player.lifespan) * barwith, 7)
end

--
-- Main gamestate. Forwards to substates
--
function st:enter(pre, port, grid, startpos, exit)
	Level.init()
	Deus.pipe = NetPipe.new(port)
	love.graphics.setBackgroundColor(0,0,0)
	world, playerpos = grid, startpos
	substate = wait_for_client

	wait_for_client.handshake = coroutine.create(Deus.handshake)
	send_world.sendworld = coroutine.create(Deus.sendworld)

	player.init(startpos, 20)
	function player.ondie()
		Deus.killPlayer()
	end

	level = Level.new(grid)
	local levelsize = vector(#grid[1], #grid) * TILESIZE
	local zoom = math.min(love.graphics.getWidth() / levelsize.x,
	                      love.graphics.getHeight() / levelsize.y)
	camera = Camera.new(levelsize/2, zoom)

	Inventory.selected = 1
	Inventory.items = {
		{obj = wrapDraw(love.graphics.newImage('images/left.png')),    what = "left"},
		{obj = wrapDraw(love.graphics.newImage('images/right.png')),   what = "right"},
		{obj = wrapDraw(love.graphics.newImage('images/up.png')),      what = "up"},
		{obj = wrapDraw(love.graphics.newImage('images/down.png')),    what = "down"},
		{obj = wrapDraw(love.graphics.newImage('images/deadend.png')), what = "deadend"},
	}
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

function st:keypressed(key,unicode)
	if substate.keypressed then
		substate:keypressed(key,unicode)
	end
end
