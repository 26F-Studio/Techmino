--Vertical red-green gradient
local gc=love.graphics
local rnd=math.random
local back={}

local t
function back.init()
	t=rnd()*2600
	BG.resize(nil,SCR.h)
end
function back.resize(_,h)
	SHADER.gradient2:send("h",h*SCR.dpi)
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	SHADER.gradient2:send("t",t)
	gc.setShader(SHADER.gradient2)
	gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.setShader()
end
return back