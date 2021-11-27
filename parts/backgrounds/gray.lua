--Customizable grey background
local gc=love.graphics
local back={}
local brightness=.26
function back.draw()
    gc.clear(brightness,brightness,brightness)
end
function back.event(b)
    brightness=b
end
return back
