--Cool liquid background
local gc=love.graphics
local rnd=math.random
local back={}

local t
function back.init()
	t=rnd()*2600
	BG.resize(SCR.w,SCR.h)
end
function back.resize(_,h)
	SHADER.aura:send("w",SCR.W)
	SHADER.aura:send("h",h*SCR.dpi)
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	SHADER.aura:send("t",t)
	gc.setShader(SHADER.aura)
	gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.setShader()
end
return back