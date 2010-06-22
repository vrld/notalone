require "button"
require "color"

Dialog = {}
Dialog.__index = Dialog

Dialog.bgcolor     = Color.new(150,150,150, 230)
Dialog.bordercolor = Color.new(50,50,50)
Dialog.textcolor   = Color.new(50,50,50)

function Dialog.new(size)
	local dialog = {}
	local center = vector.new(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	dialog.size = size
	dialog.pos  = center - size/2
	return setmetatable(dialog, Dialog)
end

function Dialog:open()
	self.__draw = love.draw
	love.draw = function()
		self.__draw()
        love.graphics.setColor(0,0,0,100)
        love.graphics.rectangle('fill', 0,0, love.graphics.getWidth(), love.graphics.getHeight())

        Dialog.bgcolor:set()
        love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.size:unpack())
        Dialog.bordercolor:set()
        love.graphics.rectangle('line', self.pos.x, self.pos.y, self.size:unpack())
		self:draw()
	end

	self.__update = love.update
	love.update = function(dt)
        self:update(dt)
	end

    return self.enter and self:enter()
end

function Dialog:close()
	love.draw = self.__draw
	self.__draw = nil

	love.update = self.__update
	self.__update = nil

    return self.leave and self:leave()
end
