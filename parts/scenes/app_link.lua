local ms=love.mouse
local msIsDown,kbIsDown=ms.isDown,love.keyboard.isDown
local gc=love.graphics
local gc_setColor,gc_rectangle,gc_draw=gc.setColor,gc.rectangle,gc.draw
local setFont,mStr=FONT.set,GC.mStr

local int,rnd,abs=math.floor,math.random,math.abs
local max,min=math.max,math.min
local ins,rem=table.insert,table.remove

local levels={
    {c=6,r=3,color=3},
    {c=6,r=4,color=3},
    {c=6,r=4,color=4},
    {c=8,r=5,color=4},
    {c=8,r=6,color=5},
    {c=9,r=6,color=5},
    {c=10,r=6,color=6},
    {c=12,r=7,color=6},
    {c=14,r=8,color=7},
    {c=14,r=9,color=7},
    {c=15,r=10,color=7},
    {c=17,r=10,color=8},
    {c=18,r=11,color=8},
    {c=20,r=12,color=9},
    {c=22,r=13,color=9},
    {c=24,r=14,color=9},
}
local colorList={
    COLOR.lR,
    COLOR.lB,
    COLOR.lY,
    COLOR.lG,
    COLOR.lM,
    COLOR.lC,
    COLOR.H,
    COLOR.Z,
    COLOR.lF,
}
gc.setDefaultFilter('nearest','nearest')
local iconList={
    GC.DO{10,10,{'fRect',2,2,6,6}},
    GC.DO{10,10,{'dRect',2.5,2.5,5,5}},
    GC.DO{10,10,{'fCirc',5,5,2}},
    GC.DO{10,10,{'fRect',2,2,2,6},{'fRect',6.5,2,2,6}},
    GC.DO{10,10,{'fRect',2,2,1,1},{'fRect',3,3,1,1},{'fRect',4,4,1,1},{'fRect',5,5,1,1},{'fRect',6,6,1,1},{'fRect',7,7,1,1}},
    GC.DO{10,10,{'fRect',2,2,2,2},{'fRect',2,6,2,2},{'fRect',6,2,2,2},{'fRect',6,6,2,2}},
    GC.DO{1,1},
    GC.DO{10,10,{'fRect',2,2,1,6},{'fRect',3,2,1,5},{'fRect',4,2,1,4},{'fRect',5,2,1,3},{'fRect',6,2,1,2},{'fRect',7,2,1,1}},
    GC.DO{10,10,{'fRect',2,5,3,3},{'fRect',5,2,3,3}},
}
gc.setDefaultFilter('linear','linear')

local invis
local state
local startTime,time
local progress,level
local score,score1
local combo,comboTime,maxCombo,noComboBreak
local field={
    x=160,y=40,
    w=960,h=640,
    c=16,r=10,
    remain=0,
}
local lines={}
local selX,selY

local function resetBoard()
    selX,selY=false,false

    local colors=levels[level].color
    field.c,field.r=levels[level].c,levels[level].r

    local total=field.r*field.c/2-- Total cell count
    local pool=TABLE.new(int(total/colors),colors)
    for i=1,total%colors do pool[i]=pool[i]+1 end
    for i=1,#pool do pool[i]=pool[i]*2 end
    field.remain=total
    field.full=true
    total=total*2

    TABLE.cut(field)
    for y=1,field.r do
        field[y]={}
        for x=1,field.c do
            local ri=0
            local rn=rnd(total)
            while rn>0 do
                ri=ri+1
                rn=rn-pool[ri]
            end
            total=total-1
            pool[ri]=pool[ri]-1
            field[y][x]=ri
        end
    end

    noComboBreak=true
    comboTime=comboTime+2
    SYSFX.newShade(2,field.x,field.y,field.w,field.h,1,1,1)
end
local function newGame()
    state=0
    level=1
    progress={}
    time=0
    startTime=TIME()
    score,score1,combo,comboTime,maxCombo=0,0,0,0,0
    resetBoard()
end
local function addPoint(list,x,y)
    local l=#list
    if x~=list[l-1] or y~=list[l] then
        list[l+1]=x
        list[l+2]=y
    end
end
local function checkLink(x1,y1,x2,y2)
    -- Y-X-Y Check
    local bestLen,bestLine=1e99,false
    do
        if x1>x2 then x1,y1,x2,y2=x2,y2,x1,y1 end
        local luy,ldy,ruy,rdy=y1,y1,y2,y2
        while luy>1       and not field[luy-1][x1] do luy=luy-1 end
        while ldy<field.r and not field[ldy+1][x1] do ldy=ldy+1 end
        while ruy>1       and not field[ruy-1][x2] do ruy=ruy-1 end
        while rdy<field.r and not field[rdy+1][x2] do rdy=rdy+1 end
        for y=max(luy,ruy),min(ldy,rdy) do
            local nextLine
            for x=x1+1,x2-1 do if field[y][x] then nextLine=true break end end-- goto CONTINUE_nextRow
            if not nextLine then
                local len=abs(x1-x2)+abs(y-y1)+abs(y-y2)
                if len<bestLen then
                    bestLen=len
                    bestLine={x1,y1}
                    addPoint(bestLine,x1,y)
                    addPoint(bestLine,x2,y)
                    addPoint(bestLine,x2,y2)
                end
            end
            -- ::CONTINUE_nextRow::
        end
    end
    -- X-Y-X Check
    do
        if y1>y2 then x1,y1,x2,y2=x2,y2,x1,y1 end
        local ulx,urx,dlx,drx=x1,x1,x2,x2
        while ulx>1       and not field[y1][ulx-1] do ulx=ulx-1 end
        while urx<field.c and not field[y1][urx+1] do urx=urx+1 end
        while dlx>1       and not field[y2][dlx-1] do dlx=dlx-1 end
        while drx<field.c and not field[y2][drx+1] do drx=drx+1 end
        for x=max(ulx,dlx),min(urx,drx) do
            local nextLine
            for y=y1+1,y2-1 do if field[y][x] then nextLine=true break end end-- goto CONTINUE_nextCol
            if not nextLine then
                local len=abs(y1-y2)+abs(x-x1)+abs(x-x2)
                if len<bestLen then
                    bestLen=len
                    bestLine={x1,y1}
                    addPoint(bestLine,x,y1)
                    addPoint(bestLine,x,y2)
                    addPoint(bestLine,x2,y2)
                end
            end
            -- ::CONTINUE_nextCol::
        end
    end
    return bestLine
end
local function tap(x,y)
    if x>=1 and x<=field.c and y>=1 and y<=field.r then
        if state==0 then
            state=1
            startTime=TIME()
        elseif state==1 then
            if selX and (x~=selX or y~=selY) and field[y][x]==field[selY][selX] then
                local line=checkLink(x,y,selX,selY)
                if line then
                    ins(lines,{time=0,line=line})

                    -- Clear
                    field[y][x]=false
                    field[selY][selX]=false
                    field.remain=field.remain-1
                    field.full=false

                    -- Score
                    local s=1000+int(combo^.9)
                    score=score+s
                    TEXT.show("+"..s,1205,600,20,'score')

                    -- Combo
                    if comboTime==0 then
                        combo=0
                        noComboBreak=false
                    end
                    comboTime=comboTime*max(1-combo*.001,.95)+max(1-combo*.01,.8)
                    combo=combo+1
                    if combo>maxCombo then maxCombo=combo end

                    -- Check win
                    if field.remain==0 then
                        if noComboBreak then
                            SFX.play('emit')
                            SFX.play('clear_4')
                            TEXT.show("FULL COMBO",640,360,100,'beat',.626)
                            comboTime=comboTime+3
                            score=int(score*1.1)
                        end
                        ins(progress,
                            noComboBreak and
                            ("%s [FC] %.2fs"):format(level,TIME()-startTime) or
                            ("%s - %.2fs"):format(level,TIME()-startTime)
                        )
                        level=level+1
                        if levels[level] then
                            resetBoard()
                            SFX.play('reach')
                        else
                            state=2
                            SFX.play('win')
                        end
                    else
                        SFX.play(
                            combo<50 and 'clear_1' or
                            combo<100 and 'clear_2' or
                            'clear_3',.8
                        )
                    end
                    selX,selY=false,false
                else
                    selX,selY=x,y
                    SFX.play('lock',.9)
                end
            else
                if field[y][x] and (x~=selX or y~=selY) then
                    selX,selY=x,y
                    SFX.play('lock',.8)
                end
            end
        end
    end
end

local scene={}

function scene.enter()
    invis=false
    newGame()
    BGM.play('truth')
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='r' then
        if state~=1 or tryReset() then
            newGame()
        end
    elseif key=='z' or key=='x' then
        love.mousepressed(ms.getPosition())
    elseif key=='escape' then
        if state~=1 or tryBack() then
            SCN.back()
        end
    elseif state==0 then
        if key=='q' then
            invis=not invis
        end
    end
end
local function touch(x,y)
    x=int((x-field.x)/field.w*field.c+1)
    y=int((y-field.y)/field.h*field.r+1)
    tap(x,y)
end
function scene.mouseDown(x,y,k) if k==1 or k==2 or not k then touch(x,y) end end
function scene.mouseMove(x,y) if (msIsDown(1) or kbIsDown('z','x')) then touch(x,y) end end
function scene.touchDown(x,y) touch(x,y) end
function scene.touchMove(x,y) touch(x,y) end

function scene.update(dt)
    if state==1 then
        time=TIME()-startTime
        comboTime=max(comboTime-dt,0)
        score1=score1+MATH.sign(score-score1)+int((score-score1)*.1+.5)
    end

    for i=#lines,1,-1 do
        local L=lines[i]
        L.time=L.time+dt
        if L.time>=1 then
            rem(lines,i)
        end
    end
end

function scene.draw()
    gc.push('transform')
        -- Camera
        gc.translate(field.x,field.y)

        -- Background
        gc.setColor(COLOR.dX)
        gc.rectangle('fill',0,0,field.w,field.h)

        gc.scale(field.w/field.c,field.h/field.r)

        -- Matrix
        local mono=state==0 or invis and not field.full
        if mono then
            gc_setColor(COLOR.dH)
            for y=1,field.r do
                for x=1,field.c do
                    if field[y][x] then
                        gc_rectangle('fill',x-1,y-1,1,1)
                    end
                end
            end
        else
            for y=1,field.r do
                for x=1,field.c do
                    local t=field[y][x]
                    if t then
                        gc_setColor(colorList[t])
                        gc_rectangle('fill',x-1,y-1,1,1)
                        gc_setColor(0,0,0,.26)
                        gc_draw(iconList[t],x-1,y-1,nil,.1,.1)
                    end
                end
            end
        end

        -- Selecting box
        gc.setLineWidth(.1)
        if selX then
            gc_setColor(1,1,1)
            gc_rectangle('line',selX-1+.05,selY-1+.05,.9,.9)
        end

        -- Clearing lines
        gc.translate(-.5,-.5)
        for i=1,#lines do
            gc_setColor(1,1,1,1-lines[i].time)
            gc.line(lines[i].line)
        end
    gc.pop()
    -- Frame

    if state==2 then
        gc.setColor(.9,.9,0)-- win
    elseif state==1 then
        gc.setColor(.9,.9,.9)-- game
    elseif state==0 then
        gc.setColor(.2,.8,.2)-- ready
    end
    gc.setLineWidth(6)
    gc.rectangle('line',field.x-5,field.y-5,field.w+10,field.h+10)

    -- Draw no-setting area
    if state==2 then
        gc.setColor(1,0,0,.3)
        gc.rectangle('fill',0,100,155,80)
    end

    -- Maxcombo
    setFont(20)gc.setColor(COLOR.dF)
    gc.print(maxCombo,1142,1)

    -- Time
    setFont(30)gc.setColor(COLOR.Z)
    gc.print(("%.3f"):format(time),1140,20)

    -- Progress time list
    setFont(15)gc.setColor(.6,.6,.6)
    for i=1,#progress do gc.print(progress[i],1140,40+20*i) end

    -- Combo Rectangle
    if comboTime>0 then
        local r=32*comboTime^.3
        gc.setColor(1,1,1,min(.6+comboTime,1)*.25)
        gc.rectangle('fill',1205-r,440-r,2*r,2*r,2)
        gc.setColor(1,1,1,min(.6+comboTime,1))
        gc.setLineWidth(2)
        gc.rectangle('line',1205-r,440-r,2*r,2*r,4)
    end

    -- Combo Text
    setFont(60)
    if combo>50 then
        gc.setColor(1,.2,.2,min(.3+comboTime*.5,1)*min(comboTime,1))
        mStr(combo,1205+(rnd()-.5)*combo^.5,398+(rnd()-.5)*combo^.5)
    end
    gc.setColor(1,1,max(1-combo*.001,.5),min(.4+comboTime,1))
    mStr(combo,1205,398)

    -- Score
    setFont(25)gc.setColor(COLOR.Z)
    mStr(score1,1205,560)
end

scene.widgetList={
    WIDGET.newButton{name='reset',x=80,y=60,w=110,h=60,color='lG',fText=CHAR.icon.retry_spin,code=pressKey'r',hideF=function() return state==0 end},
    WIDGET.newSwitch{name='invis',x=100,y=140,lim=80,disp=function() return invis end,code=pressKey'q',hideF=function() return state==1 end},
    WIDGET.newButton{name='back',x=1200,y=660,w=110,font=45,sound='back',fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
