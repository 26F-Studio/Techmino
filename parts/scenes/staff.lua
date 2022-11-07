local kb,tc=love.keyboard,love.touch
local rnd=math.random
local ins,rem=table.insert,table.remove

local scene={}

local time,v
local patron=require"parts.patron"
local names
local counter

function scene.enter()
    time=0
    v=22.6
    BG.set()
    names={}
    counter=26
end

function scene.mouseDown(x,y)
    local T=40*math.min(time,185)
    if x>330 and x<950 then
        if math.abs(y-900+T)<70 then
            loadGame('sprintLock',true)
        elseif math.abs(y-7770+T)<70 then
            loadGame('sprintFix',true)
        end
    end
end
scene.touchDown=scene.mouseDown

function scene.keyDown(key)
    if key=='l' then
        loadGame('sprintLock',true)
    elseif key=='f' then
        loadGame('sprintFix',true)
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.update(dt)
    if (kb.isDown('space','return') or tc.getTouches()[1]) and v<16.2 then
        v=v+.42
    elseif v>3.55 then
        v=v-.42
    end
    time=time+v*dt
    counter=counter-1
    if counter==0 then
        local N=patron[rnd(#patron)]
        local T=GC.newText(getFont(N.font),N.name)
        local r=rnd()<.5
        ins(names,{
            text=T,
            x=r and -T:getWidth() or SCR.w,
            y=rnd()*(SCR.h-T:getHeight()),
            w=T:getWidth(),
            vx=(r and 1 or -1)*(1.626+rnd())*(SCR.w+T:getWidth())/SCR.w,
        })
        counter=26
    end
    for i=#names,1,-1 do
        local N=names[i]
        N.x=N.x+N.vx
        if N.vx>0 and N.x>SCR.w or N.vx<0 and N.x<-N.w then
            rem(names,i)
        end
    end
end

function scene.draw()
    GC.replaceTransform(SCR.origin)
    GC.setColor(1,1,1,.3)
    for i=1,#names do
        local N=names[i]
        GC.draw(N.text,N.x,N.y)
    end

    GC.replaceTransform(SCR.xOy)
    local T=40*math.min(time,185)
    GC.setColor(.97,.97,.97,185-math.min(time,185))
    local L=text.staff
    setFont(40)
    for i=1,#L do
        GC.mStr(L[i],640,950+65*i-T)
    end
    GC.setColor(1,1,1)
    mDraw(TEXTURE.title_color,640,900-T,nil,.6)
    mDraw(TEXTURE.title,640,7770-T,nil,.6)
    if time>190 then
        GC.print("CLICK ME →",50,550,-.5)
    end
end

scene.widgetList={
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
