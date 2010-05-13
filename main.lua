require "gamestate.lua"
require "state_title.lua"

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
    Level.init()
    Gamestate.switch(state_title)
end
