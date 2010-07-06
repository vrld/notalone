-- provide draw and update function for
-- things like love's Image
local gfxDrawWrapper = {}
gfxDrawWrapper.__index = gfxDrawWrapper
function gfxDrawWrapper:draw(x,y, ang, sx, sy, ox, oy)
	love.graphics.draw(self.obj, x, y, ang, sx, sy, ox, oy)
end
function gfxDrawWrapper:update() --[[ nothing --]] end

function wrapDraw(obj)
	return setmetatable({obj = obj}, gfxDrawWrapper)
end

local item = {}
item.__index = item
function item:draw(seen)
	if not seen or (seen and seen[self.pos.y] and seen[self.pos.y][self.pos.x]) then
		self.obj:draw(((self.pos - vector(1,1)) * TILESIZE):unpack())
	end
end
function item:update(dt)
	self.obj:update(dt)
end

Items = {}
local items = {} -- datatabse
function Items.add(drawable, pos)
	assert(drawable and pos, "dude!")
	local it = setmetatable({obj = drawable, pos = pos}, item)
	items[it] = pos
end

function Items.draw(seen)
	love.graphics.setColor(255,255,255)
	for it,_ in pairs(items) do
		it:draw(seen)
	end
end

function Items.update(dt)
	for it,_ in pairs(items) do
		it:update(dt)
	end
end

function Items.remove(item)
	items[item] = nil
end

function Items.clear()
	items = {}
end
