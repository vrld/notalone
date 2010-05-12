player = {
    age         = 0,
    lifespan    = 30,
    startpos    = vector.new(0,0),
    pos         = vector.new(0,0),
    dir         = vector.new(1,0),
    seen        = {},
    zoom        = 10,
    visibility_range = 3,
    carried     = nil,
    sprite      = nil,
    keydelay    = 0,
	path_decal  = love.image.newImageData(30,30),
    ref_level   = nil
}
function player.init(level, start, lifespan)
    player.ref_level = level
    assert(start, "start position must be supplied")
    player.startpos = start:clone()
    player.lifespan = lifespan or 45

    -- TODO: nicer sprite
    for x=0,29 do
        for y=0,29 do
            player.path_decal:setPixel(x,y, 100,0,0,255)
        end
    end

    player.reset()
    player.update_seen()
end

function player.reset()
    player.pos = player.startpos:clone()
    player.age = 0
    player.zoom = 10
end

function player.pixelpos()
    return player.pos * 32 + vector.new(16,16)
end

function player.draw()
	love.graphics.setColor(0,180,60)
	love.graphics.rectangle('fill', player.pos.x*32, player.pos.y*32, 32, 32)
end

function player.update(dt)
    player.age = player.age + dt
    if player.age > player.lifespan then
        player.reset()
    end

    if player.keydelay <= 0 then
        local pospre = player.pos:clone()
        if love.keyboard.isDown('up') then
            player.dir = vector.new(0,-1)
        elseif love.keyboard.isDown('down') then
            player.dir = vector.new(0,1)
        elseif love.keyboard.isDown('left') then
            player.dir = vector.new(-1,0)
        elseif love.keyboard.isDown('right') then
            player.dir = vector.new(1,0)
        else
            return
        end
        player.pos = player.pos + player.dir
        if player.ref_level[player.pos.y][player.pos.x] == 0 then
            player.pos = pospre
        end
        Decals.add(player.path_decal, 45, pospre*32 + vector.new(16,16))
        player.keydelay = .2
        player.update_seen()
        player.zoom = math.max(math.min(10 - (player.pos - player.startpos):len(), player.zoom), 1)
    else
        player.keydelay = player.keydelay - dt
    end
end

function player.update_seen()
    -- TODO: refactor (metatables)
	for x=-1,1 do
		for y=-1,1 do
			if player.seen[player.pos.y+y] then
				player.seen[player.pos.y+y][player.pos.x+x] = true
            else
                player.seen[player.pos.y+y] = {[player.pos.x+x] = true}
			end
		end
	end
    local tmp = player.pos + player.dir
    local fields = 1
    while player.ref_level[tmp.y] and player.ref_level[tmp.y][tmp.x] ~= 0 and fields < player.visibility_range do
        if not player.seen[tmp.y] then player.seen[tmp.y] = {} end
        player.seen[tmp.y][tmp.x] = true
        tmp = tmp + player.dir
        fields = fields + 1
    end
    if not player.seen[tmp.y] then player.seen[tmp.y] = {} end
    player.seen[tmp.y][tmp.x] = true
end

function player.has_seen(x,y)
    if not player.seen[y] then
        return false
    end
    return player.seen[y][x]
end
