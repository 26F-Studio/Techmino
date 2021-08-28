--Flash after random time
local gc=love.graphics
local back={}

local t
function back.init()
    t=math.random()*2600
end
function back.update(dt)
    t=t+dt
end
function back.draw()
    local t1=.13-t%3%1.9
    if t1<.2 then gc.clear(t1,t1,t1)
    else gc.clear(0,0,0)
    end
end
return back
