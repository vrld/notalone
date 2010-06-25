Color = {}
Color.__index = Color

function Color.rgb(r,g,b,a)
	assert(r and g and b, "Need to specify r, g and b of color!")
	return setmetatable({r=r,g=g,b=b,a=a or 255}, Color)
end

function Color.hsv(h,s,v,a)
	assert(h and s and v, "Need to specify h, s and v of color!")
    local H = h/60 
    local Hi = math.floor(H)
    local f = H - Hi
    local p,q,t = v * (1 - s), v * (1 - s*f), v * (1 - s*(1-f))

    if     Hi == 5 then
        return Color.rgb(v * 255, p * 255, q * 255, a)
    elseif Hi == 4 then
        return Color.rgb(t * 255, p * 255, v * 255, a)
    elseif Hi == 3 then
        return Color.rgb(p * 255, q * 255, v * 255, a)
    elseif Hi == 2 then
        return Color.rgb(p * 255, v * 255, t * 255, a)
    elseif Hi == 1 then
        return Color.rgb(q * 255, v * 255, p * 255, a)
    else -- 0 or 6
        return Color.rgb(v * 255, t * 255, p * 255, a)
    end
end

function Color:set()
	love.graphics.setColor(self.r, self.g, self.b, self.a)
end

function Color.__add(a, b)
	assert(getmetatable(a) == getmetatable(b), "`+' only defined for two Colors")
	return Color.rgb(math.min(a.r + b.r, 255),
					 math.min(a.g + b.g, 255),
					 math.min(a.b + b.g, 255),
					 math.min(a.a + b.a, 255))
end

function Color.__sub(a, b)
	assert(getmetatable(a) == getmetatable(b), "`-' only defined for two Colors")
	return Color.rgb(math.max(a.r - b.r, 0),
					 math.max(a.g - b.g, 0),
					 math.max(a.b - b.g, 0),
					 math.max(a.a - b.a, 0))
end

function Color.__mul(a, b)
	if type(b) == "number" then
		return Color.rgb(math.min(a.r * b, 255),
						 math.min(a.g * b, 255),
						 math.min(a.b * b, 255),
						 math.min(a.a * b, 255))
	 elseif type(a) == "number" then
		 return b * a
	 elseif getmetatable(a) == getmetatable(b) then
		return Color.rgb(math.min(a.r * b.r, 255),
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
