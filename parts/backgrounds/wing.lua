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
local wingHeight={.572,.536,.472,.405,.307,.402,.457,.367}
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
    gc.setColor(.12,.12,.12)
    gc.setLineWidth(0.02*SCR.h)
    gc.line(0.018*SCR.w,0.567*SCR.h,0.101*SCR.w,0.512*SCR.h)
    gc.line(0.202*SCR.w,0.369*SCR.h,0.099*SCR.w,0.514*SCR.h)
    gc.line(0.201*SCR.w,0.371*SCR.h,0.260*SCR.w,0.212*SCR.h)
    gc.line(0.247*SCR.w,0.257*SCR.h,0.307*SCR.w,0.383*SCR.h)
    gc.line(0.352*SCR.w,0.436*SCR.h,0.305*SCR.w,0.381*SCR.h)
    gc.line(0.344*SCR.w,0.437*SCR.h,0.401*SCR.w,0.307*SCR.h)
    gc.line(0.982*SCR.w,0.567*SCR.h,0.899*SCR.w,0.512*SCR.h)
    gc.line(0.798*SCR.w,0.369*SCR.h,0.901*SCR.w,0.514*SCR.h)
    gc.line(0.799*SCR.w,0.371*SCR.h,0.740*SCR.w,0.212*SCR.h)
    gc.line(0.753*SCR.w,0.257*SCR.h,0.693*SCR.w,0.383*SCR.h)
    gc.line(0.648*SCR.w,0.436*SCR.h,0.695*SCR.w,0.381*SCR.h)
    gc.line(0.656*SCR.w,0.437*SCR.h,0.599*SCR.w,0.307*SCR.h)

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
