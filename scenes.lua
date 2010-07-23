scenes = {}
scenes.credits = Scene(10)
function scenes.credits:draw()
	local frac = self.time / self.length
	local dir = vector(60, 12) * frac
	love.graphics.setColor(255,255,255)
	love.graphics.print('CREDITS', (800 - 93) / 2, 30)

	love.graphics.setColor(255,255,255,180)
	love.graphics.print('Idea and programming', (vector(200,130) + dir):unpack())
	love.graphics.setColor(255,255,255)
	love.graphics.print('Matthias Richter', (vector(220,150) + dir):unpack())

	dir = vector(-60, 1) * frac
	love.graphics.setColor(255,255,255,180)
	love.graphics.print('Music and Sound', (vector(400,190) + dir):unpack())
	love.graphics.setColor(255,255,255)
	love.graphics.print('Tilmann Hars', (vector(380,210) + dir):unpack())
	love.graphics.print('Frederik Schroff', (vector(375,230) + dir):unpack())

	dir = vector(52, 28) * frac
	love.graphics.setColor(255,255,255,180)
	love.graphics.print('Graphics', (vector(250,270) + dir):unpack())
	love.graphics.setColor(255,255,255)
	love.graphics.print('Gregor Belogour', (vector(270,290) + dir):unpack())

	dir = vector(-64, 16) * frac
	love.graphics.setColor(255,255,255,180)
	love.graphics.print('Framework', (vector(350,370) + dir):unpack())
	love.graphics.setColor(255,255,255)
	love.graphics.print('LOVE - love2d.org', (vector(330,390) + dir):unpack())
	love.graphics.print('by a lot of lovely people', (vector(325,410) + dir):unpack())

	dir = vector(-65, -15) * frac
	love.graphics.setColor(255,255,255,180)
	love.graphics.print('Font created by', (vector(350,470) + dir):unpack())
	love.graphics.setColor(255,255,255)
	love.graphics.print('Sizenko Alexander', (vector(355,490) + dir):unpack())
end

scenes.highscores = Scene(15)
function scenes.highscores:draw()
	local score_height = 30
	local ypos = 70
	local frac = self.time / self.length
	local font = fonts[35]
	love.graphics.setColor(255,255,255, 180)
	local w = font:getWidth('HIGHSCORES')
	love.graphics.print('HIGHSCORES', (820 - w)/2 - 40 * frac, ypos + 3 * 20)
	love.graphics.setColor(255,255,255, 255)

	if not self.scores then
		self:enter()
	end
	for i,s in ipairs(self.scores) do
		love.graphics.print(s.name, (800 - w)/2 + 40 * frac, ypos + (3.2+i) * score_height)
		love.graphics.print(s.score, (800 - w + 200)/2 + 40 * frac, ypos + (3.2+i) * score_height)
	end
end

function scenes.highscores:enter()
	self.scores = load_highscores('highscores')
	love.graphics.setFont(fonts[35])
end

function scenes.highscores:leave()
	love.graphics.setFont(fonts[30])
end

scenes.title = Scene(15)
local titlescreen = love.graphics.newImage("images/titlescreen.jpg")
local mask = love.graphics.newImage("images/mask.png")
local pos = vector(0,0)
local direction = vector(3,2)
local limits = vector(800 - titlescreen:getWidth(), 600 - titlescreen:getHeight())
function scenes.title:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(titlescreen, pos:unpack())
	love.graphics.draw(mask, 0,0)
end

function scenes.title:update(dt)
	pos = pos - direction * dt
	if pos.x <= limits.x or pos.x >= 0 then
		direction.x = - direction.x
	end
	if pos.y <= limits.y or pos.y >= 0 then
		direction.y = - direction.y
	end
end
