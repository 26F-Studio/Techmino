-- Space with stars
local gc=love.graphics
local rectangle=gc.rectangle
local rnd=math.random
local back={}

local stars
local W,H
function back.init()
    stars={}
    BG.resize(SCR.w,SCR.h)
end
function back.resize(w,h)
    W,H=w+20,h+20
    local S=stars
    for i=1,1260,5 do
        local s=rnd(26,40)*.1
        S[i]=s*SCR.k           -- Size
        S[i+1]=rnd(W)-10       -- X
        S[i+2]=rnd(H)-10       -- Y
        S[i+3]=(rnd()-.5)*.01*s-- Vx
        S[i+4]=(rnd()-.5)*.01*s-- Vy
    end
end
function back.update(dt)
    local S=stars
    -- Star moving
    for i=1,1260,5 do
        S[i+1]=(S[i+1]+S[i+3]*dt*60)%W
        S[i+2]=(S[i+2]+S[i+4]*dt*60)%H
    end
end
function back.draw()
    gc.clear(.08,.08,.084)
    if not stars[1] then return end
    gc.translate(-10,-10)
    gc.setColor(1,1,1,.6)
    for i=1,1260,5 do
        rectangle('fill',stars[i+1],stars[i+2],stars[i],stars[i])
    end
    gc.translate(10,10)
end
function back.discard()
    stars=nil
end
return back
