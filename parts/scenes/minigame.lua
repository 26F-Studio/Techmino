function sceneInit.minigame()
	BG.set("space")
end

WIDGET.init("minigame",{
	WIDGET.newButton({name="p15",		x=240,	y=250,w=350,h=120,font=40,code=WIDGET.lnk.goScene("p15")}),
	WIDGET.newButton({name="schulte_G",	x=640,	y=250,w=350,h=120,font=40,code=WIDGET.lnk.goScene("schulte_G")}),
	WIDGET.newButton({name="pong",		x=1040,	y=250,w=350,h=120,font=40,code=WIDGET.lnk.goScene("pong")}),
	WIDGET.newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})