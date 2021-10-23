--Flandre's wing
local gc=love.graphics
local rnd=math.random
local back={}
local crystal_img,crystals
local wingColor={
    {.3,.8,.9,.3},
    {.5,1.,.5,.3},
    {.9,.9,.3,.3},
    {1.,.7,.3,.3},
    {1.,.5,.7,.3},
    {.7,.3,1.,.3},
    {.5,.5,1.,.3},
    {.3,.8,.9,.3},
}
local wingHeight={.41,.42,.43,.44,.45,.46,.47,.48}
function back.init()
    crystal_img=GC.DO{42,118,
        {'setCL',.93,.93,.93},
        {'fPoly',21,0,0,29,21,40},
        {'setCL',.6,.6,.6},
        {'fPoly',0,29,21,118,21,40},
        {'fPoly',21,0,42,29,21,40},
        {'setCL',.4,.4,.4},
        {'fPoly',21,118,42,29,21,40},
    }
    back.resize()
end
function back.resize()
    crystals={}
    for i=1,16 do
        crystals[i]={
            x=i<9 and SCR.w*.05*i or SCR.w*.05*(28-i),
            y=SCR.h*(wingHeight[i]or wingHeight[i-8]),
            a=0,
            va=0,
            f=i<9 and .012-i*.0005 or .012-(17-i)*.0005
        }
    end
end
function back.update()
    for i=1,16 do
        local B=crystals[i]
        B.a=B.a+B.va
        B.va=B.va*.986-B.a*B.f
    end
end
function back.draw()
    gc.clear(.06,.06,.06)
    gc.setColor(.12,.08,.05)
    gc.setLineWidth(6)
    for i=1,7 do
        local B1,B2=crystals[i],crystals[i+1]
        gc.line(B1.x,B1.y,B2.x,B2.y)
        B1,B2=crystals[i+8],crystals[i+9]
        gc.line(B1.x,B1.y,B2.x,B2.y)
    end
    local k=SCR.k
    for i=1,8 do
        gc.setColor(wingColor[i])
        local B=crystals[i]
        gc.draw(crystal_img,B.x,B.y,B.a,k,k,21,0)
        B=crystals[17-i]
        gc.draw(crystal_img,B.x,B.y,B.a,-k,k,21,0)
    end
end
function back.event(level)
    for i=1,8 do
        local B=crystals[i]
        B.va=B.va+.001*level*(1+rnd())
        B=crystals[17-i]
        B.va=B.va-.001*level*(1+rnd())
    end
end
function back.discard()
    crystal_img,crystals=nil
end
return back
