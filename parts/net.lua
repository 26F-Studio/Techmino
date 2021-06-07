local data=love.data
local rem=table.remove

local WS,TIME=WS,TIME
local yield=YIELD

local NET={
	allow_online=false,
	accessToken=false,
	cloudData={},

	roomList={},--Local roomlist, updated frequently
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

	allReady=false,
	connectingStream=false,
	waitingStream=false,

	UserCount="_",
	PlayCount="_",
	StreamCount="_",
}

local mesType={
	Connect=true,
	Self=true,
	Broadcast=true,
	Private=true,
	Server=true,
}

--Lock & Unlock submodule
local locks do
	local rawset=rawset
	locks=setmetatable({},{
		__index=function(self,k)rawset(self,k,-1e99)return -1e99 end,
		__newindex=function(self,k)rawset(self,k,-1e99)end,
	})
end
function NET.lock(name,T)
	if TIME()>=locks[name]then
		locks[name]=TIME()+(T or 1e99)
		return true
	else
		return false
	end
end
function NET.unlock(name)
	locks[name]=-1e99
end
function NET.getlock(name)
	return TIME()<locks[name]
end

--Parse json message
local function _parse(res)
	res=JSON.decode(res)
	if res then
		if mesType[res.type]then
			return res
		else
			LOG.print(
				"WS error:"..(
					res.type and(
						res.reason and res.type..": "..res.reason or
						res.type
					)or
					"[NO Message]"
				),
			'warn')
		end
	end
end

--WS close message
local function wsCloseMessage(message)
	local mes=JSON.decode(message:sub(3))
	if mes then
		LOG.print(("%s [%s] %s"):format(text.wsClose,mes.type or"unknown type",mes.reason or""),'error')
	else
		LOG.print(text.wsClose,'error')
	end
end

--Remove player when leave
local function removePlayer(L,sid)
	for i=1,#L do
		if L[i].sid==sid then
			rem(L,i)
			break
		end
	end
end

--Push stream data to players
local function pumpStream(d)
	if d.uid~=USER.uid then
		for _,P in next,PLAYERS do
			if P.uid==d.uid then
				local res,stream=pcall(love.data.decode,'string','base64',d.stream)
				if res then
					DATA.pumpRecording(stream,P.stream)
				else
					LOG.print("Bad stream from "..P.username.."#"..P.uid,10)
				end
				break
			end
		end
	end
end

--Connect
function NET.wsconn_app()
	WS.connect('app','/app')
	TASK.new(NET.updateWS_app)
	TASK.new(NET.freshPlayerCount)
end
function NET.wsconn_user_pswd(email,password)
	if WS.status('wsc_user')=='dead'then NET.unlock('wsc_user')end
	if NET.lock('wsc_user',5)then
		WS.connect('user','/user',JSON.encode{
			email=email,
			password=password,
		},6)
		TASK.new(NET.updateWS_user)
	end
end
function NET.wsconn_user_token(uid,authToken)
	if WS.status('wsc_user')=='dead'then NET.unlock('wsc_user')end
	if NET.lock('wsc_user',5)then
		WS.connect('user','/user',JSON.encode{
			uid=uid,
			authToken=authToken,
		},6)
		TASK.new(NET.updateWS_user)
	end
end
function NET.wsconn_play()
	if WS.status('wsc_play')=='dead'then NET.unlock('wsc_play')end
	if NET.lock('wsc_play',5)then
		WS.connect('play','/play',JSON.encode{
			uid=USER.uid,
			accessToken=NET.accessToken,
		},6)
		TASK.new(NET.updateWS_play)
	end
end
function NET.wsconn_stream(srid)
	if NET.lock('wsc_stream',5)then
		NET.roomState.start=true
		WS.connect('stream','/stream',JSON.encode{
			uid=USER.uid,
			accessToken=NET.accessToken,
			srid=srid,
		},10)
		TASK.new(NET.updateWS_stream)
	end
end
function NET.wsconn_manage()
	if WS.status('wsc_manage')=='dead'then NET.unlock('wsc_manage')end
	if NET.lock('wsc_manage',5)then
		WS.connect('manage','/manage',JSON.encode{
			uid=USER.uid,
			authToken=USER.authToken,
		},10)
		TASK.new(NET.updateWS_manage)
	end
end

--Disconnect
function NET.wsclose_app()WS.close('app')end
function NET.wsclose_user()WS.close('user')end
function NET.wsclose_play()WS.close('play')end
function NET.wsclose_stream()
	NET.roomState.start=false
	WS.close('stream')
end

--Account & User
function NET.register(username,email,password)
	if NET.lock('register')then
		WS.send('app',JSON.encode{
			action=2,
			data={
				username=username,
				email=email,
				password=password,
			}
		})
	end
end
function NET.tryLogin(ifAuto)
	if NET.allow_online then
		if WS.status('user')=='running'then
			NET.getAccessToken()
		elseif not ifAuto then
			SCN.go('login')
		end
	else
		TEXT.show(text.needUpdate,640,450,60,'flicker')
		SFX.play('finesseError')
	end
end
function NET.pong(wsName,message)
	WS.send(wsName,type(message)=='string'and message or"",'pong')
end
function NET.getAccessToken()
	if NET.lock('access_and_login',10)then
		WS.send('user',JSON.encode{action=0})
	end
end
function NET.getUserInfo(uid)
	local hash=(not SETTING.dataSaving or nil)and USERS.getHash(uid)
	WS.send('user',JSON.encode{
		action=1,
		data={
			uid=uid,
			hash=hash,
		},
	})
end

--Save
function NET.uploadSave()
	if NET.lock('uploadSave',10)then
		WS.send('user','{"action":2,"data":{"sections":'..JSON.encode{
			{section=1,data=STRING.packTable(STAT)},
			{section=2,data=STRING.packTable(RANKS)},
			{section=3,data=STRING.packTable(SETTING)},
			{section=4,data=STRING.packTable(keyMap)},
			{section=5,data=STRING.packTable(VK_org)},
			{section=6,data=STRING.packTable(FILE.load('conf/vkSave1'))},
			{section=7,data=STRING.packTable(FILE.load('conf/vkSave2'))},
		}..'}}')
		LOG.print("Uploading")
	end
end
function NET.downloadSave()
	if NET.lock('downloadSave',10)then
		WS.send('user','{"action":3,"data":{"sections":[1,2,3,4,5,6,7]}}')
		LOG.print("Downloading")
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
	if STAT.version==NET.cloudData.STAT.version then
		TABLE.update(NET.cloudData.STAT,STAT)
		FILE.save(STAT,'conf/data')

		TABLE.update(NET.cloudData.RANKS,RANKS)
		FILE.save(RANKS,'conf/unlock')

		TABLE.update(NET.cloudData.SETTING,SETTING)
		FILE.save(SETTING,'conf/settings')

		TABLE.update(NET.cloudData.keyMap,keyMap)
		FILE.save(keyMap,'conf/key')

		TABLE.update(NET.cloudData.VK_org,VK_org)
		FILE.save(VK_org,'conf/virtualkey')

		FILE.save(NET.cloudData.vkSave1,'conf/vkSave1','q')
		FILE.save(NET.cloudData.vkSave2,'conf/vkSave2','q')
	else
		LOG.print(text.versionNotMatch,60)
	end
end

--Room
function NET.fetchRoom()
	if NET.lock('fetchRoom',3)then
		WS.send('play',JSON.encode{
			action=0,
			data={
				type=nil,
				begin=0,
				count=10,
			}
		})
	end
end
function NET.createRoom(roomName,capacity,roomType,password)
	if NET.lock('enterRoom',1.26)then
		NET.roomState.private=not not password
		NET.roomState.capacity=capacity
		WS.send('play',JSON.encode{
			action=1,
			data={
				capacity=capacity,
				password=password,
				roomInfo={
					name=roomName,
					type=roomType,
					version=VERSION.short,
				},
				roomData={_=0},

				config=dumpBasicConfig(),
			}
		})
	end
end
function NET.enterRoom(room,password)
	if NET.lock('enterRoom',1.26)then
		SFX.play('reach',.6)
		WS.send('play',JSON.encode{
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
	return WS.status('play')~='running'
end
function NET.signal_quit()
	if NET.lock('quit',3)then
		WS.send('play','{"action":3}')
	end
end
function NET.sendMessage(mes)
	WS.send('play','{"action":4,"data":'..JSON.encode{message=mes}..'}')
end
function NET.changeConfig()
	WS.send('play','{"action":5,"data":'..JSON.encode({config=dumpBasicConfig()})..'}')
end
function NET.signal_setMode(mode)
	if not NET.roomState.start and NET.lock('ready',3)then
		WS.send('play','{"action":6,"data":'..JSON.encode{mode=mode}..'}')
	end
end
function NET.signal_die()
	WS.send('stream','{"action":4,"data":{"score":0,"survivalTime":0}}')
end
function NET.uploadRecStream(stream)
	WS.send('stream','{"action":5,"data":{"stream":"'..data.encode('string','base64',stream)..'"}}')
end

--Chat
function NET.sendChatMes(mes)
	WS.send('chat',"T"..data.encode('string','base64',mes))
end
function NET.quitChat()
	WS.send('chat','q')
end

--WS tick funcs
function NET.freshPlayerCount()
	while WS.status('app')~='dead'do
		for _=1,260 do yield()end
		WS.send('app',JSON.encode{action=3})
	end
end
function NET.updateWS_app()
	while WS.status('app')~='dead'do
		yield()
		local message,op=WS.read('app')
		if message then
			if op=='ping'then
				NET.pong('app',message)
			elseif op=='pong'then
			elseif op=='close'then
				wsCloseMessage(message)
				return
			else
				local res=_parse(message)
				if res then
					if res.type=='Connect'then
						if VERSION.code>=res.lowest then
							NET.allow_online=true
							if USER.authToken then
								NET.wsconn_user_token(USER.uid,USER.authToken)
							elseif SCN.cur=='main'then
								SCN.go('login')
							end
						end
						if VERSION.code<res.newestCode then
							LOG.print(text.oldVersion:gsub("$1",res.newestName),180)
						end
						LOG.print(res.notice,300)
						NET.tryLogin(true)
					elseif res.action==0 then--Broadcast
						LOG.print(res.data.message,300)
					elseif res.action==1 then--Get notice
						--?
					elseif res.action==2 then--Register
						if res.type=='Self'or res.type=='Server'then
							LOG.print(res.data.message,300)
							if SCN.cur=='register'then
								SCN.back()
							end
						else
							LOG.print(res.reason or"Registration failed",300)
						end
						NET.unlock('register')
					elseif res.action==3 then--Get player counts
						NET.UserCount=res.data.User
						NET.PlayCount=res.data.Play
						NET.StreamCount=res.data.Stream
						--res.data.Chat
					end
				else
					WS.alert('app')
				end
			end
		end
	end
end
function NET.updateWS_user()
	while WS.status('user')~='dead'do
		yield()
		local message,op=WS.read('user')
		if message then
			if op=='ping'then
				NET.pong('user',message)
			elseif op=='pong'then
			elseif op=='close'then
				wsCloseMessage(message)
				return
			else
				local res=_parse(message)
				if res then
					if res.type=='Connect'then
						if res.uid then
							USER.uid=res.uid
							USER.authToken=res.authToken
							FILE.save(USER,'conf/user','q')
							if SCN.cur=='login'then SCN.back()end
						end
						LOG.print(text.loginSuccessed,'message')

						--Get self infos
						NET.getUserInfo(USER.uid)
						NET.unlock('wsc_user')
					elseif res.action==0 then--Get accessToken
						NET.accessToken=res.accessToken
						LOG.print(text.accessSuccessed,'message')
						NET.wsconn_play()
					elseif res.action==1 then--Get userInfo
						USERS.updateUserData(res.data)
					elseif res.action==2 then--Upload successed
						NET.unlock('uploadSave')
						LOG.print(text.exportSuccess)
					elseif res.action==3 then--Download successed
						NET.unlock('downloadSave')
						NET.loadSavedData(res.data.sections)
						LOG.print(text.importSuccess)
					end
				else
					WS.alert('user')
				end
			end
		end
	end
end
function NET.updateWS_play()
	while WS.status('play')~='dead'do
		yield()
		local message,op=WS.read('play')
		if message then
			if op=='ping'then
				NET.pong('play',message)
			elseif op=='pong'then
			elseif op=='close'then
				wsCloseMessage(message)
				return
			else
				local res=_parse(message)
				if res then
					local d=res.data
					if res.type=='Connect'then
						SCN.go('net_menu')
						NET.unlock('wsc_play')
						NET.unlock('access_and_login')
						SFX.play('connected')
					elseif res.action==0 then--Fetch rooms
						NET.roomList=res.roomList
						NET.unlock('fetchRoom')
					elseif res.action==1 then--Create room (not used)
						--?
					elseif res.action==2 then--Player join
						if res.type=='Self'then
							--Enter new room
							netPLY.clear()
							if d.players then
								for _,p in next,d.players do
									netPLY.add{
										uid=p.uid,
										username=p.username,
										sid=p.sid,
										mode=p.mode,
										config=p.config,
									}
								end
							end
							NET.roomState.roomInfo=d.roomInfo
							NET.roomState.roomData=d.roomData
							NET.roomState.count=d.count
							NET.roomState.capacity=d.capacity
							NET.roomState.private=d.private
							NET.roomState.start=d.start

							NET.allReady=false
							NET.connectingStream=false
							NET.waitingStream=false

							NET.spectate=false

							if d.srid then
								NET.spectate=true
								NET.specSRID=d.srid
								NET.connectingStream=true
							end
							loadGame('netBattle',true,true)
						else
							--Load other players
							netPLY.add{
								uid=d.uid,
								username=d.username,
								sid=d.sid,
								mode=d.mode,
								config=d.config,
							}
							if SCN.socketRead then SCN.socketRead('join',d)end
							NET.allReady=false
						end
					elseif res.action==3 then--Player leave
						if not d.uid then
							NET.wsclose_stream()
							NET.unlock('quit')
							SCN.back()
						else
							removePlayer(netPLY.list,d.sid)
							netPLY.freshPos()
							removePlayer(PLAYERS,d.sid)
							removePlayer(PLY_ALIVE,d.sid)
							if SCN.socketRead then SCN.socketRead('leave',d)end
						end
					elseif res.action==4 then--Player talk
						if SCN.socketRead then SCN.socketRead('talk',d)end
					elseif res.action==5 then--Player change settings
						netPLY.setConf(d.uid,d.config)
					elseif res.action==6 then--Player change join mode
						netPLY.setJoinMode(d.uid,d.mode)
					elseif res.action==7 then--All Ready
						SFX.play('reach',.6)
						NET.allReady=true
					elseif res.action==8 then--Set
						NET.allReady=false
						NET.connectingStream=true
						NET.wsconn_stream(d.srid)
					elseif res.action==9 then--Game finished
						if SCN.socketRead then SCN.socketRead('finish',d)end

						--d.result: list of {place,survivalTime,uid,score}
						for _,p in next,d.result do
							for _,P in next,PLAYERS do
								if P.uid==p.uid then
									netPLY.setStat(p.uid,P.stat)
									netPLY.setPlace(p.uid,p.place)
									break
								end
							end
						end

						netPLY.resetState()
						netPLY.freshPos()
						NET.roomState.start=false
						if NET.spectate then NET.signal_setMode(2)end
						NET.spectate=false
						NET.wsclose_stream()
					end
				else
					WS.alert('play')
				end
			end
		end
	end
end
function NET.updateWS_stream()
	while WS.status('stream')~='dead'do
		yield()
		local message,op=WS.read('stream')
		if message then
			if op=='ping'then
				NET.pong('stream',message)
			elseif op=='pong'then
			elseif op=='close'then
				wsCloseMessage(message)
				return
			else
				local res=_parse(message)
				if res then
					local d=res.data
					if res.type=='Connect'then
						NET.unlock('wsc_stream')
						NET.connectingStream=false
					elseif res.action==0 then--Game start
						NET.waitingStream=false
						SCN.socketRead('go')
					elseif res.action==1 then--Game finished
						--?
					elseif res.action==2 then--Player join
						if res.type=='Self'then
							NET.seed=d.seed
							NET.spectate=d.spectate
							netPLY.setConnect(d.uid)
							for _,p in next,d.connected do
								if not p.spectate then
									netPLY.setConnect(p.uid)
								end
							end
							if d.spectate then
								if d.start then
									SCN.socketRead('go')
									if d.history then
										for _,v in next,d.history do
											pumpStream(v)
										end
									end
								end
							else
								NET.waitingStream=true
							end
						else
							if d.spectate then
								netPLY.setJoinMode(d.uid,2)
							else
								netPLY.setConnect(d.uid)
							end
						end
					elseif res.action==3 then--Player leave
						--?
					elseif res.action==4 then--Player died
						for _,P in next,PLY_ALIVE do
							if P.uid==d.uid then
								P:lose(true)
								break
							end
						end
					elseif res.action==5 then--Receive stream
						pumpStream(d)
					end
				else
					WS.alert('stream')
				end
			end
		end
	end
end
function NET.updateWS_chat()
	while WS.status('chat')~='dead'do
		yield()
		local message,op=WS.read('chat')
		if message then
			if op=='ping'then
				NET.pong('chat',message)
			elseif op=='pong'then
			elseif op=='close'then
				wsCloseMessage(message)
				return
			else
				local res=_parse(message)
				if res then
					--TODO
				else
					WS.alert('chat')
				end
			end
		end
	end
end
function NET.updateWS_manage()
	while WS.status('manage')~='dead'do
		yield()
		local message,op=WS.read('manage')
		if message then
			if op=='ping'then
				NET.pong('manage',message)
			elseif op=='pong'then
			elseif op=='close'then
				wsCloseMessage(message)
				return
			else
				local res=_parse(message)
				if res then
					if res.type=='Connect'then
						LOG.print("Manage connected",'warn')
					elseif res.action==0 then
						LOG.print("success",'message')
					elseif res.action==9 then
						LOG.print("success",'message')
					elseif res.action==10 then
						LOG.print(TABLE.dump(res.data))
					elseif res.action==11 then
						LOG.print(TABLE.dump(res.data))
					elseif res.action==12 then
						LOG.print(TABLE.dump(res.data))
					end
				else
					WS.alert('manage')
				end
			end
		end
	end
end

return NET