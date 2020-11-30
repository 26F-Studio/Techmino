local function send()
	local W=WIDGET.active.text
	--sendMessage(W.value)
	W.value=""
end

function sceneInit.chat()
	BG.set("none")
end

WIDGET.init("chat",{
	WIDGET.newTextBox{name="text",	x=40,	y=500,w=980,h=180,font=40},
	WIDGET.newButton{name="send",	x=1140,	y=540,w=170,h=80,font=40,code=send},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
})