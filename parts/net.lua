local loveEncode,loveDecode=love.data.encode,love.data.decode

local WS=WS
local yield=YIELD
local PLAYERS=PLAYERS

local NET={
    allow_online=false,
    accessToken=false,
    cloudData={},

    roomState={--A copy of room structure on server
        roomInfo={
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
    spectate=false,--If player is spectating
    specSRID=false,--Cached SRID when enter playing room, for connect WS after scene swapped
    seed=false,

    roomReadyState=false,

    onlineCount="_",
}

local mesType={
    Connect=true,
    Self=true,
    Broadcast=true,
    Private=true,
    Server=true,
}

--Parse json message
local function _parse(res)
    res=JSON.decode(res)
    if res then
        if mesType[res.type]then
            return res
        else
            MES.new('warn',("[%s] %s"):format(res.type or"?",res.reason or"[NO Message]"))
        end
    end
end

--WS close message
local function _closeMessage(message)
    local mes=JSON.decode(message)
    if mes then
        MES.new('info',("%s %s|%s"):format(text.wsClose,mes.type or"",mes.reason or""))
    else
        MES.new('info',("%s %s"):format(text.wsClose,message))
    end
end



--------------------------<NEW API>
local function getMsg(request,timeout)
    HTTP(request)
    local totalTime=0
    while true do
        local mes=HTTP.pollMsg(request.pool)
        if mes then
            if type(mes.body)=='string' then
                return JSON.decode(mes.body)
            end
        else
            totalTime=totalTime+yield()
            if totalTime>timeout then
                return
            end
        end
    end
end
function NET.getCode(email)
    if not TASK.lock('getCode') then return end
    TASK.new(function()
        local res=getMsg({
            pool='getCode',
            path='/techmino/api/v1/auth/verify/email',
            body={email=email},
        },12.6)

        if res then
            if res.code==200 then
                USER.email=email
                SCN.fileDropped(2)
                MES.new('info',"Please check your email",5)
            else
                MES.new('error',res.message,5)
            end
        else
            MES.new('error',"Time out",5)
        end

        WAIT.interrupt()
    end)
    WAIT{
        quit=function()
            TASK.unlock('getCode')
            HTTP.deletePool('getCode')
        end,
        timeout=12.6,
    }
end
function NET.codeLogin(code)
    if not TASK.lock('codeLogin') then return end
    TASK.new(function()
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
                USER.rToken=res.refreshToken
                USER.aToken=res.accessToken
                -- TODO: connect WS
                SCN.go('net_game')
            elseif res.code==201 then
                USER.rToken=res.refreshToken
                USER.aToken=res.accessToken
                SCN.fileDropped(3)-- Not designed for this, but it works and no side effects
                MES.new('info',"Please set your password",5)
            else
                MES.new('error',res.message,5)
            end
        else
            MES.new('error',"Time out",5)
        end

        WAIT.interrupt()
    end)
    WAIT{
        quit=function()
            TASK.unlock('codeLogin')
            HTTP.deletePool('codeLogin')
        end,
        timeout=6.26,
    }
end
function NET.setPW(code,pw)
    if not TASK.lock('setPW') then return end
    TASK.new(function()
        pw=HASH.hmac()

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
                SCN.back()
                MES.new('info',"Password set! Now you can login",5)
            else
                MES.new('error',res.message,5)
            end
        else
            MES.new('error',"Time out",5)
        end

        WAIT.interrupt()
    end)
    WAIT{
        quit=function()
            TASK.unlock('setPW')
            HTTP.deletePool('setPW')
        end,
        timeout=6.26,
    }
end
function NET.autoLogin()
    if not USER.password then
        SCN.go('login')
        return
    end
    if not TASK.lock('autoLogin') then return end
    TASK.new(function()
        if USER.aToken then
            local res=getMsg({
                pool='autoLogin',
                path='/techmino/api/v1/auth/check',
                headers={["x-access-token"]=USER.aToken},
            },6.26)

            if res then
                if res.code==200 then
                    -- TODO: connect WS
                    SCN.go('net_game')
                    WAIT.interrupt()
                    return
                else
                    MES.new('warning',res.message,5)
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
                    USER.rToken=res.refreshToken
                    USER.aToken=res.accessToken
                    -- TODO: connect WS
                    MES.new('info',"Login successed",5)
                    SCN.go('net_game')
                    WAIT.interrupt()
                    return
                else
                    MES.new('warning',res.message,5)
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
                    USER.rToken=res.refreshToken
                    USER.aToken=res.accessToken
                    -- TODO: connect WS
                    MES.new('info',"Login successed",5)
                    SCN.go('net_game')
                    WAIT.interrupt()
                    return
                else
                    MES.new('warning',res.message,5)
                end
            else
                WAIT.interrupt()
            end
        end

        SCN.go('login')
        WAIT.interrupt()
    end)
    WAIT{
        quit=function()
            TASK.unlock('autoLogin')
            HTTP.deletePool('autoLogin')
        end,
        timeout=12.6,
    }
end
function NET.pwLogin(email,pw)
    if not TASK.lock('pwLogin') then return end
    TASK.new(function()
        pw=STRING.digezt(pw)

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
                USER.rToken=res.refreshToken
                USER.aToken=res.accessToken
                -- TODO: connect WS
                SCN.go('net_game')
            else
                MES.new('error',res.message,5)
            end
        else
            MES.new('error',"Time out",5)
        end

        WAIT.interrupt()
    end)
    WAIT{
        quit=function()
            TASK.unlock('pwLogin')
            HTTP.deletePool('pwLogin')
        end,
        timeout=12.6,
    }
end
--------------------------</NEW API>



--Connect
function NET.wsconn()
    if WS.status('game')=='dead'then
        NET.roomState.start=true
        WS.connect('stream','/stream',JSON.encode{
            accessToken=USER.aToken,
        },6)
        TASK.new(NET.updateWS_stream)
    end
end

--Disconnect
function NET.wsclose()
    -- WS.close()
end

--Account & User
function NET.getUserInfo(uid)
    WS.send('game',JSON.encode{
        action=1,
        data={
            uid=uid,
            hash=USERS.getHash(uid),
        },
    })
end

--Save
function NET.uploadSave()
    if TASK.lock('uploadSave',8)then
        WS.send('game','{"action":2,"data":{"sections":'..JSON.encode{
            {section=1,data=STRING.packTable(STAT)},
            {section=2,data=STRING.packTable(RANKS)},
            {section=3,data=STRING.packTable(SETTING)},
            {section=4,data=STRING.packTable(KEY_MAP)},
            {section=5,data=STRING.packTable(VK_ORG)},
            {section=6,data=STRING.packTable(loadFile('conf/vkSave1','-canSkip')or{})},
            {section=7,data=STRING.packTable(loadFile('conf/vkSave2','-canSkip')or{})},
        }..'}}')
        MES.new('info',"Uploading")
    end
end
function NET.downloadSave()
    if TASK.lock('downloadSave',8)then
        WS.send('game','{"action":3,"data":{"sections":[1,2,3,4,5,6,7]}}')
        MES.new('info',"Downloading")
    end
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

    if #NET.cloudData.vkSave1[1]then success=success and saveFile(NET.cloudData.vkSave1,'conf/vkSave1')end
    if #NET.cloudData.vkSave2[1]then success=success and saveFile(NET.cloudData.vkSave2,'conf/vkSave2')end
    if success then
        MES.new('check',text.saveDone)
    else
        MES.new('warn',text.dataCorrupted)
    end
end

--Room
function NET.fetchRoom()
    if TASK.lock('fetchRoom',3)then
        WS.send('game',JSON.encode{
            action=0,
            data={
                type=nil,
                begin=0,
                count=10,
            }
        })
    end
end
function NET.createRoom(roomName,description,capacity,roomType,roomData,password)
    if TASK.lock('enterRoom',2)then
        NET.roomState.private=not not password
        NET.roomState.capacity=capacity
        WS.send('game',JSON.encode{
            action=1,
            data={
                capacity=capacity,
                password=password,
                roomInfo={
                    name=roomName,
                    type=roomType,
                    version=VERSION.room,
                    description=description,
                },
                roomData=roomData,

                config=dumpBasicConfig(),
            }
        })
    end
end
function NET.enterRoom(room,password)
    if TASK.lock('enterRoom',6)then
        SFX.play('reach',.6)
        WS.send('game',JSON.encode{
            action=2,
            data={
                rid=room.rid,
                config=dumpBasicConfig(),
                password=password,
            }
        })
    end
end

--Play
function NET.checkPlayDisconn()
    return WS.status('game')~='running'
end
function NET.signal_quit()
    if TASK.lock('quit',3)then
        WS.send('game','{"action":3}')
    end
end
function NET.sendMessage(mes)
    WS.send('game','{"action":4,"data":'..JSON.encode{message=mes}..'}')
end
function NET.changeConfig()
    WS.send('game','{"action":5,"data":'..JSON.encode({config=dumpBasicConfig()})..'}')
end
function NET.signal_setMode(mode)
    if not NET.roomState.start and TASK.lock('ready',3)then
        WS.send('game','{"action":6,"data":'..JSON.encode{mode=mode}..'}')
    end
end
function NET.signal_die()
    WS.send('game','{"action":4,"data":{"score":0,"survivalTime":0}}')
end
function NET.uploadRecStream(stream)
    WS.send('game','{"action":5,"data":{"stream":"'..loveEncode('string','base64',stream)..'"}}')
end

--Chat
function NET.sendChatMes(mes)
    WS.send('game',"T"..loveEncode('string','base64',mes))
end
function NET.quitChat()
    WS.send('game','q')
end

--WS task funcs
function NET.freshPlayerCount()
    while WS.status('game')=='running'do
        for _=1,260 do yield()end
        if TASK.lock('freshPlayerCount',10)then
            WS.send('game',JSON.encode{action=3})
        end
    end
end
function NET.updateWS_user()
    while WS.status('game')~='dead'do
        yield()
        local message,op=WS.read('user')
        if message then
            if op=='ping'then
            elseif op=='pong'then
            elseif op=='close'then
                _closeMessage(message)
                return
            else
                local res=_parse(message)
                if res then
                    if res.type=='Connect'then
                        if res.uid then
                            USER.uid=res.uid
                            USER.authToken=res.authToken
                            saveFile(USER,'conf/user')
                            if SCN.cur=='login'then
                                SCN.back()
                            end
                        end
                        MES.new('check',text.loginOK)

                        --Get self infos
                        NET.getUserInfo(USER.uid)
                        TASK.unlock('wsc_user')
                    elseif res.action==0 then--Get accessToken
                        NET.accessToken=res.accessToken
                        MES.new('check',text.accessOK)
                        NET.wsconn_play()
                    elseif res.action==1 then--Get userInfo
                        USERS.updateUserData(res.data)
                    elseif res.action==2 then--Upload successed
                        TASK.unlock('uploadSave')
                        MES.new('check',text.exportSuccess)
                    elseif res.action==3 then--Download successed
                        TASK.unlock('downloadSave')
                        NET.loadSavedData(res.data.sections)
                        MES.new('check',text.importSuccess)
                    end
                else
                    WS.alert('user')
                end
            end
        end
    end
end

return NET
