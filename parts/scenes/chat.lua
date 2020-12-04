local function socketWrite(message)
	if WSCONN then
		local writeErr=client.write(WSCONN,message)
		if writeErr then print(writeErr,"warn")end
	else
		LOG.print("尚未连接到服务器","warn")
	end
end

local function sendMessage()
	local W=WIDGET.active.text
	if #W.value>0 then
		socketWrite(W.value)
		W.value=""
	end
end

local scene={}

function scene.sceneInit()
	BG.set("none")
	wsConnect(
		TICK.wsCONN_connect,
		PATH.socket..PATH.chat.."?email="..urlEncode(ACCOUNT.email).."&access_token="..urlEncode(ACCOUNT.access_token)
	)
end

function scene.sceneBack()
    WSCONN=nil
end

function scene.keyDown(k)
	if k=="return"then
		sendMessage()
	elseif k=="escape"then
		SCN.back()
	else
		WIDGET.keyPressed(k)
	end
end

scene.widgetList={
	WIDGET.newTextBox{name="text",	x=40,	y=500,w=980,h=180,font=40},
	WIDGET.newButton{name="send",	x=1140,	y=540,w=170,h=80,font=40,code=sendMessage},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene