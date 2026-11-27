local Json=require'parts.online.json'
local Config=require'parts.online.config'
local Protocol=require'parts.online.protocol'
local Session=require'parts.online.session'
local RoomStore=require'parts.online.roomStore'
local MatchSession=require'parts.online.matchSession'
local NET={connectionState='offline',socketId=false,pending={},requestSequence=0,wantOnline=false,recoverUntil=false,chatSerial=0}
NET.textBox=WIDGET.newTextBox{name='texts',x=20,y=110,w=980,h=500}
NET.inputBox=WIDGET.newInputBox{name='input',x=20,y=630,w=980,h=50,limit=512}
NET.textBox.hide=true
NET.inputBox.hide=true
function NET.report(code,message)
    MES.new('error',tostring(code)..': '..tostring(message),5)
end
NET.roomStore=RoomStore.new(NET.report)
NET.match=MatchSession.new(NET)
NET.session=Session.new{
    productId='techmino',transport='Zframework.transport',json=Json,config=Config.load(),
    notify=function(kind,message) MES.new(kind,message,5) end,
    onSession=function(session)
        local accountId=session.user and session.user.id or false
        if NET.cloud and (USER.uid~=accountId or NET.grantId~=session.grantId) then NET.cloud:clear() end
        NET.grantId=session.grantId
        USER.uid=session.user and session.user.id or false
        if session.user then USERS.setName(session.user.id,session.user.name) end
        if NET.socketId and NET.connectionState=='ready' and session:isAuthenticated() then
            NET.request('connection.renew',{accessToken=session.accessToken})
        elseif NET.wantOnline and session:isAuthenticated() then NET.connect()
        elseif not session:isAuthenticated() and NET.socketId then NET.disconnect('Authorization ended.') end
    end,
}
function NET.slotForAccount(id)
    return NET.match.accountSlots and NET.match.accountSlots[id]
end
function NET.request(operation,data,callback)
    if NET.connectionState~='ready' or not NET.socketId then
        NET.report('CONNECTION_REQUIRED','The authenticated game connection is not ready.')
        if callback then callback(nil,{code='CONNECTION_REQUIRED',message='The game connection is not ready.'}) end
        return
    end
    local count=0
    for _ in pairs(NET.pending) do count=count+1 end
    if count>=64 then
        NET.report('REQUEST_LIMIT','Too many control requests are pending.')
        if callback then callback(nil,{code='REQUEST_LIMIT',message='Too many control requests are pending.'}) end
        return
    end
    NET.requestSequence=NET.requestSequence+1
    local id='c'..NET.requestSequence
    local payload=Json.encode{protocolVersion=1,kind='request',requestId=id,type=operation,data=data or {}}
    if not payload or #payload>16384 then
        NET.report('INVALID_CONTROL','The control request exceeds its approved limit.')
        if callback then callback(nil,{code='INVALID_CONTROL',message='The control request exceeds its approved limit.'}) end
        return
    end
    local ok,err=NET.session.client:send(NET.socketId,payload,'text')
    if not ok then NET.session:report(err) if callback then callback(nil,err) end return end
    NET.pending[id]={operation=operation,callback=callback,deadline=love.timer.getTime()+10}
    return id
end
function NET.roomCommand(operation,data,callback)
    local room=NET.roomStore.snapshot
    if not room then NET.report('ROOM_REQUIRED','Join a room first.') return end
    data=data or {}
    data.roomId=room.id
    return NET.request(operation,data,callback)
end
function NET.listRooms()
    if NET.roomStore.listPending then return end
    NET.roomStore.listPending=true
    NET.request('rooms.list',{},function(data,err)
        NET.roomStore.listPending=false
        if err then return end
        NET.roomStore:setList(data)
    end)
end
function NET.enterRoom(id,password,role)
    NET.request('room.join',{roomId=id,password=password,role=role or 'player'},function(data,err)
        if err then return end
        if NET.roomStore:apply(data) then SCN.go('net_game','swipeD') end
    end)
end
function NET.createRoom(data)
    NET.request('room.create',data,function(snapshot,err)
        if err then return end
        if NET.roomStore:apply(snapshot) then SCN.go('net_game','swipeD') end
    end)
end
function NET.leaveRoom(callback)
    NET.match:releaseAll()
    NET.match:flush()
    NET.roomCommand('room.leave',{},function(_,err)
        if err then return end
        NET.roomStore:clear()
        NET.match:clear()
        if callback then callback() end
    end)
end
function NET.tuning()
    local limits={das=60,arr=30,dascut=60,irscut=30,dropcut=30,sddas=60,sdarr=30}
    local tuning={}
    for key,max in pairs(limits) do tuning[key]=math.max(0,math.min(max,math.floor(SETTING[key]))) end
    for _,key in ipairs{'ihs','irs','ims'} do tuning[key]=SETTING[key]==true end
    return tuning
end
function NET.ready(ready)
    return NET.roomCommand('room.ready',{ready=ready,tuning=NET.tuning()})
end
function NET.chat(message)
    if not Protocol.string(message,512) or #message==0 then NET.report('INVALID_CHAT','Chat is limited to 512 UTF-8 bytes.') return end
    return NET.roomCommand('room.chat',{text=message})
end
function NET.configure(config)
    local ok,err=NET.session:configure(config)
    if ok then Config.save(NET.session.config) else NET.report('INVALID_CONFIGURATION',err) end
    return ok
end
function NET.beginLogin()
    NET.wantOnline=true
    NET.session:beginLogin()
end
function NET.cancelLogin() NET.session:cancelLogin() end
function NET.openOnline()
    NET.wantOnline=true
    if NET.session:isAuthenticated() then
        NET.connect()
        SCN.go(NET.roomStore.snapshot and 'net_game' or 'net_menu')
    elseif NET.session.refreshToken or SYSTEM=='Web' then
        NET.session:refresh(function(ok)
            if ok then SCN.go('net_menu') else SCN.go('login') end
        end)
    else SCN.go('login') end
end
function NET.connect()
    if NET.connectionState=='connecting' or NET.connectionState=='ready' or not NET.session:isAuthenticated() then return end
    NET.connectionState='connecting'
    if SYSTEM~='Web' then
        local url=NET.session.config.cadenceOrigin:gsub('^https:','wss:'):gsub('^http:','ws:')..'/v1/products/techmino/ws'
        local id,err=NET.session.client:connect{url=url,headers={Authorization='Bearer '..NET.session.accessToken},timeout=8}
        if not id then NET.connectionState='offline' NET.session:report(err) else NET.socketId=id end
        return
    end
    NET.session:request('cadence','/v1/products/techmino/connections/tickets','POST',{},function(data,err)
        if err then
            NET.connectionState='offline'
            NET.session:report(err)
            return
        end
        if type(data)~='table' or not Protocol.string(data.ticket,512) or not Protocol.string(data.websocketUrl,2048) then
            NET.connectionState='offline'
            NET.report('INVALID_TICKET','The game server returned an invalid connection ticket.')
            return
        end
        local origin=NET.session.config.cadenceOrigin:gsub('^https:','wss:'):gsub('^http:','ws:')
        if data.websocketUrl:sub(1,#origin+1)~=origin..'/' then NET.connectionState='offline' NET.report('INVALID_SOCKET_URL','The connection URL does not match the configured game server.') return end
        local url=data.websocketUrl
        local id,connectError=NET.session.client:connect{url=url,headers={},timeout=8}
        if not id then NET.connectionState='offline' NET.session:report(connectError) else NET.socketId=id end
    end,true)
end
function NET.disconnect(reason)
    NET.wantOnline=false
    if NET.socketId then NET.session.client:close(NET.socketId,1000,reason or 'Leaving online services.') end
    NET.socketId=false
    NET.connectionState='offline'
    NET.recoverUntil=false
    NET.pending={}
    NET.roomStore:clear()
    NET.match:clear()
end
function NET.logout(callback)
    NET.session:logout(function(ok,err)
        if ok then NET.disconnect('Product session revoked.') if callback then callback() end
        elseif err then NET.session:report(err) end
    end)
end
function NET.website(path)
    local host=NET.session.config.websiteOrigin
    if host then love.system.openURL(host..(path or '/account')) else NET.report('ONLINE_NOT_CONFIGURED','Configure the account website origin first.') end
end
function NET.getProfile(id)
    if not Protocol.id(id) or not NET.session.config.tesseraOrigin then return end
    NET.session:request('tessera','/v1/profiles/'..id,'GET',nil,function(data,err)
        if not err and type(data)=='table' and data.id==id then USERS.updateProfile(data) end
    end)
end
function NET.getAvatar(id,version)
    if not Protocol.id(id) then return end
    NET.session:request('tessera','/v1/profiles/'..id..'/avatar','GET',nil,function(bytes,err,event)
        if not err then USERS.updateAvatar(id,version,bytes,event.headers) end
    end,false,true)
end
local languages={en='en',fr='fr',es='es',id='id',pt='pt',ru='ru',ja='ja',vi='vi',zh='zh',zh_trad='zh-TW',zh_code='zh'}
function NET.announcements(show,cursor)
    if not NET.session.config.cadenceOrigin then return end
    local language=languages[SETTING.locale] or 'en'
    NET.session:request('cadence','/v1/products/techmino/announcements?language='..language..(cursor and '&cursor='..cursor or ''),'GET',nil,function(data,err)
        if err then return end
        if type(data)~='table' or type(data.announcements)~='table' or #data.announcements>32 then NET.report('INVALID_ANNOUNCEMENTS','The announcement response is invalid.') return end
        local contents={}
        for _,item in ipairs(data.announcements) do
            if type(item)~='table' or not Protocol.string(item.content,8192) then NET.report('INVALID_ANNOUNCEMENTS','An invalid announcement was isolated.') return end
            contents[#contents+1]={id=item.id,content=item.content,timestamp=item.createdAt,title=item.title}
        end
        if show then SCN.go('notice',nil,language,contents) elseif contents[1] then MES.new('info',contents[1].content,12) end
    end)
end
local function applyResponse(event)
    local pending=NET.pending[event.requestId]
    if not pending or pending.operation~=event.type then return end
    NET.pending[event.requestId]=nil
    local err
    if not event.ok then
        err=type(event.error)=='table' and event.error or {code='REQUEST_FAILED',message='The operation failed.'}
        NET.report(err.code,err.message)
    elseif pending.operation=='room.update' or pending.operation=='room.password' or pending.operation=='room.ready' or pending.operation=='room.team' or pending.operation=='room.role' or pending.operation=='room.kick' or pending.operation=='room.transfer' then
        if Protocol.room(event.data) then NET.roomStore:apply(event.data) end
    elseif pending.operation=='room.close' then NET.roomStore:clear() NET.match:clear() end
    if pending.callback then pending.callback(event.data,err) end
end
local function control(bytes)
    if type(bytes)~='string' or #bytes>262144 then NET.session.client:close(NET.socketId,1009,'Control response too large.') return end
    local event=Json.decode(bytes)
    if type(event)~='table' or event.protocolVersion~=1 or not Protocol.string(event.type,64) or (event.kind~='response' and event.kind~='event') or type(event.data)~='table' and event.ok~=false then NET.session.client:close(NET.socketId,1002,'Invalid control envelope.') return end
    if event.kind=='response' then
        if not Protocol.string(event.requestId,64) or type(event.ok)~='boolean' then NET.session.client:close(NET.socketId,1002,'Invalid response envelope.') return end
        applyResponse(event)
    elseif event.type=='connection.ready' then
        local identity=event.data.identity
        if type(identity)~='table' or not NET.session.user or identity.productId~='techmino' or identity.subject~=NET.session.user.id or not Protocol.id(identity.subject) then NET.session.client:close(NET.socketId,1002,'Invalid trusted identity.') return end
        NET.identity=identity
        NET.generation=event.data.generation
        NET.connectionState='ready'
        NET.recoverUntil=false
        if event.data.room then
            NET.roomStore:apply(event.data.room)
        else
            NET.roomStore:clear()
            NET.match:clear()
        end
        if NET.match:isActive() then NET.match:resume() end
    elseif event.type=='connection.renewalRequired' then NET.session:refresh()
    elseif event.type=='connection.authorizationEnded' then NET.session:authorizationEnded() NET.disconnect('Authorization ended.')
    elseif event.type=='connection.replaced' then NET.disconnect('Another connection replaced this device.') NET.report('CONNECTION_REPLACED','Another connection replaced this game connection.')
    elseif event.type:sub(1,5)=='room.' then
        local was=NET.roomStore.snapshot
        NET.roomStore:event(event.type,event.data)
        if was and not NET.roomStore.snapshot then NET.match:clear() end
    elseif event.type:sub(1,6)=='match.' then NET.match:event(event.type,event.data)
    else NET.report('UNKNOWN_EVENT','The server sent an unsupported event type.') end
end
function NET.update(dt)
    if NET.session.closed then return end
    NET.session:update()
    if NET.session.client then
        for _=1,128 do
            local event=NET.session.client:poll()
            if not event then break end
            local ok,err=pcall(function()
                if NET.session:handle(event) then return end
                if event.id~=NET.socketId then return end
                if event.kind=='ws_message' then
                    if event.binary then NET.session.client:close(NET.socketId,1002,'Unexpected server binary frame.') else control(event.data) end
                elseif event.kind=='ws_close' or event.kind=='error' then
                    if NET.match:isActive() then NET.match.recovering=true NET.match.releasePending=true end
                    NET.socketId=false
                    NET.connectionState='offline'
                    for _,pending in pairs(NET.pending) do if pending.callback then pending.callback(nil,{code='CONNECTION_LOST',message='The game connection was lost.'}) end end
                    NET.pending={}
                    local terminal=event.code==4001 or event.code==4003 or event.code==1002 or event.code==1009 or event.code==4008
                    if terminal then
                        NET.wantOnline=false
                        NET.match.state='aborted'
                        NET.roomStore:clear()
                        if event.code==4003 then NET.session:authorizationEnded() end
                        NET.report('CONNECTION_CLOSED',event.reason or event.message or 'The server closed this connection.')
                    elseif NET.wantOnline and NET.session:isAuthenticated() then
                        NET.recoverUntil=NET.recoverUntil or love.timer.getTime()+10
                        NET.nextConnect=love.timer.getTime()+.5
                    end
                end
            end)
            if not ok then NET.report('INVALID_MESSAGE','A malformed online message was isolated.') end
        end
    end
    for id,pending in pairs(NET.pending) do
        if love.timer.getTime()>pending.deadline then
            NET.pending[id]=nil
            local err={code='CONTROL_TIMEOUT',message='The game operation timed out.'}
            NET.report(err.code,err.message)
            if pending.callback then pending.callback(nil,err) end
        end
    end
    if NET.recoverUntil then
        if love.timer.getTime()>NET.recoverUntil then
            NET.wantOnline=false
            NET.recoverUntil=false
            NET.match:clear()
            NET.roomStore:clear()
            NET.report('RECOVERY_EXPIRED','The ten-second match recovery window expired.')
        elseif NET.connectionState=='offline' and love.timer.getTime()>NET.nextConnect then NET.nextConnect=love.timer.getTime()+1 NET.connect() end
    end
    NET.match:update(dt)
end
function NET.start()
    Config.removeLegacyCredentials()
    TASK.new(function()
        while not NET.session.closed do
            local dt=coroutine.yield()
            NET.update(dt or 1/60)
        end
    end)
end
function NET.shutdown()
    NET.match:releaseAll()
    NET.match:flush()
    if NET.roomStore.snapshot and NET.connectionState=='ready' then NET.roomCommand('room.leave') end
    NET.session:close()
end
NET.cloud=require('parts.online.cloud').new(NET)
return NET
