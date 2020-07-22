local gc=love.graphics
local int=math.floor
local format=string.format

local fontData=love.filesystem.newFile("font.ttf")
local newFont=gc.setNewFont
local setNewFont=gc.setFont
local fontCache,currentFontSize={}
function setFont(s)
	local f=fontCache[s]
	if s~=currentFontSize then
		if f then
			setNewFont(f)
		else
			f=newFont(fontData,s)
			fontCache[s]=f
			setNewFont(f)
		end
		currentFontSize=s
	end
	return f
end

function toTime(s)
	if s<60 then
		return format("%.3fs",s)
	elseif s<3600 then
		return format("%d:%.2f",int(s/60),s%60)
	else
		local h=int(s/3600)
		return format("%d:%d:%.2f",h,int(s/60%60),s%60)
	end
end
function mStr(s,x,y)
	gc.printf(s,x-450,y,900,"center")
end
function mText(s,x,y)
	gc.draw(s,x-s:getWidth()*.5,y)
end
function mDraw(s,x,y,a,k)
	gc.draw(s,x,y,a,k,nil,s:getWidth()*.5,s:getHeight()*.5)
end