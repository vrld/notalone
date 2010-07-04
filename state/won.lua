require "util/camera"
require "level"
require "gamestate"

local level, camera, center, sc
local fadetime, time = 20, 0
local str
local size = 5
local life = 20

Gamestate.won = Gamestate.new()
local st = Gamestate.won
function st:enter(pre, player, cam)
	time = 0
	level = pre.level
	love.graphics.setBackgroundColor(0,0,0)

	center = vector(#level.grid[1]/2, #level.grid/2) * TILESIZE
	sc = math.min(love.graphics.getWidth()/#level.grid[1]/TILESIZE,
	              love.graphics.getHeight()/#level.grid/TILESIZE)
	camera = cam
	level.seen = level.seen_accum

	if player.lifes > 1 then
		str = "You were not alone in this world"
	else
		str = "You were alone in this world"
	end
end

local function next_level()
	size = size + 2
	life = life + 5
	local grid,start,exit= Maze.new(size*4,size*3)
	Gamestate.switch(Gamestate.play, grid, start,exit, life)
end

function st:draw()
	camera:predraw()
	level:draw(camera)
	level:drawFog(camera)
	camera:postdraw()

	local fade = math.min(time/fadetime, 1)
	love.graphics.setColor(0,0,0,fade * 255)
	love.graphics.rectangle('fill', 0,0, 800,600)

	love.graphics.setColor(255,255,255, fade * 255)
	love.graphics.print(str, 200, 100)

	local fade = math.max(math.min(time/fadetime - .3, 1), 0)
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
		next_level()
	end
end
