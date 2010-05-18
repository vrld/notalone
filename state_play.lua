require "camera"
require "decals"
require "player"
require "level"
require "gamestate"
require "state_won"

local level, camera, img
state_play = Gamestate.new()
local st = state_play
st.paused = false
function st:enter(pre, grid, pos, life)
	assert(grid, "Wha?")
	assert(pos, "Whoop Whoop Whoop")
	assert(life, "Good news everyone")
	love.graphics.setBackgroundColor(0,0,0)
	Decals.clear()

	level = Level.new(grid)
	player.init(level, pos, life)
	camera = Camera.new(player.pixelpos(),1)
	level:updateFog(pos, vector.new(0,0), 1)
	img = love.graphics.newImage(level:render())
	self.level = level
    love.graphics.setScissor(0,0,love.graphics.getWidth(), love.graphics.getHeight())
end

function st:draw()
	camera:predraw()
	level:draw()
	Decals.draw()
	level:drawGraves()
	level:drawFog(camera:rect())
	player.draw()
	camera:postdraw()

	local frac = 1 - player.age / player.lifespan
	local barwith = love.graphics.getWidth() - 20
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle('fill', 10, 10, barwith, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 10, 10, frac*barwith, 7)

	if self.show_map then
		love.graphics.setColor(255,255,255,200)
		local sx,sy = 200 / level.pixels.w, 200 / level.pixels.h
		local sc = math.min(sx,sy)
		love.graphics.draw(img, 590,390,0, sc)
	end

	if self.paused then
		love.graphics.setColor(0,0,0,150)
		love.graphics.rectangle('fill', 0,0, 800,600)
		love.graphics.setColor(255,255,255)
		love.graphics.print('PAUSE', 380,300)
	end

end

function st:update(dt)
	if self.paused then return end

	Decals.update(dt)
	camera.pos = camera.pos - (camera.pos - player.pixelpos()) * dt * 5
	camera.zoom = camera.zoom - (camera.zoom - player.zoom) * dt

	player.update(dt, level)
	if level.grid[player.pos.y][player.pos.x] == 2 then
		Gamestate.switch(state_won, player)
	end
end

function st:keyreleased(key)
	if key == 'p' then
		self.paused = not self.paused
	elseif key == 'm' then
		self.show_map = not self.show_map
	elseif key == 'escape' then
		Gamestate.switch(state_title)
	end
end
