require "camera"
require "level"
require "gamestate"

local level, camera, center, sc
local fadetime, time = 20, 0
local str
local size = 5
local life = 20

state_won = Gamestate.new()
local st = state_won
function st:enter(pre, player)
	time = 0
	level = pre.level
	love.graphics.setBackgroundColor(0,0,0)
	Decals.clear()

	center = vector.new(level.pixels.w/2, level.pixels.h/2) + vector.new(TILESIZE,TILESIZE)
	sc = math.min(love.graphics.getWidth()/level.pixels.w,
	              love.graphics.getHeight()/level.pixels.h)
	camera = Camera.new(player.pixelpos(), player.zoom)
	level.fog = level.fog_accum

	if player.lifes > 1 then
		str = "You were not alone in this world"
	else
		str = "You were alone in this world"
	end
end

local function next_level()
	size = size + 2
	life = life + 5
	local grid,start= Maze.new(size*4,size*3)
	Gamestate.switch(state_play, grid, start, life)
end

function st:draw()
	camera:predraw()
	level:draw()
	level:drawGraves()
	level:drawFog()
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
		Gamestate.switch(state_title)
	elseif key == 'return' then
		next_level()
	end
end
