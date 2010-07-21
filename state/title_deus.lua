Gamestate.title_deus = Gamestate.new()
local st = Gamestate.title_deus
function st:enter()
	love.graphics.setBackgroundColor(0,0,0)

	if not music_loop then
		music_loop = love.audio.newSource('sound/startscreen.ogg', 'stream')
		music_loop:setLooping(true)
	end
	love.audio.stop()
	if music_loop:isStopped() then
		love.audio.play(music_loop)
	end
end

-- image scroller and stuff
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
	love.graphics.print("AND BE A GOD", (800 - font:getWidth("AND BE A GOD")) / 2, 580)
end

function st:keypressed(key, unicode)
	if key == keys.start then
		Gamestate.switch(Gamestate.deus, 12345, Maze.new(40,30))
	end
end
