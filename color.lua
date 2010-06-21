Color = {}
Color.__index = Color

function Color.new(r,g,b,a)
	assert(r and g and b, "Need to specify r, g and b of color!")
	return setmetatable({r=r,g=g,b=b,a=a or 255}, Color)
end

function Color:set()
	love.graphics.setColor(self.r, self.g, self.b, self.a)
end

function Color.__add(a, b)
	assert(getmetatable(a) == getmetatable(b), "`+' only defined for two Colors")
	return Color.new(math.min(a.r + b.r, 255),
					 math.min(a.g + b.g, 255),
					 math.min(a.b + b.g, 255),
					 math.min(a.a + b.a, 255))
end

function Color.__sub(a, b)
	assert(getmetatable(a) == getmetatable(b), "`-' only defined for two Colors")
	return Color.new(math.max(a.r - b.r, 0),
					 math.max(a.g - b.g, 0),
					 math.max(a.b - b.g, 0),
					 math.max(a.a - b.a, 0))
end

function Color.__mul(a, b)
	if type(b) == "number" then
		return Color.new(math.min(a.r * b, 255),
						 math.min(a.g * b, 255),
						 math.min(a.b * b, 255),
						 math.min(a.a * b, 255))
	 elseif type(a) == "number" then
		 return b * a
	 elseif getmetatable(a) == getmetatable(b) then
		return Color.new(math.min(a.r * b.r, 255),
						 math.min(a.g * b.g, 255),
						 math.min(a.b * b.b, 255),
						 math.min(a.a * b.a, 255))
	 else
		 error("`*' not defined for whatever you tried")
	 end
end

function Color.__tostring(a)
	return string.format("color(r=%d,g=%d,b=%d,a=%d)", a.r, a.g, a.b, a.a)
end
