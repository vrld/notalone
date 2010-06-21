require "gamestate"
require "state_deus"
require "maze"
require "button"

state_title = Gamestate.new()
local st = state_title

local font1,font2
local btnDeus, btnMortem
function st:enter()
	love.graphics.setBackgroundColor(40,80,20)
	if not font1 then
		font1 = love.graphics.newFont(12)
	end
	if not font2 then
		font2 = love.graphics.newFont(30)
	end

	if not btnDeus then
		btnDeus = Button.new("Deus", vector.new(400,400), vector.new(200,40), font2)
		btnDeus.onClick = function()
			local grid,start= Maze.new(20,15)
			Gamestate.switch(state_deus, grid, start, 20)
		end
	end
	if not btnMortem then
		btnMortem = Button.new("Mortem", vector.new(400,490), vector.new(200,40), font2)
		btnMortem.onClick = function()
			Gamestate.switch(state_mortem, grid, start, 20)
		end
	end
end

function st:leave()
	love.graphics.setFont(font1)
end

function st:update(dt)
	Button.update(dt)
end

function st:draw()
	love.graphics.setFont(font2)
	love.graphics.print('You Are Not Alone In This World', 200, 100)
	Button.draw_all()
	love.graphics.setFont(font1)
end
