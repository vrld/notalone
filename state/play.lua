require "util/camera"
require "player"
require "level"
require "gamestate"
require "state/won"

local level, camera
Gamestate.play = Gamestate.new()
local st = Gamestate.play
st.paused = false
function st:enter(pre, grid, pos, life)
	assert(grid, "Wha?")
	assert(pos, "Whoop Whoop Whoop")
	assert(life, "Good news everyone")
	love.graphics.setBackgroundColor(0,0,0)

	level = Level.new(grid)
	player.init(level, pos, life)
	camera = Camera.new(player.pixelpos(),1)
	level:see(pos, vector(0,0), 1)
	self.level = level
    love.graphics.setScissor(0,0,love.graphics.getWidth(), love.graphics.getHeight())
end

function st:draw()
	camera:predraw()
	level:draw(camera)
	level:drawFog(camera)
	player.draw()
	camera:postdraw()

	local frac = 1 - player.age / player.lifespan
	local barwith = love.graphics.getWidth() - 20
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle('fill', 10, 10, barwith, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 10, 10, frac*barwith, 7)

	if self.paused then
		love.graphics.setColor(0,0,0,150)
		love.graphics.rectangle('fill', 0,0, 800,600)
		love.graphics.setColor(255,255,255)
		love.graphics.print('PAUSE', 380,300)
	end

end

function st:update(dt)
	if self.paused then return end

	local min,max = player.seen.min, player.seen.max
	local center = ((max - min) / 2 + min) * TILESIZE + vector(TILESIZE/2, TILESIZE/2)
	camera.pos = camera.pos - (camera.pos - (.75 * center + .25 * player.pixelpos())) * dt * 10
	camera.zoom = camera.zoom - (camera.zoom - player.zoom) * dt * 10

	player.update(dt, level)
	if level.grid[player.pos.y][player.pos.x] == 2 then
		Gamestate.switch(Gamestate.won, player, camera)
	end
end

function st:keyreleased(key)
	if key == 'p' then
		self.paused = not self.paused
	elseif key == 'm' then
		self.show_map = not self.show_map
	elseif key == 'escape' then
		Gamestate.switch(Gamestate.title)
	end
end
