-- Yuyuko's fan
local gc=love.graphics
local gc_clear,gc_origin,gc_replaceTransform=gc.clear,gc.origin,gc.replaceTransform
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_line,gc_polygon=gc.line,gc.polygon
local gc_arc,gc_ellipse=gc.arc,gc.ellipse

local rnd=math.random
local max,min,sin=math.max,math.min,math.sin
local ins,rem=table.insert,table.remove
local back={}

local t
local petal
function back.init()
    t=0
    petal={}
end
function back.update()
    t=t+1
    if t%10==0 then
        ins(petal,{
            x=SCR.w*rnd(),
            y=0,
            vy=2+rnd()*2,
            vx=rnd()*2-.5,
            rx=4+rnd()*4,
            ry=4+rnd()*4,
        })
    end
    for i=#petal,1,-1 do
        local P=petal[i]
        P.y=P.y+P.vy
        if P.y>SCR.h then
            rem(petal,i)
        else
            P.x=P.x+P.vx
            P.vx=P.vx+rnd()*.01
            P.rx=max(min(P.rx+rnd()-.5,10),2)
            P.ry=max(min(P.ry+rnd()-.5,10),2)
        end
    end
end
function back.draw()
    gc_clear(.1,.1,.1)

    gc_replaceTransform(SCR.xOy_m)
    gc_translate(0,20*sin(t*.02))

    gc_setLineWidth(320)
    gc_setColor(.9,.6,.9,.1)
    gc_arc('line','open',0,420,500,-.8*3.1416,-.2*3.1416)

    gc_setLineWidth(4)
    gc_setColor(1,.7,.9,.2)
    gc_arc('line','open',0,420,660,-.799*3.1416,-.201*3.1416)
    gc_arc('line','open',0,420,340,-.808*3.1416,-.192*3.1416)
    gc_line(-281,224,-530,30.5)
    gc_line(281,224,530,30.5)

    gc_setLineWidth(6)
    gc_setColor(.8,.9,1,.3)
    for i=1,#SVG_TITLE_FAN do gc_polygon('line',SVG_TITLE_FAN[i]) end

    gc_setLineWidth(2)
    gc_setColor(1,.5,.7,.3)

    gc_origin()
    for i=1,#petal do
        local P=petal[i]
        gc_ellipse('fill',P.x,P.y,P.rx,P.ry)
    end
end
function back.discard()
    petal=nil
end
return back
