local gc=love.graphics
local setFont,mStr=FONT.set,GC.mStr

local int,rnd=math.floor,math.random
local ins,rem=table.insert,table.remove

local targets={
    [40]=true,
    [100]=true,
    [200]=true,
    [400]=true,
    [620]=true,
    [1000]=true,
    [2600]=true,
}

local state,progress
local startTime,time
local keyTime
local speed,maxSpeed
local arcade,rollSpeed

local reset=error-- function, defined later

local bgm="secret7th"
local tileColor="black"
local mode="Normal"
local modeSelector=WIDGET.newSelector{name='mode',x=150,y=220,w=290,
    list={
        "Normal",
        "Split",
        "Short",
        "Stairs",
        "Double",
        "Singlestream",
        "Light_Jumpstream",
        "Dense_Jumpstream",
        "Light_Handstream",
        "Dense_Handstream",
        "Light_Quadstream",
        "Quadstream",
    },disp=function() return mode end,code=function(m) mode=m reset() end
}
local bgmSelector=WIDGET.newSelector{name='bgm',x=150,y=290,w=290,list=BGM.getList(),disp=function() return bgm end,code=function(i) bgm=i BGM.play(i) end}
local colorSelector=WIDGET.newSelector{name='color',x=150,y=360,w=290,
    list={"black","dGray","gray","lGray","dRed","red","lRed","dFire","fire","lFire","dOrange","orange","lOrange","dYellow","yellow","lYellow","dLime","lime","lLime","dJade","jade","lJade","dGreen","green","lGreen","dAqua","aqua","lAqua","dCyan","cyan","lCyan","dNavy","navy","lNavy","dSea","sea","lSea","dBlue","blue","lBlue","dViolet","violet","lViolet","dPurple","purple","lPurple","dMagenta","magenta","lMagenta","dWine","wine","lWine"},
    disp=function() return tileColor end,code=function(m) tileColor=m end
}
local arcadeSwitch=WIDGET.newSwitch{name='arcade',x=240,y=430,lim=200,font=40,disp=function() return arcade end,code=pressKey'e'}
local function freshSelectors()
    local f=state~=0
    modeSelector.hide=f
    bgmSelector.hide=f
    colorSelector.hide=f
    arcadeSwitch.hide=f
end

local score
local pos,height
local diePos

local function get1(prev)
    if prev<10 or prev>999 then
        local r=rnd(3)
        return r>=prev and r+1 or r
    else
        while true do
            local r=rnd(4)
            if not string.find(prev,r) then return r end
        end
    end
end
local function get2(prev)
    while true do
        local i=rnd(4)
        local r=rnd(3)
        if r>=i then r=r+1 end
        if not (string.find(prev,r) or string.find(prev,i)) then
            return 10*i+r
        end
    end
end
local function get3(prev)
    if prev==0 then prev=rnd(4) end
    if prev==1 then return 234
    elseif prev==2 then return 134
    elseif prev==3 then return 124
    elseif prev==4 then return 123
    else error("wrong get3 usage: "..(prev or -1))
    end
end

local generator={
    Normal=function()
        ins(pos,rnd(4))
    end,
    Split=function()
        if #pos==0 then ins(pos,rnd(4)) end
        ins(pos,pos[#pos]<=2 and rnd(3,4) or rnd(2))
    end,
    Short=function()
        if #pos<2 then ins(pos,rnd(4))ins(pos,rnd(4)) end
        local r
        if pos[#pos]==pos[#pos-1] then
            r=rnd(3)
            if r>=pos[#pos] then r=r+1 end
            ins(pos,r)
        else
            ins(pos,rnd(4))
        end
    end,
    Stairs=function()
        local r=get1(pos[#pos] or 0)
        local dir=r==1 and 1 or r==4 and -1 or rnd()<.5 and 1 or -1
        local count=rnd(3,5)
        while count>0 do
            ins(pos,r)
            r=r+dir
            if r==0 then
                r,dir=2,1
            elseif r==5 then
                r,dir=3,-1
            end
            count=count-1
        end
    end,
    Double=function()
        local i=rnd(4)
        local r=rnd(3)
        if r>=i then r=r+1 end
        r=10*i+r
        ins(pos,r)
    end,
    Singlestream=function()
        ins(pos,get1(pos[#pos] or 0))
    end,
    Light_Jumpstream=function()-- 2111
        ins(pos,get2(pos[#pos] or 0))
        ins(pos,get1(pos[#pos]))
        ins(pos,get1(pos[#pos]))
        ins(pos,get1(pos[#pos]))
    end,
    Dense_Jumpstream=function()-- 2121
        ins(pos,get2(pos[#pos] or 0))
        ins(pos,get1(pos[#pos]))
        ins(pos,get2(pos[#pos]))
        ins(pos,get1(pos[#pos]))
    end,
    Light_Handstream=function()-- 3111
        ins(pos,get3(pos[#pos] or 0))
        ins(pos,get1(pos[#pos]))
        ins(pos,get1(pos[#pos]))
        ins(pos,get1(pos[#pos]))
    end,
    Dense_Handstream=function()-- 3121
        ins(pos,get3(pos[#pos] or 0))
        ins(pos,get1(pos[#pos]))
        ins(pos,get2(pos[#pos]))
        ins(pos,get1(pos[#pos]))
    end,
    Light_Quadstream=function()-- 4111
        ins(pos,1234)
        ins(pos,get1(pos[#pos-1] or 0))
        ins(pos,get1(pos[#pos]))
        ins(pos,get1(pos[#pos]))
    end,
    Quadstream=function()-- 4121
        ins(pos,1234)
        ins(pos,get1(pos[#pos-1] or 0))
        ins(pos,get2(pos[#pos]))
        ins(pos,get1(pos[#pos]))
    end,
}

function reset()
    keyTime={} for i=1,40 do keyTime[i]=-1e99 end
    speed,maxSpeed=0,0
    progress={}
    state=0
    freshSelectors()
    time=0
    score=0

    local t=love.system.getClipboardText()
    if type(t)=='string' then
        t=t:lower():match("^s=(.+)")
        t=t and tonumber(t) and tonumber(t)*2
        t=t and tonumber(t)>=0 and tonumber(t)<=60 and t
    end
    rollSpeed=type(t)=='number' and t or 6.26

    pos={}
    while #pos<7 do generator[mode]() end
    height=0
    diePos=false
end

local scene={}

function scene.enter()
    reset()
    BG.set('fixColor',.26,.26,.26)
    BGM.play(bgm)
end

local function touch(n)
    if state==0 then
        state=1
        freshSelectors()
        startTime=TIME()
    end
    local t=tostring(pos[1])
    local p=string.find(t,n)
    if p then
        t=t:sub(1,p-1)..t:sub(p+1)
        if #t>0 then
            pos[1]=tonumber(t)
            SFX.play('lock')
        else
            rem(pos,1)
            while #pos<7 do generator[mode]() end
            ins(keyTime,1,TIME())
            keyTime[21]=nil
            score=score+1
            if not arcade and targets[score] then
                ins(progress,("%s - %.3fs"):format(score,TIME()-startTime))
                if score==2600 then
                    for i=1,#pos do
                        pos[i]=626
                    end
                    time=TIME()-startTime
                    state=2
                    SFX.play('win')
                else
                    SFX.play('reach',.5)
                end
            end
            height=height+120
            SFX.play('lock')
        end
    else
        time=TIME()-startTime
        state=2
        diePos=n
        SFX.play('clear_2')
    end
end
function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='r' or key=='space' then reset()
    elseif key=='escape' then SCN.back()
    elseif state~=2 then
        if key=='d' or key=='c' then touch(1)
        elseif key=='f' or key=='v' then touch(2)
        elseif key=='j' or key=='n' then touch(3)
        elseif key=='k' or key=='m' then touch(4)
        elseif state==0 then
            if key=='tab' then
                local mode1=mode
                modeSelector:scroll(love.keyboard.isDown('lshift','rshift') and -1 or 1)
                if mode1~=mode then reset() end
            elseif key=='q' then
                bgmSelector:scroll(love.keyboard.isDown('lshift','rshift') and -1 or 1)
            elseif key=='w' then
                colorSelector:scroll(love.keyboard.isDown('lshift','rshift') and -1 or 1)
            elseif key=='e' then
                arcade=not arcade
            end
        end
    end
end
function scene.mouseDown(x)
    scene.touchDown(x)
end
function scene.touchDown(x)
    if state==2 then return end
    x=int((x-300)/170+1)
    if x>=1 and x<=4 then
        touch(x)
    end
end

function scene.update(dt)
    if state==1 then
        local t=TIME()
        time=t-startTime
        local v=0
        for i=2,20 do v=v+i*(i-1)*.3/(t-keyTime[i]) end
        speed=MATH.expApproach(speed,v,dt)
        if speed>maxSpeed then maxSpeed=speed end

        if arcade then
            height=height-rollSpeed
            rollSpeed=rollSpeed+.00355
            if height<-120 then
                state=2
                SFX.play('clear_2')
            end
        else
            height=height*.6
        end
    end
end

local function boardStencil() gc.rectangle('fill',300,0,680,720) end
function scene.draw()
    setFont(50)
    if arcade then
        -- Draw rolling speed
        mStr(("%.2f/s"):format(rollSpeed/2),155,490)
    else
        -- Draw speed
        setFont(45)
        gc.setColor(1,.6,.6)
        mStr(("%.2f"):format(maxSpeed/60),155,460)
        gc.setColor(COLOR.Z)
        mStr(("%.2f"):format(speed/60),155,520)

        -- Progress time list
        setFont(30)
        gc.setColor(.6,.6,.6)
        for i=1,#progress do
            gc.print(progress[i],1030,120+25*i)
        end

        -- Draw time
        gc.setColor(COLOR.Z)
        setFont(45)
        gc.print(("%.3f"):format(time),1030,70)
    end

    -- Draw mode
    if state~=0 then
        gc.setColor(COLOR.Z)
        setFont(30)mStr(mode,155,212)
    end

    -- Draw tiles
    gc.stencil(boardStencil)
    gc.setStencilTest('equal',1)
    gc.rectangle('fill',300,0,680,720)
    gc.setColor(COLOR[tileColor])
    gc.push('transform')
    gc.translate(0,720-height+8)
    for i=1,7 do
        local t=pos[i]
        while t>0 do
            gc.rectangle('fill',130+170*(t%10)+8,-i*120,170-16,120-16)
            t=(t-t%10)/10
        end
    end
    gc.pop()
    gc.setStencilTest()
    -- Draw track line
    gc.setColor(COLOR.D)
    gc.setLineWidth(2)
    for x=1,5 do
        x=130+170*x
        gc.line(x,0,x,720)
    end
    for y=0,6 do
        y=720-120*y-height%120
        gc.line(300,y,980,y)
    end

    -- Draw red tile
    if diePos then
        gc.setColor(1,.2,.2)
        gc.rectangle('fill',130+170*diePos+8,600-height+8,170-16,120-16)
    end

    -- Draw score
    setFont(100)
    gc.push('transform')
    gc.translate(640,26)
    gc.scale(1.6)
    gc.setColor(.5,.5,.5,.6)
    mStr(score,0,0)
    gc.pop()
end

scene.widgetList={
    WIDGET.newButton{name='reset',x=155,y=100,w=180,h=100,color='lG',font=50,fText=CHAR.icon.retry_spin,code=pressKey'r'},
    modeSelector,bgmSelector,colorSelector,
    arcadeSwitch,
    WIDGET.newButton{name='back', x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
