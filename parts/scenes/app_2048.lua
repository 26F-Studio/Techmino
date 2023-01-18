local gc,kb=love.graphics,love.keyboard
local setColor,rectangle=gc.setColor,gc.rectangle

local int,abs=math.floor,math.abs
local rnd,min=math.random,math.min
local ins=table.insert
local setFont=FONT.set

local scene={}

local invis,tapControl

local board
local startTime,time
local state,progress
local move

local autoPressing
local nextTile,nextCD
local nextPos,prevPos
local prevSpawnTime=0
local maxTile

local skipper={
    used=false,
    cd=0,
}
local repeater={
    focus=false,
    seq={"",""},last={"X","X"},
}
local score

--[[Tiles' value:
    -1: black tile, cannot move
    0: X tile, cannot merge
    1/2/3/...: 2/4/8/... tile
]]
local tileColor={
    [-1]=COLOR.D,
    [0]={.5,.3,.3},
    {.93,.89,.85},
    {.93,.88,.78},
    {.95,.69,.47},
    {.96,.58,.39},
    {.96,.49,.37},
    {.96,.37,.23},
    {.93,.81,.45},
    {.93,.80,.38},
    {.93,.78,.31},
    {.93,.77,.25},
    {.93,.76,.18},
    {.40,.37,.33},
    {.22,.19,.17},
}
local tileFont={
    80,80,80,-- 2/4/8
    70,70,70,-- 16/32/64
    60,60,60,-- 128/256/512
    55,55,55,55,-- 1024/2048/4096/8192
    50,50,50,-- 16384/32768/65536
    45,45,45,-- 131072/262144/524288
    30,-- 1048576
}
local tileName={[0]="X","2","4","8","16","32","64","128","256","512","1024","2048","4096","8192","16384","32768","65536","131072","262144","524288","2^20"}
local function airExist()
    for i=1,16 do
        if not board[i] then
            return true
        end
    end
end
local function newTile()
    -- Select position & generate number
    nextPos=(nextPos+6)%16+1
    while board[nextPos] do
        nextPos=(nextPos-4)%16+1
    end
    board[nextPos]=nextTile
    prevPos=nextPos
    prevSpawnTime=0

    -- Fresh score
    score=score+2^nextTile
    TEXT.show("+"..2^nextTile,1130+rnd(-60,60),575+rnd(-30,30),30,'score',1.5)

    -- Generate next number
    nextCD=nextCD-1
    if nextCD>0 then
        nextTile=1
    else
        nextTile=MATH.roll(.9) and 2 or MATH.roll(.9) and 3 or 4
        nextCD=rnd(8,12)
    end

    -- Check if board is full
    if airExist() then return end

    -- Check if board is locked in all-directions
    for i=1,12 do
        if board[i]==board[i+4] then
            return
        end
    end
    for i=1,13,4 do
        if
            board[i+0]==board[i+1] or
            board[i+1]==board[i+2] or
            board[i+2]==board[i+3]
        then
            return
        end
    end

    -- Die.
    state=2
    SFX.play(maxTile>=10 and 'win' or 'fail')
end
local function freshMaxTile()
    maxTile=maxTile+1
    if maxTile==12 then
        skipper.cd=0
    end
    SFX.play('reach')
    ins(progress,("%s - %.3fs"):format(tileName[maxTile],TIME()-startTime))
end
local function squash(L)
    local p1,p2=1
    local moved=false
    while true do
        p2=p1+1
        while not L[p2] and p2<5 do
            p2=p2+1
        end
        if p2==5 then
            if p1==4 then
                return L[1],L[2],L[3],L[4],moved
            else
                p1=p1+1
            end
        else
            if not L[p1] then-- air←2
                L[p1],L[p2]=L[p2],false
                moved=true
            elseif L[p1]==L[p2] then-- 2←2
                L[p1],L[p2]=L[p1]+1,false
                if L[p1]>maxTile then
                    freshMaxTile()
                end
                L[p2]=false
                p1=p1+1
                moved=true
            elseif p1+1~=p2 then-- 2←4
                L[p1+1],L[p2]=L[p2],false
                p1=p1+1
                moved=true
            else-- 2,4
                p1=p1+1
            end
        end
    end
end
local function reset()
    for i=1,16 do board[i]=false end
    progress={}
    state=0
    score=0
    time=0
    move=0
    maxTile=6
    nextTile,nextPos=1,rnd(16)
    nextCD=32
    skipper.cd,skipper.used=false,false
    repeater.seq[1],repeater.seq[2]="",""
    repeater.last[1],repeater.last[2]="X","X"
    newTile()
end

local function moveUp()
    local moved
    for i=1,4 do
        local m
        board[i],board[i+4],board[i+8],board[i+12],m=squash({board[i],board[i+4],board[i+8],board[i+12]})
        if m then moved=true end
    end
    return moved
end
local function moveDown()
    local moved
    for i=1,4 do
        local m
        board[i+12],board[i+8],board[i+4],board[i],m=squash({board[i+12],board[i+8],board[i+4],board[i]})
        if m then moved=true end
    end
    return moved
end
local function moveLeft()
    local moved
    for i=1,13,4 do
        local m
        board[i],board[i+1],board[i+2],board[i+3],m=squash({board[i],board[i+1],board[i+2],board[i+3]})
        if m then moved=true end
    end
    return moved
end
local function moveRight()
    local moved
    for i=1,13,4 do
        local m
        board[i+3],board[i+2],board[i+1],board[i],m=squash({board[i+3],board[i+2],board[i+1],board[i]})
        if m then moved=true end
    end
    return moved
end
local function skip()
    if state==1 and skipper.cd==0 then
        if airExist() then
            skipper.cd=1024
            skipper.used=true
            newTile()
            SFX.play('hold')
        else
            SFX.play('finesseError')
        end
    end
end

function scene.enter()
    BG.set('cubes')
    BGM.play('truth')
    board={}

    invis=false
    tapControl=false
    startTime=0
    reset()
end

function scene.mouseDown(x,y,k)
    if tapControl then
        if k==2 then
            skip()
        else
            local dx,dy=x-640,y-360
            if abs(dx)<320 and abs(dy)<320 and (abs(dx)>60 or abs(dy)>60) then
                scene.keyDown(abs(dx)-abs(dy)>0 and
                    (dx>0 and 'right' or 'left') or
                    (dy>0 and 'down' or 'up')
                )
            end
        end
    end
end
scene.touchDown=scene.mouseDown

local moveFunc={
    up=moveUp,
    down=moveDown,
    left=moveLeft,
    right=moveRight,
}
local arrows={
    up='↑',down='↓',left='←',right='→',
    ['↑']='up',['↓']='down',['←']='left',['→']='right',
}
local function setFocus(n)
    if state~=2 then
        repeater.focus=n
        repeater.seq[n]=""
    end
end
local function playRep(n)
    if state~=2 and #repeater.seq[n]>0 then
        repeater.focus=false
        local move0=move
        for i=1,#repeater.seq[n],3 do
            autoPressing=true
            scene.keyDown(arrows[repeater.seq[n]:sub(i,i+2)])
            autoPressing=false
        end
        if move~=move0 then
            if repeater.seq[n]~=repeater.last[n] then
                repeater.last[n]=repeater.seq[n]
                move=move0+#repeater.seq[n]/3+1
            else
                move=move0+1
            end
        end
    end
end
function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='up' or key=='down' or key=='left' or key=='right' then
        if repeater.focus then
            local f=repeater.focus
            if #repeater.seq[f]<24 then
                repeater.seq[f]=repeater.seq[f]..arrows[key]
            end
        else
            if moveFunc[key]() then
                if state==0 then
                    startTime=TIME()
                    state=1
                end
                if skipper.cd and skipper.cd>0 then
                    skipper.cd=skipper.cd-1
                    if skipper.cd==0 then
                        SFX.play('spin_0')
                    end
                end
                newTile()
                TEXT.show(arrows[key],640,360,80,'beat',3)
                move=move+1
                if not autoPressing then
                    SFX.play('touch')
                end
            end
        end
    elseif key=='space' then skip()
    elseif key=='r' then reset()
    elseif key=='q' then if state==0 then invis=not invis end
    elseif key=='w' then if state==0 then tapControl=not tapControl end
    elseif key=='1' or key=='2' then (kb.isDown('lshift','lctrl','lalt') and playRep or setFocus)(key=='1' and 1 or 2)
    elseif key=='c1' then playRep(1)
    elseif key=='c2' then playRep(2)
    elseif key=='return' or key=='kpenter' then
        if repeater.focus then
            repeater.focus=false
        end
    elseif key=='escape' then
        if repeater.focus then
            repeater.focus=false
        elseif tryBack() then
            SCN.back()
        end
    end
end

function scene.update(dt)
    if state==1 then
        time=TIME()-startTime
    end
    if prevSpawnTime<1 then
        prevSpawnTime=min(prevSpawnTime+3*dt,1)
    end
end

function scene.draw()
    setFont(35)
    setColor(1,1,1)
    gc.print(("%.3f"):format(time),1000,10)
    gc.print(move,1000,45)

    -- Progress time list
    setFont(20)
    setColor(.6,.6,.6)
    for i=1,#progress do
        gc.print(progress[i],1000,65+20*i)
    end

    -- Repeater
    gc.setLineWidth(6)
    setFont(25)
    for i=1,2 do
        setColor(COLOR[
            repeater.focus==i and (
                TIME()%.5>.25 and
                'R' or
                'Y'
            ) or (
                repeater.seq[i]==repeater.last[i] and
                'H' or
                'Z'
            )
        ])
        rectangle('line',990,305+60*i,220,50)
        gc.print(repeater.seq[i],1000,313+60*i)
    end

    -- Score
    setFont(40)
    setColor(1,.7,.7)
    GC.mStr(score,1130,510)

    -- Messages
    if state==2 then
        -- Draw no-setting area
        setColor(1,0,0,.3)
        rectangle('fill',15,265,285,140)

        setColor(.9,.9,0)-- win
    elseif state==1 then
        setColor(.9,.9,.9)-- game
    elseif state==0 then
        setColor(.2,.8,.2)-- ready
    end
    gc.setLineWidth(10)
    rectangle('line',310,30,660,660)

    -- Board
    for i=1,16 do
        if board[i] then
            local x,y=1+(i-1)%4,int((i+3)/4)
            local N=board[i]
            if i~=prevPos or prevSpawnTime==1 then
                if not invis or i==prevPos then
                    setColor(tileColor[N] or COLOR.D)
                    rectangle('fill',x*160+163,y*160-117,154,154,15)
                    if N>=0 then
                        setColor(N<3 and COLOR.D or COLOR.Z)
                        local fontSize=tileFont[N]
                        setFont(fontSize)
                        GC.mStr(tileName[N],320+(x-.5)*160,40+(y-.5)*160-fontSize*.7)
                    end
                else
                    setColor(COLOR.H)
                    rectangle('fill',x*160+163,y*160-117,154,154,15)
                end
            else
                local c=tileColor[N]
                setColor(c[1],c[2],c[3],prevSpawnTime)
                rectangle('fill',x*160+163,y*160-117,154,154,15)
                c=N<3 and 0 or 1
                setColor(c,c,c,prevSpawnTime)
                local fontSize=tileFont[N]
                setFont(fontSize)
                GC.mStr(tileName[N],320+(x-.5)*160,40+(y-.5)*160-fontSize*.7)
            end
        end
    end

    -- Next indicator
    setColor(1,1,1)
    if nextCD<=12 then
        for i=1,nextCD do
            rectangle('fill',140+i*16-nextCD*8,170,12,12)
        end
    end

    -- Next
    setFont(40)
    gc.print("Next",50,195)
    if nextTile>1 then
        setColor(1,.5,.4)
    end
    setFont(70)
    GC.mStr(tileName[nextTile],220,175)

    -- Skip CoolDown
    if skipper.cd and skipper.cd>0 then
        setFont(50)
        setColor(1,1,.5)
        GC.mStr(skipper.cd,155,600)
    end

    -- Skip mark
    if skipper.used then
        setColor(1,1,.5)
        gc.circle('fill',280,675,10)
    end

    -- New tile position
    local x,y=1+(prevPos-1)%4,int((prevPos+3)/4)
    gc.setLineWidth(8)
    setColor(.2,.8,0,prevSpawnTime)
    local d=25-prevSpawnTime*25
    rectangle('line',x*160+163-d,y*160-117-d,154+2*d,154+2*d,15)

    -- Touch control border line
    if tapControl then
        gc.setLineWidth(6)
        setColor(1,1,1,.2)
        gc.line(310,30,580,300)
        gc.line(970,30,700,300)
        gc.line(310,690,580,420)
        gc.line(970,690,700,420)
        rectangle('line',580,300,120,120,10)
    end
end

scene.widgetList={
    WIDGET.newButton{name='reset',     x=155, y=100,w=180,h=100,color='lG',font=50,fText=CHAR.icon.retry_spin,code=pressKey'r'},
    WIDGET.newSwitch{name='invis',     x=240, y=300,lim=200,font=40,disp=function() return invis end,code=pressKey'q',hideF=function() return state==1 end},
    WIDGET.newSwitch{name='tapControl',x=240, y=370,lim=200,font=40,disp=function() return tapControl end,code=pressKey'w',hideF=function() return state==1 end},

    WIDGET.newKey{name='up',           x=155, y=460,w=100,fText="↑",font=50, color='Y',code=pressKey'up',   hideF=function() return tapControl end},
    WIDGET.newKey{name='down',         x=155, y=660,w=100,fText="↓",font=50, color='Y',code=pressKey'down', hideF=function() return tapControl end},
    WIDGET.newKey{name='left',         x=55,  y=560,w=100,fText="←",font=50, color='Y',code=pressKey'left',  hideF=function() return tapControl end},
    WIDGET.newKey{name='right',        x=255, y=560,w=100,fText="→",font=50,color='Y',code=pressKey'right', hideF=function() return tapControl end},
    WIDGET.newKey{name='skip',         x=155, y=400,w=100,font=20,          color='Y',code=pressKey'space', hideF=function() return state~=1 or not skipper.cd or skipper.cd>0 end},
    WIDGET.newKey{name='record1',      x=1100,y=390,w=220,h=50,fText="",   color='H',code=pressKey'1',     hideF=function() return state==2 end},
    WIDGET.newKey{name='record2',      x=1100,y=450,w=220,h=50,fText="",   color='H',code=pressKey'2',     hideF=function() return state==2 end},
    WIDGET.newKey{name='replay1',      x=1245,y=390,w=50,fText="!",        color='G',code=pressKey'c1',    hideF=function() return state==2 or #repeater.seq[1]==0 end},
    WIDGET.newKey{name='replay2',      x=1245,y=450,w=50,fText="!",        color='G',code=pressKey'c2',    hideF=function() return state==2 or #repeater.seq[2]==0 end},
    WIDGET.newButton{name='back',      x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
