Input = {}
Input.__index      = Input
Input.bgcolor      = Color.rgb(30,30,30, 120)
Input.bordercolor  = Color.rgb(80,80,80, 120)
Input.textcolor    = Color.rgb(255,255,255, 120)
Input.bgActive     = Color.rgb(80,80,80, 120)
Input.borderActive = Button.bordercolor * 1.5
Input.textActive   = Color.rgb(255,255,255, 120)
Input.fields = {}

local function __NULLFUNCTION__() end
function Input.new(center, size, accept)
	assert(center, "Input needs a center")
	assert(size,   "Input needs a size")

	local inp = {
		text    = "",
		center  = center,
		textpos = center - vector(0,20),
		pos     = center - size/2,
		size    = size,
		font    = love.graphics.getFont(),
		accept  = accept or "[^\n\t]",
		active  = false,
		keyactions = {}
	}
	function inp.keyactions.backspace(self)
		self.text = self.text:sub(1,-2)
	end
	function inp.keyactions.tab(self)
		if self.nextitem then
			self.active = false
			self.nextitem.active = true
		end
	end
	inp.keyactions["return"] = inp.keyactions.tab
	inp.keyactions.kpenter = inp.keyactions.tab

	inp = setmetatable(inp, Input)
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

	if self.active and self.text:len() > 0 then
		love.graphics.print(self.text .. "_", self.textpos:unpack())
	else
		love.graphics.print(self.text, self.textpos:unpack())
	end
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

function Input:onKeyPressed(key, unicode)
	if not self.active then return end

	if self.keyactions[key] then
		self.keyactions[key](self, key, unicode)
	else
		local char = string.char(unicode):match(self.accept)
		if not char then return end
		self.text = self.text .. char
	end

	self:centerText()
	return true
end

function Input:centerText()
	if not self.font then return end
	local tw, th = self.font:getWidth(self.text), self.font:getHeight(self.text)
	self.textpos = self.center - vector(tw/2, -10)
end

function Input.handleMouseDown(x,y,btn)
	if btn ~= 'l' then return end
	for _,inp in pairs(Input.fields) do
		inp:onMouseDown(x,y,btn)
	end
end

function Input.handleKeyPressed(key, unicode)
	for _,inp in pairs(Input.fields) do
		if inp:onKeyPressed(key, unicode) then return end
	end
end

function Input.draw_all()
	for _,inp in pairs(Input.fields) do
		inp:draw()
	end
end
