--Welcome to Techmino
local gc=love.graphics
local sin=math.sin
local back={}

local t
local textObj
function back.init()
    t=math.random()*2600
    textObj=gc.newText(getFont(80),"Welcome To Techmino")
end
function back.update(dt)
    t=t+dt
end
function back.draw()
    if -t%13.55<.1283 then
        gc.clear(.2+.1*sin(t),.2+.1*sin(1.26*t),.2+.1*sin(1.626*t))
    else
        gc.clear(.08,.08,.084)
    end
    gc.push('transform')
    gc.translate(SCR.cx,SCR.cy+20*sin(t*.02))
    gc.scale(SCR.k)
    gc.scale(1.26,1.36)
    if -t%6.26<.1355 then
        gc.translate(60*sin(t*.26),100*sin(t*.626))
    end
    if -t%12.6<.1626 then
        gc.rotate(t+5*sin(.26*t)+5*sin(.626*t))
    end
    gc.setColor(.4,.6,1,.3)
    mDraw(textObj,4*sin(t*.7942),4*sin(t*.7355))
    gc.setColor(.5,.7,1,.4)
    mDraw(textObj,2*sin(t*.77023),2*sin(t*.7026))
    gc.setColor(1,1,1,.5)
    mDraw(textObj,3*sin(t*.7283),3*sin(t*.7626))
    gc.pop()
end
return back
