local Vector = {}
Vector.__index = Vector

function vector(x,y)
	local v = {x = x or 0, y = y or 0}
	setmetatable(v, Vector)
	return v
end

function Vector:unpack()
	return self.x, self.y
end

function Vector:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..")"
end

function Vector.__unm(a)
	return vector(-a.x, -a.y)
end

function Vector.__add(a,b)
	return vector(a.x+b.x, a.y+b.y)
end

function Vector.__sub(a,b)
	return vector(a.x-b.x, a.y-b.y)
end

function Vector.__mul(a,b)
	if type(a) == "number" then 
		return vector(a*b.x, a*b.y)
	elseif type(b) == "number" then
		return vector(b*a.x, b*a.y)
	else
		return a.x*b.x + a.y*b.y
	end
end

function Vector.__div(a,b)
	if type(b) ~= "number" then
		error("cannot divide Vector by Vector.") 
	end
	return vector(a.x / b, a.y / b)
end

function Vector.__eq(a,b)
	return a.x == b.x and a.y == b.y
end

function Vector.__lt(a,b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Vector.__le(a,b)
	return a.x <= b.x and a.y <= b.y
end

function Vector.len2(a)
	return a*a
end

function Vector.len(a)
	return math.sqrt(a*a)
end

function Vector.normalize_inplace(a)
	local l =  Vector.len(a)
	a.x = a.x / l
	a.y = a.y / l
	return a
end

function Vector.normalized(a)
	return a / Vector.len(a)
end

function Vector.dist(a, b)
	return Vector.len(b-a)
end

function Vector.clone(a)
	return vector(a.x, a.y)
end
