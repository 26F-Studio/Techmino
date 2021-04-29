--Blackhole
local gc=love.graphics
local sin,cos=math.sin,math.cos
local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local t
local squares
function back.init()
	t=26
	squares={}
end
function back.update()
	t=t-1
	if t==0 then
		local S={
			ang=6.2832*rnd(),
			d=SCR.rad*1.05/2,
			rotate=6.2832*rnd(),
			va=.05-rnd()*.1,
			size=SCR.rad*(2+rnd()*3)/100,
			texture=SKIN.curText[rnd(16)],
		}
		ins(squares,S)
		t=rnd(6,12)
	end
	for i=#squares,1,-1 do
		local S=squares[i]
		S.d=S.d-SCR.rad/(S.d+60)
		if S.d>0 then
			S.ang=S.ang+.008
			S.rotate=S.rotate+S.va
		else
			rem(squares,i)
		end
	end
end
function back.draw()
	gc.clear(.1,.1,.1)
	gc.push('transform')
	gc.origin()
	gc.translate(SCR.w/2,SCR.h/2)

	--Squares
	gc.setColor(.5,.5,.5)
	for i=1,#squares do
		local S=squares[i]
		gc.draw(S.texture,S.d*cos(S.ang),S.d*sin(S.ang),S.rotate,S.size*.026,nil,15,15)
	end

	--Blackhole
	gc.scale(SCR.rad/1600)
	gc.setColor(0,0,0)
	gc.circle('fill',0,0,157)
	gc.setLineWidth(6)
	for i=0,15 do
		gc.setColor(0,0,0,1-i*.0666)
		gc.circle('line',0,0,160+6*i)
	end
	gc.scale(1600/SCR.rad)
	gc.pop()
end
function back.discard()
	squares=nil
end
return back