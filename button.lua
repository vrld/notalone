require "vector"
require "color"

Button = {}
Button.__index = Button
Button.bgcolor       = Color.new(150,150,150)
Button.bordercolor   = Color.new(50,50,50)
Button.textcolor     = Color.new(50,50,50)
Button.bgHovered     = Button.bgcolor * 1.5
Button.borderHovered = Button.bordercolor * 1.5
Button.textHovered   = Button.bordercolor * 1.5
Button.buttons = {}

local function __NULLFUNCTION__() end
function Button.new(text, center, size, font, onMouseEnter, onMouseLeave, onClick)
	assert(text,   "Buttons need text")
	assert(center, "Button '"..text.."' needs a center")
	assert(size,   "Button '"..text.."' needs a size")

	local btn = {text = text, pos = center - size/2, size = size, hovered = false}
	btn.font         = font or love.graphics.getFont()
	btn.onMouseEnter = onMouseEnter or __NULLFUNCTION__
	btn.onMouseLeave = onMouseLeave or __NULLFUNCTION__
	btn.onClick      = onClick      or __NULLFUNCTION__

	local tw, th = btn.font:getWidth(text), btn.font:getHeight(text)
	btn.textpos = center - vector.new(tw/2, th)

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
	love.graphics.setFont(self.font)
	if self.hovered then
		Button.bgHovered:set()
	else
		Button.bgcolor:set()
	end
	love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.size:unpack())

	if self.hovered then
		Button.borderHovered:set()
	else
		Button.bordercolor:set()
	end
	love.graphics.rectangle('line', self.pos.x, self.pos.y, self.size:unpack())

	if self.hovered then
		Button.textHovered:set()
	else
		Button.textcolor:set()
	end
	love.graphics.print(self.text, self.textpos:unpack())
end

function Button:update(dt, mouse)
	local mouse = mouse or vector.new(love.mouse.getPosition())
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

function Button.update_all(dt)
	local mouse = vector.new(love.mouse.getPosition())
	for _,btn in pairs(Button.buttons) do
		btn:update(dt, mouse)
	end
end

function Button.draw_all()
	for _,btn in pairs(Button.buttons) do
		btn:draw()
	end
end
