--Fast lightning + spining tetromino
local gc=love.graphics
local int,rnd=math.floor,math.random
local back={}

local t
local colorLib
local blocks
local scs
function back.init()
	colorLib=SKIN.libColor
	blocks=BLOCKS
	scs=spinCenters
	t=rnd()*2600
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	local R=7-int(t*.5%7)
	local T=1.2-t%10%3%1.2
	if T<.3 then gc.clear(T,T,T)
	else gc.clear(0,0,0)
	end
	local _=colorLib[SETTING.skin[R]]
	gc.setColor(_[1],_[2],_[3],.12)
	gc.draw(TEXTURE.miniBlock[R],SCR.w/2,SCR.h/2,t%3.1416*6,400*SCR.k,nil,scs[R][0][2]+.5,#blocks[R][0]-scs[R][0][1]-.5)
end
return back