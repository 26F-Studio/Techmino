--Welcome to Techmino
local gc=love.graphics
local rnd,sin=math.random,math.sin
local back={}

local t
local txt
function back.init()
	t=rnd()*2600
	txt=gc.newText(getFont(80),"Welcome To Techmino")
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	if -t%13.55<.1283 then
		gc.clear(.2+.1*sin(t),.2+.1*sin(1.26*t),.2+.1*sin(1.626*t))
	else
		gc.clear(.1,.1,.1)
	end
	gc.push("transform")
	gc.translate(SCR.w/2,SCR.h/2+20*sin(t*.02))
	gc.scale(SCR.k)
	gc.scale(1.1626,1.26)
	if -t%6.26<.1355 then
		gc.translate(60*sin(t*.26),100*sin(t*.626))
	end
	if -t%12.6<.1626 then
		gc.rotate(t+5*sin(.26*t)+5*sin(.626*t))
	end
	gc.setColor(.2,.3,.5)
	gc.draw(txt,-883*.5+4*sin(t*.7942),-110*.5+4*sin(t*.7355))
	gc.setColor(.4,.6,.8)
	gc.draw(txt,-883*.5+2*sin(t*.77023),-110*.5+2*sin(t*.7026))
	gc.setColor(.9,.9,.9)
	gc.draw(txt,-883*.5+3*sin(t*.7283),-110*.5+3*sin(t*.7626))
	gc.pop()
end
return back