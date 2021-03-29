local data=love.data
local NET={
	login=false,
	allow_online=false,
	roomList=false,
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
function NET.getSelfInfo()
	if NET.lock("getSelfInfo")then
		WS.send("user",JSON.encode{
			action=1,
			data={
				id=USER.id,
			},
		})
	end
end

--Play
function NET.wsConnectPlay()
	if NET.lock("connectPlay")then
		WS.connect("play","/play",JSON.encode{
			id=USER.id,
			accessToken=USER.accessToken,
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
	WS.send("play","/play",JSON.encode{
		action=0,
		data={
			type=nil,
			begin=0,
			count=10,
		}
	})
end
function NET.createRoom()
	WS.send("play",JSON.encode{
		action=1,
		data={
			type="classic",
			name=(USER.name or"???").."'s room",
			password=nil,
			conf=dumpBasicConfig(),
		}
	})
end
function NET.enterRoom(roomID,password)
	if NET.lock("enterRoom")then
		WS.send("play","/play",JSON.encode{
			action=2,
			data={
				rid=roomID,
				conf=dumpBasicConfig(),
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

return NET