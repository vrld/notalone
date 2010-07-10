require "util/camera"
require "level"
require "gamestate"

local level, camera, center, sc, before
local fadetime, time = 20, 0

Gamestate.score = Gamestate.new()
local st = Gamestate.score
function st:enter(pre, lvl, score, cam)
	before = pre
	time = 0
	level = lvl
	self.score = score
	love.graphics.setBackgroundColor(0,0,0)

	center = vector(#level.grid[1]/2, #level.grid/2) * TILESIZE
	sc = math.min(love.graphics.getWidth()/#level.grid[1]/TILESIZE,
	              love.graphics.getHeight()/#level.grid/TILESIZE)
	camera = cam
	level.seen = level.seen_accum
end

function st:draw()
	camera:predraw()
	if before == Gamestate.deus then
		level:draw(camera, true)
	else
		level:draw(camera)
		level:drawFog(camera)
	end
	camera:postdraw()

	local fade = math.min(time/fadetime, 1)
	love.graphics.setColor(0,0,0,fade * 255)
	love.graphics.rectangle('fill', 0,0, 800,600)

	love.graphics.setColor(255,255,255, fade * 255)
	love.graphics.print('Score: ' .. tostring(self.score), 300, 200)

	fade = math.max(math.min(time/fadetime - .3, 1), 0)
	love.graphics.setColor(255,255,255, fade * 255)
	love.graphics.print('press [return] to continue', 300, 200)
end

function st:update(dt)
	time = time + dt
	if time > fadetime then
		time = fadetime
	end

	camera.pos = camera.pos - (camera.pos - center) * dt
	camera.zoom = camera.zoom - (camera.zoom - sc) * dt
end

function st:keyreleased(key)
	if key == 'escape' then
		Gamestate.switch(Gamestate.title)
	elseif key == 'return' then
		if before == Gamestate.deus then
			Gamestate.switch(before, before.port, Maze.new(40,30))
		else
			Gamestate.switch(before, before.ip, before.port)
		end
	end
end
