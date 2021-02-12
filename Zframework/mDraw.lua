local gc=love.graphics
function mStr(s,x,y)
	gc.printf(s,x-626,y,1252,"center")
end
function mText(s,x,y)
	gc.draw(s,x-s:getWidth()*.5,y)
end
function mDraw(s,x,y,a,k)
	gc.draw(s,x,y,a,k,nil,s:getWidth()*.5,s:getHeight()*.5)
end