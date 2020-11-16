--Colorful RGB
local gc=love.graphics
local rnd=math.random
local back={}
local shader=SHADER.rgb1

local t
function back.init()
	t=rnd()*2600
	BG.resize(SCR.w,SCR.h)
end
function back.resize(_,h)
	shader:send("w",SCR.W)
	shader:send("h",h*SCR.dpi)
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	shader:send("t",t)
	gc.setShader(shader)
	gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.setShader()
end
return back