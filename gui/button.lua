Button = {}
Button.__index = Button
Button.bgcolor       = Color.rgb(30,30,30, 120)
Button.bordercolor   = Color.rgb(80,80,80, 120)
Button.textcolor     = Color.rgb(255,255,255, 120)
Button.bgHovered     = Color.rgb(80,80,80, 120)
Button.borderHovered = Button.bordercolor * 1.5
Button.textHovered   = Color.rgb(255,255,255, 120)
Button.buttons = {}

local function __NULLFUNCTION__() end
local function __HOVER__() playsound(select_sound) end
function Button.new(text, center, size, onMouseEnter, onMouseLeave, onClick)
	assert(text,   "Buttons need text")
	assert(center, "Button '"..text.."' needs a center")
	assert(size,   "Button '"..text.."' needs a size")

	local btn = {text = text, pos = center - size/2, size = size, hovered = false, active = false}
	btn.font         = love.graphics.getFont()
	btn.onMouseEnter = onMouseEnter or __HOVER__
	btn.onMouseLeave = onMouseLeave or __NULLFUNCTION__
	btn.onClick      = onClick      or __NULLFUNCTION__

	btn.keyactions = {}
	btn.keyactions[keys.down] = function(self)
		if not self.active then return end
		if self.nextitem then
			self.nextitem.previtem = self
			self.active = false
			self.nextitem.active = true
		end
		return true
	end
	btn.keyactions[keys.up] = function(self)
		if not self.active then return end
		if self.previtem then
			self.previtem.nextitem = self
			self.active = false
			self.previtem.active = true
		end
		return true
	end
	btn.keyactions[keys.start] = function(self) self.onClick() end
	btn.keyactions.tab = btn.keyactions[keys.down]

	local tw, th = btn.font:getWidth(text), btn.font:getHeight(text)
	btn.textpos = center - vector(tw/2, -th/2+5)

	return setmetatable(btn, Button)
end

function Button.add(btn, ...)
	if not btn then return end
	Button.buttons[btn] = btn
	Button.add(...)
end

function Button.remove(btn, ...)
	if not btn then return end
	Button.buttons[btn] = nil
	Button.remove(...)
end

function Button.remove_all()
	Button.buttons = {}
end

function Button:draw()
	if self.hovered or self.active then
		Button.bgHovered:set()
	else
		Button.bgcolor:set()
	end
	love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.size:unpack())

	if self.hovered or self.active then
		Button.borderHovered:set()
	else
		Button.bordercolor:set()
	end
	love.graphics.rectangle('line', self.pos.x, self.pos.y, self.size:unpack())

	if self.hovered or self.active then
		Button.textHovered:set()
	else
		Button.textcolor:set()
	end
	love.graphics.print(self.text, self.textpos:unpack())
end

function Button:update(dt, mouse)
	local mouse = mouse or vector(love.mouse.getPosition())
	local mouseOverButton = mouse.x >= self.pos.x and mouse.x <= self.pos.x + self.size.x and
	                        mouse.y >= self.pos.y and mouse.y <= self.pos.y + self.size.y

	if not mouseOverButton then
		if self.hovered then
			self.hovered = false
			self:onMouseLeave()
		end
		return -- skip other tests when not hovered
	elseif mouseOverButton and not self.hovered then
		self:onMouseEnter()
	end
	self.hovered = true

	if self.clicked and not love.mouse.isDown('l') then -- mouse released
		self:onClick()
	end
	self.clicked = mouseOverButton and love.mouse.isDown('l')
end

function Button:onKeyPressed(key, unicode)
	if not self.active then return end

	if self.keyactions[key] then
		return self.keyactions[key](self, key, unicode)
	end
end

function Button.update_all(dt)
	local mouse = vector(love.mouse.getPosition())
	for _,btn in pairs(Button.buttons) do
		btn:update(dt, mouse)
	end
end

function Button.draw_all()
	for _,btn in pairs(Button.buttons) do
		btn:draw()
	end
end

function Button.handleKeyPressed(key, unicode)
	for _,btn in pairs(Button.buttons) do
		if btn:onKeyPressed(key, unicode) then return end
	end
end
