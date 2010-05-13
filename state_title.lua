require "gamestate"
require "state_play.lua"
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
	love.graphics.print('Press a key to start', 400, 300)
end

function st:mousereleased(btn,x,y)
end

function st:keyreleased(key)
	local grid = {
		--   1       5         10        15        20
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- 1
		{0,1,1,1,1,0,1,0,0,1,1,1,0,1,1,1,1,1,1,0},
		{0,1,0,0,1,0,1,0,0,1,0,0,0,0,1,0,0,0,1,0},
		{0,1,0,0,1,0,1,1,3,1,0,1,1,1,1,0,1,0,1,0},
		{0,1,1,0,1,1,1,0,0,1,0,1,0,0,1,0,1,0,1,0}, -- 5
		{0,1,0,0,0,0,1,0,0,1,1,1,0,3,1,0,1,1,1,0},
		{0,1,0,1,0,1,1,0,1,1,0,0,0,1,0,0,0,1,0,0},
		{0,1,0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,0},
		{0,1,0,1,1,0,1,1,1,1,0,1,0,1,0,1,1,1,1,0},
		{0,1,0,0,1,0,0,0,0,1,0,1,0,1,0,1,0,0,1,0}, -- 10
		{0,1,0,0,1,1,1,1,0,1,0,1,0,1,0,1,0,0,1,0},
		{0,1,1,1,1,0,0,1,1,1,0,1,1,1,0,1,1,1,1,0},
		{0,0,1,0,1,1,0,0,0,0,0,0,1,0,0,0,0,1,0,0},
		{0,0,1,0,0,0,0,0,1,0,1,1,1,1,1,0,0,1,0,0},
		{0,1,1,1,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1,0}, -- 15
		{0,0,0,1,0,0,1,0,1,0,1,0,1,1,1,1,1,1,0,0},
		{0,1,0,1,0,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0},
		{0,1,1,1,1,1,1,0,1,0,1,0,1,1,1,0,1,0,0,0},
		{0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,1,1,1,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0}, -- 20
	}
	local x,y = 7,9
	--	local grid,x,y = Maze.new(20,20,0)
	Gamestate.switch(state_play, grid, vector.new(x,y), 10)
end
