require "keys"
require "gamestate"

require "util/camera"
require "util/color"
require "util/tileset"
require "util/vector"

require "gui/button"
require "gui/dialog"
require "gui/input"

require "maze"
require "scores"
require "trail"

require "net/pipes"
require "net/protocol"

require "AnAL"
require "items"
require "level"
require "player"

require "state/deus"
require "state/mortem"
require "state/play"
require "state/score"
require "state/title"
require "state/won"

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
	love.graphics.setLine(3)
	love.graphics.setFont(love.graphics.newFont('fonts/digital-7.ttf', 20))
	Gamestate.switch(Gamestate.title)
end
