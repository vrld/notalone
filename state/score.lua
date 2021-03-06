local level, camera, center, sc, before, score_width, score_height, name, pos, score
local fadetime, time = 10, 0

function load_highscores(fn)
	local scores = {}
	if not love.filesystem.exists(fn) then
		local f = love.filesystem.newFile(fn)
		f:open('w')
		f:write("VRLD,55\n")
		f:write("VRLD,34\n")
		f:write("VRLD,21\n")
		f:write("VRLD,13\n")
		f:write("VRLD,8\n")
		f:write("VRLD,5\n")
		f:write("VRLD,3\n")
		f:write("VRLD,2\n")
		f:write("VRLD,1\n")
		f:write("VRLD,1\n")
		f:close()
	end
	local file = love.filesystem.newFile(fn)
	file:open('r')
	for line in file:lines() do
		local name, score = line:match('(%w+),(%d+)')
		if name and score then
			scores[#scores+1] = {name = name, score = tonumber(score)}
		end
	end
	return scores
end

function sort_highscores(scores)
	table.sort(scores, function(a, b) return a.score > b.score end)
	while #scores > 10 do -- 10 entries at max
		table.remove(scores)
	end
end

function save_highscores(scores, fn)
	local file = love.filesystem.newFile(fn)
	file:open('w')
	for _,score in ipairs(scores) do
		file:write(string.format("%s,%s\n", score.name, score.score))
	end
end

Gamestate.score = Gamestate.new()
local st = Gamestate.score
function st:enter(pre, lvl, scre, cam)
	before = pre
	time = 0
	level = lvl
	love.graphics.setBackgroundColor(0,0,0)

	center = vector(#level.grid[1]/2, #level.grid/2) * TILESIZE
	sc = math.min(love.graphics.getWidth()/#level.grid[1]/TILESIZE,
	              love.graphics.getHeight()/#level.grid/TILESIZE)
	camera = cam
	level.seen = level.seen_accum

	local font = fonts[35]
	love.graphics.setFont(fonts[35])

	score = scre
	self.score = string.format('SCORE: %s', score)
	score_width, score_height = font:getWidth(self.score), font:getHeight(self.score)
	name, pos = 'AAAA', 1

	highscores = load_highscores('highscores')
	if highscores[#highscores].score < score then
		new_highscore = true
		self.score = string.format('score: %s - new highscore!', score)
		score_width, score_height = font:getWidth(self.score), font:getHeight(self.score)
	end

	love.audio.play(music_loop)
end

function st:leave()
	save_highscores(highscores, 'highscores')
end

function st:draw()
	camera:predraw()
	if before == Gamestate.deus then
		level:draw(camera, true)
	else
		level:draw(camera)
		level:drawFog(camera)
	end
	camera:postdraw()

	local fade = math.min(time/fadetime, 1)
	love.graphics.setColor(0,0,0,fade * 255)
	love.graphics.rectangle('fill', 0,0, 800,600)

	local font = fonts[35]
	local ypos = 70
	love.graphics.setColor(255,255,255, fade * 255)
	love.graphics.print(self.score, (800 - score_width)/2, ypos)
	if new_highscore then
		local w = font:getWidth('YOUR NAME: ')
		local w2 = font:getWidth('A')
		love.graphics.print('YOUR NAME: ' .. name, (800 - w - 3 * w2)/2, ypos + 1.5 * score_height)
		if pos <= 4 then
			love.graphics.print('_', (800 - w - 3 * w2) / 2 + w + (pos-1) * w2, ypos + 1.7 * score_height)
		end
	else
		love.graphics.setColor(255,255,255,100 * fade)
		love.graphics.print("PRESS RETURN TO CONTINUE", (800 - font:getWidth("PRESS RETURN TO CONTINUE")) / 2, ypos + 1.5 * score_height)
	end
	love.graphics.setColor(255,255,255, fade * 180)
	local w = font:getWidth('HIGHSCORES')
	love.graphics.print('HIGHSCORES', (800 - w)/2, ypos + 3 * score_height)
	love.graphics.setColor(255,255,255, fade * 255)
	for i,s in ipairs(highscores) do
		love.graphics.print(s.name, (800 - w)/2, ypos + (3.2+i) * score_height)
		love.graphics.print(s.score, (800 - w + 200)/2, ypos + (3.2+i) * score_height)
	end
end

local keydelay = 0
local nextchar = {
	A = 'B', B = 'C', C = 'D', D = 'E', E = 'F', F = 'G', G = 'H', H = 'I', ['I'] = 'J', J = 'K',
	K = 'L', L = 'M', M = 'N', N = 'O', O = 'P', P = 'Q', Q = 'R', R = 'S', S = 'T', T = 'U',
	U = 'V', V = 'W', W = 'X', X = 'Y', Y = 'Z', Z = 'A'
}
local prevchar = {
	A = 'Z', B = 'A', C = 'B', D = 'C', E = 'D', F = 'E', G = 'F', H = 'G', ['I'] = 'H', J = 'I',
	K = 'J', L = 'K', M = 'L', N = 'M', O = 'N', P = 'O', Q = 'P', R = 'Q', S = 'R', T = 'S',
	U = 'T', V = 'U', W = 'V', X = 'W', Y = 'X', Z = 'Y'
}
function st:update(dt)
	time = time + dt

	if keydelay <= 0 then
		keydelay = .1

		if love.keyboard.isDown(keys.up) and pos <= 4 then
			local n = {name:match('(%s?%w)(%s?%w)(%s?%w)(%s?%w)')}
			n[pos] = nextchar[n[pos]]
			name = table.concat(n)
		elseif love.keyboard.isDown(keys.down) and pos <= 4 then
			local n = {name:match('(%s?%w)(%s?%w)(%s?%w)(%s?%w)')}
			n[pos] = prevchar[n[pos]]
			name = table.concat(n)
		end
		if love.keyboard.isDown(keys.left) and pos > 1 then
			pos = pos - 1
		elseif (love.keyboard.isDown(keys.right) or love.keyboard.isDown(keys.item_left) or love.keyboard.isDown(keys.right)) and pos < 4 then
			pos = pos + 1
		end

		if love.keyboard.isDown(keys.start) or love.keyboard.isDown(keys.item_action) or (pos >= 4 and (love.keyboard.isDown(keys.item_left) or love.keyboard.isDown(keys.item_right))) then
			if new_highscore then
				keydelay = .5
				highscores[#highscores] = {name = name, score = score}
				sort_highscores(highscores)
				save_highscores(highscores, 'highscores')
				new_highscore = false
				time = fadetime
			else
				Gamestate.switch(Gamestate.title)
			end
		end

	else
		keydelay = keydelay - dt
	end

	camera.pos = camera.pos - (camera.pos - center) * dt
	camera.zoom = camera.zoom - (camera.zoom - sc) * dt

	if music_loop:isStopped() then
		music_loop = love.audio.newSource('sound/startscreen.ogg', 'stream')
		music_loop:setLooping(true)
		love.audio.play(music_loop)
	end

	if not new_highscore and time - fadetime > 10 then
		Gamestate.switch(Gamestate.title_mortem)
	end

end
