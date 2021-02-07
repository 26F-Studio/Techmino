local function tick_goChatRoom(task)
	local time=0
	while true do
		coroutine.yield()
		local wsconn,connErr=client.poll(task)
		if wsconn then
			WSCONN=wsconn
			SCN.go("net_chat")
			LOG.print(text.wsSuccessed,"warn")
			return
		elseif connErr then
			LOG.print(text.wsFailed..": "..connErr,"warn")
			return
		end
		time=time+1
		if time>360 then
			LOG.print(text.wsFailed..": "..text.httpTimeout,"message")
			return
		end
	end
end

local scene={}

function scene.sceneInit()
	BG.set("matrix")
end

scene.widgetList={
	WIDGET.newButton{name="ffa",	x=640,	y=200,w=350,h=120,font=40,code=NULL},
	WIDGET.newButton{name="rooms",	x=640,	y=360,w=350,h=120,font=40,code=goScene"net_rooms"},
	WIDGET.newButton{name="chat",	x=640,	y=540,w=350,h=120,font=40,code=function()
		wsConnect(
			tick_goChatRoom,
			PATH.socket..PATH.onlineChat..
			"?email="..urlEncode(USER.email)..
			"&token="..urlEncode(USER.access_token)
		)
	end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene