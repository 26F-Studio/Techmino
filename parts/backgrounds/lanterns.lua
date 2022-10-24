-- A lantern background which is full of festive atmosphere. Lantern image by ScF
local int,rnd=math.floor,math.random
local ins,rem=table.insert,table.remove
local mDraw=mDraw
local back={}

local lanterns
local t
function back.init()
    lanterns={}
    t=0
end
function back.update(dt)
    t=t-dt
    local H=SCR.h
    if t<=0 then
        local size=SCR.rad*(2+rnd()*3)/5/2000
        local L={
            x=SCR.w*rnd(),
            y=H*1.1,
            vy=size*2,
            size=size,
            phase=rnd(),
            vp=(.02+.02*rnd())*(rnd(2)*2-3),
        }
        ins(lanterns,L)
        t=rnd(.626,1.626)
    end
    for i=#lanterns,1,-1 do
        local L=lanterns[i]
        L.y=L.y-L.vy*dt*60
        L.phase=(L.phase+L.vp*dt*60)%1
        if L.y<-.1*H then
            rem(lanterns,i)
        end
    end
end
function back.draw()
    GC.clear(.08,.08,.084)
    GC.setColor(1,1,1,.2)
    local img=IMG.lanterns
    for i=1,#lanterns do
        local L=lanterns[i]
        mDraw(img[int(L.phase*6)+1],L.x,L.y,nil,L.size)
    end
end
return back
