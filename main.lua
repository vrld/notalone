require "camera"
require "decals"

level = {
--   1       5         10        15        20
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- 1
	{0,1,1,1,1,0,1,0,0,1,1,1,0,1,1,1,1,1,1,0},
	{0,1,0,0,1,0,1,0,0,1,0,0,0,0,1,0,0,0,1,0},
	{0,1,0,0,1,0,1,1,1,1,0,1,1,1,1,0,1,0,1,0},
	{0,1,1,0,1,1,1,0,0,1,0,1,0,0,1,0,1,0,1,0}, -- 5
	{0,1,0,0,0,0,1,0,0,1,1,1,0,1,1,0,1,1,1,0},
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

seen = {}
for i,_ in ipairs(level) do
	seen[i] = {}
end

player = vector.new(7,9)
function update_seen(pos, dir)
	for x=-1,1 do
		for y=-1,1 do
			if seen[pos.y+y] then
				seen[pos.y+y][pos.x+x] = true
			end
		end
	end
end
update_seen(player)
max = vector.new(0,0)
newzoom = 10

images = {walls = {}}
function love.load()
	camera = Camera.new(player*44+vector.new(-15,8),1)
	love.graphics.setBackgroundColor(20,0,0)
	decal = love.image.newImageData(30,30)
	for x=0,29 do
		for y=0,29 do
			decal:setPixel(x,y, 100,0,0,255)
		end
	end

	images.ground = love.graphics.newImage('images/ground0.png')
	images.ground1 = love.graphics.newImage('images/ground1.png')
	for _,d in ipairs{'NESW', 'NEW', 'NSW', 'ESW', 'NES', 'EW', 'NS', 'ES', 'NE', 'NW', 'SW', 'E', 'N', 'S', 'W'} do
		images.walls[d] = love.graphics.newImage('images/wall'..d..'.png')
	end
	images.walls[''] = love.graphics.newImage('images/wall.png')
end

function love.draw()
	camera:predraw()
	love.graphics.setColor(255,255,255)
	for y=1,#level do
		for x=1,#level[y] do
			if seen[y][x] then
				if level[y][x] == 1 then
					love.graphics.draw(images.ground, x*32, y*32, 0)
				elseif level[y][x] == 2 then
					love.graphics.setColor(255,180,100)
					love.graphics.draw(images.ground1, x*32, y*32, 0)
					love.graphics.setColor(255,255,255)
				else
					local which = ''
					if y == 1 or level[y-1][x] ~= 0      then which = which..'N' end
					if level[y][x+1] ~= 0                then which = which..'E' end
					if y == #level or level[y+1][x] ~= 0 then which = which..'S' end
					if level[y][x-1] ~= 0                then which = which..'W' end
					love.graphics.draw(images.walls[which], x*32, y*32, 0)
				end
			end
		end
	end
	Decals.draw()
	love.graphics.setColor(0,180,60)
	love.graphics.rectangle('fill', player.x*32, player.y*32, 32, 32)
	camera:postdraw()
	love.graphics.print('len: ' .. tostring(max:len()), 10,10)
end

function love.update(dt)
	Decals.update(dt)
	camera.pos = camera.pos - (camera.pos - player*32 + vector.new(-16,-16)) * dt * 5
	newzoom = math.max(9 - max:len(), .75)
	camera.zoom = camera.zoom - (camera.zoom - newzoom) * dt

	if level[player.y][player.x] == 2 then
		player = vector.new(7,9)
		max = vector.new(0,0)
	end
end

function love.keyreleased(key)
	if key == 'left' and level[player.y][player.x-1] >= 1 then
		player.x = player.x - 1
	elseif key == 'right' and level[player.y][player.x+1] >= 1 then
		player.x = player.x + 1
	elseif key == 'up' and level[player.y-1][player.x] >= 1 then
		player.y = player.y - 1
	elseif key == 'down' and level[player.y+1][player.x] >= 1 then
		player.y = player.y + 1
	else
		return
	end
	Decals.add(decal, 45,player*32+vector.new(16,16))
	update_seen(player)

	max.x = math.max(math.abs(player.x - 7), max.x)
	max.y = math.max(math.abs(player.y - 9), max.y)
end
