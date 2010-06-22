require "vector"
require "color"

Input = {}
Input.__index      = Input
Input.bgcolor      = Color.new(150,150,150)
Input.bordercolor  = Color.new(50,50,50)
Input.textcolor    = Color.new(50,50,50)
Input.bgActive     = Input.bgcolor * 1.5
Input.borderActive = Input.bordercolor * 1.5
Input.textActive   = Input.bordercolor * 1.5
Input.fields = {}

local function __NULLFUNCTION__() end
function Input.new(center, size, accept, font)
	assert(center, "Input needs a center")
	assert(size,   "Input needs a size")

	local inp = {
		text    = "",
		center  = center,
		textpos = center,
		pos     = center - size/2,
		size    = size,
		font    = font or love.graphics.getFont(),
		accept  = accept or "[^\n\t]",
		active  = false}

	inp = setmetatable(inp, Input)
	Input.fields[inp] = inp
	return inp
end

function Input.add(inp, ...)
	if not inp then return end
	Input.fields[inp] = inp
	Input.add(...)
end

function Input.remove(inp, ...)
	if not inp then return end
	Input.fields[inp] = nil
	Input.remove(...)
end

function Input.remove_all()
	Input.fields = {}
end

function Input:draw()
	love.graphics.setFont(self.font)
	if self.active then
		Input.bgActive:set()
	else
		Input.bgcolor:set()
	end
	love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.size:unpack())

	if self.active then
		Input.borderActive:set()
	else
		Input.bordercolor:set()
	end
	love.graphics.rectangle('line', self.pos.x, self.pos.y, self.size:unpack())

	if self.active then
		Input.textActive:set()
	else
		Input.textcolor:set()
	end
	love.graphics.print(self.text, self.textpos:unpack())
end

function Input:update(dt, down, mouse)
	local down = down or love.mouse.isDown('l')
end

function Input:onMouseDown(x,y,btn)
	if btn ~= 'l' then return end
	self.active = x >= self.pos.x and x <= self.pos.x + self.size.x and
	              y >= self.pos.y and y <= self.pos.y + self.size.y
	return self.active
end

function Input:onKeyPressed(unicode)
	if not self.active then return false end

	if unicode == 8 then -- backspace
		self.text = self.text:sub(1,-2)
	else
		local char = string.char(unicode):match(self.accept)
		if not char then return end
		self.text = self.text .. char
	end

	local tw, th = self.font:getWidth(self.text), self.font:getHeight(self.text)
	self.textpos = self.center - vector.new(tw/2, th)
end

function Input.handleMouseDown(x,y,btn)
	if btn ~= 'l' then return end
	for _,inp in pairs(Input.fields) do
		inp:onMouseDown(x,y,btn)
	end
end

function Input.handleKeyPressed(unicode)
	for _,inp in pairs(Input.fields) do
		inp:onKeyPressed(unicode)
	end
end

function Input.draw_all()
	for _,inp in pairs(Input.fields) do
		inp:draw()
	end
end
