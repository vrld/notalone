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

-- TODO: remove this from here!
sounds = {}
function playsound(sound)
	local s = love.audio.newSource(sound)
	love.audio.play(s)
	sounds[s] = s
end
function love.update(dt)
	Gamestate.current:update(dt)
	for k,s in pairs(sounds) do
		if s:isStopped() then
			sounds[k] = nil
		end
	end
end

function love.keypressed(key, unicode)
	Gamestate.current:keypressed(key, unicode)
end

function love.keyreleased(key)
	if key == "q" then
		love.event.push('q')
--		profiler.stop()
	end
	Gamestate.current:keyreleased(key)
end

function love.mousereleased(x,y,btn)
	Gamestate.current:mousereleased(x,y,btn)
end

function love.draw()
	Gamestate.current:draw()
end
