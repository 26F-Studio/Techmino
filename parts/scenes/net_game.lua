local gc,kb,tc=love.graphics,love.keyboard,love.touch

local gc_setColor=gc.setColor
local gc_print,gc_printf=gc.print,gc.printf
local gc_draw=gc.draw
local setFont,mStr=FONT.set,GC.mStr

local ins=table.insert

local SCR,VK,NET,NETPLY=SCR,VK,NET,NETPLY
local PLAYERS,GAME=PLAYERS,GAME
local ROLLBACK=ROLLBACK

local textBox=NET.textBox
local inputBox=NET.inputBox

local playing
local paused
local abandonCount=0
local lastUpstreamTime
local upstreamProgress

-- Bot config for the +Bot button. The host can adjust type and
-- CCLoader level (Lv 1-5) in the room lobby before adding bots.
-- 9S is a built-in simple bot; CC uses the CCLoader (Cold Clear)
-- plugin. speedLV maps to the AISpeed table in parts/bot/init.lua.
local BOT_CFG={
    type='CC',
    data={next=5,hold=true,speedLV=3,node=500,randomizer='bag',_20G=false},
}
-- The four bot presets available in the lobby. key:display.
local BOT_PRESETS={
    {'CC Lv1',{type='CC',data={next=5,hold=false,speedLV=1,node=100,randomizer='bag',_20G=false}}},
    {'CC Lv2',{type='CC',data={next=5,hold=true, speedLV=2,node=200,randomizer='bag',_20G=false}}},
    {'CC Lv3',{type='CC',data={next=5,hold=true, speedLV=3,node=500,randomizer='bag',_20G=false}}},
    {'CC Lv4',{type='CC',data={next=6,hold=true, speedLV=4,node=2000,randomizer='bag',_20G=false}}},
    {'CC Lv5',{type='CC',data={next=6,hold=true, speedLV=5,node=5000,randomizer='bag',_20G=false}}},
    {'9S',  {type='9S',data={hold=true, speedLV=5}}},
}
local noTouch,noKey=false,false
local touchMoveLastFrame=false

local function _replayFinished()
    for p=1,#PLAYERS do
        local P=PLAYERS[p]
        -- A player is still "live" only if they are alive and still have an
        -- unconsumed recording entry. Once a player tops out their stream stops
        -- being advanced (they are dead), leaving streamProgress on a valid entry
        -- that would otherwise make this report false forever, so dead players
        -- count as finished.
        if P.alive and P.stream and P.stream[P.streamProgress] then
            return false
        end
    end
    return true
end

-- _stepPlayers runs the per-player fixed-step update loop. When the rollback
-- netcode layer is enabled (NET._rollbackEnabled), it delegates to
-- ROLLBACK.step which adds snapshotting and server reconciliation around the
-- same Player:update calls. Default off — visible behavior is identical to
-- the legacy loop until the integration test (slice 4) flips the flag.
local function _stepPlayers(dt)
    if NET._rollbackEnabled and ROLLBACK then
        ROLLBACK.step(PLAYERS, dt)
    else
        for p=1,#PLAYERS do PLAYERS[p]:update(dt) end
    end
end
local function _replaySeekTo(frame)
    if frame<NET._replayCur then
        -- Backward seek: re-simulate from frame 0 and fast-forward to the target.
        NET.seekRankedReplay(frame)
    else
        -- Forward seek: just keep playing (fast-forward) from the current frame.
        NET._replayFF=true
        NET._replayFFTarget=frame
    end
    NET._replayEndPos=nil
    NET._replaySettled=false
end
-- Once the replay ends the survivor is laid out at the full-size centred 1P
-- position (its board bottom would sit under the seek bar at y>=664). Scale it
-- down and lift it so it clears the slider instead of overlapping it.
local function _replaySettleLayout()
    local L=PLY_ALIVE
    if #L==0 then return end
    local size=#L==1 and .85 or .7
    for i=1,#L do
        local P=L[i]
        local x=#L==1 and (640-300*size) or P.x
        local y=664-600*size-36
        P:movePosition(x,y,size)
    end
end
local function _replayUpdate(dt)
    -- Apply a pending seek. Honored even while paused so a frozen replay can
    -- still be scrubbed. Debounced until the user pauses dragging.
    if NET._replaySeekPending and (not WIDGET.sel or WIDGET.sel.type~='slider' or love.timer.getTime()-NET._replaySeekLast>0.2) then
        _replaySeekTo(NET._replaySeekFrame)
        NET._replaySeekPending=false
    end
    if NET._replayFF then
        -- Fast-forward to the seek target, capped per frame so a long jump
        -- spreads across a few frames instead of freezing the client.
        local cap=400
        while NET._replayFF and cap>0 do
            _stepPlayers(dt)
            cap=cap-1
            if _replayFinished() or (NET._replayFFTarget>0 and PLAYERS[1].frameRun>=NET._replayFFTarget) then
                NET._replayFF=false
                break
            end
        end
    elseif not paused then
        local steps=GAME.replaySpeed or 1
        for s=1,steps do
            _stepPlayers(dt)
            if _replayFinished() then break end
        end
    end
    -- Track the current frame for the seek bar.
    NET._replayCur=0
    for p=1,#PLAYERS do
        if PLAYERS[p].frameRun>NET._replayCur then NET._replayCur=PLAYERS[p].frameRun end
    end
    -- The REPLAY banner fades out once the replay ends and fades back in when
    -- the user seeks away from the end.
    NET._replayBannerAlpha=MATH.expApproach(NET._replayBannerAlpha,_replayFinished() and 0 or 1,dt*4)
    -- When the replay ends, snapshot each board's end-of-replay position/size so
    -- a later backward seek can animate it back into place instead of popping in.
    if _replayFinished() and not NET._replayEndPos then
        NET._replayEndPos={}
        for p=1,#PLAYERS do
            local P=PLAYERS[p]
            if P.uid then NET._replayEndPos[P.uid]={P.x,P.y,P.size} end
        end
        -- Shrink the surviving board(s) so they clear the seek bar.
        if not NET._replaySettled then
            NET._replaySettled=true
            _replaySettleLayout()
        end
    end
end

local function _setCancel()
    if NETPLY.map[USER.uid].playMode=='Gamer' then
        NET.player_setReady(false)
    else
        NET.player_setPlayMode('Gamer')
    end
end
local function _setReady()
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
        if not GAME.replaying then NET.room_leave() end
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
    paused=false
    abandonCount=0
    lastUpstreamTime=0
    upstreamProgress=1

    if SCN.prev=='setting_game' then
        NET.player_updateConf()
    end
    if GAME.prevBG then
        BG.set(GAME.prevBG)
        GAME.prevBG=false
    end
    DiscordRPC.update("Playing Multiplayer")
end
function scene.leave()
    TASK.unlock('netPlaying')
    -- A ranked replay borrows the live net_game/netBattle machinery and replaces
    -- the room state with a throwaway one. Restore the real (post-match) room if
    -- we had one, otherwise clear it so ranked matchmaking isn't left pointing at
    -- the replay's fake "Playing" room (which would block starting a new search).
    if GAME.replaying then
        if NET._replayRoomState~=nil then
            NET.roomState=NET._replayRoomState
        else
            NET.roomState=nil
        end
        NET._replayRoomState=nil
        NETPLY.clear()
        GAME.replaySetup=false
        GAME.replaying=false
    end
end

scene.mouseDown=NULL
function scene.mouseMove(x,y) NETPLY.mouseMove(x,y) end
function scene.touchDown(x,y)
    if not playing or GAME.replaying then NETPLY.mouseMove(x,y) return end
    if NET.spectate or noTouch or not textBox.hide or paused then return end

    local t=VK.on(x,y)
    if t then
        PLAYERS[1]:pressKey(t)
        VK.touch(t,x,y)
    end
end
function scene.touchUp(x,y)
    if not playing or GAME.replaying or NET.spectate or noTouch or not textBox.hide then return end
    local n=VK.on(x,y)
    if n then
        PLAYERS[1]:releaseKey(n)
        VK.release(n)
    end
end
function scene.touchMove()
    if touchMoveLastFrame or not playing or noTouch or GAME.replaying then return end
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
    if GAME.replaying and paused then
        if key=='escape' then paused=false return end
        if key=='q' then _quit() return end
        return
    end
    if GAME.replaying and playing and key=='space' then paused=not paused return end
    if key=='escape' then
        if GAME.replaying then
            paused=not paused
        elseif not inputBox.hide then
            _switchChat()
        elseif NET.roomState and NET.roomState.info and NET.roomState.info.type=='ranked' and playing then
            -- Require several ESC taps so a ranked match can't be abandoned by
            -- accident. The third tap sends player_finish, which the server
            -- treats as this player leaving the match and settles a win for the
            -- opponent still in the game.
            abandonCount=abandonCount+1
            if abandonCount>=3 then
                abandonCount=0
                MES.new('warn',"Abandoning match — you forfeit the win")
                NET.player_finish()
            else
                MES.new('warn',"Press ESC "..(3-abandonCount).." more time(s) to abandon this match")
            end
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
        if NET.spectate or noKey or isRep or GAME.replaying or paused then return end
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
    if not playing or NET.spectate or noKey or GAME.replaying then return end
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
        if not playing or GAME.replaying then return end
        local k=KEY_MAP.joystick[key]
        if k and k>0 then
            PLAYERS[1]:pressKey(k)
            VK.press(k)
        end
    end
end
function scene.gamepadUp(key)
    if not playing or GAME.replaying then return end
    local k=KEY_MAP.joystick[key]
    if k and k>0 then
        PLAYERS[1]:releaseKey(k)
        VK.release(k)
    end
end

function scene.update(dt)
    if not GAME.replaying and WS.status('game')~='running' then
        TASK.unlock('netPlaying')
        NET.ws_close()
        SCN.back()
        return
    end
    if playing then
        if paused and not GAME.replaying then return end
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
                if GAME.replaying then
                    _replayUpdate(dt)
                else
                    _stepPlayers(dt)
                end

                local P1=PLAYERS[1]

                -- Warning check
                checkWarning(P1,dt)

                -- Upload stream
                if not GAME.replaying and not NET.spectate and P1.frameRun-lastUpstreamTime>8 then
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
                    -- Flush any queued authoritative-sim inputs (1413) at the
                    -- same cadence as the legacy stream upload. No-op when
                    -- not in a ranked room (NET._inputSubmitBuf stays empty).
                    NET.flushInputs()
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
        -- Warning
        drawWarning()

        -- Players
        for p=1,#PLAYERS do
            PLAYERS[p]:draw()
        end

        -- Virtual keys
        VK.draw()

        -- Board labels: mark which board is yours (shown in live net matches
        -- and replays, mirroring the ranked replay presentation).
        if GAME.net then
            setFont(GAME.replaying and 18 or 25)
            for p=1,#PLAYERS do
                local P=PLAYERS[p]
                local isYou=P.uid==USER.uid
                gc_setColor(isYou and COLOR.lY or COLOR.lR)
                mStr(isYou and "YOU" or (P.username or "OPPONENT"), P.centerX, P.fieldY-72)
            end
        end

        -- Replay UI
        if GAME.replaying then
            -- Top "REPLAY" banner: fades out when the replay ends and fades
            -- back in when the user seeks away from the end.
            setFont(40)
            gc_setColor(COLOR.Z[1],COLOR.Z[2],COLOR.Z[3],NET._replayBannerAlpha)
            mStr("REPLAY",640,8)

            -- Media-player style seek bar backdrop, so the slider/buttons don't
            -- clash with the boards behind them.
            gc_setColor(0,0,0,.5)
            gc.rectangle('fill',20,664,1240,56,6)

            -- Current / total frame readout, left of the slider.
            if NET._replayTotal and NET._replayTotal>0 then
                setFont(20)
                gc_setColor(COLOR.lY[1],COLOR.lY[2],COLOR.lY[3],1)
                gc_print(("%d / %d"):format(NET._replayCur,NET._replayTotal),30,678)
            end

        end

        -- Add dark overlay if chat is open
        if not textBox.hide then
            gc_setColor(0, 0, 0, 0.62-0.26)
            love.graphics.rectangle('fill',0,0,1280,720)
        end

        if NET.spectate then
            setFont(30)
            gc_setColor(.2,1,0,.8)
            gc_print(text.spectating,940,0)
        end
    else
        if textBox.hide then
            -- Users
            NETPLY.draw()

            -- Room's capacity + private?
            gc_setColor(1,1,1)
            setFont(40)
            gc_print(#NETPLY.list.."/"..NET.roomState.capacity,70,655)
            if NET.roomState.private then
                gc_draw(IMG.lock,30,668)
            end
        else
            -- Room's capacity + private?
            setFont(40)
            gc_setColor(1,1,1)
            gc_printf(#NETPLY.list.."/"..NET.roomState.capacity,1120,540,100,'right')
            if NET.roomState.private then
                gc_draw(IMG.lock,1070,553)
            end
            setFont(30)
            -- Ready/Spectate indicator
            if NETPLY.map[USER.uid].playMode=='Spectator' then
                gc_printf(text.WidgetText.net_game.spectate,1020,600,240,'center')
            elseif NETPLY.map[USER.uid].readyMode=='Ready' then
                gc_printf(text.WidgetText.net_game.ready,1020,600,240,'center')
            else
                gc_printf('-----',1020,600,240,'center')
            end
        end

        -- Room's name
        gc_setColor(1,1,1)
        setFont(25)
        gc_printf(NET.roomState.info.name,0,685,1270,'right')

        -- Ready & Set mark
        setFont(50)
        if NET.roomAllReady then
            gc_setColor(.6,.95,1,.9)
            mStr(text.ready,640,15)
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
        gc_print(CHAR.icon.pencil,430,10)
    end

    -- Replay pause overlay
    if paused then
        gc_setColor(0,0,0,.5)
        gc.rectangle('fill',0,0,1280,720)
        setFont(60)
        gc_setColor(COLOR.Z)
        mStr("PAUSED",640,300)
        setFont(25)
        gc_setColor(COLOR.lY)
        mStr("Press ESC to resume",640,370)
        setFont(20)
        gc_setColor(COLOR.lR)
        mStr("Press Q to quit replay",640,405)
    end
end
local function _hideF_ready() return not (textBox.hide) or playing or (NETPLY.map[USER.uid].playMode=='Spectator' or NETPLY.map[USER.uid].readyMode=='Ready') end
local function _hideF_standby() return not (textBox.hide) or playing or not (NETPLY.map[USER.uid].playMode=='Spectator' or NETPLY.map[USER.uid].readyMode=='Ready') end
local function _hideF_hideChat() return textBox.hide end
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

    WIDGET.newKey{x=1045,y=135,w=50,font=40,fText=CHAR.zChan.normal     ,code=function() inputBox:addText(CHAR.zChan.normal     ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1110,y=135,w=50,font=40,fText=CHAR.zChan.full       ,code=function() inputBox:addText(CHAR.zChan.full       ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1175,y=135,w=50,font=40,fText=CHAR.zChan.happy      ,code=function() inputBox:addText(CHAR.zChan.happy      ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1240,y=135,w=50,font=40,fText=CHAR.zChan.confused   ,code=function() inputBox:addText(CHAR.zChan.confused   ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1045,y=200,w=50,font=40,fText=CHAR.zChan.grinning   ,code=function() inputBox:addText(CHAR.zChan.grinning   ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1110,y=200,w=50,font=40,fText=CHAR.zChan.frowning   ,code=function() inputBox:addText(CHAR.zChan.frowning   ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1175,y=200,w=50,font=40,fText=CHAR.zChan.tears      ,code=function() inputBox:addText(CHAR.zChan.tears      ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1240,y=200,w=50,font=40,fText=CHAR.zChan.anxious    ,code=function() inputBox:addText(CHAR.zChan.anxious    ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1045,y=265,w=50,font=40,fText=CHAR.zChan.rage       ,code=function() inputBox:addText(CHAR.zChan.rage       ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1110,y=265,w=50,font=40,fText=CHAR.zChan.fear       ,code=function() inputBox:addText(CHAR.zChan.fear       ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1175,y=265,w=50,font=40,fText=CHAR.zChan.question   ,code=function() inputBox:addText(CHAR.zChan.question   ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1240,y=265,w=50,font=40,fText=CHAR.zChan.angry      ,code=function() inputBox:addText(CHAR.zChan.angry      ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1045,y=330,w=50,font=40,fText=CHAR.zChan.shocked    ,code=function() inputBox:addText(CHAR.zChan.shocked    ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1110,y=330,w=50,font=40,fText=CHAR.zChan.ellipses   ,code=function() inputBox:addText(CHAR.zChan.ellipses   ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1175,y=330,w=50,font=40,fText=CHAR.zChan.sweatDrop  ,code=function() inputBox:addText(CHAR.zChan.sweatDrop  ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1240,y=330,w=50,font=40,fText=CHAR.zChan.cry        ,code=function() inputBox:addText(CHAR.zChan.cry        ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1045,y=395,w=50,font=40,fText=CHAR.zChan.cracked    ,code=function() inputBox:addText(CHAR.zChan.cracked    ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1110,y=395,w=50,font=40,fText=CHAR.zChan.qualified  ,code=function() inputBox:addText(CHAR.zChan.qualified  ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1175,y=395,w=50,font=40,fText=CHAR.zChan.unqualified,code=function() inputBox:addText(CHAR.zChan.unqualified) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1240,y=395,w=50,font=40,fText=CHAR.zChan.understand ,code=function() inputBox:addText(CHAR.zChan.understand ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1045,y=460,w=50,font=40,fText=CHAR.zChan.thinking   ,code=function() inputBox:addText(CHAR.zChan.thinking   ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1110,y=460,w=50,font=40,fText=CHAR.zChan.spark      ,code=function() inputBox:addText(CHAR.zChan.spark      ) end,hideF=_hideF_hideChat},
--  WIDGET.newKey{x=1175,y=460,w=50,font=40,fText=CHAR.zChan.           ,code=function() inputBox:addText(                      ) end,hideF=_hideF_hideChat},
    WIDGET.newKey{x=1240,y=460,w=50,font=40,fText=CHAR.zChan.none       ,code=function() inputBox:addText(CHAR.zChan.none       ) end,hideF=_hideF_hideChat},

    WIDGET.newKey{name='chat',    x=390,y=45,w=60,fText="···",                code=_switchChat,hideF=function() return GAME.replaying or (NET.roomState and NET.roomState.info and NET.roomState.info.type=='ranked') end},
    -- "Add Bot" button: host only, casual rooms only. Adds a CCLoader
    -- (Cold Clear) bot to the room. Max 5 bots per room (enforced both
    -- client-side here and server-side in handleRoomAddBot). The bot
    -- runs locally on the host's client and is included in the local
    -- game simulation; the server only tracks it for lobby presence.
    WIDGET.newSelector{name='botCfg',x=620,y=35,w=150,color='lG',list=(function() local t={} for i=1,#BOT_PRESETS do t[i]=BOT_PRESETS[i][1] end return t end)(),disp=function() for i,p in next,BOT_PRESETS do if p[2].type==BOT_CFG.type and p[2].data.speedLV==BOT_CFG.data.speedLV then return p[1] end end return BOT_PRESETS[1][1] end,code=function(_,i) BOT_CFG=BOT_PRESETS[i][2] end,hideF=function() return GAME.replaying or playing or not (NET.roomState and NET.roomState.info and NET.roomState.info.type~='ranked') or not (NETPLY.map[USER.uid] and NETPLY.map[USER.uid].role=='Admin') end},
    WIDGET.newButton{name='addBot',x=780,y=35,w=50,font=25,fText="+Bot",code=function()
        NET.room_addBot(BOT_CFG.type,BOT_CFG.data)
    end,hideF=function()
        return GAME.replaying or playing
            or not (NET.roomState and NET.roomState.info and NET.roomState.info.type~='ranked')
            or not (NETPLY.map[USER.uid] and NETPLY.map[USER.uid].role=='Admin')
    end},
    -- "Remove Bot" button: host only. Removes the most recently added
    -- bot. The server broadcasts a 1320 room_playerLeave so all
    -- clients remove the bot from their lobby display.
    WIDGET.newButton{name='rmBot',x=835,y=35,w=50,font=25,fText="-Bot",code=function()
        if #NET.bots>0 then
            NET.room_removeBot(NET.bots[#NET.bots].botId)
        end
    end,hideF=function()
        return GAME.replaying or playing
            or not (NET.roomState and NET.roomState.info and NET.roomState.info.type~='ranked')
            or not (NETPLY.map[USER.uid] and NETPLY.map[USER.uid].role=='Admin')
            or #NET.bots==0
    end},
    WIDGET.newKey{name='quit',    x=890,y=45,w=60,font=30,fText=CHAR.icon.cross_thick,code=_quit,hideF=function() return GAME.replaying or (NET.roomState and NET.roomState.info and NET.roomState.info.type=='ranked') end},

    WIDGET.newKey{name='replayPause', x=40, y=50, w=60, font=40, fText=CHAR.icon.pause,   code=function() paused=not paused end,                                                                                       hideF=function() return not GAME.replaying end},
    WIDGET.newKey{name='replaySpd1',  x=105,y=50, w=60, font=40, fText=CHAR.icon.speedOne,  code=function() GAME.replaySpeed=1  end,                                                                                       hideF=function() return not GAME.replaying end},
    WIDGET.newKey{name='replaySpd2',  x=170,y=50, w=60, font=40, fText=CHAR.icon.speedTwo,  code=function() GAME.replaySpeed=2  end,                                                                                       hideF=function() return not GAME.replaying end},
    WIDGET.newKey{name='replaySpd5',  x=235,y=50, w=60, font=40, fText=CHAR.icon.speedFive, code=function() GAME.replaySpeed=5  end,                                                                                       hideF=function() return not GAME.replaying end},
    WIDGET.newKey{name='replaySpd10', x=300,y=50, w=60, font=30, fText="10x",               code=function() GAME.replaySpeed=10 end,                                                                                       hideF=function() return not GAME.replaying end},
    WIDGET.newSlider{name='replaySeek',x=160,y=683,w=1020,axis={0,1,false},disp=function() return (NET._replayTotal and NET._replayTotal>0) and NET._replayCur/NET._replayTotal or 0 end,code=function(v) NET._replaySeekFrame=math.floor(v*(NET._replayTotal or 1)); NET._replaySeekPending=true; NET._replaySeekLast=love.timer.getTime() end,hideF=function() return not GAME.replaying end},
}

return scene
