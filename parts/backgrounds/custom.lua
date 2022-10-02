-- Custom background
local gc_clear,gc_setColor=love.graphics.clear,love.graphics.setColor
local back={}

local image=false
local alpha=.26

local mx,my,k

function back.init()
    back.resize()
end
function back.resize()
    mx,my=SCR.w*.5,SCR.h*.5
    if image then
        k=math.max(SCR.w/image:getWidth(),SCR.h/image:getHeight())
    end
end
function back.draw()
    gc_clear(.1,.1,.1)
    if image then
        gc_setColor(1,1,1,alpha)
        mDraw(image,mx,my,nil,k)
    end
end
function back.event(a,img)
    if a then alpha=a end
    if img then image=img end
    back.resize()
end
return back
