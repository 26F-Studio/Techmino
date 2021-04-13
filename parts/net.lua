local data=love.data
local ins,rem=table.insert,table.remove
local WS,TIME=WS,TIME
local NET={
	connected=false,
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
			"warn")
		end
	end
end

--WS close message
local function wsCloseMessage(message)
	local mes=JSON.decode(message)
	if mes then
		LOG.print(("%s [%s] %s"):format(text.wsClose,mes.type or"unknown type",mes.reason or""),"warn")
	else
		LOG.print(text.wsClose.."","warn")
	end
end

--Connect
function NET.wsconn_app()
	WS.connect("app","/app")
end
function NET.wsconn_user_pswd(email,password)
	if NET.lock("wsc_user",5)then
		WS.connect("user","/user",JSON.encode{
			email=email,
			password=password,
		})
	end
end
function NET.wsconn_user_token(uid,authToken)
	if NET.lock("wsc_user",5)then
		WS.connect("user","/user",JSON.encode{
			uid=uid,
			authToken=authToken,
		})
	end
end
function NET.wsconn_play()
	if NET.lock("wsc_play",5)then
		WS.connect("play","/play",JSON.encode{
			uid=USER.uid,
			accessToken=NET.accessToken,
		})
	end
end
function NET.wsconn_stream()
	if NET.lock("wsc_stream",5)then
		WS.connect("stream","/stream",JSON.encode{
			uid=USER.uid,
			accessToken=NET.accessToken,
			rid=NET.rsid,
		})
	end
end

--Disconnect
function NET.wsclose_user()
	WS.close("user")
end
function NET.wsclose_play()
	WS.close("play")
end
function NET.wsclose_stream()
	WS.close("stream")
end

--Account
function NET.register(username,email,password)
	if NET.lock("register")then
		WS.send("app",JSON.encode{
			action=2,
			data={
				username=username,
				email=email,
				password=password,
			}
		})
	end
end
function NET.pong(wsName,message)
	WS.send(wsName,type(message)=="string"and message or"","pong")
end
function NET.getAccessToken()
	if NET.lock("access_and_login",10)then
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
function NET.storeUserInfo(d)
	local user=USERS[d.uid]
	if not user then
		user={}
		USERS[d.uid]=user
	end
	user.uid=d.uid
	user.username=d.username
	user.motto=d.motto
	user.avatar=d.avatar

	--Get own name
	if d.uid==USER.uid then
		USER.username=d.username
		FILE.save(USER,"conf/user","q")
	end

	-- FILE.save(USERS,"conf/users")
end

--Room
function NET.fetchRoom()
	if NET.lock("fetchRoom",3)then
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
function NET.createRoom(roomType,name)
	if NET.lock("enterRoom",1.26)then
		WS.send("play",JSON.encode{
			action=1,
			data={
				type=roomType,
				name=name,
				password=nil,
				config=dumpBasicConfig(),
			}
		})
	end
end
function NET.enterRoom(roomID,password)
	if NET.lock("enterRoom",1.26)then
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
function NET.checkPlayDisconn()
	return WS.status("play")~="running"
end
function NET.signal_ready(ready)
	if NET.lock("ready",3)then
		WS.send("play",'{"action":6,"data":{"ready":'..tostring(ready)..'}}')
	end
end
function NET.signal_quit()
	if NET.lock("quit",3)then
		WS.send("play",'{"action":3}')
	end
end
function NET.signal_die()
	WS.send("stream",'{"action":4,"data":{"score":0,"survivalTime":0}}')
end
function NET.uploadRecStream(stream)
	WS.send("stream",'{"action":5,"data":{"stream":"'..data.encode("string","base64",stream)..'"}}')
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
	local retryTime=3
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
					wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						if res.type=="Connect"then
							NET.connected=true
							if VERSION.code>=res.lowest then
								NET.allow_online=true
								if USER.authToken then
									NET.wsconn_user_token(USER.uid,USER.authToken)
								end
							end
							if VERSION.code<res.newestCode then
								LOG.print(text.oldVersion:gsub("$1",res.newestName),180,COLOR.sky)
							end
							LOG.print(res.notice,300,COLOR.sky)
						elseif res.action==0 then--Get new version info
							--?
						elseif res.action==1 then--Get notice
							--?
						elseif res.action==2 then--Register
							LOG.print(res.data.message,300,COLOR.sky)
							if SCN.cur=="register"then SCN.back()end
							NET.unlock("register")
						end
					else
						WS.alert("app")
					end
				end
			end
		elseif status=="dead"then
			retryTime=retryTime-1
			if retryTime==0 then return end
			for _=1,180 do YIELD()end
			WS.connect("app","/app")
		end
	end
end
function NET.updateWS_user()
	while true do
		YIELD()
		if WS.status("user")=="running"then
			local message,op=WS.read("user")
			if message then
				if op=="ping"then
					NET.pong("user",message)
				elseif op=="pong"then
				elseif op=="close"then
					wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						if res.type=="Connect"then
							if res.uid then
								USER.uid=res.uid
								USER.authToken=res.authToken
								FILE.save(USER,"conf/user","q")
								if SCN.cur=="login"then SCN.back()end
							end
							LOG.print(text.loginSuccessed)

							--Get self infos
							NET.getUserInfo(USER.uid)
							NET.unlock("wsc_user")
						elseif res.action==0 then--Get accessToken
							NET.accessToken=res.accessToken
							LOG.print(text.accessSuccessed)
							NET.wsconn_play()
						elseif res.action==1 then--Get userInfo
							NET.storeUserInfo(res.data)
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
		if WS.status("play")=="running"then
			local message,op=WS.read("play")
			if message then
				if op=="ping"then
					NET.pong("play",message)
				elseif op=="pong"then
				elseif op=="close"then
					wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						local d=res.data
						if res.type=="Connect"then
							SCN.go("net_menu")
							NET.unlock("wsc_play")
							NET.unlock("access_and_login")
						elseif res.action==0 then--Fetch rooms
							NET.roomList=res.roomList
							NET.unlock("fetchRoom")
						elseif res.action==1 then--Create room (not used)
							--?
						elseif res.action==2 then--Player join
							if res.type=="Self"then
								--Create room
								TABLE.clear(PLY_NET)
								if d.players then
									for _,p in next,d.players do
										ins(PLY_NET,p.uid==USER.uid and 1 or #PLY_NET+1,{
											uid=p.uid,
											username=p.username,
											sid=p.sid,
											ready=p.ready,
											config=p.config,
										})
									end
								end
								loadGame("netBattle",true,true)
							else
								--Load other players
								ins(PLY_NET,{
									uid=d.uid,
									username=d.username,
									sid=d.sid,
									ready=d.ready,
									config=d.config,
								})
								if SCN.socketRead then SCN.socketRead("Join",d)end
							end
						elseif res.action==3 then--Player leave
							if not d.uid then
								NET.wsclose_stream()
								SCN.back()
								NET.unlock("quit")
							else
								for i=1,#PLY_NET do
									if PLY_NET[i].sid==d.sid then
										rem(PLY_NET,i)
										break
									end
								end
								for i=1,#PLAYERS do
									if PLAYERS[i].sid==d.sid then
										rem(PLAYERS,i)
										break
									end
								end
								for i=1,#PLY_ALIVE do
									if PLY_ALIVE[i].sid==d.sid then
										rem(PLY_ALIVE,i)
										break
									end
								end
								if SCN.socketRead then SCN.socketRead("Leave",d)end
							end
						elseif res.action==4 then--Player talk
							if SCN.socketRead then SCN.socketRead("Talk",d)end
						elseif res.action==5 then--Player change settings
							if tostring(USER.uid)~=d.uid then
								for i=1,#PLY_NET do
									if PLY_NET[i].uid==d.uid then
										PLY_NET[i].config=d.config
										PLY_NET[i].p:setConf(d.config)
										return
									end
								end
								resetGameData("qn")
							end
						elseif res.action==6 then--One ready
							for i,p in next,PLY_NET do
								if p.uid==d.uid then
									if p.ready~=d.ready then
										p.ready=d.ready
										SFX.play("spin_0",.6)
										if i==1 then
											NET.unlock("ready")
										elseif not PLY_NET[1].ready then
											for j=2,#PLY_NET do
												if not PLY_NET[j].ready then
													break
												elseif j==#PLY_NET then
													SFX.play("blip_2",.5)
												end
											end
										end
									end
									break
								end
							end
						elseif res.action==7 then--Ready
							SFX.play("reach",.6)
						elseif res.action==8 then--Set
							NET.rsid=d.rid
							NET.wsconn_stream()
							TASK.new(NET.updateWS_stream)
						elseif res.action==9 then--Game finished
							NET.wsclose_stream()
							if SCN.socketRead then SCN.socketRead("Finish",d)end
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
		if WS.status("stream")=="running"then
			local message,op=WS.read("stream")
			if message then
				if op=="ping"then
					NET.pong("stream",message)
				elseif op=="pong"then
				elseif op=="close"then
					wsCloseMessage(message)
					return
				else
					local res=_parse(message)
					if res then
						local d=res.data
						if res.type=="Connect"then
							NET.unlock("wsc_stream")
						elseif res.action==0 then--Game start
							SCN.socketRead("Go",d)
						elseif res.action==1 then--Game finished
							--?
						elseif res.action==2 then--Player join
							--?
						elseif res.action==3 then--Player leave
							--?
						elseif res.action==4 then--Player died
							local uid=res.data.uid
							for _,P in next,PLY_ALIVE do
								if P.uid==uid then
									P:lose(true)
									break
								end
							end
						elseif res.action==5 then--Receive stream
							SCN.socketRead("Stream",d)
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
		if WS.status("chat")=="running"then
			local message,op=WS.read("chat")
			if message then
				if op=="ping"then
					NET.pong("chat",message)
				elseif op=="pong"then
				elseif op=="close"then
					wsCloseMessage(message)
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