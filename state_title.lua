require "gamestate"
require "state_deus.lua"
require "maze.lua"

state_title = Gamestate.new()
local st = state_title

local font1,font2
function st:enter()
	love.graphics.setBackgroundColor(40,80,20)
	if not font1 then
		font1 = love.graphics.newFont(12)
	end
	if not font2 then
		font2 = love.graphics.newFont(30)
	end
	love.graphics.setFont(font2)
end

function st:leave()
	love.graphics.setFont(font1)
end

function st:draw()

	love.graphics.print('You Are Not Alone In This World', 200, 100)
	love.graphics.print('Press [return] to start', 400, 300)
end

function st:keyreleased(key)
	if key ~= 'return' then return end
	local grid,start= Maze.new(20,15)
	Gamestate.switch(state_deus, grid, start, 20)
end
