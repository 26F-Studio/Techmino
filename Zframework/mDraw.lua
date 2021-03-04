local printf=love.graphics.printf
local draw=love.graphics.draw
function mStr(s,x,y)
	printf(s,x-626,y,1252,"center")
end
function mText(s,x,y)
	draw(s,x-s:getWidth()*.5,y)
end
function mDraw(s,x,y,a,k)
	draw(s,x,y,a,k,nil,s:getWidth()*.5,s:getHeight()*.5)
end