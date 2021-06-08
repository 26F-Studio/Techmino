local printf=love.graphics.printf
local draw=love.graphics.draw
local aDraw={}
function aDraw.str(obj,x,y)printf(obj,x-626,y,1252,'center')end
function aDraw.simpX(obj,x,y)draw(obj,x-obj:getWidth()*.5,y)end
function aDraw.simpY(obj,x,y)draw(obj,x,y-obj:getHeight()*.5)end
function aDraw.X(obj,x,y,a,k)draw(obj,x,y,a,k,nil,obj:getWidth()*.5,0)end
function aDraw.Y(obj,x,y,a,k)draw(obj,x,y,a,k,nil,0,obj:getHeight()*.5)end
function aDraw.draw(obj,x,y,a,k)draw(obj,x,y,a,k,nil,obj:getWidth()*.5,obj:getHeight()*.5)end
function aDraw.outDraw(obj,div,x,y,a,k)
	local w,h=obj:getWidth()*.5,obj:getHeight()*.5
	draw(obj,x-div,y-div,a,k,nil,w,h)
	draw(obj,x-div,y+div,a,k,nil,w,h)
	draw(obj,x+div,y-div,a,k,nil,w,h)
	draw(obj,x+div,y+div,a,k,nil,w,h)
end
return aDraw