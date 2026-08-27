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

    rankedResult=false,-- Summary of the last ranked match for the results scene

    roomAllReady=false,

    onlineCount="0",
    onlinePlayers={},-- List of online players (id, username, elo)

    textBox=WIDGET.newTextBox{name='texts',x=20,y=110,w=980,h=500},
    inputBox=WIDGET.newInputBox{name='input',x=20,y=630,w=980,h=50,limit=256},
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
                        local errMsg = body.message
                        if not errMsg and msg and msg.body then
                            errMsg = tostring(msg.body)
                        elseif not errMsg then
                            errMsg = "HTTP "..tostring(msg and msg.code or "?")
                        end
                        parseError(errMsg)
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

function NET.login(auto)
    if not TASK.lock('login') then return end
    TASK.new(function()
        WAIT{
            quit=function()
                TASK.unlock('login')
                HTTP.deletePool('login')
            end,
            timeout=12.6,
        }

        if USER.aToken then
            local res=getMsg({
                pool='login',
                url=AUTHHOST,
                path='/api/auth/check',
                headers={["x-access-token"]=USER.aToken},
            },6.26)

            if res and res.code and math.floor(res.code/100)==2 then
                USER.uid=res.data.playerId
                if res.data.accessToken then
                    USER.aToken=res.data.accessToken
                end
                if res.data.username then
                    USERS.updateUsername(USER.uid,res.data.username)
                end
                saveUser()
                NET.ws_connect()
                NET.getUserInfo(USER.uid)
                if not auto then-- Quit login menu
                    SCN.pop()
                end
                SCN.go('lobby')
                WAIT.interrupt()
                return
            end
        end
        if auto then
            SCN.go('lobby')
        end

        WAIT.interrupt()
    end)
end
function NET.loginWithPassword(username,password)
    if not TASK.lock('login') then return end
    TASK.new(function()
        WAIT{
            quit=function()
                TASK.unlock('login')
                HTTP.deletePool('loginPW')
            end,
            timeout=12.6,
        }

        local res=getMsg({
            pool='loginPW',
            url=AUTHHOST,
            path='/api/login',
            body={username=username,password=password},
        },6.26)

        if res and res.code and math.floor(res.code/100)==2 and res.data and res.data.token then
            USER.oToken=res.data.token
            USER.aToken=res.data.token
            if res.data.playerId then
                USER.uid=res.data.playerId
                if res.data.username then
                    USERS.updateUsername(USER.uid,res.data.username)
                end
            end
            saveUser()
            NET.ws_connect()
            NET.getUserInfo(USER.uid)
            SCN.go('lobby')
            WAIT.interrupt()
            return
        elseif res then
            MES.new('error',res.message or 'Login failed')
        else
            MES.new('error',text.serverDown)
        end

        WAIT.interrupt()
    end)
end
function NET.register(username,email,password)
    if not TASK.lock('register') then return end
    TASK.new(function()
        WAIT{
            quit=function()
                TASK.unlock('register')
                HTTP.deletePool('register')
            end,
            timeout=12.6,
        }

        HTTP({
            pool='register',
            url=AUTHHOST,
            path='/api/register',
            body={username=username,email=email,password=password},
        })

        local totalTime=0
        while true do
            local msg=HTTP.pollMsg('register')
            if msg then
                if type(msg.body)=='string' and #msg.body>0 then
                    if msg.code==201 then
                        MES.new('check','Registration successful! You can now log in.')
                        NET.loginWithPassword(username,password)
                    else
                        MES.new('error',msg.body)
                    end
                else
                    MES.new('info',text.serverDown)
                end
                break
            else
                totalTime=totalTime+coroutine.yield()
                if totalTime>6.26 then
                    MES.new('info',text.serverDown)
                    break
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
            url=AUTHHOST,
            path='/api/player/info?playerId='..uid,
        },6.26)

        if res and res.code==200 and type(res.data)=='table' then
            USERS.updateUserData(res.data)
            -- When this is our own profile, sync the competitive elo and rank
            -- so the lobby/card reflect the values persisted on the server
            -- (otherwise they reset to the defaults after a client restart).
            if uid==USER.uid then
                if type(res.data.elo)=='number' then STAT.elo=res.data.elo end
                if type(res.data.globalRank)=='number' then STAT.globalRank=res.data.globalRank end
            end
        end
    end)
end
function NET.getAvatar(uid)
    TASK.new(function()
        local res=getMsg({
            pool='getInfo',
            url=AUTHHOST,
            path='/api/player/avatar?playerId='..uid,
        },6.26)

        if res and res.code==200 and type(res.data)=='string' then
            USERS.updateAvatar(uid,res.data)
        end
    end)
end

local noticeLang={
    en='en_us',
    fr='en_us', -- fr_fr
    es='en_us', -- es_es
    id='en_us', -- id_id
    pt='en_us', -- pt_pt
    ru='en_us', -- ru_ru
    ja='en_us', -- ja_jp
    vi='en_us', -- vi_vn
    zh='zh_cn',
    zh_trad='zh_tw',
    zh_code='zh_cn',
}
function NET.launchNotice()
    TASK.new(function()
        local res=getMsg({
            pool='getNotice',
            path='/api/notice?language='..noticeLang[SETTING.locale]..'&lastCount=1',
        },6.26)

        if res and res.code==200 then
            local opt=res.data.contents[1]
            if opt then
                MES.new('info',opt.content,12.6)
            else
                MES.new('info',text.Techrater.NoticeManager.noticeNotFound)
            end
        end
    end)
end
function NET.getNotice(count)
    WAIT{timeout=6.26}
    TASK.new(function()
        local res=getMsg({
            pool='getNotice',
            path='/api/notice?language='..noticeLang[SETTING.locale]..'&lastCount='..(count or 5),
        },6.26)

        if res and res.code==200 then
            WAIT.interrupt()
            SCN.go('notice',nil,noticeLang[SETTING.locale],res.data.contents)
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
    online_getPlayers=      1312,
    online_playerJoin=      1313,
    online_playerLeave=     1314,
    player_updateElo=       1315,
    global_chat=            1316,
    match_join=             1400,
    match_leave=            1401,
    match_found=            1402,
    match_start_ranked=      1403,
    match_finish_ranked=     1404,
    match_cancel=            1405,
    match_uploadReplay=      1406,
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
        SCN.backTo('lobby')
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

-- Global
function NET.global_chat(text)
    if not TASK.lock('chatLimit',1.26) then
        MES.new('warn',text.tooFrequent)
    elseif #text>0 then
        wsSend(actMap.global_chat,{message=text})
        return true
    end
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
function NET.online_getPlayers()
    wsSend(actMap.online_getPlayers)
end
function NET.player_updateElo()
    wsSend(actMap.player_updateElo)
end

-- Ranked 1v1 matchmaking
function NET.ranked_join()
    if WS.status('game')=='dead' then NET.ws_connect() end
    wsSend(actMap.match_join)
end
function NET.ranked_leave()
    wsSend(actMap.match_leave)
end

-- Build the local player's .rep bytes (zlib-compressed metadata + recording)
-- from the in-memory GAME.rep. Returns the raw bytes string, or false.
local function _buildLocalRepBytes()
    if not GAME.rep or #GAME.rep==0 then return false end
    local metadata={
        date=os.date("%Y/%m/%d %H:%M:%S"),
        mode=GAME.curModeName,
        version=VERSION.string,
        player=USERS.getUsername(USER.uid),
        -- Store the exact seed string (NET.seed) rather than the numeric
        -- GAME.seed: a 64-bit match seed cannot survive JSON number round-trips
        -- as a double, and a lossy seed would make the replay's piece sequence
        -- diverge from the live match.
        seed=NET.seed,
        setting=GAME.setting,
        mod={},
        tasUsed=GAME.tasUsed,
    }
    local ok,content=pcall(love.data.compress,'string','zlib',
        JSON.encode(metadata).."\n"..DATA.dumpRecording(GAME.rep))
    if not ok or not content then return false end
    return content
end

-- Upload the local player's replay for a finished ranked match. The server
-- stores it under replays/<matchId>/<playerId>.rep so both participants' runs
-- live in the same match folder. Fire-and-forget (best effort).
function NET.uploadRankedReplay(matchId)
    if not matchId or not USER.uid then return end
    local content=_buildLocalRepBytes()
    if not content then return end
    TASK.new(function()
        wsSend(actMap.match_uploadReplay,{
            matchId=matchId,
            playerId=USER.uid,
            data=love.data.encode('string','base64',content),
        })
    end)
end

-- Save both players' replays locally (under replay/ranked_<matchId>_<uid>.rep)
-- so they appear in the replay list and can be watched later. The local file
-- is built from GAME.rep directly; the opponent's is fetched from the server.
function NET.saveRankedReplays(matchId,oppId)
    if not matchId or not USER.uid then return end
    TASK.new(function()
        local content=_buildLocalRepBytes()
        if content then
            love.filesystem.write(("replay/ranked_%s_%s.rep"):format(matchId,USER.uid),content)
        end
        if oppId then
            local oppRaw=_fetchRankedReplayRaw(matchId,oppId)
            if oppRaw then
                love.filesystem.write(("replay/ranked_%s_%s.rep"):format(matchId,oppId),oppRaw)
            end
        end
    end)
end

-- Fetch a stored ranked replay's raw bytes from the server. Returns the body
-- string (zlib-compressed .rep) or false on failure/timeout.
local function _fetchRankedReplayRaw(matchId,playerId)
    HTTP{
        pool='repDL',
        url=AUTHHOST,
        path=("/api/match/replay?matchId=%s&playerId=%s"):format(matchId,playerId),
        headers={['x-access-token']=USER.oToken},
    }
    local totalTime=0
    while true do
        local msg=HTTP.pollMsg('repDL')
        if msg then
            if type(msg.body)=='string' and #msg.body>0 then
                return msg.body
            end
            return false
        else
            totalTime=totalTime+coroutine.yield()
            if totalTime>6.26 then return false end
        end
    end
end

-- Download both players' replays for a finished ranked match, save them
-- locally (so they persist in the replay list), and play the match back as a
-- combined 1v1 net replay. Both clients only record their own placements, so
-- the combined replay needs both files to be complete; we wait/poll until the
-- opponent's replay has finished uploading before playing, so we never watch a
-- truncated/corrupt replay.
function NET.watchRankedReplay()
    local R=NET.rankedResult
    if not R or not R.matchId or not R.oppId then
        MES.new('error',"No replay available")
        return
    end
    TASK.new(function()
        local ok,err=pcall(function()
            MES.new('info',"Waiting for replay...")
            local myRaw,oppRaw
            -- Poll until both replays are available (the opponent may still be
            -- uploading their recording when the results screen appears).
            local waited=0
            while true do
                myRaw=_fetchRankedReplayRaw(R.matchId,USER.uid)
                oppRaw=_fetchRankedReplayRaw(R.matchId,R.oppId)
                if myRaw and oppRaw then break end
                waited=waited+coroutine.yield()
                if waited>15.26 then
                    MES.new('error',"Replay not ready yet")
                    return
                end
            end
            -- Persist both original replays locally.
            love.filesystem.write(("replay/ranked_%s_%s.rep"):format(R.matchId,USER.uid),myRaw)
            love.filesystem.write(("replay/ranked_%s_%s.rep"):format(R.matchId,R.oppId),oppRaw)

            -- Register them in the replay list (if not already) so they can also
            -- be watched later through the standard replay scene's buttons.
            for _,uid in next,{USER.uid,R.oppId} do
                local fn=("replay/ranked_%s_%s.rep"):format(R.matchId,uid)
                local exists=false
                for _,r in next,REPLAY do
                    if r.fileName==fn then exists=true break end
                end
                if not exists then
                    local rep=DATA.parseReplay(fn)
                    if rep and rep.available then table.insert(REPLAY,1,rep) end
                end
            end

            local myRep=DATA.parseReplayData("ranked",myRaw,true)
            local oppRep=DATA.parseReplayData("ranked",oppRaw,true)
            if not (myRep and myRep.available and oppRep and oppRep.available) then
                MES.new('error',"Replay data corrupted")
                return
            end
            NET.startRankedReplay(myRep,oppRep,USER.uid,R.oppId)
        end)
        if not ok then
            MES.new('error',"Replay playback failed")
            LOG("watchRankedReplay error: "..tostring(err))
            LOG(debug.traceback())
        end
    end)
end

-- Start a combined 1v1 net replay: player 1 is driven by `myRep`'s recording
-- and player 2 (remote) by `oppRep`'s recording, reusing the live net_game
-- streaming path. Does not affect live matchmaking.
function NET.startRankedReplay(myRep,oppRep,myUid,oppUid)
    myUid=myUid or USER.uid
    oppUid=oppUid or (NET.rankedResult and NET.rankedResult.oppId)
    if not myUid or not oppUid then
        MES.new('error',"Missing replay player info")
        LOG("startRankedReplay: missing player uids")
        return
    end
    if not MODES.netBattle then
        MODES.netBattle=require('parts.modes.netBattle')
        MODES.netBattle.name='netBattle'
    end

    GAME.net=true
    GAME.replaying=true
    GAME.replaySetup=true
    GAME.fromRepMenu=false
    GAME.init=false
    GAME.seed=myRep.seed or oppRep.seed
    GAME.setting=myRep.setting or GAME.setting
    GAME.curModeName='netBattle'
    GAME.curMode=MODES.netBattle
    GAME.modeEnv=GAME.curMode.env
    GAME.rep={}

    NET.roomState={
        info={name="Ranked Replay",type="ranked",version="",description=""},
        data={},
        count={Gamer=2,Spectator=0},
        capacity=2,
        private=true,
        state="Playing",
    }
    -- Remember the real post-match room so we can restore it once the replay
    -- ends, instead of leaving the fake replay room cached on the client
    -- (which would otherwise keep the matchmaking state polluted).
    NET._replayRoomState=NET.roomState
    NETPLY.clear()
    -- Feed each side its own match settings as the config so the remote-env
    -- loader has a real (non-empty) config. An empty string makes
    -- _loadRemoteEnv emit a "Bad conf" warning (and the ZFramework error
    -- collector then dumps the loadremoteenv/newRemotePlayer/resetGameData
    -- stack) even though this is just a local replay with no live opponent.
    NETPLY.add{uid=myUid,  group=0,role='Admin', playMode='Gamer',readyMode='Playing',config=JSON.encode(myRep.setting or {})}
    NETPLY.add{uid=oppUid,group=0,role='Normal',playMode='Gamer',readyMode='Playing',config=JSON.encode(oppRep.setting or {})}

    NET.seed=GAME.seed
    -- This is a local replay, not a live room: suppress the chat box/overlay
    -- and the networking-only widgets so the replay doesn't look or behave
    -- like an active net session.
    NET.textBox.hide=true
    NET.inputBox.hide=true
    TASK.lock('netPlaying')
    SCN.go('net_game','fade')

    -- After net_game builds the players, feed both recordings as streams.
    TASK.new(function()
        while #PLAYERS<2 do coroutine.yield() end
        local myList={}  DATA.pumpRecording(myRep.data,myList)
        local oppList={} DATA.pumpRecording(oppRep.data,oppList)
        GAME.rep=myList
        GAME.replaying=true
        GAME.replaySetup=false
        GAME.recording=false
        -- Stream sids are mapped onto this replay's canonical NET.uid_sid values
        -- in netBattle.load (same as live net play), so attacks route correctly.
        PLAYERS[1]:startStreaming(myList)
        PLAYERS[2]:startStreaming(oppList)
    end)
end



-- WS
NET.wsCallBack={}
function NET.wsCallBack.global_getOnlineCount(body)
    NET.onlineCount=tonumber(body.data) or "_"
end
function NET.wsCallBack.global_chat(body)
    local name=USERS.getUsername(body.data.playerId)
    if not name or #name==0 then
        name=tostring(body.data.playerId)
    end
    local msg=body.data.message
    if CHAT and CHAT.receiveMessage then
        CHAT.receiveMessage(name,msg)
    end
end
function NET.wsCallBack.room_chat(body)
    if SCN.cur~='net_game' then return end
    TASK.unlock('receiveMessage')
    TASK.lock('receiveMessage',1)

    local name=_getFullName(body.data.playerId).." "
    -- P/s: we need to wrap both name and message, not just only message
    local _,msgWrapped=FONT.get(NET.inputBox.font):getWrap(name..body.data.message,950)
    -- We don't want to see the name repeat twice :skull:
    msgWrapped[1]=string.gsub(msgWrapped[1],name,"",1)
    -- Push the name in white and first line of message in blue first
    NET.textBox:push{COLOR.Z,name,COLOR.N,msgWrapped[1]}
    for i, line in ipairs(msgWrapped) do
        if i ~= 1 then
            NET.textBox:push{COLOR.N,msgWrapped[i]}
        end
    end
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
function NET.wsCallBack.online_getPlayers(body)
    if type(body.data)=='table' then
        NET.onlinePlayers=body.data
    end
end
function NET.wsCallBack.online_playerJoin(body)
    if type(body.data)=='table' then
        table.insert(NET.onlinePlayers,body.data)
    end
end
function NET.wsCallBack.online_playerLeave(body)
    if type(body.data)=='table' and NET.onlinePlayers then
        for i=#NET.onlinePlayers,1,-1 do
            if NET.onlinePlayers[i].id==body.data.id then
                table.remove(NET.onlinePlayers,i)
                break
            end
        end
    end
end
function NET.wsCallBack.player_updateElo(body)
    if type(body.data)=='table' then
        if type(body.data.elo)=='number' then
            STAT.elo=body.data.elo
        end
        if type(body.data.globalRank)=='number' then
            STAT.globalRank=body.data.globalRank
        end
    end
end
function NET.wsCallBack.match_finish()
    if SCN.cur~='net_game' then return end
    -- Ranked matches are finalized by match_finish_ranked, which keeps the
    -- game on screen until the finish animation completes and then drives the
    -- transition to the results screen. Skip the casual waiting-room flow here
    -- so netPlaying is not unlocked early (which would briefly flash the
    -- net_game waiting room before the results scene).
    if NET.roomState.info and NET.roomState.info.type=='ranked' then return end
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
    -- Note: we must set the lock/seed even if the scene hasn't finished
    -- transitioning into net_game yet. The server sends room_enter (1306) and
    -- match_start (1102) back-to-back, and the scene switch is applied at the
    -- frame boundary, so a SCN.cur guard here would drop the lock and the
    -- match would never start. net_game.update only consumes the lock once it
    -- is actually the active scene, so this is safe.
    TASK.lock('netPlaying')
    NET.seed=body.data and body.data.seed
    if not NET.seed then
        NET.seed=0
        MES.new("error",'No seed received')
    end
end
function NET.wsCallBack.match_found(body)
    -- A ranked match was found. The server follows this with a room_enter
    -- (1306) snapshot so the client enters net_game and uses the standard
    -- ready/stream/finish flow, then match_start_ranked (1403).
    MES.new('info',"Match found!")
end
function NET.wsCallBack.match_start_ranked(body)
    -- Same as match_start: set the lock/seed unconditionally (see note there)
    -- so the match starts even if the net_game scene switch is still pending.
    TASK.lock('netPlaying')
    NET.seed=body.data and body.data.seed
    if not NET.seed then
        NET.seed=0
        MES.new("error",'No seed received')
    end
end
function NET.wsCallBack.match_finish_ranked(body)
    if SCN.cur~='net_game' then return end
    for _,P in next,PLAYERS do
        NETPLY.setStat(P.uid,P.stat)
    end
    if body.data then
        local d=body.data
        local matchId=type(d.matchId)=='string' and d.matchId or false
        local myDelta=type(d.ratingChange)=='number' and d.ratingChange or 0
        local myNew=type(d.ratingAfter)=='number' and d.ratingAfter or (STAT.elo or 1200)
        local myOld=myNew-myDelta
        if type(d.globalRank)=='number' then STAT.globalRank=d.globalRank end
        STAT.elo=myNew

        local opp=d.opponent or {}
        local oppId=type(opp.playerId)=='string' and opp.playerId or false
        local oppDelta=type(opp.ratingChange)=='number' and opp.ratingChange or 0
        local oppNew=type(opp.ratingAfter)=='number' and opp.ratingAfter or 0
        local oppOld=oppNew-oppDelta

        -- Cache the opponent's profile so their name shows on the results
        -- screen even if we never fetched it during the match.
        if oppId then NET.getUserInfo(oppId) end

        -- Stash the summary now so the results scene has it ready.
        NET.rankedResult={
            matchId=matchId,
            winnerId=type(d.winnerId)=='string' and d.winnerId or USER.uid,
            myOld=myOld, myNew=myNew, myDelta=myDelta, myRank=STAT.globalRank,
            oppId=oppId, oppOld=oppOld, oppNew=oppNew, oppDelta=oppDelta, oppRank=type(opp.globalRank)=='number' and opp.globalRank or 0,
        }

        -- Best-effort: upload this player's replay into the match folder.
        if matchId then NET.uploadRankedReplay(matchId) end
    end
    -- Let the finish animation (e.g. the opponent's top-out) play out before
    -- showing results. Keep netPlaying locked so net_game does not briefly drop
    -- to the waiting room, and only then transition. net_game.leave() will
    -- unlock netPlaying when the results scene takes over.
    -- Disband the live room on finish so the client isn't left sitting in a
    -- stale room that blocks starting a new ranked search.
    TASK.new(function()
        TEST.yieldT(2.6)
        if SCN.cur=='net_game' then
            NET.roomState=nil
            NETPLY.clear()
            SCN.go('net_rankedResult','fade')
        end
    end)
end
function NET.wsCallBack.match_cancel()
    -- Opponent left the queue before a match was formed.
    if SCN.cur~='net_ranked' then return end
    matchmaking=false
    searchTimer=0
    MES.new('info',"Matchmaking cancelled")
end

function NET.ws_connect()
    if WS.status('game')=='dead' then
        WS.connect('game','',{['x-access-token']=USER.oToken},6)
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
            USER.aToken=false
            USER.oToken=false
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
            path='/api/auth/check',
            headers={["x-access-token"]=USER.oToken},
        },6.26)

        if res and res.code and math.floor(res.code/100)==2 then
            USER.uid=res.data.playerId
            if res.data.accessToken then
                USER.oToken=res.data.accessToken
            end
            if res.data.username then
                USERS.updateUsername(USER.uid,res.data.username)
            end
            saveUser()
        else
            TEST.yieldUntilNextScene()
            GAME.playing=false
            SCN.backTo('main')
            return
        end
    end

    -- Initialize player setting
    NET.player_updateConf()
    -- Sync our competitive elo/rank from the server (persists across restarts).
    NET.getUserInfo(USER.uid)

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
        if updateOnlineCD%125==0 then NET.online_getPlayers() end

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
