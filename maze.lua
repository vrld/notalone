require "util/vector"
Maze = {}

function Maze.initGrid(w,h)
	local grid = {}
	for y = 1,h do
		grid[y] = {}
		for x = 1,w do
			grid[y][x] = 0
		end
	end

	return grid
end

function Maze.randomexit(grid,w,h)
	local which_wall,x,y = math.random()
	if which_wall < .25 then     -- top
		x, y = math.random(2,w-1), 1
	elseif which_wall < .5 then  -- left
		x, y = 1, math.random(2,h-1)
	elseif which_wall < .75 then -- bottom
		x, y = math.random(2,w-1), h
	else                         -- right
		x, y = w, math.random(2,h-1)
	end
	return vector(x,y)
end

function Maze.reachable(grid, start)
	local filled = 0
	local looked = {}
	local function floodfill(x,y)
		if not looked[y] then
			looked[y] = {}
		end
		if looked[y][x] or not grid[y] or not grid[y][x] or grid[y][x] == 0 then
			return
		end

		filled = filled + 1
		looked[y][x] = true
		floodfill(x+1,y) floodfill(x-1,y)
		floodfill(x,y+1) floodfill(x,y-1)
	end
	floodfill(start.x, start.y)
	return filled
end

function Maze.carve(grid,w,h, start, exit)
	local function randomdirection()
		local dir = math.random()
		if     dir < .25 then -- up
			return vector(0,1)
		elseif dir < .5  then -- right
			return vector(1,0)
		elseif dir < .75 then -- down
			return vector(0,-1)
		else                  -- left
			return vector(-1,0)
		end
	end

	local function carve_valid(cell, dir)
		local ort = vector(dir.y, dir.x)

		-- a carve from the exit is always valid
		if grid[cell.y][cell.x] == 2 and
			grid[cell.y+dir.y] and grid[cell.y+dir.y][cell.x+dir.x] then
			return true
		end

		local tocheck = {vector(0,0), ort, -ort, dir, dir+ort, dir-ort}
		if math.random() > .8 then -- randomly allow loops
			tocheck = {vector(0,0), dir+ort, dir-ort}
		end
		for _,c in pairs(tocheck) do
			local t = cell + c
			if grid[t.y][t.x] ~= 0 and grid[t.y][t.x] ~= 2 then
				return false
			end
		end
		return true
	end

	local carved, reachable = 2, 0
	local function dig(cur, pre)
		local predir = pre - cur
		local dir, to
		repeat
			dir = randomdirection()
		until dir ~= predir
		to = cur + dir

		if to.x <= 1 or to.x >= w or to.y <= 1 or to.y >= h then
			return false, cur, pre
		end
		if not carve_valid(to, dir) then
			return false, cur, pre
		end

		grid[to.y][to.x] = 1
		carved = carved + 1
		return true, to, cur
	end

	local function carve(ok, cur, pre)
		if ok then
			for i = 1,3 do
				carve(dig(cur, pre))
			end
		end
	end

	carve(true, start, vector(0,0))
	carve(true, exit, vector(0,0))
	reachable = Maze.reachable(grid, exit)
	return carved == reachable
end

function Maze.new(w,h, seed)
	local seed = seed or os.time()
	math.randomseed(seed)

	local grid, exit, enter
	local iterations = 0
	repeat
		grid = Maze.initGrid(w,h)
		exit = Maze.randomexit(grid,w,h)

		local c = vector(w/2,h/2)
		local r = vector(w/5,h/5)
		local exitpostries = 0
		repeat
			enter = vector(math.random(c.x-r.x, c.x+r.x), math.random(c.y-r.y, c.y+r.y))
			exitpostries = exitpostries + 1
		until (enter-exit):len() > 10 or exitpostries > 10
		grid[enter.y][enter.x] = 1
		grid[exit.y][exit.x] = 2

		iterations = iterations + 1
		if iterations > 10 then
			error("Cannot generate maze. I tried. Sorry.")
		end

	until Maze.carve(grid,w,h, enter, exit)

	return grid, enter, exit
end
