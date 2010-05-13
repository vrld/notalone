Gamestate = {}
function Gamestate.new()
	return {
		enter          = function() end,
		leave          = function() end,
		update         = function() end,
		draw           = function() end,
		keyreleased    = function() end,
		mousereleased  = function() end,
	}
end

function Gamestate.switch(to, ...)
	if not to then return end
	if Gamestate.current then
		Gamestate.current:leave()
	end
	local pre = Gamestate.current
	Gamestate.current = to
	Gamestate.current:enter(pre, ...)
end

function love.update(dt)
	Gamestate.current:update(dt)
end

function love.keyreleased(key)
	Gamestate.current:keyreleased(key)
end

function love.mousereleased(btn,x,y)
	Gamestate.current:mousereleased(btn,x,y)
end

function love.draw()
	Gamestate.current:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 10,10)
end
