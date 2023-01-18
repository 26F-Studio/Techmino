-- Changing pure color
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
    GC.clear(
        sin(t*1.2)*.06+.08,
        sin(t*1.5)*.06+.08,
        sin(t*1.9)*.06+.08
    )
end
return back
