require "camera"
require "decals"
require "player"

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

images = {walls = {}}
function love.load()
	camera = Camera.new(player.pixelpos(),1)
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

    player.init(level, vector.new(7,9), 30)
end

function love.draw()
	camera:predraw()
	love.graphics.setColor(255,255,255)
	for y=1,#level do
		for x=1,#level[y] do
			if player.has_seen(x,y) then
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
    player.draw()
	camera:postdraw()

    local frac = 1 - player.age / player.lifespan
    local barwith = love.graphics.getWidth() - 20
    love.graphics.setColor(255,255,255,100)
    love.graphics.rectangle('fill', 10, 10, barwith, 7)
    love.graphics.setColor(255,255,255)
    love.graphics.rectangle('fill', 10, 10, frac*barwith, 7)
end

function love.update(dt)
	Decals.update(dt)
	camera.pos = camera.pos - (camera.pos - player.pixelpos()) * dt * 5
	camera.zoom = camera.zoom - (camera.zoom - player.zoom) * dt

    player.update(dt, level)

	if level[player.pos.y][player.pos.x] == 2 then
        -- TODO: fade
		player.reset()
	end
end
