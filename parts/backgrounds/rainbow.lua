--Colorful RGB
local gc=love.graphics
local rnd=math.random
local back={}

local t
function back.init()
	t=rnd()*2600
	BG.resize(SCR.w,SCR.h)
end
function back.resize(_,h)
	SHADER.rgb1:send("w",SCR.W)
	SHADER.rgb1:send("h",h*SCR.dpi)
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	SHADER.rgb1:send("t",t)
	gc.setShader(SHADER.rgb1)
	gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.setShader()
end
return back