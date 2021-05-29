--Blackhole
local gc=love.graphics
local gc_push,gc_pop,gc_clear,gc_origin=gc.push,gc.pop,gc.clear,gc.origin
local gc_translate,gc_scale=gc.translate,gc.scale
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_circle=gc.draw,gc.circle

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
	gc_clear(.1,.1,.1)
	gc_push('transform')
	gc_origin()
	gc_translate(SCR.cx,SCR.cy)

	--Squares
	gc_setColor(1,1,1,.2)
	for i=1,#squares do
		local S=squares[i]
		gc_draw(S.texture,S.d*cos(S.ang),S.d*sin(S.ang),S.rotate,S.size*.026,nil,15,15)
	end

	--Blackhole
	gc_scale(SCR.rad/1600)
	gc_setColor(.07,.07,.07)
	gc_circle('fill',0,0,157)
	gc_setLineWidth(6)
	for i=0,15 do
		gc_setColor(.07,.07,.07,1-i*.0666)
		gc_circle('line',0,0,160+6*i)
	end
	gc_scale(1600/SCR.rad)
	gc_pop()
end
function back.discard()
	squares=nil
end
return back