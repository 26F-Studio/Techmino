local WS=WS

local NET={
    uid=false,
    uid_sid={},
    storedStream=false,

    roomState={-- A copy of room structure on server
        info={
            name=false,
            type=false,
            version=false,
            description=false,
        },
        data={},
        count={
            Gamer=0,
            Spectator=0,
        },
        capacity=false,
        private=false,
        state='Standby',
    },

    spectate=false,-- If player is spectating
    seed=false,

    roomAllReady=false,

    onlineCount="_",

    textBox=WIDGET.newTextBox{name='texts',x=340,y=80,w=600,h=560},
    inputBox=WIDGET.newInputBox{name='input',x=340,y=660,w=600,h=50,limit=256},
}

function NET.freshRoomAllReady()
    local playCount,readyCount=0,0
    for j=1,#NETPLY.list do
        if NETPLY.list[j].playMode=='Gamer' then playCount=playCount+1 end
        if NETPLY.list[j].readyMode=='Ready' then readyCount=readyCount+1 end
    end

    NET.roomAllReady=playCount>0 and playCount==readyCount

    if playCount>1 and playCount-readyCount==1 then
        local p=NETPLY.map[USER.uid]
        if p.playMode=='Gamer' and p.readyMode~='Ready' and TASK.lock('urgeReady',1) then
            SFX.play('warn_2',.5)
        end
    end
end

--------------------------<NEW HTTP API>
local ignoreError={
    ["Techrater.PlayerStream.notAvailable"]=true,
    ["Techrater.PlayerManager.invalidAccessToken"]=true,
    ["Techrater.PlayerManager.invalidRefreshToken"]=true,
}
local availableErrorTextType={info=1,warn=1,error=1}
local function parseError(pathStr)
    if ignoreError[pathStr] then return end
    LOG(pathStr)
    if type(pathStr)~='string' then
        MES.new('error',"<"..tostring(pathStr)..">",5)
    elseif pathStr:find("[^0-9a-zA-Z.]") then
        MES.new('error',"["..pathStr.."]",5)
    else
        local mesPath=STRING.split(pathStr,'.')
        if mesPath[1]~='Techrater' then
            MES.new('error',"["..pathStr.."]",5)
            return
        end
        local curText=text.Techrater
        for i=2,#mesPath do
            if type(curText)~='table' then break end
            curText=curText[mesPath[i]]
        end
        if not curText then
            curText=text.Techrater[mesPath[#mesPath]]
        end

        if type(curText)=='table' then
            if availableErrorTextType[curText[1]] and type(curText[2])=='string' and type(curText[3])=='number' then
                MES.new(curText[1],curText[2],math.min(curText[3],5))
                return
            end
        elseif type(curText)=='string' then
            if #curText>0 then
                MES.new('warn',curText,5)
                return
            end
        end
        MES.new('warn',"["..pathStr.."]",5)
    end
end
local function getMsg(request,timeout)
    HTTP(request)
    local totalTime=0
    while true do
        local msg=HTTP.pollMsg(request.pool)
        if msg then
            if type(msg.body)=='string' and #msg.body>0 then
                local body=JSON.decode(msg.body)
                if body then
                    if tostring(body.code):sub(1,1)~='2' then
                        parseError(body.message~=nil and body.message or msg)
                    end
                    return body
                end
            else
                MES.new('info',text.serverDown)
                return
            end
        else
            totalTime=totalTime+coroutine.yield()
            if totalTime>timeout then
                return
            end
        end
    end
end
function NET.getCode(email)
    if not TASK.lock('getCode') then return end
    TASK.new(function()
        WAIT{
            quit=function()
                TASK.unlock('getCode')
                HTTP.deletePool('getCode')
            end,
            timeout=12.6,
        }

        local res=getMsg({
            pool='getCode',
            path='/techmino/api/v1/auth/verify/email',
            body={email=email},
        },12.6)

        if res and res.code==200 then
            MES.new('info',text.checkEmail,5)
        end

        WAIT.interrupt()
    end)
end
function NET.codeLogin(email,code)
    if not TASK.lock('codeLogin') then return end
    TASK.new(function()
        WAIT{
            quit=function()
                TASK.unlock('codeLogin')
                HTTP.deletePool('codeLogin')
            end,
            timeout=6.26,
        }

        local res=getMsg({
            pool='codeLogin',
            path='/techmino/api/v1/auth/login/email',
            body={
                email=email,
                code=code,
            },
        },6.26)

        if res then
            if res.code==200 then
                USER.rToken=res.data.refreshToken
                USER.aToken=res.data.accessToken
                saveUser()
                NET.ws_connect()
                SCN.swapTo('net_menu')
            elseif res.code==201 then
                USER.rToken=res.data.refreshToken
                USER.aToken=res.data.accessToken
                saveUser()
                SCN.pop()SCN.push('net_menu')
                SCN.go('reset_password',nil,code)
            end
        end

        WAIT.interrupt()
    end)
end
function NET.setPW(code,pw)
    if not TASK.lock('setPW') then return end
    TASK.new(function()
        WAIT{
            quit=function()
                TASK.unlock('setPW')
                HTTP.deletePool('setPW')
            end,
            timeout=6.26,
        }

        local salt do
            local res=getMsg({
                pool='pwLogin',
                path='/techmino/api/v1/auth/seed/email',
                body={
                    email=USER.email,
                },
            },6.26)

            if res and res.code==200 then
                salt=res.data
            else
                WAIT.interrupt()
                return
            end
        end

        pw=HASH.pbkdf2(HASH.sha3_256,pw,salt,260)

        local res=getMsg({
            pool='setPW',
            method='PUT',
            path='/techmino/api/v1/auth/reset/email',
            body={
                email=USER.email,
                code=code,
                newPassword=pw,
            },
        },6.26)

        if res then
            if res.code==200 then
                USER.password=pw
                saveUser()
                SCN.back()
            end
        end

        WAIT.interrupt()
    end)
end
function NET.autoLogin()
    if not TASK.lock('autoLogin') then return end
    TASK.new(function()
        WAIT{
            quit=function()
                TASK.unlock('autoLogin')
                HTTP.deletePool('autoLogin')
            end,
            timeout=12.6,
        }

        if USER.aToken then
            local res=getMsg({
                pool='autoLogin',
                path='/techmino/api/v1/auth/check',
                headers={["x-access-token"]=USER.aToken},
            },6.26)

            if res then
                if res.code==200 then
                    USER.uid=res.data
                    saveUser()
                    NET.ws_connect()
                    SCN.go('net_menu')
                    WAIT.interrupt()
                    return
                end
            else
                WAIT.interrupt()
                return
            end
        end
        if USER.rToken then
            local res=getMsg({
                pool='autoLogin',
                path='/techmino/api/v1/auth/refresh',
                headers={["x-refresh-token"]=USER.rToken},
            },6.26)

            if res then
                if res.code==200 then
                    USER.rToken=res.data.refreshToken
                    USER.aToken=res.data.accessToken
                    saveUser()
                    NET.ws_connect()
                    SCN.go('net_menu')
                    WAIT.interrupt()
                    return
                end
            else
                WAIT.interrupt()
                return
            end
        end
        if USER.password then
            local res=getMsg({
                pool='pwLogin',
                path='/techmino/api/v1/auth/login/email',
                body={
                    email=USER.email,
                    password=USER.password,
                },
            },6.26)
            if res then
                if res.code==200 then
                    USER.rToken=res.data.refreshToken
                    USER.aToken=res.data.accessToken
                    saveUser()
                    NET.ws_connect()
                    SCN.go('net_menu')
                    WAIT.interrupt()
                    return
                end
            else
                WAIT.interrupt()
            end
        end

        SCN.go('login_pw')
        WAIT.interrupt()
    end)
end
function NET.pwLogin(email,pw)
    if not TASK.lock('pwLogin') then return end
    TASK.new(function()
        WAIT{
            quit=function()
                TASK.unlock('pwLogin')
                HTTP.deletePool('pwLogin')
            end,
            timeout=12.6,
        }
        TEST.yieldT(.26)

        local salt do
            local res=getMsg({
                pool='pwLogin',
                path='/techmino/api/v1/auth/seed/email',
                body={
                    email=email,
                },
            },6.26)

            if res and res.code==200 then
                salt=res.data
            else
                WAIT.interrupt()
                return
            end
        end

        pw=HASH.pbkdf2(HASH.sha3_256,pw,salt,260)

        do
            local res=getMsg({
                pool='pwLogin',
                path='/techmino/api/v1/auth/login/email',
                body={
                    email=email,
                    password=pw,
                },
            },6.26)

            if res then
                if res.code==200 then
                    USER.email=email
                    USER.password=pw
                    USER.rToken=res.data.refreshToken
                    USER.aToken=res.data.accessToken
                    saveUser()
                    NET.ws_connect()
                    SCN.swapTo('net_menu')
                end
            end
        end

        WAIT.interrupt()
    end)
end
function NET.getUserInfo(uid)
    TASK.new(function()
        local res=getMsg({
            pool='getInfo',
            path='/techmino/api/v1/player/info?playerId='..uid,
        },6.26)

        if res and res.code==200 and type(res.data)=='table' then
            USERS.updateUserData(res.data)
        end
    end)
end
function NET.getAvatar(uid)
    TASK.new(function()
        local res=getMsg({
            pool='getInfo',
            path='/techmino/api/v1/player/avatar?playerId='..uid,
        },6.26)

        if res and res.code==200 and type(res.data)=='string' then
            USERS.updateAvatar(uid,res.data)
        end
    end)
end
--------------------------<NEW WS API>
local actMap={
    global_getOnlineCount= 1000,
    match_finish=          1100,
    match_ready=           1101,
    match_start=           1102,
    player_updateConf=     1200,
    player_finish=         1201,
    player_joinGroup=      1202,
    player_setReadyMode=   1203,
    player_setHost=        1204,
    player_setState=       1205,
    player_stream=         1206,
    player_setPlayMode=    1207,
    room_chat=             1300,
    room_create=           1301,
    room_getData=          1302,
    room_setData=          1303,
    room_getInfo=          1304,
    room_setInfo=          1305,
    room_enter=            1306,
    room_kick=             1307,
    room_leave=            1308,
    room_fetch=            1309,
    room_setPW=            1310,
    room_remove=           1311,
} for k,v in next,actMap do actMap[v]=k end

local function wsSend(act,data)
    -- print(("Send: $1 -->"):repD(act))
    -- print(("Send: $1 -->"):repD(act)) print(type(data)=='table' and TABLE.dump(data) or tostring(data),"\n")
    WS.send('game',JSON.encode{
        action=assert(act),
        data=data,
    })
end

local function _getFullName(uid)
    return USERS.getUsername(uid).."#"..uid
end

--Remove player when leave
local function _playerLeaveRoom(uid)
    if SCN.cur~='net_game' then return end
    for i=1,#PLAYERS do if PLAYERS[i].uid==uid then table.remove(PLAYERS,i) break end end
    for i=1,#PLY_ALIVE do if PLY_ALIVE[i].uid==uid then table.remove(PLY_ALIVE,i) break end end
    if uid==USER.uid then
        GAME.playing=false
        SCN.backTo('net_menu')
    else
        NETPLY.remove(uid)
    end
end

--Push stream data to players
function NET.pumpStream(d)
    if d.playerId==USER.uid then return end
    for _,P in next,PLAYERS do
        if P.uid==d.playerId then
            local res,stream=pcall(love.data.decode,'string','base64',d.data)
            if res then
                DATA.pumpRecording(stream,P.stream)
            else
                MES.new('error',"Bad stream from ".._getFullName(P.uid),.1)
            end
            return
        end
    end
end

-- Global
function NET.global_getOnlineCount()
    wsSend(actMap.global_getOnlineCount)
end

-- Room
function NET.room_chat(msg,rid)
    if not TASK.lock('chatLimit',1.26) then
        MES.new('warn',text.tooFrequent)
    elseif #msg>0 then
        wsSend(1300,{
            message=msg,
            roomId=rid,-- Admin
        })
        return true
    end
end
function NET.room_create(data)
    if not TASK.lock('createRoom',10) then MES.new('warn',text.tooFrequent) return end
    TABLE.coverR(data,NET.roomState)
    WAIT{timeout=12}
    wsSend(actMap.room_create,data)
end
function NET.room_getData(rid)
    wsSend(actMap.room_getData,{
        roomId=rid,-- Admin
    })
end
function NET.room_setData(data,rid)
    wsSend(actMap.room_setData,{
        data=data,
        roomId=rid,-- Admin
    })
end
function NET.room_getInfo(rid)
    wsSend(actMap.room_getInfo,{
        roomId=rid,-- Admin
    })
end
function NET.room_setInfo(info,rid)
    wsSend(actMap.room_setInfo,{
        info=info,
        roomId=rid,-- Admin
    })
end
function NET.room_enter(rid,password)
    if not TASK.lock('enterRoom',6) then return end
    SFX.play('reach',.6)
    wsSend(actMap.room_enter,{
        roomId=rid,
        password=password,
    })
end
function NET.room_kick(pid,rid)
    wsSend(actMap.room_kick,{
        playerId=pid,-- Host
        roomId=rid,-- Admin
    })
end
function NET.room_leave()
    wsSend(actMap.room_leave)
end
function NET.room_fetch()
    if not TASK.lock('fetchRoom',3) then return end
    wsSend(actMap.room_fetch,{
        pageIndex=0,
        pageSize=26,
    })
end
function NET.room_setPW(pw,rid)
    if not TASK.lock('setRoomPW',2) then return end
    wsSend(actMap.room_setPW,{
        password=pw,
        roomId=rid,-- Admin
    })
end
function NET.room_remove(rid)
    wsSend(actMap.room_remove,{
        roomId=rid-- Admin
    })
end

-- Player
function NET.player_updateConf()
    wsSend(actMap.player_updateConf,dumpBasicConfig())
end
function NET.player_finish(msg)
    wsSend(actMap.player_finish,msg)
end
function NET.player_joinGroup(gid)
    wsSend(actMap.player_joinGroup,gid)
end
function NET.player_setReady(isReady)
    wsSend(actMap.player_setReadyMode,isReady)
end
function NET.player_setHost(pid)
    wsSend(actMap.player_setHost,{
        playerId=pid,
        role='Admin',
    })
end
function NET.player_setState(state)-- not used
    wsSend(actMap.player_setState,state)
end
function NET.player_stream(stream)
    wsSend(actMap.player_stream,love.data.encode('string','base64',stream))
end
function NET.player_setPlayMode(mode)
    wsSend(actMap.player_setPlayMode,mode)
end



-- WS
NET.wsCallBack={}
function NET.wsCallBack.global_getOnlineCount(body)
    NET.onlineCount=tonumber(body.data) or "_"
end
function NET.wsCallBack.room_chat(body)
    if SCN.cur~='net_game' then return end
    TASK.unlock('receiveMessage')
    TASK.lock('receiveMessage',1)
    NET.textBox:push{
        COLOR.Z,_getFullName(body.data.playerId).." ",
        COLOR.N,body.data.message,
    }
end
function NET.wsCallBack.room_create(body)
    MES.new('check',text.createRoomSuccessed)
    SCN.pop()
    NET.wsCallBack.room_enter(body)
    WAIT.interrupt()
end
function NET.wsCallBack.room_getData(body)
    NET.roomState.data=body.data
end
function NET.wsCallBack.room_setData(body)
    NET.wsCallBack.room_getData(body)
end
function NET.wsCallBack.room_getInfo(body)
    NET.roomState.info=body.info
end
function NET.wsCallBack.room_setInfo(body)
    NET.wsCallBack.room_getInfo(body)
end
function NET.wsCallBack.room_enter(body)
    TASK.unlock('enterRoom')

    if body.data.players then
        NET.textBox.hide=true
        NET.inputBox.hide=true
        NET.textBox:clear()
        NET.inputBox:clear()

        NET.roomState=body.data
        NETPLY.clear()
        destroyPlayers()
        loadGame('netBattle',true,true)
        for _,p in next,body.data.players do
            NETPLY.add{
                uid=p.playerId,
                group=p.group,
                role=p.role,
                playMode=p.type,
                readyMode=p.state,
                config=p.config,
            }
        end
        if NET.roomState.state=='Playing' then
            NET.storedStream={}
            for _,p in next,body.data.players do
                table.insert(NET.storedStream,{
                    playerId=p.playerId,
                    data=p.history,
                })
            end
            NET.seed=body.data.seed
            TASK.lock('netPlaying')
        else
            NET.freshRoomAllReady()
        end
    else
        local p=body.data
        if NETPLY.exist(p.playerId) then _playerLeaveRoom(p.playerId) end
        NETPLY.add{
            uid=p.playerId,
            group=p.group,
            role=p.role,
            playMode=p.type,
            readyMode=p.state,
            config=p.config,
        }
        NET.textBox:push{COLOR.Y,text.joinRoom:repD(_getFullName(p.playerId))}
        if not TASK.getLock('netPlaying') then
            SFX.play('connected')
            NET.freshRoomAllReady()
        end
    end
end
function NET.wsCallBack.room_kick(body)
    MES.new('info',text.playerKicked:repD(_getFullName(body.data.executorId),_getFullName(body.data.playerId)))
    _playerLeaveRoom(body.data.playerId)
end
function NET.wsCallBack.room_leave(body)
    local uid=body.data and body.data.playerId or USER.uid
    if body.data then
        NET.textBox:push{COLOR.Y,text.leaveRoom:repD(_getFullName(uid))}
    end
    _playerLeaveRoom(uid)
    NET.freshRoomAllReady()
end
function NET.wsCallBack.room_fetch(body)
    TASK.unlock('fetchRoom')
    if not body.data then body.data={} end
    SCN.scenes.net_rooms.widgetList.roomList:setList(body.data)
end
function NET.wsCallBack.room_setPW()
    if SCN.cur~='net_game' then return end
    MES.new(text.roomPasswordChanged)
end
function NET.wsCallBack.room_remove()
    if SCN.cur~='net_game' then return end
    MES.new('info',text.roomRemoved)
    _playerLeaveRoom(USER.uid)
end
function NET.wsCallBack.player_updateConf(body)
    if SCN.cur~='net_game' then return end
    if type(body.data)=='table' then
        NETPLY.map[body.data.playerId].config=body.data.config
    end
end
function NET.wsCallBack.player_finish(body)
    if SCN.cur~='net_game' then return end
    for _,P in next,PLY_ALIVE do
        if P.uid==body.data.playerId then
            NETPLY.setPlace(P.uid,#PLY_ALIVE)
            P.loseTimer=26
            break
        end
    end
end
function NET.wsCallBack.player_joinGroup(body)
    if SCN.cur~='net_game' then return end
    NETPLY.map[body.data.playerId].group=body.data.group
end
function NET.wsCallBack.player_setHost(body)
    if SCN.cur~='net_game' then return end
    if body.data.role=='Admin' then
        MES.new('info',text.becomeHost:repD(_getFullName(body.data.playerId)))
    end
    NETPLY.map[body.data.playerId].role=body.data.role
end
function NET.wsCallBack.player_setState(body)-- not used
end
function NET.wsCallBack.player_stream(body)
    if SCN.cur~='net_game' then return end
    NET.pumpStream(body.data)
end
function NET.wsCallBack.player_setPlayMode(body)
    if SCN.cur~='net_game' then return end
    NETPLY.map[body.data.playerId].playMode=body.data.type
    NET.freshRoomAllReady()
end
function NET.wsCallBack.player_setReadyMode(body)
    if SCN.cur~='net_game' then return end
    NETPLY.map[body.data.playerId].readyMode=body.data.isReady and 'Ready' or 'Standby'
    NET.freshRoomAllReady()
end
function NET.wsCallBack.match_finish()
    if SCN.cur~='net_game' then return end
    for _,P in next,PLAYERS do
        NETPLY.setStat(P.uid,P.stat)
    end
    TASK.new(function()
        TEST.yieldT(2.6)
        TASK.unlock('netPlaying')
    end)
end
function NET.wsCallBack.match_ready()-- not used
end
function NET.wsCallBack.match_start(body)
    if SCN.cur~='net_game' then return end
    TASK.lock('netPlaying')
    NET.seed=body.data and body.data.seed
    if not NET.seed then
        NET.seed=0
        MES.new("error",'No seed received')
    end
end

function NET.ws_connect()
    if WS.status('game')=='dead' then
        WS.connect('game','',{['x-access-token']=USER.aToken},6)
        TASK.removeTask_code(NET.ws_update)
        TASK.new(NET.ws_update)
    end
end
function NET.ws_close()
    WS.close('game')
end
function NET.ws_update()
    -- Wait until connected
    while true do
        TEST.yieldT(1/26)
        if WS.status('game')=='dead' then
            TEST.yieldUntilNextScene()
            GAME.playing=false
            SCN.backTo('main')
            return
        elseif WS.status('game')=='running' then
            break
        end
    end

    do-- Get UID
        local res=getMsg({
            pool='getUID',
            path='/techmino/api/v1/auth/check',
            headers={["x-access-token"]=USER.aToken},
        },6.26)

        if res and res.code==200 then
            USER.uid=res.data
        else
            TEST.yieldUntilNextScene()
            GAME.playing=false
            SCN.backTo('main')
            return
        end
    end

    -- Initialize player setting
    NET.player_updateConf()

    -- Websocket main loop
    local updateOnlineCD=0
    while true do
        TEST.yieldT(.01)-- Network messages, max 126 FPS is enough

        if WS.status('game')=='dead' then
            TEST.yieldUntilNextScene()
            GAME.playing=false
            SCN.backTo('main')
            return
        end

        updateOnlineCD=updateOnlineCD%626+1
        if updateOnlineCD==1 then NET.global_getOnlineCount() end

        local msg,op=WS.read('game')
        if msg then
            if op=='ping' then
            elseif op=='pong' then
            elseif op=='close' then
                msg=JSON.decode(msg)
                if msg then
                    MES.new('info',text.wsClose:repD(msg and msg.message or msg))
                    if msg and msg.message then LOG(msg.message) end
                end
                TEST.yieldUntilNextScene()
                GAME.playing=false
                SCN.backTo('main')
                return
            elseif msg then
                msg=JSON.decode(msg)
                -- print(("Recv:      <-- $1 err:$2"):repD(msg.action,msg.errno))
                -- print(("Recv:      <-- $1 err:$2"):repD(msg.action,msg.errno)) print(TABLE.dump(msg),"\n")
                if msg.errno~=0 then
                    parseError(msg.message~=nil and msg.message or msg)
                else
                    local f=NET.wsCallBack[actMap[msg.action]]
                    if f then f(msg) end
                end
            else
                MES.new('warn',"Wrong json: "..msg,5)
                WS.alert('user')
            end
        end
    end
end

--------------------------<OLD ONLINE API>
-- Save
function NET.uploadSave()
    if not TASK.lock('uploadSave',8) then return end
    wsSend({data={sections={
        {section=1,data=STRING.packTable(STAT)},
        {section=2,data=STRING.packTable(RANKS)},
        {section=3,data=STRING.packTable(SETTING)},
        {section=4,data=STRING.packTable(KEY_MAP)},
        {section=5,data=STRING.packTable(VK_ORG)},
        {section=6,data=STRING.packTable(loadFile('conf/vkSave1','-canSkip') or{})},
        {section=7,data=STRING.packTable(loadFile('conf/vkSave2','-canSkip') or{})},
    }}})
    MES.new('info',"Uploading")
end
function NET.downloadSave()
    if not TASK.lock('downloadSave',8) then return end
    wsSend({data={sections={1,2,3,4,5,6,7}}})
    MES.new('info',"Downloading")
end
function NET.loadSavedData(sections)
    local cloudData={}
    local secNameList={'STAT','RANKS','SETTING','keyMap','VK_org','vkSave1','vkSave2'}
    for _,sec in next,sections do
        cloudData[secNameList[sec.section]]=STRING.unpackTable(sec.data)
    end

    local fail
    repeat
        if cloudData.STAT then
            TABLE.cover(cloudData.STAT,STAT)
            if not saveStats() then fail=true end
        end

        if cloudData.RANKS then
            TABLE.cover(cloudData.RANKS,RANKS)
            if not saveProgress() then fail=true end
        end

        if cloudData.SETTING then
            TABLE.cover(cloudData.SETTING,SETTING)
            if not saveSettings() then fail=true end
        end
        applySettings()

        if cloudData.keyMap then
            TABLE.cover(cloudData.keyMap,KEY_MAP)
            if not saveFile(KEY_MAP,'conf/key') then fail=true end
        end

        if cloudData.VK_org then
            TABLE.cover(cloudData.VK_org,VK_ORG)
            if not saveFile(VK_ORG,'conf/virtualkey') then fail=true end
        end

        if #cloudData.vkSave1[1] and not saveFile(cloudData.vkSave1,'conf/vkSave1') then fail=true end
        if #cloudData.vkSave2[1] and not saveFile(cloudData.vkSave2,'conf/vkSave2') then fail=true end
    until true

    if fail then
        MES.new('error',text.dataCorrupted)
    else
        MES.new('check',text.saveDone)
    end
end

return NET
