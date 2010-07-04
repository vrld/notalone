require "gamestate"
require "state/title"
require "level"
--require "profiler"

TILESIZE = 32

function spatialrange(a1,a2,b1,b2)
	local i,k = a1-1,b1
	return function()
		i = i+1
		if i > a2 then i, k = a1, k+1 end
		if k > b2 then return nil end
		return i,k
	end
end

function love.load()
	--profiler.start()
	Level.init()
	Gamestate.switch(Gamestate.title)
	love.graphics.setLine(3)
end
