Gamestate.title_mortem = Gamestate.new()
local st = Gamestate.title_mortem

function st:enter()
	love.graphics.setBackgroundColor(0,0,0)

	if not music_loop then
		music_loop = love.audio.newSource('sound/startscreen.ogg', 'stream')
		music_loop:setLooping(true)
	end
	love.audio.stop()
end

local sequence = Sequence(scenes.title, scenes.highscores, scenes.credits)
function st:update(dt)
	sequence:update(dt)
	if music_loop:isStopped() then -- hack to 'solve' the no music problem
		music_loop = love.audio.newSource('sound/startscreen.ogg', 'stream')
		music_loop:setLooping(true)
		love.audio.play(music_loop)
	end
end

function st:draw()
	local font = love.graphics.getFont()
	sequence:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print("PRESS 1", (800 - font:getWidth("PRESS 1")) / 2, 550)
	love.graphics.setColor(255,255,255,150)
	love.graphics.print("AND YOU WILL PERISH", (800 - font:getWidth("AND YOU WILL PERISH")) / 2, 580)
end

function st:keypressed(key, unicode)
	if key == keys.start then
		Gamestate.switch(Gamestate.mortem, "192.168.0.24", 12345)
--		Gamestate.switch(Gamestate.mortem, "127.0.0.1", 12345)
	end
end
