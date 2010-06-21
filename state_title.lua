require "gamestate"
require "state_deus"
require "state_mortem"
require "state_play"
require "maze"
require "button"
require "input"

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
		btnDeus = Button.new("Deus", vector.new(400,400), vector.new(400,40), font2)
		btnDeus.onClick = function()
			local grid,start= Maze.new(20,15)
			Gamestate.switch(state_deus, grid, start, 20)
		end
	end
	if not btnMortem then
		btnMortem = Button.new("Mortem", vector.new(400,450), vector.new(400,40), font2)
		btnMortem.onClick = function()
			Gamestate.switch(state_mortem, grid, start, 20)
		end
	end
	if not btnAlone then
		btnAlone = Button.new("Yes, I Am Alone", vector.new(400,350), vector.new(400,40), font2)
		btnAlone.onClick = function()
			local grid,start= Maze.new(20,15)
			Gamestate.switch(state_play, grid, start, 20)
		end
	end

	Button.add(btnMortem, btnDeus, btnAlone)
	local inpStuff = Input.new( vector.new(400,300), vector.new(400,40), font2 )
	inpStuff.active = true
	Input.add(inpStuff)
end

function st:leave()
	Button.remove_all()
	Input.remove_all()
	love.graphics.setFont(font1)
end

function st:update(dt)
	Button.update_all(dt)
end

function st:draw()
	love.graphics.setFont(font2)
	love.graphics.print('You Are Not Alone In This World', 200, 100)
	Button.draw_all()
	Input.draw_all()
	love.graphics.setFont(font1)
end

function st:keypressed(key, unicode)
	Input.handleKeyPressed(unicode)
end

function st:mousereleased(x,y,btn)
	Input.handleMouseDown(x,y,btn)
end
