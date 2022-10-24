-- Welcome to Techmino
local sin=math.sin
local back={}

local t
local textObj
function back.init()
    t=math.random()*2600
    textObj=GC.newText(getFont(80),"Welcome To Techmino")
end
function back.update(dt)
    t=t+dt
end
function back.draw()
    if -t%13.55<.1283 then
        GC.clear(.2+.1*sin(t),.2+.1*sin(1.26*t),.2+.1*sin(1.626*t))
    else
        GC.clear(.08,.08,.084)
    end
    GC.push('transform')
    GC.replaceTransform(SCR.xOy_m)
    GC.translate(0,20*sin(t*.02))
    GC.scale(1.26,1.36)
    if -t%6.26<.1355 then
        GC.translate(60*sin(t*.26),100*sin(t*.626))
    end
    if -t%12.6<.1626 then
        GC.rotate(t+5*sin(.26*t)+5*sin(.626*t))
    end
    GC.setColor(.4,.6,1,.3)
    mDraw(textObj,4*sin(t*.7942),4*sin(t*.7355))
    GC.setColor(.5,.7,1,.4)
    mDraw(textObj,2*sin(t*.77023),2*sin(t*.7026))
    GC.setColor(1,1,1,.5)
    mDraw(textObj,3*sin(t*.7283),3*sin(t*.7626))
    GC.pop()
end
return back
