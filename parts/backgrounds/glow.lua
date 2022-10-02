-- Light-dark
local sin=math.sin
local back={}

local t
function back.init()
    t=math.random()*2600
end
function back.update(dt)
    t=t+dt
end
function back.draw()
    local t1=(sin(t*.5)+sin(t*.7)+sin(t*.9+1)+sin(t*1.5)+sin(t*2+10))*.08
    GC.clear(t1,t1,t1)
end
return back
