require "keys"
require "gamestate"

require "util/camera"
require "util/color"
require "util/playlist"
require "util/sequence"
require "util/tileset"
require "util/vector"
require "scenes"

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

ingame_playlist = Playlist('sound/maze1.ogg', 'sound/maze2.ogg', 'sound/maze3.ogg')
require "state/title_deus"
require "state/title_mortem"
require "state/title"
require "state/deus"
require "state/mortem"
require "state/score"
require "state/play"
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
	love.graphics.setFont(love.graphics.newFont('fonts/arena_berlin_redux.ttf', 35))
	Gamestate.switch(Gamestate.title)
	--Gamestate.switch(Gamestate.title_mortem)
	--Gamestate.switch(Gamestate.title_deus)
end
