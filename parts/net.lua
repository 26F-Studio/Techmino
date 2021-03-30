local data=love.data
local NET={
	login=false,
	allow_online=false,
	roomList=false,
	accessToken=false,
}

--Lock & Unlock submodule
local locks={}
function NET.lock(name,T)
	if locks[name]and TIME()<locks[name]then
		return false
	else
		locks[name]=TIME()+(T or 1e99)
		return true
	end
end
function NET.unlock(name)
	locks[name]=false
end

--messageParse
function NET.parse(res)
	res=JSON.decode(res)
	if res then
		if res.message=="OK"or res.message=="Connected"then
			return res
		else
			LOG.print(res.message and res.message..": "..(res.reason or"[NO reason]")or"[NO Message]","warning")
		end
	end
end

--wsEvent
function NET.wsCloseMessage(message)
	if message:sub(1,1)=="{"then
		local mes=JSON.decode(message)
		LOG.print(text.wsClose..mes.message,"warn")
	else
		LOG.print(text.wsClose..message,"warn")
	end
end

--Account
function NET.pong(wsName,message)
	WS.send(wsName,message,"pong")
end
function NET.getAccessToken()
	if NET.lock("accessToken")then
		WS.send("user",JSON.encode{action=0})
	end
end
function NET.getUserInfo(id,ifDetail)
	WS.send("user",JSON.encode{
		action=1,
		data={
			id=id or USER.id,
			detailed=ifDetail or false,
		},
	})
end
function NET.storeUserInfo(res)
	local user=USERS[res.id]
	if not user then
		user={}
		user.email=res.email
		user.name=res.username
		USERS[res.id]=user
	else
		user.email=res.email
		user.name=res.username
		if not user.motto then user.motto=res.motto end
		if not user.avatar then user.avatar=res.avatar end
	end

	--Get own name
	if res.id==USER.id then
		USER.name=res.name
		FILE.save(USER,"conf/user")
	end

	-- FILE.save(USERS,"conf/users")
end

--Play
function NET.wsConnectPlay()
	if NET.lock("connectPlay")then
		WS.connect("play","/play",JSON.encode{
			id=USER.id,
			accessToken=NET.accessToken,
		})
	end
end
function NET.signal_ready()
	WS.send("play","R")
end
function NET.uploadRecStream(stream)
	WS.send("stream",data.encode("string","base64",stream))
end
function NET.signal_die()
	WS.send("play","D")
end
function NET.signal_quit()
	WS.send("play","Q")
end

--Room
function NET.freshRoom()
	WS.send("play",JSON.encode{
		action=0,
		data={
			type=nil,
			begin=0,
			count=10,
		}
	})
end
function NET.createRoom()
	if NET.lock("enterRoom")then
		WS.send("play",JSON.encode{
			action=1,
			data={
				type="classic",
				name=(USER.name or"???").."'s room",
				password=nil,
				config=dumpBasicConfig(),
			}
		})
	end
end
function NET.enterRoom(roomID,password)
	if NET.lock("enterRoom")then
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

--Chat
function NET.sendChatMes(mes)
	WS.send("chat","T"..data.encode("string","base64",mes))
end
function NET.quitChat()
	WS.send("chat","Q")
end

--WS tick funcs
function NET.TICK_WS_app()
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
					local res=NET.parse(message)
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
function NET.TICK_WS_user()
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
					local res=NET.parse(message)
					if res then
						if res.message=="Connected"then
							NET.login=true
							if res.id then
								USER.id=res.id
								USER.authToken=res.authToken
								FILE.save(USER,"conf/user","q")
								SCN.back()
							end
							LOG.print(text.loginSuccessed)

							--Get self infos
							NET.getUserInfo(USER.id)
						elseif res.action==0 then--Get accessToken
							NET.accessToken=res.accessToken
							LOG.print(text.accessSuccessed)
							NET.wsConnectPlay()
							NET.unlock("accessToken")
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
function NET.TICK_WS_play()
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
					local res=NET.parse(message)
					if res then
						if res.message=="Connected"then
							NET.unlock("connectPlay")
							SCN.go("net_menu")
						elseif res.action==0 then--Fetch rooms
							NET.roomList=res.roomList
						elseif res.action==2 then--Join(create) room
							-- loadGame("netBattle",true,true)
							NET.unlock("enterRoom")
						elseif res.action==3 then--Leave room
							SCN.back()
						end
					else
						WS.alert("play")
					end
				end
			end
		end
	end
end
function NET.TICK_WS_stream()
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
					--TODO
				end
			end
		end
	end
end
function NET.TICK_WS_chat()
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
					local res=NET.parse(message)
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