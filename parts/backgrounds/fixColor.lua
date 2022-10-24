-- Customizable grey background
local back={}
local r,g,b=.26,.26,.26
function back.draw()
    GC.clear(r,g,b)
end
function back.event(_r,_g,_b)
    r,g,b=_r,_g,_b
end
return back
