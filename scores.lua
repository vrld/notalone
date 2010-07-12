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

function getScore(walkedFields, totalFields, points, time)
	-- count walked fields
	local seen = 0
	for _,s in pairs(walkedFields) do
		seen = seen + 1
	end
	seen = seen * 20

	local speed = totalFields / time * 20
	return math.ceil(seen + speed + points)
end
