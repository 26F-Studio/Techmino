local data=love.data
local NET={
	login=false,
	allow_online=false,
	roomList=false,
}

--Account
function NET.pong(wsName,message)
	WS.send(wsName,message,"pong")
end
function NET.getAccessToken()
	WS.send("user",JSON.encode{action=0})
end
function NET.getSelfInfo()
	WS.send("user",JSON.encode{
		action=1,
		data={
			id=USER.id,
		},
	})
end

--Play
function NET.wsConnectPlay()
	WS.connect("play","/play",JSON.encode{
		id=USER.id,
		accessToken=USER.accessToken,
	})
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
			type=nil,
			name=(USER.name or"???").."'s room",
			password=nil,
			conf=dumpBasicConfig(),
		}
	})
end
function NET.enterRoom(roomID,password)
	WS.send("play","/play",JSON.encode{
		action=2,
		data={
			rid=roomID,
			conf=dumpBasicConfig(),
			password=password,
		}
	})
end

--Chat
function NET.sendChatMes(mes)
	WS.send("chat","T"..data.encode("string","base64",mes))
end
function NET.quitChat()
	WS.send("chat","Q")
end

return NET