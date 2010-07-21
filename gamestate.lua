Gamestate = {}
local function __NULLFUNCTION__() end
function Gamestate.new()
	return {
		enter          = __NULLFUNCTION__,
		leave          = __NULLFUNCTION__,
		update         = __NULLFUNCTION__,
		draw           = __NULLFUNCTION__,
		keyreleased    = __NULLFUNCTION__,
		keypressed     = __NULLFUNCTION__,
		mousereleased  = __NULLFUNCTION__,
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

local _update
function Gamestate.update(dt)
	if _update then _update(dt) end
	Gamestate.current:update(dt)
end

local _keypressed
function Gamestate.keypressed(key, unicode)
	if _keypressed then _keyreleased(key) end
	Gamestate.current:keypressed(key, unicode)
end

local _keyreleased
function Gamestate.keyreleased(key)
	if _keyreleased then _keyreleased(key) end
	Gamestate.current:keyreleased(key)
end

local _mousereleased
function Gamestate.mousereleased(x,y,btn)
	if _mousereleased then _mousereleased(x,y,btn) end
	Gamestate.current:mousereleased(x,y,btn)
end

local _draw
function Gamestate.draw()
	if _draw then _draw() end
	Gamestate.current:draw()
end

function Gamestate.registerEvents()
	_update            = love.update
	love.update        = Gamestate.update
	_keypressed        = love.keypressed
	love.keypressed    = Gamestate.keypressed
	_keyreleased       = love.keyreleased
	love.keyreleased   = Gamestate.keyreleased
	_mousereleased     = love.mousereleased
	love.mousereleased = Gamestate.mousereleased
	_draw              = love.draw
	love.draw          = Gamestate.draw
end
