local gc,kb,tc=love.graphics,love.keyboard,love.touch

local gc_setColor=gc.setColor
local gc_print,gc_printf=gc.print,gc.printf
local gc_draw=gc.draw
local setFont,mStr=FONT.set,GC.mStr

local ins=table.insert

local SCR,VK,NET,NETPLY=SCR,VK,NET,NETPLY
local PLAYERS,GAME=PLAYERS,GAME

local textBox=WIDGET.newTextBox{name='texts',x=340,y=80,w=600,h=560}
local inputBox=WIDGET.newInputBox{name='input',x=340,y=660,w=600,h=50,limit=256}

local playing
local lastUpstreamTime
local upstreamProgress
local noTouch,noKey=false,false
local touchMoveLastFrame=false
local newMessageTimer

local function _hideReadyUI()
    return
        playing or
        NET.roomState.start or
        NET.getlock('ready')
end

local function _setCancel()NET.signal_setMode(0)end
local function _setReady()NET.signal_setMode(1)end
local function _setSpectate()NET.signal_setMode(2)end
local function _gotoSetting()
    GAME.prevBG=BG.cur
    SCN.go('setting_game')
end
local function _quit()
    if tryBack()then
        NET.signal_quit()
        if SCN.stack[#SCN.stack-1]=='net_newRoom'then
            SCN.pop()
        end
        SCN.back()
    end
end
local function _switchChat()
    if inputBox.hide then
        textBox.hide=false
        inputBox.hide=false
        WIDGET.focus(inputBox)
    else
        textBox.hide=true
        inputBox.hide=true
        WIDGET.unFocus(true)
    end
end

local scene={}

function scene.sceneInit()
    textBox.hide=true
    textBox:clear()
    inputBox.hide=true

    noTouch=not SETTING.VKSwitch
    playing=false
    lastUpstreamTime=0
    upstreamProgress=1
    newMessageTimer=0

    if SCN.prev=='setting_game'then
        NET.changeConfig()
    end
    if GAME.prevBG then
        BG.set(GAME.prevBG)
        GAME.prevBG=false
    end
    if NET.specSRID then
        NET.wsconn_stream(NET.specSRID)
        NET.specSRID=false
    end
end
function scene.sceneBack()
    GAME.playing=false
end

scene.mouseDown=NULL
function scene.mouseMove(x,y)NETPLY.mouseMove(x,y)end
function scene.touchDown(x,y)
    if not playing then NETPLY.mouseMove(x,y)return end
    if noTouch then return end

    local t=VK.on(x,y)
    if t then
        PLAYERS[1]:pressKey(t)
        VK.touch(t,x,y)
    end
end
function scene.touchUp(x,y)
    if not playing or noTouch then return end
    local n=VK.on(x,y)
    if n then
        PLAYERS[1]:releaseKey(n)
        VK.release(n)
    end
end
function scene.touchMove()
    if touchMoveLastFrame or not playing or noTouch then return end
    touchMoveLastFrame=true

    local L=tc.getTouches()
    for i=#L,1,-1 do
        L[2*i-1],L[2*i]=SCR.xOy:inverseTransformPoint(tc.getPosition(L[i]))
    end
    local keys=VK.keys
    for n=1,#keys do
        local B=keys[n]
        if B.ava then
            for i=1,#L,2 do
                if(L[i]-B.x)^2+(L[i+1]-B.y)^2<=B.r^2 then
                    goto CONTINUE_nextKey
                end
            end
            PLAYERS[1]:releaseKey(n)
            VK.release(n)
        end
        ::CONTINUE_nextKey::
    end
end
function scene.keyDown(key,isRep)
    if key=='escape'then
        if not inputBox.hide then
            _switchChat()
        else
            _quit()
        end
    elseif key=='return'then
        local mes=STRING.trim(inputBox:getText())
        if not inputBox.hide and #mes>0 then
            NET.sendMessage(mes)
            inputBox:clear()
        else
            _switchChat()
        end
    elseif not inputBox.hide then
        WIDGET.focus(inputBox)
        inputBox:keypress(key)
    elseif playing then
        if noKey or isRep then return end
        local k=KEY_MAP.keyboard[key]
        if k and k>0 then
            PLAYERS[1]:pressKey(k)
            VK.press(k)
        end
    elseif not _hideReadyUI()then
        if key=='space'then
            if NETPLY.getSelfJoinMode()==0 then
                (kb.isDown('lctrl','rctrl','lalt','ralt')and _setSpectate or _setReady)()
            else
                _setCancel()
            end
        elseif key=='s'then
            _gotoSetting()
        end
    end
end
function scene.keyUp(key)
    if not playing or noKey then return end
    local k=KEY_MAP.keyboard[key]
    if k and k>0 then
        PLAYERS[1]:releaseKey(k)
        VK.release(k)
    end
end
function scene.gamepadDown(key)
    if key=='back'then
        scene.keyDown('escape')
    else
        if not playing then return end
        local k=KEY_MAP.joystick[key]
        if k and k>0 then
            PLAYERS[1]:pressKey(k)
            VK.press(k)
        end
    end
end
function scene.gamepadUp(key)
    if not playing then return end
    local k=KEY_MAP.joystick[key]
    if k and k>0 then
        PLAYERS[1]:releaseKey(k)
        VK.release(k)
    end
end

function scene.socketRead(cmd,d)
    if cmd=='join'then
        textBox:push{
            COLOR.lR,d.username,
            COLOR.dY,"#"..d.uid.." ",
            COLOR.Y,text.joinRoom,
        }
        SFX.play('warn_1')
    elseif cmd=='leave'then
        textBox:push{
            COLOR.lR,d.username,
            COLOR.dY,"#"..d.uid.." ",
            COLOR.Y,text.leaveRoom,
        }
    elseif cmd=='talk'then
        newMessageTimer=80
        textBox:push{
            COLOR.Z,d.username,
            COLOR.dY,"#"..d.uid.." ",
            COLOR.N,d.message or"[_]",
        }
    elseif cmd=='go'then
        if not playing then
            playing=true
            lastUpstreamTime=0
            upstreamProgress=1
            resetGameData('n',NET.seed)
            NETPLY.mouseMove(0,0)
        else
            MES.new('warn',"Redundant [Go]")
        end
    elseif cmd=='finish'then
        playing=false
        BG.set()
    end
end

function scene.update(dt)
    if NET.checkPlayDisconn()then
        NET.wsclose_stream()
        SCN.back()
        return
    end
    if playing then
        local P1=PLAYERS[1]

        touchMoveLastFrame=false
        VK.update(dt)

        --Update players
        for p=1,#PLAYERS do PLAYERS[p]:update(dt)end

        --Warning check
        checkWarning(dt)

        --Upload stream
        if not NET.spectate and P1.frameRun-lastUpstreamTime>8 then
            local stream
            if not GAME.rep[upstreamProgress]then
                ins(GAME.rep,P1.frameRun)
                ins(GAME.rep,0)
            end
            stream,upstreamProgress=DATA.dumpRecording(GAME.rep,upstreamProgress)
            if #stream%3==1 then
                stream=stream.."\0\0"
            elseif #stream%3==2 then
                stream=stream.."\0\0\0\0"
            end
            NET.uploadRecStream(stream)
            lastUpstreamTime=PLAYERS[1].alive and P1.frameRun or 1e99
        end
    else
        NETPLY.update(dt)
    end
    if newMessageTimer>0 then
        newMessageTimer=newMessageTimer-1
    end
end

function scene.draw()
    if playing then
        --Players
        for p=1,#PLAYERS do
            PLAYERS[p]:draw()
        end

        --Virtual keys
        VK.draw()

        --Warning
        drawWarning()

        if NET.spectate then
            setFont(30)
            gc_setColor(.2,1,0,.8)
            gc_print(text.spectating,940,0)
        end
    else
        --Users
        NETPLY.draw()

        --Ready & Set mark
        setFont(50)
        if NET.roomReadyState=='allReady'then
            gc_setColor(1,.85,.6,.9)
            mStr(text.ready,640,15)
        elseif NET.roomReadyState=='connecting'then
            gc_setColor(.6,1,.9,.9)
            mStr(text.connStream,640,15)
        elseif NET.roomReadyState=='waitConn'then
            gc_setColor(.6,.95,1,.9)
            mStr(text.waitStream,640,15)
        end

        --Room info.
        gc_setColor(1,1,1)
        setFont(25)
        gc_printf(NET.roomState.roomInfo.name,0,685,1270,'right')
        setFont(40)
        gc_print(NETPLY.getCount().."/"..NET.roomState.capacity,70,655)
        if NET.roomState.private then
            gc_draw(IMG.lock,30,668)
        end
        if NET.roomState.start then
            gc_setColor(0,1,0)gc_print(text.started,230,655)
        end

        --Profile
        drawSelfProfile()

        --Player count
        drawOnlinePlayerCount()
    end

    --New message
    if newMessageTimer>0 then
        setFont(40)
        gc_setColor(.3,.7,1,(newMessageTimer/60)^2)
        gc_print("M",430,10)
    end
end
local function _hideF_ingame()return _hideReadyUI()or NETPLY.getSelfReady()end
local function _hideF_ingame2()return _hideReadyUI()or not NETPLY.getSelfReady()end
scene.widgetList={
    textBox,
    inputBox,
    WIDGET.newKey{name='setting', x=1200,y=160,w=90,h=90,font=60,fText=CHAR.icon.settings,code=_gotoSetting,hideF=_hideF_ingame},
    WIDGET.newKey{name='ready',   x=1060,y=510,w=360,h=90,color='lG',font=35, code=_setReady,hideF=_hideF_ingame},
    WIDGET.newKey{name='spectate',x=1060,y=610,w=360,h=90,color='lO',font=35, code=_setSpectate,hideF=_hideF_ingame},
    WIDGET.newKey{name='cancel',  x=1060,y=560,w=360,h=120,color='lH',font=40,code=_setCancel,hideF=_hideF_ingame2},
    WIDGET.newKey{name='chat',    x=390,y=45,w=60,fText="···",                code=_switchChat},
    WIDGET.newKey{name='quit',    x=890,y=45,w=60,font=30,fText=CHAR.icon.cross_thick,code=_quit},
}

return scene
