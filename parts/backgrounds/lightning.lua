-- Lightning
local back={}

local t
function back.init()
    t=math.random()*2600
end
function back.update(dt)
    t=t+dt
end
function back.draw()
    local t1=2.5-t%20%6%2.5
    if t1<.3 then GC.clear(t1,t1,t1)
    else GC.clear(0,0,0)
    end
end
return back
