--Space with stars
local gc=love.graphics
local circle,setColor,hsv=gc.circle,gc.setColor,COLOR.hsv
local rnd,pi,sin,cos=math.random,math.pi,math.sin,math.cos
local back={}

local sDist,sRev={},{} -- star data in SoA [distance from center, revolution progress, color]
local k

local d,r -- temp vars for optimization
function back.init()
    if sDist[1]then return end
    local max
    for i=0,20 do
        max=16*(i+1)
        for j=1,max do
            sDist[#sDist+1]=i+rnd()
            sRev[#sRev+1]=2*pi*j/max+2*pi*rnd()/max
        end
    end
end
function back.resize(w,h)k=3*SCR.k end
function back.update(dt)
    for i=1,#sDist do sRev[i]=(sRev[i]+dt/(sDist[i]+1))%(2*pi) end
end
function back.draw()
    gc.clear()
    gc.translate(SCR.cx,SCR.cy)
    gc.rotate(1)
    for i=1,#sDist do
        d,r=sDist[i],sRev[i]
        if d<5 then
            setColor(hsv(.088,(d-2)/7,1,.7))
        else
            setColor(hsv(.572,d/70+.1,(22-d)/12,.7))
        end
        circle('fill',8*d*cos(r),24*d*sin(r),3)
    end
    gc.rotate(-1)
    gc.translate(-SCR.cx,-SCR.cy)
end
function back.discard()end
return back
