local level, camera
Gamestate.play = Gamestate.new()
local st = Gamestate.play
st.paused = false
local grave_image
function st:enter(pre, grid, pos, exit, life)
	assert(grid, "Wha?")
	assert(pos, "Whoop Whoop Whoop")
	assert(life, "Good news everyone")
	love.graphics.setBackgroundColor(0,0,0)

	level = Level.new(grid)
	player.init(pos, life)
	camera = Camera.new(player.pixelpos(),1)
	level:see(pos, 3)
--	love.graphics.setScissor(0,0,love.graphics.getWidth(), love.graphics.getHeight())
--
  	if not grave_image then
		local img = love.graphics.newImage('images/grave.png')
		img:setFilter('nearest', 'nearest')
		grave_image = wrapDraw(img)
	end

	local diesound = love.sound.newSoundData('sound/die.ogg')
	function player.ondie()
		Items.add(grave_image, player.pos)
		playsound(diesound)
		player.lifespan = player.lifespan + 5
		level:unsee()
		player.reset()
		level:see(player.pos,1)
	end

	function player.onmove(pos, direction)
		local newpos = pos + direction
		if grid[newpos.y][newpos.x] == 0 then
			return
		end

		player.pos = newpos
		player.trail:add(player.pixelpos())
		level:see(newpos)
	end

	Items.clear()
	local exitanim = newAnimation(love.graphics.newImage('images/exit.png'), 32, 32, .1, 0)
	Items.add(exitanim, exit)

	if ingame_playlist:isStopped() then
		love.audio.stop()
		ingame_playlist:shuffle()
		ingame_playlist:play()
	end
end

function st:draw()
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

	if self.paused then
		love.graphics.setColor(0,0,0,150)
		love.graphics.rectangle('fill', 0,0, 800,600)
		love.graphics.setColor(255,255,255)
		love.graphics.print('PAUSE', 380,300)
	end

end

function st:update(dt)
	ingame_playlist:update(dt)
	if self.paused then return end

	local min,max = level.seen.min, level.seen.max
	local center = ((max - min) / 2 + min) * TILESIZE - vector(TILESIZE/2, TILESIZE/2)
	camera.pos = camera.pos - (camera.pos - (.75 * center + .25 * player.pixelpos())) * dt * 10
	camera.zoom = camera.zoom - (camera.zoom - level.zoom) * dt * 10

	player.grow(dt)
	player.update(dt, level)
	Trails.update(dt)
	if level.grid[player.pos.y][player.pos.x] == 2 then
		Trails.clear()
		self.level = level
		Gamestate.switch(Gamestate.won, player, camera)
	end

	Items.update(dt)
end

function st:keyreleased(key)
	if key == keys.start then
		Gamestate.switch(Gamestate.title)
	end
end
