local kb,tc=love.keyboard,love.touch
local rnd=math.random
local ins,rem=table.insert,table.remove

local maxTime=187.5

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
    local T=40*math.min(time,maxTime)
    if x>330 and x<950 then
        if math.abs(y-900+T)<70 then
            loadGame('sprintLock',true)
        elseif math.abs(y-7870+T)<70 then
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
    GC.translate(640,-40*math.min(time,maxTime)) -- 0~7600
    GC.setColor(.97,.97,.97,math.max(maxTime-time,0))
    local L=text.staff
    setFont(40)
    for i=1,#L do
        GC.mStr(L[i],0,950+65*i)
    end
    GC.setColor(1,1,1)
    mDraw(TEXTURE.title_color,0,900,nil,.6)
    mDraw(TEXTURE.title,0,7870,nil,.6)
    if time>maxTime+6.26 then
        GC.print("CLICK ME →",-526,8026,-.5)
    end
end

scene.widgetList={
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
