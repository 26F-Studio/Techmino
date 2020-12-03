local function socketWrite(message)
	if not WSCONN then
		LOG.print("尚未连接到服务器","warn")
		return
	end
	local writeErr = client.write(WSCONN, message)
	if writeErr then
		print(writeErr, "warn")
	end
	return true
end

local function send()
	local W=WIDGET.active.text
	socketWrite(W.value)
	W.value=""
end

function sceneInit.chat()
	BG.set("none")
	wsConnect(
		TICK.wsCONN_connect,
		PATH.socket..PATH.chat.."?email="..urlEncode(ACCOUNT.email).."&access_token="..urlEncode(ACCOUNT.access_token),
		{}
	)
end

WIDGET.init("chat",{
	WIDGET.newTextBox{name="text",	x=40,	y=500,w=980,h=180,font=40},
	WIDGET.newButton{name="send",	x=1140,	y=540,w=170,h=80,font=40,code=send},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
})