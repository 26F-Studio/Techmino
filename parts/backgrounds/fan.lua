--UUZ's fan
local gc=love.graphics
local rnd=math.random
local max,min,sin=math.max,math.min,math.sin
local ins,rem=table.insert,table.remove
local back={}

local t
local fan,petal
function back.init()
	t=rnd(2600)
	fan=title_fan
	petal={}
	BG.resize()
end
function back.update()
	t=t+1
	if t%10==0 then
		ins(petal,{
			x=SCR.w*rnd(),
			y=0,
			vy=2+rnd()*2,
			vx=rnd()*2-.5,
			rx=4+rnd()*4,
			ry=4+rnd()*4,
		})
	end
	for i=#petal,1,-1 do
		local P=petal[i]
		P.y=P.y+P.vy
		if P.y>SCR.h then
			rem(petal,i)
		else
			P.x=P.x+P.vx
			P.vx=P.vx+rnd()*.01
			P.rx=max(min(P.rx+rnd()-.5,10),2)
			P.ry=max(min(P.ry+rnd()-.5,10),2)
		end
	end
end
function back.draw()
	gc.push("transform")
	gc.translate(SCR.w/2,SCR.h/2+20*sin(t*.02))
	gc.scale(SCR.k)
	gc.clear(.1,.1,.1)
	gc.setLineWidth(320)
	gc.setColor(.3,.2,.3)
	gc.arc("line","open",0,420,500,-.8*3.1416,-.2*3.1416)

	gc.setLineWidth(4)
	gc.setColor(.7,.5,.65)
	gc.arc("line","open",0,420,660,-.799*3.1416,-.201*3.1416)
	gc.arc("line","open",0,420,340,-.808*3.1416,-.192*3.1416)
	gc.line(-281,224,-530,30.5)
	gc.line(281,224,530,30.5)

	gc.setLineWidth(6)
	gc.setColor(.55,.5,.6)
	for i=1,8 do
		gc.polygon("line",fan[i])
	end

	gc.setLineWidth(2)
	gc.setColor(.6,.3,.5)
	gc.origin()
	for i=1,#petal do
		local P=petal[i]
		gc.ellipse("fill",P.x,P.y,P.rx,P.ry)
	end
	gc.pop()
end
function back.discard()
	petal=nil
end
return back