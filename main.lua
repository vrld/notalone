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

select_sound = love.sound.newSoundData(.005 * 44100, 44100, 16, 1)
for i = 0, .005 * 44100 do
    local t = i / 44100
    select_sound:setSample(i, math.random() * .4 * (1 - t / .005))
end

click_sound = love.sound.newSoundData(.01 * 44100, 44100, 16, 1)
for i = 0, .01 * 44100 do
    local t = i / 44100
    click_sound:setSample(i, math.sin(2 * math.pi * t * 2640) * .4 * (1 - t / .01))
end

sounds = {}
function playsound(sound)
	local s = love.audio.newSource(sound)
	love.audio.play(s)
	sounds[s] = s
end

fonts = {}

require "keys"
require "gamestate"

require "util/camera"
require "util/color"
require "util/playlist"
ingame_playlist = Playlist('sound/maze1.ogg', 'sound/maze2.ogg', 'sound/maze3.ogg')
require "util/sequence"
require "util/tileset"
require "util/vector"
require "scenes"

require "net/pipes"
require "net/protocol"

require "gui/button"
require "gui/dialog"
require "gui/input"

require "maze"
require "scores"
require "trail"

require "AnAL"
require "items"
require "level"
require "player"

require "state/title"
require "state/play"
require "state/won"
require "state/deus"
require "state/mortem"
require "state/score"

function love.load()
	Gamestate.registerEvents()
	Level.init()
	love.graphics.setLine(3)
	fonts[30] = love.graphics.newFont('fonts/arena_berlin_redux.ttf', 30)
	fonts[35] = love.graphics.newFont('fonts/arena_berlin_redux.ttf', 35)
	love.graphics.setFont(fonts[30])
	Gamestate.switch(Gamestate.title)
end

function love.update(dt)
	for k,s in pairs(sounds) do
		if s:isStopped() then
			sounds[k] = nil
		end
	end
end

function love.keyreleased(key)
	if key == "q" then
		love.event.push('q')
	elseif key == "escape" then
		Gamestate.switch(Gamestate.title)
	end
end
