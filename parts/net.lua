local data=love.data
local ins,rem=table.insert,table.remove
local NET={
	login=false,
	allow_online=false,
	roomList={},
	accessToken=false,
	rid=false,
	rsid=false,
}

local mesType={
	Connect=true,
	Self=true,
	Broadcast=true,
	Private=true,
	Server=true,
}

--Lock & Unlock submodule
local locks={}
local function _lock(name,T)
	if locks[name]and TIME()<locks[name]then
		return false
	else
		locks[name]=TIME()+(T or 1e99)
		return true
	end
end
local function _unlock(name)
	locks[name]=false
end
function NET.getLock(name)
	return locks[name]
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
			"warning")
		end
	end
end

--wsEvent
function NET.wsCloseMessage(message)
	local mes=JSON.decode(message)
	if mes then
		LOG.print(("%s [%s] %s"):format(text.wsClose,mes.type or"unknown type",mes.reason or""),"warn")
	else
		LOG.print(text.wsClose.."","warn")
	end
end

--Account
function NET.pong(wsName,message)
	WS.send(wsName,message,"pong")
end
function NET.getAccessToken()
	if _lock("accessToken")then
		WS.send("user",JSON.encode{action=0})
	end
end
function NET.getUserInfo(id,ifDetail)
	WS.send("user",JSON.encode{
		action=1,
		data={
			id=id or USER.uid,
			detailed=ifDetail or false,
		},
	})
end
function NET.storeUserInfo(res)
	local user=USERS[res.uid]
	if not user then
		user={}
		user.email=res.email
		user.name=res.username
		USERS[res.uid]=user
	else
		user.email=res.email
		user.name=res.username
		if not user.motto then user.motto=res.motto end
		if not user.avatar then user.avatar=res.avatar end
	end

	--Get own name
	if res.uid==USER.uid then
		USER.username=res.username
		FILE.save(USER,"conf/user")
	end

	-- FILE.save(USERS,"conf/users")
end

--Room
function NET.fetchRoom()
	if _lock("fetchRoom")then
		WS.send("play",JSON.encode{
			action=0,
			data={
				type=nil,
				begin=0,
				count=10,
			}
		})
	end
end
function NET.createRoom()
	if _lock("enterRoom")then
		WS.send("play",JSON.encode{
			action=1,
			data={
				type="classic",
				name=(USER.username or"???").."'s room",
				password=nil,
				config=dumpBasicConfig(),
			}
		})
	end
end
function NET.enterRoom(roomID,password)
	if _lock("enterRoom")then
		NET.rid=roomID
		WS.send("play",JSON.encode{
			action=2,
			data={
				rid=roomID,
				config=dumpBasicConfig(),
				password=password,
			}
		})
	end
end

--Play
function NET.wsConnectPlay()
	if _lock("connectPlay")then
		WS.connect("play","/play",JSON.encode{
			uid=USER.uid,
			accessToken=NET.accessToken,
		})
	end
end
function NET.signal_ready()
	if _lock("ready")then
		WS.send("play",'{"action":6,"data":{"ready":true}}')
	end
end
function NET.signal_quit()
	WS.send("play",'{"action":3}')
end
function NET.wsConnectStream()
	if _lock("connectStream")then
		WS.connect("stream","/stream",JSON.encode{
			uid=USER.uid,
			accessToken=NET.accessToken,
			rid=NET.rsid,
		})
	end
end
function NET.uploadRecStream(stream)
	WS.send("stream",'{"action":2,"data":{"stream":"'..data.encode("string","base64",stream)..'"}}')
end
function NET.signal_die()
	WS.send("stream",'{"action":3,"data":{"score":0,"survivalTime":0}}')
end

--Chat
function NET.sendChatMes(mes)
	WS.send("chat","T"..data.encode("string","base64",mes))
end
function NET.quitChat()
	WS.send("chat","Q")
end

--WS tick funcs
function NET.updateWS_app()
	local retryTime=5
	while true do
		YIELD()
		local status=WS.status("app")
		if status=="running"then
			local message,op=WS.read("app")
			if message then
				if op=="ping"then
					NET.pong("app",message)
				elseif op=="pong"then
				elseif op=="close"then
					NET.wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						if VERSION_CODE>=res.lowest then
							NET.allow_online=true
						end
						if VERSION_CODE<res.newestCode then
							LOG.print(text.oldVersion:gsub("$1",res.newestName),180,COLOR.sky)
						end
						LOG.print(res.notice,300,COLOR.sky)
					else
						WS.alert("app")
					end
				end
			end
		elseif status=="dead"then
			retryTime=retryTime-1
			if retryTime==0 then return end
			for _=1,120 do YIELD()end
			WS.connect("app","/app")
		end
	end
end
function NET.updateWS_user()
	while true do
		YIELD()
		local status=WS.status("user")
		if status=="running"then
			local message,op=WS.read("user")
			if message then
				if op=="ping"then
					NET.pong("user",message)
				elseif op=="pong"then
				elseif op=="close"then
					NET.wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						if res.type=="Connect"then
							NET.login=true
							if res.uid then
								USER.uid=res.uid
								USER.authToken=res.authToken
								FILE.save(USER,"conf/user","q")
								SCN.back()
							end
							LOG.print(text.loginSuccessed)

							--Get self infos
							NET.getUserInfo(USER.uid)
						elseif res.action==0 then--Get accessToken
							NET.accessToken=res.accessToken
							LOG.print(text.accessSuccessed)
							NET.wsConnectPlay()
							_unlock("accessToken")
						elseif res.action==1 then--Get userInfo
							NET.storeUserInfo(res)
						end
					else
						WS.alert("user")
					end
				end
			end
		end
	end
end
function NET.updateWS_play()
	while true do
		YIELD()
		local status=WS.status("play")
		if status=="running"then
			local message,op=WS.read("play")
			if message then
				if op=="ping"then
					NET.pong("play",message)
				elseif op=="pong"then
				elseif op=="close"then
					NET.wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						if res.type=="Connect"then
							SCN.go("net_menu")
							_unlock("connectPlay")
						elseif res.action==0 then--Fetch rooms
							NET.roomList=res.roomList
							_unlock("fetchRoom")
						elseif res.action==1 then--Create room (not used)
						elseif res.action==2 then--Player join
							if res.type=="Self"then
								--Create room
								TABLE.clear(PLY_NET)
								ins(PLY_NET,{
									uid=USER.uid,
									username=USER.username,
									sid=data.sid,
									ready=data.ready,
									conf=dumpBasicConfig(),
								})
								if data.players then
									for _,p in next,data.players do
										ins(PLY_NET,{
											uid=p.uid,
											username=p.username,
											sid=p.sid,
											ready=p.ready,
											conf=p.config,
										})
									end
								end
								loadGame("netBattle",true,true)
								_unlock("enterRoom")
							else
								--Load other players
								ins(PLY_NET,{
									uid=data.uid,
									username=data.username,
									sid=data.sid,
									ready=data.ready,
									conf=data.config,
								})
								SCN.socketRead("Join",res.data)
							end
						elseif res.action==3 then--Player leave
							for i=1,#PLY_NET do
								if PLY_NET[i].uid==data.uid then
									rem(PLY_NET,i)
									break
								end
							end
							for i=1,#PLAYERS do
								if PLAYERS[i].userID==data.uid then
									rem(PLAYERS,i)
									break
								end
							end
							for i=1,#PLY_ALIVE do
								if PLY_ALIVE[i].userID==data.uid then
									rem(PLY_ALIVE,i)
									break
								end
							end
							SCN.socketRead("Leave",res.data)
						elseif res.action==4 then--Player talk
							SCN.socketRead("Talk",res.data)
						elseif res.action==5 then--Player change settings
							SCN.socketRead("Config",res.data)
						elseif res.action==6 then--Player ready
							SCN.socketRead("Ready",res.data)
							_unlock("ready")
						elseif res.action==7 then--All ready
						elseif res.action==8 then--Sure ready
							SCN.socketRead("Set",res.data)
						end
					else
						WS.alert("play")
					end
				end
			end
		end
	end
end
function NET.updateWS_stream()
	while true do
		YIELD()
		local status=WS.status("stream")
		if status=="running"then
			local message,op=WS.read("stream")
			if message then
				if op=="ping"then
					NET.pong("stream",message)
				elseif op=="pong"then
				elseif op=="close"then
					NET.wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						if res.type=="Connect"then
							--?
						elseif res.action==0 then--Game start
							SCN.socketRead("Begin",res.data)
						elseif res.action==1 then--Game finished
							SCN.socketRead("Finish",res.data)
						elseif res.action==2 then--Player join
							--?
						elseif res.action==3 then--Player leave
							--?
						elseif res.action==4 then--Player died
							SCN.socketRead("Die",res.data)
						elseif res.action==5 then--Receive stream
							SCN.socketRead("Stream",res.data)
						end
					else
						WS.alert("stream")
					end
				end
			end
		end
	end
end
function NET.updateWS_chat()
	while true do
		YIELD()
		local status=WS.status("chat")
		if status=="running"then
			local message,op=WS.read("chat")
			if message then
				if op=="ping"then
					NET.pong("chat",message)
				elseif op=="pong"then
				elseif op=="close"then
					NET.wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						--TODO
					else
						WS.alert("chat")
					end
				end
			end
		end
	end
end

return NET