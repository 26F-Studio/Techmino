-- Snow
local gc=love.graphics
local ellipse=gc.ellipse
local rnd=math.random
local max,min=math.max,math.min
local ins,rem=table.insert,table.remove
local back={}

local t
local snow
function back.init()
    t=0
    snow={}
end
function back.update()
    t=t+1
    if t%(t%626>260 and 3 or 6)==0 then
        ins(snow,{
            x=SCR.w*rnd(),
            y=0,
            vy=1+rnd()*.6,
            vx=rnd()*2-.5,
            rx=2+rnd()*2,
            ry=2+rnd()*2,
        })
    end
    for i=#snow,1,-1 do
        local P=snow[i]
        P.y=P.y+P.vy
        if P.y>SCR.h then
            rem(snow,i)
        else
            P.x=P.x+P.vx
            P.vx=P.vx-.02+rnd()*.04
            P.rx=max(min(P.rx+rnd()-.5,4),2)
            P.ry=max(min(P.ry+rnd()-.5,5),3)
        end
    end
end
function back.draw()
    gc.clear(.08,.08,.084)
    gc.setColor(.7,.7,.7)
    for i=1,#snow do
        local P=snow[i]
        ellipse('fill',P.x,P.y,P.rx,P.ry)
    end
end
function back.discard()
    snow=nil
end
return back
