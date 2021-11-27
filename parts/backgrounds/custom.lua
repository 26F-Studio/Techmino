--Secret custom background
local gc=love.graphics
local back={}
local image=false
local alpha=.26
function back.draw()
    if image then
        gc.clear(.1,.1,.1)
        gc.setColor(1,1,1,alpha)
        local k=math.max(SCR.w/image:getWidth(),SCR.h/image:getHeight())
        mDraw(image,SCR.w*.5,SCR.h*.5,nil,k)
    end
end
function back.event(a,img)
    if a then alpha=a end
    if img then image=img end
end
return back
