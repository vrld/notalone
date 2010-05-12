require "gamestate.lua"
require "state_title.lua"

TILESIZE = 32

function love.load()
    Level.init()
    Gamestate.switch(state_title)
end
