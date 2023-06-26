local gc,kb,tc=love.graphics,love.keyboard,love.touch

local gc_setColor=gc.setColor
local gc_print,gc_printf=gc.print,gc.printf
local gc_draw=gc.draw
local setFont,mStr=FONT.set,GC.mStr

local ins=table.insert

local SCR,VK,NET,NETPLY=SCR,VK,NET,NETPLY
local PLAYERS,GAME=PLAYERS,GAME

local textBox=NET.textBox
local inputBox=NET.inputBox

local playing
local lastUpstreamTime
local upstreamProgress
local noTouch,noKey=false,false
local touchMoveLastFrame=false

local function _setCancel()
    if NETPLY.map[USER.uid].playMode=='Gamer' then
        NET.player_setReady(false)
    else
        NET.player_setPlayMode('Gamer')
    end
end
local function _setReady()
    NET.player_setPlayMode('Gamer')
    NET.player_setReady(true)
end
local function _setSpectate()
    NET.player_setPlayMode('Spectator')
end

local function _gotoSetting()
    GAME.prevBG=BG.cur
    SCN.go('setting_game')
end
local function _quit()
    if tryBack() then
        NET.room_leave()
        GAME.playing=false
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

function scene.enter()
    noTouch=not SETTING.VKSwitch
    playing=false
    lastUpstreamTime=0
    upstreamProgress=1

    if SCN.prev=='setting_game' then
        NET.player_updateConf()
    end
    if GAME.prevBG then
        BG.set(GAME.prevBG)
        GAME.prevBG=false
    end
end
function scene.leave()
    TASK.unlock('netPlaying')
end

scene.mouseDown=NULL
function scene.mouseMove(x,y) NETPLY.mouseMove(x,y) end
function scene.touchDown(x,y)
    if not playing then NETPLY.mouseMove(x,y) return end
    if NET.spectate or noTouch then return end

    local t=VK.on(x,y)
    if t then
        PLAYERS[1]:pressKey(t)
        VK.touch(t,x,y)
    end
end
function scene.touchUp(x,y)
    if not playing or NET.spectate or noTouch then return end
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
    if key=='escape' then
        if not inputBox.hide then
            _switchChat()
        else
            _quit()
        end
    elseif key=='/' then
        if inputBox.hide then
            _switchChat()
            local mes=STRING.trim(inputBox:getText())
            if #mes==0 then
                inputBox:setText("/")
            end
        end
    elseif key=='return' or key=='kpenter' then
        local mes=STRING.trim(inputBox:getText())
        if not inputBox.hide and #mes>0 then
            if mes:sub(1,1)=='/' then
                local cmd=STRING.split(mes,' ')

                -- Common commands
                if cmd[1]=='/kick' then
                    if tonumber(cmd[2]) then NET.room_kick(tonumber(cmd[2])) end
                elseif cmd[1]=='/pw' then
                    if cmd[2] then NET.room_setPW(cmd[2]) end
                elseif cmd[1]=='/host' then
                    if tonumber(cmd[2]) then NET.player_setHost(tonumber(cmd[2])) end
                elseif cmd[1]=='/group' then
                    if tonumber(cmd[2]) and tonumber(cmd[2])%1==0 and tonumber(cmd[2])>=0 and tonumber(cmd[2])<=6 then
                        NET.player_joinGroup(tonumber(cmd[2]))
                    end
                elseif cmd[1]=='/exit' or cmd[1]=='/quit' then
                    _quit()

                -- Admin commands
                elseif cmd[1]=='/fkick' then
                    if tonumber(cmd[2]) then NET.room_kick(tonumber(cmd[2]),NET.roomState.roomId) end
                elseif cmd[1]=='/fpw' then
                    if cmd[2] then NET.room_setPW(cmd[2],NET.roomState.roomId) end
                elseif cmd[1]=='/fexit' or cmd[1]=='/fquit' then
                    NET.room_remove(NET.roomState.roomId)

                else
                    NET.textBox:push{COLOR.R,'Invalid command'}
                end
                inputBox:clear()
            elseif NET.room_chat(mes) then
                inputBox:clear()
            end
        else
            _switchChat()
        end
    elseif #key==1 and key:find("^[0-6]$") and kb.isDown('lctrl','rctrl') then
        NET.player_joinGroup(tonumber(key))
    elseif not inputBox.hide then
        WIDGET.focus(inputBox)
        inputBox:keypress(key)
    elseif playing then
        if NET.spectate or noKey or isRep then return end
        local k=KEY_MAP.keyboard[key]
        if k and k>0 then
            PLAYERS[1]:pressKey(k)
            VK.press(k)
        end
    elseif not playing then
        if key=='space' then
            if NETPLY.map[USER.uid].playMode=='Spectator' or NETPLY.map[USER.uid].readyMode=='Ready' then
                _setCancel()
            else
                (kb.isDown('lctrl','rctrl','lalt','ralt') and _setSpectate or _setReady)()
            end
        elseif key=='s' then
            _gotoSetting()
        end
    end
end
function scene.keyUp(key)
    if not playing or NET.spectate or noKey then return end
    local k=KEY_MAP.keyboard[key]
    if k and k>0 then
        PLAYERS[1]:releaseKey(k)
        VK.release(k)
    end
end
function scene.gamepadDown(key)
    if key=='back' then
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

function scene.update(dt)
    if WS.status('game')~='running' then
        TASK.unlock('netPlaying')
        NET.ws_close()
        SCN.back()
        return
    end
    if playing then
        if not TASK.getLock('netPlaying') then
            playing=false
            BG.set()
            for i=1,#NETPLY.list do
                NETPLY.list[i].readyMode='Standby'
            end
            NETPLY.freshPos()
            NET.freshRoomAllReady()
            return
        else
            touchMoveLastFrame=false
            VK.update(dt)

            if #PLAYERS>0 then
                -- Update players
                for p=1,#PLAYERS do PLAYERS[p]:update(dt) end

                local P1=PLAYERS[1]

                -- Warning check
                checkWarning(P1,dt)

                -- Upload stream
                if not NET.spectate and P1.frameRun-lastUpstreamTime>8 then
                    local stream
                    if not GAME.rep[upstreamProgress] then
                        ins(GAME.rep,P1.frameRun)
                        ins(GAME.rep,0)
                    end
                    stream,upstreamProgress=DATA.dumpRecording(GAME.rep,upstreamProgress)
                    if #stream%3==1 then
                        stream=stream.."\0\0"
                    elseif #stream%3==2 then
                        stream=stream.."\0\0\0\0"
                    end
                    NET.player_stream(stream)
                    lastUpstreamTime=PLAYERS[1].alive and P1.frameRun or 1e99
                end
            end
        end
    else
        if not TASK.getLock('netPlaying') then
            NETPLY.update(dt)
        else
            playing=true
            TASK.lock('netPlaying')
            lastUpstreamTime=0
            upstreamProgress=1
            resetGameData('n',NET.seed)
            NETPLY.mouseMove(0,0)

            for i=1,#NETPLY.list do
                local p=NETPLY.list[i]
                if p.playMode=='Gamer' then
                    p.readyMode='Playing'
                    p.place=1
                else
                    p.place=1e99
                end
            end
            NET.spectate=PLAYERS[1].uid~=USER.uid
            if NET.storedStream then
                for i=1,#NET.storedStream do
                    NET.pumpStream(NET.storedStream[i])
                end
                NET.storedStream=false
            end
        end
    end
end

function scene.draw()
    if playing then
        -- Players
        for p=1,#PLAYERS do
            PLAYERS[p]:draw()
        end

        -- Virtual keys
        VK.draw()

        -- Warning
        drawWarning()

        if NET.spectate then
            setFont(30)
            gc_setColor(.2,1,0,.8)
            gc_print(text.spectating,940,0)
        end
    else
        -- Users
        NETPLY.draw()

        -- Ready & Set mark
        setFont(50)
        if NET.roomAllReady then
            gc_setColor(.6,.95,1,.9)
            mStr(text.ready,640,15)
        end

        -- Room info.
        gc_setColor(1,1,1)
        setFont(25)
        gc_printf(NET.roomState.info.name,0,685,1270,'right')
        setFont(40)
        gc_print(#NETPLY.list.."/"..NET.roomState.capacity,70,655)
        if NET.roomState.private then
            gc_draw(IMG.lock,30,668)
        end

        -- Profile
        drawSelfProfile()

        -- Player count
        drawOnlinePlayerCount()
    end

    -- New message
    local a=TASK.getLock('receiveMessage')
    if a then
        setFont(40)
        gc_setColor(.3,.7,1,a^2)
        gc_print("M",430,10)
    end
end
local function _hideF_ready() return playing or (NETPLY.map[USER.uid].playMode=='Spectator' or NETPLY.map[USER.uid].readyMode=='Ready') end
local function _hideF_standby() return playing or not (NETPLY.map[USER.uid].playMode=='Spectator' or NETPLY.map[USER.uid].readyMode=='Ready') end
scene.widgetList={
    textBox,
    inputBox,
    WIDGET.newKey{name='setting', x=1200,y=160,w=90,h=90,font=60,fText=CHAR.icon.settings,code=_gotoSetting,hideF=_hideF_ready},
    WIDGET.newKey{name='ready',   x=1060,y=510,w=360,h=90,color='lG',font=35, code=_setReady,hideF=_hideF_ready},
    WIDGET.newKey{name='spectate',x=1060,y=610,w=360,h=90,color='lO',font=35, code=_setSpectate,hideF=_hideF_ready},
    WIDGET.newKey{name='cancel',  x=1060,y=560,w=360,h=120,color='lH',font=40,code=_setCancel,hideF=_hideF_standby},

    WIDGET.newButton{x=320,y=45,w=40,color='Z', fText="",code=function() NET.player_joinGroup(0) end,hideF=_hideF_ready},
    WIDGET.newButton{x=190,y=25,w=30,color='lR',fText="",code=function() NET.player_joinGroup(1) end,hideF=_hideF_ready},
    WIDGET.newButton{x=230,y=25,w=30,color='lG',fText="",code=function() NET.player_joinGroup(2) end,hideF=_hideF_ready},
    WIDGET.newButton{x=270,y=25,w=30,color='lB',fText="",code=function() NET.player_joinGroup(3) end,hideF=_hideF_ready},
    WIDGET.newButton{x=190,y=65,w=30,color='lY',fText="",code=function() NET.player_joinGroup(4) end,hideF=_hideF_ready},
    WIDGET.newButton{x=230,y=65,w=30,color='lM',fText="",code=function() NET.player_joinGroup(5) end,hideF=_hideF_ready},
    WIDGET.newButton{x=270,y=65,w=30,color='lC',fText="",code=function() NET.player_joinGroup(6) end,hideF=_hideF_ready},

    WIDGET.newKey{name='chat',    x=390,y=45,w=60,fText="···",                code=_switchChat},
    WIDGET.newKey{name='quit',    x=890,y=45,w=60,font=30,fText=CHAR.icon.cross_thick,code=_quit},
}

return scene
