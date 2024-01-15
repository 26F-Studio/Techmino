local tc=love.touch
local gc_setColor,gc_setLineWidth=GC.setColor,GC.setLineWidth
local gc_draw,gc_line=GC.draw,GC.line
local gc_circle,gc_print=GC.circle,GC.print

local SCR,VK=SCR,VK
local GAME,PLAYERS=GAME,PLAYERS
local setFont,mStr=FONT.set,GC.mStr

local noTouch,noKey=false,false
local touchMoveLastFrame=false
local trigGameRate,gameRate
local autoSkip=0
local modeTextPos,modeTextWidK

local replaying
local repRateStrings={[0]="pause",[.125]="0.125x",[.5]="0.5x",[1]="1x",[2]="2x",[5]="5x"}

local scene={}

-- Widget hashmap (key = widget name, value = index)
local widgetHashmap={}
local function widgetWithName(name)
    if #widgetHashmap==0 then widgetHashmap=TABLE.kvSwap(TABLE.extract(scene.widgetList,'name')) end
    return scene.widgetList[widgetHashmap[name]]
end

local function _updateMenuButtons()
    widgetWithName('restart').hide=replaying

    local pos=(GAME.tasUsed or replaying) and 'right' or SETTING.menuPos
    modeTextWidK=math.min(280/TEXTOBJ.modeName:getWidth(),1)
    if SETTING.portrait then
        widgetWithName('restart').y=25-400
        widgetWithName('pause').y=25-400
    else
        widgetWithName('restart').y=25
        widgetWithName('pause').y=25
    end
    if GAME.replaying then
        widgetWithName('pause').x=1195
        modeTextPos=1185-TEXTOBJ.modeName:getWidth()*modeTextWidK
    elseif pos=='right' then
        widgetWithName('restart').x=1125
        widgetWithName('pause').x=1195
        modeTextPos=1115-TEXTOBJ.modeName:getWidth()*modeTextWidK
    elseif pos=='middle' then
        widgetWithName('restart').x=360
        widgetWithName('pause').x=860
        modeTextPos=940
    elseif pos=='left' then
        widgetWithName('restart').x=120
        widgetWithName('pause').x=190
        modeTextPos=1200-TEXTOBJ.modeName:getWidth()*modeTextWidK
    end
end

local speedButtons={'rep0','repP8','repP2','rep1','rep2','rep5'}
local stepButtons={'step','autoSkip'}
local replayButtons=TABLE.combine(speedButtons,stepButtons)
local function _updateRepButtons()
    local L=scene.widgetList
    if replaying or GAME.tasUsed then
        for i=1,#speedButtons do
            widgetWithName(speedButtons[i]).hide=false
        end
        for i=1,#stepButtons do
            widgetWithName(stepButtons[i]).hide=gameRate~=0
        end
        if gameRate==0 then
            widgetWithName('rep0').hide=true
        elseif gameRate==.125 then
            widgetWithName('repP8').hide=true
        elseif gameRate==.5 then
            widgetWithName('repP2').hide=true
        elseif gameRate==1 then
            widgetWithName('rep1').hide=true
        elseif gameRate==2 then
            widgetWithName('rep2').hide=true
        elseif gameRate==5 then
            widgetWithName('rep5').hide=true
        end
    else
        for i=1,#replayButtons do widgetWithName(replayButtons[i]).hide=true end
    end
end
local function _speedUp()
    if gameRate==.125 then gameRate=.5
    elseif gameRate==.5 then gameRate=1
    elseif gameRate==1 then gameRate=2
    elseif gameRate==2 then gameRate=5
    end
    _updateRepButtons()
end
local function _speedDown()
    if gameRate==.5 then gameRate=.125
    elseif gameRate==1 then gameRate=.5
    elseif gameRate==2 then gameRate=1
    elseif gameRate==5 then gameRate=2
    end
    _updateRepButtons()
end
local function _rep0()
    scene.widgetList[1].hide=true
    scene.widgetList[7].hide=false
    gameRate=0
    _updateRepButtons()
end
local function _repP8()
    scene.widgetList[2].hide=true
    gameRate=.125
    _updateRepButtons()
end
local function _repP2()
    scene.widgetList[3].hide=true
    gameRate=.5
    _updateRepButtons()
end
local function _rep1()
    scene.widgetList[4].hide=true
    gameRate=1
    _updateRepButtons()
end
local function _rep2()
    scene.widgetList[5].hide=true
    gameRate=2
    _updateRepButtons()
end
local function _rep5()
    scene.widgetList[6].hide=true
    gameRate=5
    _updateRepButtons()
end
local function _skip(P)
    if P.frameRun<179 then
        trigGameRate=trigGameRate+(179-P.frameRun)
    else
        trigGameRate=trigGameRate+MATH.clamp(P.waiting+P.falling,1,300)
    end
end
local fastForwardObj = GC.newText(FONT.get(40),CHAR.icon.fastForward)
local nextFrameObj = GC.newText(FONT.get(40),CHAR.icon.nextFrame)
local function _updateStepButton()
    local w=PLAYERS[1].waiting+PLAYERS[1].falling
    if (autoSkip==1 and w>1) or (autoSkip>0 and PLAYERS[1].frameRun<178) then
        widgetWithName('step').obj=fastForwardObj
    else
        widgetWithName('step').obj=nextFrameObj
    end
end
local function _step()
    local P=PLAYERS[1]
    if autoSkip>0 then
        _skip(P)
    else
        trigGameRate=trigGameRate+1
    end
end
local function _fullSkipCheck()
    if autoSkip<2 or PLAYERS[1].waiting+PLAYERS[1].falling<=0 then return end
    _step()
end
local function _setAS(v)
    autoSkip=v
    if v==1 then _updateStepButton() end
end
local function _autoSkipDisp()
    return (
        autoSkip==0 and 'No skip' or
        autoSkip==1 and 'Semi-skip' or
        autoSkip==2 and 'Full skip'
    )
end

local function _restart()
    resetGameData(PLAYERS[1].frameRun<240 and 'q')
    noKey=replaying
    noTouch=replaying
    trigGameRate,gameRate=0,1
    _updateRepButtons()
end
local function _checkGameKeyDown(key)
    local k=KEY_MAP.keyboard[key]
    if k then
        if k>0 then
            if noKey then return end
            PLAYERS[1]:pressKey(k)
            VK.press(k)
            _updateStepButton()
            _fullSkipCheck()
            return
        elseif not GAME.fromRepMenu then
            _restart()
            return
        end
    end
    return true-- No key pressed
end

function scene.enter()
    if GAME.init then
        resetGameData()
        GAME.init=false
    end

    replaying=GAME.replaying
    noKey=replaying
    noTouch=not SETTING.VKSwitch or replaying

    if SCN.prev~='depause' and SCN.prev~='pause' then
        trigGameRate,gameRate=0,1
    elseif not replaying then
        if GAME.tasUsed then
            trigGameRate,gameRate=0,0
            autoSkip=1
        else
            trigGameRate,gameRate=0,1
            autoSkip=0
        end
    end

    _updateStepButton()
    _updateRepButtons()
    _updateMenuButtons()
end

scene.mouseDown=NULL
function scene.touchDown(x,y)
    if noTouch then return end

    local t=VK.on(x,y)
    if t then
        PLAYERS[1]:pressKey(t)
        VK.touch(t,x,y)
        _updateStepButton()
        _fullSkipCheck()
    end
end
function scene.touchUp(x,y)
    if noTouch then return end

    local n=VK.on(x,y)
    if n then
        PLAYERS[1]:releaseKey(n)
        VK.release(n)
    end
end
function scene.touchMove()
    if noTouch or touchMoveLastFrame then return end
    touchMoveLastFrame=true

    local L=tc.getTouches()
    for i=#L,1,-1 do
        L[2*i-1],L[2*i]=SCR.xOy:inverseTransformPoint(tc.getPosition(L[i]))
    end
    local keys=VK.keys
    for n=1,#keys do
        local B=keys[n]
        if B.ava then
            local nextKey
            for i=1,#L,2 do
                if (L[i]-B.x)^2+(L[i+1]-B.y)^2<=B.r^2 then
                    nextKey=true
                    break-- goto CONTINUE_nextKey
                end
            end
            if not nextKey then
                PLAYERS[1]:releaseKey(n)
                VK.release(n)
            end
            -- ::CONTINUE_nextKey::
        end
    end
end
function scene.keyDown(key,isRep)
    if replaying then
        if key=='space' then
            if not isRep then
                gameRate=gameRate==0 and 1 or 0
            end
            _updateRepButtons()
        elseif key=='left' then
            if not isRep then
                _speedDown()
            end
        elseif key=='right' then
            if gameRate==0 then
                _step()
            elseif not isRep then
                _speedUp()
            end
        elseif key=='escape' then
            pauseGame()
        end
    else
        if isRep then
            return
        elseif _checkGameKeyDown(key) then
            if GAME.tasUsed then
                if key=='f1' then
                    if not isRep then
                        gameRate=gameRate==0 and .125 or 0
                    end
                    _updateRepButtons()
                elseif key=='f2' then
                    if not isRep then
                        _speedDown()
                    end
                elseif key=='f3' then
                    if gameRate==0 then
                        _step()
                    elseif not isRep then
                        _speedUp()
                    end
                elseif key=='f4' then
                    autoSkip=(autoSkip+1)%3
                end
            end
            if key=='escape' then
                pauseGame()
            end
        end
    end
end
function scene.keyUp(key)
    if noKey then return end
    local k=KEY_MAP.keyboard[key]
    if k then
        if k>0 then
            PLAYERS[1]:releaseKey(k)
            VK.release(k)
        end
    end
end
function scene.gamepadDown(key)
    if noKey then return end
    local k=KEY_MAP.joystick[key]
    if k then
        if k>0 then
            PLAYERS[1]:pressKey(k)
            VK.press(k)
            _updateStepButton()
            _fullSkipCheck()
        else
            _restart()
        end
    elseif key=='back' then
        pauseGame()
    end
end
function scene.gamepadUp(key)
    if noKey then return end
    local k=KEY_MAP.joystick[key]
    if k then
        if k>0 then
            PLAYERS[1]:releaseKey(k)
            VK.release(k)
        end
    end
end

local function _update_common(dt)
    -- Update control
    touchMoveLastFrame=false
    VK.update(dt)

    -- Update players
    for p=1,#PLAYERS do PLAYERS[p]:update(dt) end

    -- Fresh royale target
    if PLAYERS[1].frameRun%120==0 and PLAYERS[1].gameEnv.layout=='royale' then
        freshMostDangerous()
    end

    -- Warning check
    checkWarning(PLAYERS[1],dt)
end
function scene.update(dt)
    trigGameRate=trigGameRate+gameRate
    while trigGameRate>=1 do
        trigGameRate=trigGameRate-1
        _update_common(dt)
        _updateStepButton()
    end
end

local tasText=GC.newText(getFont(100),"TAS")
local function _drawAtkPointer(x,y)
    local t=TIME()
    local a=t*3%1*.8
    t=math.sin(t*20)

    gc_setColor(.2,.7+t*.2,1,.6+t*.4)
    gc_circle('fill',x,y,25,6)

    gc_setColor(0,.6,1,.8-a)
    gc_circle('line',x,y,30*(1+a),6)
end
function scene.draw()
    local tas=GAME.tasUsed
    if tas then
        setFont(100)
        gc_setColor(.4,.4,.4,.5)
        mDraw(tasText,640,360,nil,5)
    end

    local repMode=GAME.replaying or tas

    -- Players
    for p=1,#PLAYERS do
        PLAYERS[p]:draw(repMode)
    end

    -- Virtual keys
    VK.draw()

    -- Attacking & Being attacked
    if PLAYERS[1].gameEnv.layout=='royale' then
        local P=PLAYERS[1]
        gc_setLineWidth(5)
        gc_setColor(.8,1,0,.2)
        for i=1,#P.atker do
            local p=P.atker[i]
            gc_line(p.centerX,p.centerY,P.x+300*P.size,P.y+620*P.size)
        end
        if P.atkMode~=4 then
            if P.atking then
                _drawAtkPointer(P.atking.centerX,P.atking.centerY)
            end
        else
            for i=1,#P.atker do
                local p=P.atker[i]
                _drawAtkPointer(p.centerX,p.centerY)
            end
        end
    end

    -- Mode info & Highscore & Current Rank
    local dy=SETTING.portrait and -390 or 0
    gc_setColor(1,1,1,.82)
    gc_draw(TEXTOBJ.modeName,modeTextPos,10+dy,0,modeTextWidK,1)
    if not replaying then
        local M=GAME.curMode
        if M then
            if M.score and M.records[1] then
                setFont(15)
                gc_setColor(1,1,1,.6)
                gc_print(M.scoreDisp(M.records[1]),modeTextPos,45+dy)
            end
            if M.getRank then
                local R=M.getRank(PLAYERS[1])
                if R and R>0 then
                    setFont(100)
                    local c=RANK_COLORS[R]
                    gc_setColor(c[1],c[2],c[3],.12)
                    mStr(RANK_CHARS[R],640,50+dy)
                end
            end
        end
    end

    -- Replaying
    if replaying or tas then
        setFont(20)
        gc_setColor(1,1,TIME()%.8>.4 and 1 or 0)
        mStr(replaying and text.replaying or text.tasUsing,770,6)
        gc_setColor(1,1,1,.8)
        mStr(("%s   %sf"):format(repRateStrings[gameRate],PLAYERS[1].frameRun),770,31)
    end

    -- Warning
    drawWarning()
end
scene.widgetList={
    WIDGET.newKey   {name='rep0',    x=40, y=50, w=60, code=_rep0,    font=40,          fText=CHAR.icon.pause},          -- 1
    WIDGET.newKey   {name='repP8',   x=105,y=50, w=60, code=_repP8,   font=40,          fText=CHAR.icon.speedOneEights}, -- 2
    WIDGET.newKey   {name='repP2',   x=170,y=50, w=60, code=_repP2,   font=40,          fText=CHAR.icon.speedOneHalf},   -- 3
    WIDGET.newKey   {name='rep1',    x=235,y=50, w=60, code=_rep1,    font=40,          fText=CHAR.icon.speedOne},       -- 4
    WIDGET.newKey   {name='rep2',    x=300,y=50, w=60, code=_rep2,    font=40,          fText=CHAR.icon.speedTwo},       -- 5
    WIDGET.newKey   {name='rep5',    x=365,y=50, w=60, code=_rep5,    font=40,          fText=CHAR.icon.speedFive},      -- 6
    WIDGET.newKey   {name='step',    x=40, y=50, w=60, code=_step,    font=40,          fText=CHAR.icon.nextFrame},      -- 7
    WIDGET.newSlider{name='autoSkip',x=40, y=130,w=100,code=_setAS,   axis={0,2,1},     disp=function()return autoSkip end,show=_autoSkipDisp},
    WIDGET.newKey   {name='restart', x=0,  y=25, w=60, code=_restart, font=40,          fText=CHAR.icon.retry_spin},     -- 10
    WIDGET.newKey   {name='pause',   x=0,  y=25, w=60, code=pauseGame,font=40,          fText=CHAR.icon.pause},          -- 11
}

return scene
