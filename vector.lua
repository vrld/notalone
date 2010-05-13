vector = {}
vector.__index = vector

function vector.new(x,y)
	local v = {x = x or 0, y = y or 0}
	setmetatable(v, vector)
	return v
end

function vector:unpack()
	return self.x, self.y
end

function vector:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..")"
end

function vector.__unm(a)
	return vector.new(-a.x, -a.y)
end

function vector.__add(a,b)
	return vector.new(a.x+b.x, a.y+b.y)
end

function vector.__sub(a,b)
	return vector.new(a.x-b.x, a.y-b.y)
end

function vector.__mul(a,b)
	if type(a) == "number" then 
		return vector.new(a*b.x, a*b.y)
	elseif type(b) == "number" then
		return vector.new(b*a.x, b*a.y)
	else
		return a.x*b.x + a.y*b.y
	end
end

function vector.__div(a,b)
	if type(b) ~= "number" then
		error("cannot divide vector by vector.") 
	end
	return vector.new(a.x / b, a.y / b)
end

function vector.__eq(a,b)
	return a.x == b.x and a.y == b.y
end

function vector.__lt(a,b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function vector.__le(a,b)
	return a.x <= b.x and a.y <= b.y
end

function vector.len2(a)
	return a*a
end

function vector.len(a)
	return math.sqrt(a*a)
end

function vector.normalize_inplace(a)
	local l =  vector.len(a)
	a.x = a.x / l
	a.y = a.y / l
	return a
end

function vector.normalized(a)
	return a / vector.len(a)
end

function vector.dist(a, b)
	return vector.len(b-a)
end

function vector.clone(a)
	return vector.new(a.x, a.y)
end
