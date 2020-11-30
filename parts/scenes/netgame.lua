function sceneInit.netgame()
	BG.set("matrix")
end

WIDGET.init("netgame",{
	WIDGET.newButton{name="ffa",	x=640,	y=200,w=350,h=120,font=40,code=NULL},
	WIDGET.newButton{name="rooms",	x=640,	y=360,w=350,h=120,font=40,code=NULL},
	WIDGET.newButton{name="chat",	x=640,	y=540,w=350,h=120,font=40,code=WIDGET.lnk_goScene("chat")},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
})