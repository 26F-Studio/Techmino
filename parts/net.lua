local WS=WS

local NET={
    allow_online=false,
    accessToken=false,
    cloudData={},

    roomState={-- A copy of room structure on server
        info={
            name=false,
            type=false,
            version=false,
        },
        roomData={},
        count=false,
        capacity=false,
        private=false,
        start=false,
    },
    spectate=false,-- If player is spectating
    specSRID=false,-- Cached SRID when enter playing room, for connect WS after scene swapped
    seed=false,

    roomReadyState=false,

    onlineCount="_",
}


function NET.connectLost()
    while SCN.stack[#SCN.stack-1]~='main' and #SCN.stack>0 do SCN.pop() end
    SCN.back()
end

--------------------------<NEW HTTP API>
local availableErrorTextType={info=1,warn=1,error=1}
local function parseError(pathStr)
    LOG(pathStr)
    if type(pathStr)~='string' then
        MES.new('error',"<"..tostring(pathStr)..">",5)
    elseif pathStr:find("[^0-9a-z.]") then
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

        if type(curText)=='table' then
            if availableErrorTextType[curText[1]] and type(curText[2])=='string' and type(curText[3])=='number' then
                MES.new(curText[1],curText[2],math.min(curText[3],5))
            else
                MES.new('error',"["..pathStr.."]",5)
            end
        elseif type(curText)=='string' then
            if #curText>0 then
                MES.new('warn',curText,5)
            end
        else
            MES.new('error',"["..pathStr.."]",5)
        end
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

        if res then
            if res.code==200 then
                USER.email=email
                SCN.fileDropped(2)
                MES.new('info',text.checkEmail,5)
            end
        end

        WAIT.interrupt()
    end)
end
function NET.codeLogin(code)
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
                email=USER.email,
                code=code,
            },
        },6.26)

        if res then
            if res.code==200 then
                USER.rToken=res.data.refreshToken
                USER.aToken=res.data.accessToken
                NET.ws_connect()
                SCN.pop()SCN.go('net_menu')
            elseif res.code==201 then
                USER.rToken=res.data.refreshToken
                USER.aToken=res.data.accessToken
                SCN.pop()SCN.push('net_menu')
                SCN.fileDropped(3)
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

        pw=HASH.pbkdf2(HASH.sha3_256,pw,'salt',26000)

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
                SCN.back()
            end
        end

        WAIT.interrupt()
    end)
end
function NET.autoLogin()
    if not USER.password then SCN.go('login') return end
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
                    NET.ws_connect()
                    SCN.go('net_menu')
                    WAIT.interrupt()
                    return
                end
            else
                WAIT.interrupt()
            end
        end

        SCN.go('login')
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

        pw=HASH.pbkdf2(HASH.sha3_256,pw,"salt",26000)

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
                NET.ws_connect()
                SCN.go('net_menu')
            end
        end

        WAIT.interrupt()
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
    player_setReady=       1203,
    player_setHost=        1204,
    player_setState=       1205,
    player_stream=         1206,
    player_setPlaying=     1207,
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
    -- print(("Send: $1 -->"):repD(act)) print(TABLE.dump(data),"\n")
    WS.send('game',JSON.encode{
        action=assert(act),
        data=data,
    })
end

-- Global
function NET.global_getOnlineCount()
    wsSend(actMap.global_getOnlineCount)
end

-- Room
function NET.room_chat(msg,rid)
    if not TASK.lock('chatLimit',2.6) then
        MES.new('warn',"Talk too fast")
    elseif #msg>0 then
        wsSend(1300,{
            message=msg,
            roomId=rid,-- Admin
        })
        return true
    end
end
function NET.room_create(roomName,description,capacity,roomType,roomData,password)
    if not TASK.lock('createRoom',10) then MES.new('warn',text.tooFrequently) return end
    WAIT{timeout=12}
    wsSend(actMap.room_create,{
        capacity=capacity,
        info={
            name=roomName,
            type=roomType,
            version=VERSION.room,
            description=description,
        },
        data=roomData,
        password=password,
    })
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
function NET.player_finish(msg)-- what msg?
    wsSend(actMap.player_finish,msg)
end
function NET.player_joinGroup(gid)
    wsSend(actMap.player_joinGroup,gid)
end
function NET.player_setReady(bool)
    wsSend(actMap.player_setReady,bool)
end
function NET.player_setHost(pid)
    wsSend(actMap.player_setHost,{
        playerId=pid,
        role='Admin',
    })
end
function NET.player_setState(state)-- what state?
    wsSend(actMap.player_setState,state)
end
function NET.player_stream(stream)
    wsSend(actMap.player_stream,stream)
end
function NET.player_setPlaying(playing)
    wsSend(actMap.player_setPlaying,playing and 'Gamer' or 'Spectator')
end

-- Match

-- WS
NET.wsCallBack={}
function NET.wsCallBack.global_getOnlineCount(body)
    NET.onlineCount=tonumber(body.data) or "_"
end
function NET.wsCallBack.room_chat(body)-- TODO
end
function NET.wsCallBack.room_create(body)
    TASK.unlock('createRoom')
    -- NET.roomState=...
    -- SCN.go('net_game')
    WAIT.interrupt()
end
function NET.wsCallBack.room_getData(body)-- TODO
end
function NET.wsCallBack.room_setData(body)-- TODO
end
function NET.wsCallBack.room_getInfo(body)-- TODO
end
function NET.wsCallBack.room_setInfo(body)-- TODO
end
function NET.wsCallBack.room_enter(body)
    TASK.unlock('enterRoom')
    -- NET.roomState=...
    -- SCN.go('net_game')
    WAIT.interrupt()
end
function NET.wsCallBack.room_kick(body)-- TODO
end
function NET.wsCallBack.room_leave(body)-- TODO
end
function NET.wsCallBack.room_fetch(body)
    TASK.unlock('fetchRoom')
    if body.data then SCN.scenes.net_rooms.widgetList.roomList:setList(body.data) end
end
function NET.wsCallBack.room_setPW(body)-- TODO
end
function NET.wsCallBack.room_remove(body)-- TODO
end
function NET.wsCallBack.player_updateConf(body)-- TODO
end
function NET.wsCallBack.player_finish(body)-- TODO
end
function NET.wsCallBack.player_joinGroup(body)-- TODO
end
function NET.wsCallBack.player_setReady(body)-- TODO
end
function NET.wsCallBack.player_setHost(body)-- TODO
end
function NET.wsCallBack.player_setState(body)-- TODO
end
function NET.wsCallBack.player_stream(body)-- TODO
end
function NET.wsCallBack.player_setPlaying(body)-- TODO
end

function NET.ws_connect()
    if WS.status('game')=='dead' then
        WS.connect('game','',{['x-access-token']=USER.aToken},6)
        TASK.new(NET.ws_update)
    end
end
function NET.ws_close()
    WS.close('game')
end
function NET.ws_update()
    local updateOnlineTimer=0
    while WS.status('game')~='dead' do
        local dt=coroutine.yield()

        updateOnlineTimer=updateOnlineTimer+dt
        if updateOnlineTimer>6.26 then
            NET.global_getOnlineCount()
            updateOnlineTimer=0
        end

        local msg,op=WS.read('game')
        if msg then
            if op=='ping' then
            elseif op=='pong' then
            elseif op=='close' then
                local res=JSON.decode(msg)
                MES.new('info',text.wsClose:repD(res and res.message or msg))
                if res and res.message then LOG(res.message) end
                TEST.yieldUntilNextScene()
                NET.connectLost()
                return
            else
                local body=JSON.decode(msg)
                if body then
                    -- print(("Recv:      <-- $1 ($2)"):repD(body.action,body.type))
                    -- print(("Recv:      <-- $1 ($2)"):repD(body.action,body.type)) print(TABLE.dump(body),"\n")
                    if body.type=='Failed' then
                        parseError(body.message~=nil and body.message or msg)
                    else
                        local f=NET.wsCallBack[actMap[body.action]]
                        if f then f(body) end
                    end
                else
                    MES.new('warn',"Wrong json: "..msg,5)
                    WS.alert('user')
                end
            end
        end
    end
end

--------------------------<OLD ONLINE API>
-- Account & User
function NET.getUserInfo(uid)
    wsSend({
        uid=uid,
        hash=USERS.getHash(uid),
    })
end

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
    for _,sec in next,sections do
        if sec.section==1 then
            NET.cloudData.STAT=STRING.unpackTable(sec.data)
        elseif sec.section==2 then
            NET.cloudData.RANKS=STRING.unpackTable(sec.data)
        elseif sec.section==3 then
            NET.cloudData.SETTING=STRING.unpackTable(sec.data)
        elseif sec.section==4 then
            NET.cloudData.keyMap=STRING.unpackTable(sec.data)
        elseif sec.section==5 then
            NET.cloudData.VK_org=STRING.unpackTable(sec.data)
        elseif sec.section==6 then
            NET.cloudData.vkSave1=STRING.unpackTable(sec.data)
        elseif sec.section==7 then
            NET.cloudData.vkSave2=STRING.unpackTable(sec.data)
        end
    end
    local success=true
    TABLE.cover(NET.cloudData.STAT,STAT)
    success=success and saveStats()

    TABLE.cover(NET.cloudData.RANKS,RANKS)
    success=success and saveProgress()

    TABLE.cover(NET.cloudData.SETTING,SETTING)
    success=success and saveSettings()
    applySettings()

    TABLE.cover(NET.cloudData.keyMap,KEY_MAP)
    success=success and saveFile(KEY_MAP,'conf/key')

    TABLE.cover(NET.cloudData.VK_org,VK_ORG)
    success=success and saveFile(VK_ORG,'conf/virtualkey')

    if #NET.cloudData.vkSave1[1] then success=success and saveFile(NET.cloudData.vkSave1,'conf/vkSave1') end
    if #NET.cloudData.vkSave2[1] then success=success and saveFile(NET.cloudData.vkSave2,'conf/vkSave2') end
    if success then
        MES.new('check',text.saveDone)
    else
        MES.new('warn',text.dataCorrupted)
    end
end

return NET
