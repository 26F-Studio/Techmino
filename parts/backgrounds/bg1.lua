--Horizonal red-blue gradient
local gc=love.graphics
local rnd=math.random
local back={}

local t
function back.init()
	t=rnd()*2600
	BG.resize()
end
function back.resize()
	SHADER.gradient1:send("w",SCR.W)
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	SHADER.gradient1:send("t",t)
	gc.setShader(SHADER.gradient1)
	gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.setShader()
end
return back