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
                NET.ws.connect()
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
    if not USER.password then
        SCN.go('login')
        return
    end
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
                    NET.ws.connect()
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
                    NET.ws.connect()
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
                    NET.ws.connect()
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
                NET.ws.connect()
                SCN.go('net_menu')
            end
        end

        WAIT.interrupt()
    end)
end

--------------------------<NEW WS API>
local function wsSend(act,data)
    -- print("SEND ACT: "..act)
    WS.send('game',JSON.encode{
        action=act,
        data=data,
    })
end

-- Room
NET.room={}
function NET.room.chat(msg,rid)
    wsSend(1300,{
        message=msg,
        roomId=rid,-- Admin
    })
end
function NET.room.create(roomName,description,capacity,roomType,roomData,password)
    if not TASK.lock('createRoom',6) then return end
    WAIT{
        quit=function()
            TASK.unlock('createRoom')
        end,
        timeout=1e99,
    }
    wsSend(1301,{
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
function NET.room.getData(rid)
    wsSend(1302,{
        roomId=rid,-- Admin
    })
end
function NET.room.setData(data,rid)
    wsSend(1303,{
        data=data,
        roomId=rid,-- Admin
    })
end
function NET.room.getInfo(rid)
    wsSend(1304,{
        roomId=rid,-- Admin
    })
end
function NET.room.setInfo(info,rid)
    wsSend(1305,{
        info=info,
        roomId=rid,-- Admin
    })
end
function NET.room.enter(rid,password)
    if not TASK.lock('enterRoom',6) then return end
    SFX.play('reach',.6)
    wsSend(1306,{
        data={
            roomId=rid,
            password=password,
        }
    })
end
function NET.room.kick(pid,rid)
    wsSend(1307,{
        playerId=pid,-- Host
        roomId=rid,-- Admin
    })
end
function NET.room.leave()
    wsSend(1308)
end
function NET.room.fetch()
    if not TASK.lock('fetchRoom',3) then return end
    wsSend(1309,{
        data={
            pageIndex=0,
            pageSize=26,
        }
    })
end
function NET.room.setPW(pw,rid)
    if not TASK.lock('setRoomPW',2) then return end
    wsSend(1310,{
        data={
            password=pw,
            roomId=rid,-- Admin
        }
    })
end
function NET.room.remove(rid)
    wsSend(1311,{
        roomId=rid-- Admin
    })
end

-- Player
NET.player={}
function NET.player.updateConf()
    wsSend(1200,dumpBasicConfig())
end
function NET.player.finish(msg)-- what msg?
    wsSend(1201,msg)
end
function NET.player.joinGroup(gid)
    wsSend(1202,gid)
end
function NET.player.setReady(bool)
    wsSend(1203,bool)
end
function NET.player.setHost(pid)
    wsSend(1204,{
        playerId=pid,
        role='Admin',
    })
end
function NET.player.setState(state)-- what state?
    wsSend(1205,state)
end
function NET.player.stream(stream)
    wsSend(1206,stream)
end
function NET.player.setPlaying(playing)
    wsSend(1207,playing and 'Gamer' or 'Spectator')
end

-- WS
NET.ws={}
function NET.ws.connect()
    if WS.status('game')=='dead' then
        WS.connect('game','',{['x-access-token']=USER.aToken},6)
        TASK.new(NET.ws.update)
    end
end
function NET.ws.close()
    WS.close('game')
end
function NET.ws.update()
    while WS.status('game')~='dead' do
        coroutine.yield()
        local msg,op=WS.read('game')
        if msg then
            if op=='ping' then
            elseif op=='pong' then
            elseif op=='close' then
                local res=JSON.decode(msg)
                MES.new('info',("$1 $2"):repD(text.wsClose,res and res.message or msg))
                if res and res.message then LOG(res.message) end
                TEST.yieldUntilNextScene()
                while SCN.stack[#SCN.stack-1]~='main' do SCN.pop() end
                SCN.back()
                return
            else
                local body=JSON.decode(msg)
                if body then
                    -- print(("RECV ACT: $1 ($2)"):repD(res.action,res.type))
                    if body.type=='Failed' then
                        parseError(body.message~=nil and body.message or msg)
                    elseif body.action==1100 then-- TODO
                    elseif body.action==1101 then-- TODO
                    elseif body.action==1102 then-- TODO
                    elseif body.action==1201 then-- Finish
                    elseif body.action==1202 then-- Join group
                    elseif body.action==1203 then-- Set ready
                    elseif body.action==1204 then-- Set host
                    elseif body.action==1205 then-- Set state
                    elseif body.action==1206 then-- Stream
                    elseif body.action==1207 then-- Set playing
                    elseif body.action==1301 then-- Create room
                        TASK.unlock('createRoom')
                        -- NET.roomState=...
                        -- SCN.go('net_game')
                        WAIT.interrupt()
                    elseif body.action==1302 then-- Get room data
                    elseif body.action==1303 then-- Set room data
                    elseif body.action==1304 then-- Get room info
                    elseif body.action==1305 then-- Set room info
                    elseif body.action==1306 then-- Enter room
                        TASK.unlock('enterRoom')
                        -- NET.roomState=...
                        -- SCN.go('net_game')
                        WAIT.interrupt()
                    elseif body.action==1307 then-- Kick room
                    elseif body.action==1308 then-- Leave room
                    elseif body.action==1309 then-- Fetch rooms
                        TASK.unlock('fetchRoom')
                        if body.data then SCN.scenes.net_rooms.widgetList.roomList:setList(body.data) end
                    elseif body.action==1310 then-- Set password
                    elseif body.action==1311 then-- Remove room
                    end
                else
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
        data={
            uid=uid,
            hash=USERS.getHash(uid),
        },
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
