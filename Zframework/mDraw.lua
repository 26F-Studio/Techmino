local printf=love.graphics.printf
local draw=love.graphics.draw
local mDraw={}
function mDraw.str(str,x,y)
	printf(str,x-626,y,1252,"center")
end
function mDraw.simpX(str,x,y)
	draw(str,x-str:getWidth()*.5,y)
end
function mDraw.simpY(str,x,y)
	draw(str,x,y-str:getHeight()*.5)
end
function mDraw.X(str,x,y,a,k)
	draw(str,x,y,a,k,nil,str:getWidth()*.5,0)
end
function mDraw.Y(str,x,y,a,k)
	draw(str,x,y,a,k,nil,0,str:getHeight()*.5)
end
function mDraw.draw(str,x,y,a,k)
	draw(str,x,y,a,k,nil,str:getWidth()*.5,str:getHeight()*.5)
end
return mDraw