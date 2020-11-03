--Blue RGB
local gc=love.graphics
local rnd=math.random
local back={}

local t
function back.init()
	t=rnd()*2600
	BG.resize(SCR.w,SCR.h)
end
function back.resize(_,h)
	SHADER.rgb2:send("w",SCR.W)
	SHADER.rgb2:send("h",h*SCR.dpi)
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	SHADER.rgb2:send("t",t)
	gc.setShader(SHADER.rgb2)
	gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.setShader()
end
return back