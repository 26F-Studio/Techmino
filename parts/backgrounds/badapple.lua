--Bad Apple!!
local gc=love.graphics
local back={}

local video
local X,Y,K
function back.init()
	if not video then
		video=gc.newVideo("parts/backgrounds/badapple.ogv",{false})
		video:setFilter('linear','linear')
		video:play()
	end
	back.resize()
end
function back.update()
	if not video:isPlaying()then
		video:seek(0)
	end
end
function back.resize()
	local W,H=SCR.w,SCR.h
	if H/W>=36/48 then
		K=W/48
		X,Y=0,(H-W*36/48)*.5
	else
		K=H/36
		X,Y=(W-H*48/36)*.5,0
	end
end
function back.draw()
	gc.clear(.2,.2,.2)
	local r,g,b=COLOR.rainbow_light(TIME())
	gc.setColor(r,g,b,.2)
	gc.draw(video,X,Y,nil,K)
end
function back.discard()
	video=nil
end
return back