-- Flandre's wing
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
local wingHeight={.572,.536,.476,.405,.307,.402,.457,.367}
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
            y=SCR.h*(wingHeight[i<9 and i or i-8]),
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
    GC.clear(.06,.06,.06)
    GC.setColor(.12,.10,.08)
    GC.setLineJoin('bevel')
    GC.setLineWidth(14*SCR.k)
    local W,H=SCR.w,SCR.h
    GC.line(.018*W,.567*H,.101*W,.512*H,.202*W,.369*H,.260*W,.212*H)
    GC.line(.247*W,.257*H,.307*W,.383*H,.352*W,.436*H,.401*W,.309*H)
    GC.line(.982*W,.567*H,.899*W,.512*H,.798*W,.369*H,.740*W,.212*H)
    GC.line(.753*W,.257*H,.693*W,.383*H,.648*W,.436*H,.599*W,.309*H)

    local k=SCR.k
    for i=1,8 do
        GC.setColor(wingColor[i])
        local B=crystals[i]
        GC.draw(crystal_img,B.x,B.y,B.a,k,k,21,0)
        B=crystals[8+i]
        GC.draw(crystal_img,B.x,B.y,B.a,-k,k,21,0)
    end
end
function back.event(level)
    for i=1,8 do
        local B=crystals[i]
        B.va=B.va+.001*level*(1+math.random())
        B=crystals[17-i]
        B.va=B.va-.001*level*(1+math.random())
    end
end
function back.discard()
    crystal_img,crystals=nil
end
return back
