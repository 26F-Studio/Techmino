-- Blue RGB
local back={}
local shader=SHADER.rgb2

local t
function back.init()
    t=math.random()*2600
end
function back.update(dt)
    t=(t+dt)%6200
end
function back.draw()
    GC.clear(.08,.08,.084)
    shader:send('phase',t)
    GC.setShader(shader)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)
    GC.setShader()
end
return back
