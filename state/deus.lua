--
-- message to future me:
-- THIS IS UGLY AS FUCK. I AM SORRY!
-- THE DEADLINE IS TO BLAME! o_O
--
local images = {
	left    = love.graphics.newImage('images/left.png'),
	right   = love.graphics.newImage('images/right.png'),
	up      = love.graphics.newImage('images/up.png'),
	down    = love.graphics.newImage('images/down.png'),
	deadend = love.graphics.newImage('images/deadend.png'),
	shovel  = love.graphics.newImage('images/shovel.png'),
	coin    = love.graphics.newImage('images/coin.png'),
	crate   = love.graphics.newImage('images/crate.png'),
}
for _,i in pairs(images) do
	i:setFilter('nearest', 'nearest')
end

local Powerups = {
	{obj = wrapDraw(images.left),    what = "left"},
	{obj = wrapDraw(images.right),   what = "right"},
	{obj = wrapDraw(images.up),      what = "up"},
	{obj = wrapDraw(images.down),    what = "down"},
	{obj = wrapDraw(images.deadend), what = "deadend"},
	{obj = wrapDraw(images.shovel),  what = "shovel"},
}

local Inventory = { selected = 1, items = {} }
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

function Inventory.getSelected()
	if not Inventory.items[Inventory.selected] then
		Inventory.selected = 1
	end
	return Inventory.items[Inventory.selected]
end

Gamestate.deus = Gamestate.new()
local st = Gamestate.deus

local substate, world, playerpos, level, pipe, exit, totalFields, walkedFields, coins, crates, score
local camera

local wait_for_client = {alpha = 155, t = 0}
local send_world = {}
local play = {cam = Camera.new(vector(0,0),1)}
local selected_pos = vector(0,0)
--
-- handshake state
--
local sequence = Sequence(scenes.highscores, scenes.credits, scenes.title)
local time = 0
sequence.looping = true
function wait_for_client:draw()
	sequence:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill', 240, 557, 318, 27)
	love.graphics.setColor(255,255,255,150 + math.sin(time) * 50)
	love.graphics.print('waiting for other player', (800 - 311) / 2, 580)
end

function wait_for_client:update(dt)
	sequence:update(dt)
	assert(coroutine.resume(self.handshake, Deus.pipe))
	if coroutine.status(self.handshake) == "dead" then
		substate = send_world
		time = 0
	end
end
--
-- world sending state
--
function send_world:draw()
	sequence:draw()
	if time > 5 then
		local font = fonts[30]
		local height = love.graphics.getHeight('sending world')
		love.graphics.setColor(255,255,255)
		love.graphics.print('sending world', (800 - 172) / 2, 590 - 3 * height)
		local str = "other side not responding"
		love.graphics.setColor(255,255,255,150)
		love.graphics.print(str, (800 - font:getWidth(str)) / 2, 590 - 2 * height)
		str = "press 1 to abort"
		love.graphics.print(str, (800 - font:getWidth(str)) / 2, 590 - height)
	else
		love.graphics.print('sending world', (800 - 172) / 2, 580)
	end
end

function send_world:update(dt)
	sequence:update(dt)
	assert(coroutine.resume(self.sendworld, world, playerpos, exit))
	if coroutine.status(self.sendworld) == "dead" then
		level = Level.new(world)

		Trails.clear()
		Items.clear()

		local exitanim = newAnimation(love.graphics.newImage('images/exit.png'), 32, 32, .15, 0)
		Items.add(exitanim, exit)

		local levelsize = vector(#world[1], #world + 2) * TILESIZE
		local zoom = math.min(love.graphics.getWidth() / levelsize.x,
		love.graphics.getHeight() / levelsize.y)
		camera = Camera.new(levelsize/2 - vector(0, TILESIZE * .7), zoom)

		substate = play

		selected_pos = vector(math.floor(#world[1]/2), math.floor(#world/2))

		love.graphics.setFont(fonts[30])

		love.audio.stop()
		ingame_playlist:shuffle()
		ingame_playlist:play()

		-- spawn items at random positions
		coins, crates = {}, {}
		for i=1,5 do
			local x,y
			repeat
				x,y = math.random(1,#level.grid[1]), math.random(1,#level.grid)
			until level.grid[y][x] == 1
			coins[#coins+1] = vector(x,y)
			Items.add(wrapDraw(images.coin), vector(x,y))
			level.grid[y][x] = 3
			Deus.addSign(x,y, 'coin')
		end
		for i=1,5 do
			local x,y
			repeat
				x,y = math.random(1,#level.grid[1]), math.random(1,#level.grid)
			until level.grid[y][x] == 1
			crates[#crates+1] = vector(x,y)
			Items.add(wrapDraw(images.crate), vector(x,y))
			level.grid[y][x] = 4
			Deus.addSign(x,y, 'crate')
		end

		player.init(playerpos, 20)
		function player.ondie()
			Deus.killPlayer()
			player.age = 0
			player.lifespan = player.lifespan + 5
			Deus.addSign(player.pos.x, player.pos.y, 'grave')
			local item = wrapDraw(love.graphics.newImage('images/grave.png'))
			Items.add(item, player.pos:clone())
			player.reset()
		end

		function player.onmove() end
	elseif time > 5 and love.keyboard.isDown(keys.start) then
		Gamestate.switch(Gamestate.title_deus)
	end
end
--
-- play state
--
local time, time_since_last_sync, time_since_last_ping, points = 0,0,0,0
local keydelay = 0
local min, max = math.min, math.max

local function actionMeaningful()
	if not Inventory.getSelected() then return false end
	return (level.grid[selected_pos.y][selected_pos.x] == 0 and Inventory.getSelected().what == "shovel") or
	(level.grid[selected_pos.y][selected_pos.x] ~= 0 and Inventory.getSelected().what ~= "shovel")
end

function play:update(dt)
	ingame_playlist:update(dt)
	score = getScore(walkedFields, totalFields, points, time)
	time_since_last_sync = time_since_last_sync + dt
	time_since_last_ping = time_since_last_ping + dt

	player.grow(dt)

	if player.pos == exit then
		Deus.exit(score)
		Gamestate.switch(Gamestate.score, level, score, camera)
		return
	end

	if time_since_last_sync > .25 then
		Deus.sendClock(player.age, player.lifespan)
		time_since_last_sync = 0
	end

	local message = getMessage(Deus.pipe)
	while message do
		if message[1] == "moveo" then
			local newpos = vector(tonumber(message[2]), tonumber(message[3]))
			local dir = newpos - player.pos
			player.move(dir)
			player.pos = newpos

			player.trail:add(player.pixelpos())
			if not walkedFields[player.pos.y * #level.grid + player.pos.x] then
				walkedFields[player.pos.y * #level.grid + player.pos.x] = true
			end
		elseif message[1] == "ping" then
			time_since_last_ping = 0
		end
		message = getMessage(Deus.pipe)
	end

	for i,c in ipairs(coins) do
		if c == player.pos then
			points = points + math.random(100, 400)
			Deus.removeItem(c)
			Items.remove(Items.find(c))
			table.remove(coins, i)
		end
	end

	for i,c in ipairs(crates) do
		if c == player.pos then
			Inventory.items[#Inventory.items+1] = Powerups[math.random(#Powerups)]
			Deus.removeItem(c)
			Items.remove(Items.find(c))
			table.remove(crates, i)
		end
	end

	Items.update(dt)

	-- MOVEMENT
	if keydelay <= 0 then
		keydelay = .15

		if love.keyboard.isDown(keys.up) then
			selected_pos.y = max(selected_pos.y - 1, 2)
		elseif love.keyboard.isDown(keys.down) then
			selected_pos.y = min(selected_pos.y + 1, #world-1)
		end
		if love.keyboard.isDown(keys.left) then
			selected_pos.x = max(selected_pos.x - 1, 2)
		elseif love.keyboard.isDown(keys.right) then
			selected_pos.x = min(selected_pos.x + 1, #world[1]-1)
		end

		if love.keyboard.isDown(keys.item_left) then
			Inventory.select( 1)
		elseif love.keyboard.isDown(keys.item_right) then
			Inventory.select(-1)
		end

		if love.keyboard.isDown(keys.item_action) and actionMeaningful() then
			local item = Inventory.getSelected()
			if item.what == "shovel" then
				level.grid[selected_pos.y][selected_pos.x] = 1
				Deus.shovel(selected_pos)
			else
				Items.add(item.obj, selected_pos:clone())
				Deus.addSign(selected_pos.x, selected_pos.y, item.what)
			end
			Inventory.remove(Inventory.selected)
			Inventory.selected = math.min(Inventory.selected, #Inventory.items)
			--			Inventory.select(1)
			keydelay = .3
		end

	else
		keydelay = keydelay - dt
	end

	if time_since_last_ping > 5 then
		love.graphics.setFont(20)
		MessageBox("Sorry...", "Connection lost", function() Gamestate.switch(Gamestate.title) end)
	end
end

function play:draw()
	camera:predraw()
	level:draw(camera, true)
	Items.draw()
	Trails.draw()
	player.draw()
	if actionMeaningful() then
		love.graphics.setColor(0,255,100,200)
	else
		love.graphics.setColor(255,160,0,100)
	end
	love.graphics.rectangle('fill', (selected_pos.x-1)*TILESIZE, (selected_pos.y-1)*TILESIZE, 32,32)
	camera:postdraw()

	Inventory.draw()

	local barwith = love.graphics.getWidth() - 80
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle('fill', 70, 10, barwith, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 70, 10, (1 - player.age / player.lifespan) * barwith, 7)
	love.graphics.print('life:', 10, 20)
end

--
-- Main gamestate. Forwards to substates
--
function st:enter(pre, port, grid, startpos, exitpos)
	exit = exitpos
	sequence.current:enter()
	score = 0
	self.port = port
	Level.init()
	if Deus.pipe then
		Deus.pipe.udp:close()
	end
	Deus.pipe = NetPipe.new(port)
	love.graphics.setBackgroundColor(0,0,0)
	world, playerpos = grid, startpos
	substate = wait_for_client

	wait_for_client.handshake = coroutine.create(Deus.handshake)
	send_world.sendworld = coroutine.create(Deus.sendworld)

	Inventory.items = {}
	Inventory.selected = 1
	for i,p in ipairs(Powerups) do
		Inventory.items[#Inventory.items+1] = p
	end

	totalFields = 0
	for y,x in spatialrange(1,#grid, 1,#grid[1]) do
		if grid[y][x] ~= 0 then totalFields = totalFields + 1 end
	end
	walkedFields = {}

	time_since_last_ping = 0
end

function st:draw()
	substate:draw()
end

function st:update(dt)
	time = time + dt
	local all_ok, error = pcall(function() substate:update(dt) end)
	if not all_ok then
		love.graphics.setFont(20)
		MessageBox("Error", error, function() Gamestate.switch(Gamestate.title) end)
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

function st:leave()
	ingame_playlist:stop()
end
