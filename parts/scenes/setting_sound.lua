local gc=love.graphics
local Timer=love.timer.getTime

local sin=math.sin
local rnd=math.random

function sceneInit.setting_sound()
	sceneTemp={
		last=0,--Last sound time
		jump=0,--Animation timer(10 to 0)
	}
	BG.set("space")
end
function sceneBack.setting_sound()
	FILE.saveSetting()
end

function mouseDown.setting_sound(x,y)
	local S=sceneTemp
	if x>780 and x<980 and y>470 and S.jump==0 then
		S.jump=10
		local t=Timer()-S.last
		if t>1 then
			VOC.play((t<1.5 or t>15)and"doubt"or rnd()<.8 and"happy"or"egg")
			S.last=Timer()
		end
	end
end
function touchDown.setting_sound(_,x,y)
	mouseDown.setting_sound(x,y)
end

function Tmr.setting_sound()
	local t=sceneTemp.jump
	if t>0 then
		sceneTemp.jump=t-1
	end
end

function Pnt.setting_sound()
	gc.setColor(1,1,1)
	local t=Timer()
	local _=sceneTemp.jump
	local x,y=800,340+10*sin(t*.5)+(_-10)*_*.3
	gc.translate(x,y)
	gc.draw(IMG.miyaCH,0,0)
	gc.setColor(1,1,1,.7)
	gc.draw(IMG.miyaF1,4,47+4*sin(t*.9))
	gc.draw(IMG.miyaF2,42,107+5*sin(t))
	gc.draw(IMG.miyaF3,93,126+3*sin(t*.7))
	gc.draw(IMG.miyaF4,129,98+3*sin(t*.7))
	gc.translate(-x,-y)
end