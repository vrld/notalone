require "camera"
require "decals"
require "player"
require "level"

level = Level.new{
--   1       5         10        15        20
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- 1
	{0,1,1,1,1,0,1,0,0,1,1,1,0,1,1,1,1,1,1,0},
	{0,1,0,0,1,0,1,0,0,1,0,0,0,0,1,0,0,0,1,0},
	{0,1,0,0,1,0,1,1,3,1,0,1,1,1,1,0,1,0,1,0},
	{0,1,1,0,1,1,1,0,0,1,0,1,0,0,1,0,1,0,1,0}, -- 5
	{0,1,0,0,0,0,1,0,0,1,1,1,0,3,1,0,1,1,1,0},
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
TILESIZE = 32

function love.load()
	camera = Camera.new(player.pixelpos(),1)
	love.graphics.setBackgroundColor(20,0,0)
	Level.init()
	player.init(level.grid, vector.new(7,9), 30)

	img = love.graphics.newImage(level:render())
	level:updateFog(player.pos, vector.new(0,0),1)
end

function love.draw()
	camera:predraw()
	level:draw()
	Decals.draw()
	player.draw()
	camera:postdraw()

	local frac = 1 - player.age / player.lifespan
	local barwith = love.graphics.getWidth() - 20
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle('fill', 10, 10, barwith, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', 10, 10, frac*barwith, 7)

	love.graphics.setColor(255,255,255,180)
	love.graphics.draw(img, 600,400,0,.3,.3)
end

function love.update(dt)
	Decals.update(dt)
	camera.pos = camera.pos - (camera.pos - player.pixelpos()) * dt * 5
	camera.zoom = camera.zoom - (camera.zoom - player.zoom) * dt

	player.update(dt, level)
	-- TODO: refactor, fade
	if level.grid[player.pos.y][player.pos.x] == 2 then
		player.reset()
	end
end
