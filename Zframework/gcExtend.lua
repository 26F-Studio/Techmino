local setColor=love.graphics.setColor
local printf=love.graphics.printf
local draw=love.graphics.draw
local GC={}
function GC.str(obj,x,y)printf(obj,x-626,y,1252,'center')end
function GC.simpX(obj,x,y)draw(obj,x-obj:getWidth()*.5,y)end
function GC.simpY(obj,x,y)draw(obj,x,y-obj:getHeight()*.5)end
function GC.X(obj,x,y,a,k)draw(obj,x,y,a,k,nil,obj:getWidth()*.5,0)end
function GC.Y(obj,x,y,a,k)draw(obj,x,y,a,k,nil,0,obj:getHeight()*.5)end
function GC.draw(obj,x,y,a,k)draw(obj,x,y,a,k,nil,obj:getWidth()*.5,obj:getHeight()*.5)end
function GC.outDraw(obj,div,x,y,a,k)
	local w,h=obj:getWidth()*.5,obj:getHeight()*.5
	draw(obj,x-div,y-div,a,k,nil,w,h)
	draw(obj,x-div,y+div,a,k,nil,w,h)
	draw(obj,x+div,y-div,a,k,nil,w,h)
	draw(obj,x+div,y+div,a,k,nil,w,h)
end
function GC.shadedPrint(str,x,y,mode,d,clr1,clr2)
	local w=1280
	if mode=='center'then
		x=x-w*.5
	elseif mode=='right'then
		x=x-w
	end
	if not d then d=1 end
	setColor(clr1 or COLOR.D)
	printf(str,x-d,y-d,w,mode)
	printf(str,x-d,y+d,w,mode)
	printf(str,x+d,y-d,w,mode)
	printf(str,x+d,y+d,w,mode)
	setColor(clr2 or COLOR.Z)
	printf(str,x,y,w,mode)
end
return GC