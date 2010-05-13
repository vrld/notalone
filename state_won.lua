require "camera"
require "level"
require "gamestate"

local level, camera, center, sc
local fadetime, time = 20, 0

state_won = Gamestate.new()
local st = state_won
function st:enter(pre, player)
	level = pre.level
	love.graphics.setBackgroundColor(0,0,0)
	Decals.clear()

	center = vector.new(level.pixels.w/2, level.pixels.h/2) + vector.new(TILESIZE,TILESIZE)
	sc = math.min(love.graphics.getWidth()/level.pixels.w,
	              love.graphics.getHeight()/level.pixels.h)
	camera = Camera.new(player.pixelpos(), player.zoom)
	level.fog = level.fog_accum
end

function st:draw()
	camera:predraw()
	level:draw()
	level:drawGraves()
	level:drawFog()
	camera:postdraw()

	love.graphics.setColor(0,0,0,time/fadetime * 255)
	love.graphics.rectangle('fill', 0,0, 800,600)

	love.graphics.setColor(255,255,255, time/fadetime * 255)
	love.graphics.print('You Were Not Alone In This World', 200, 100)
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
	end
end
