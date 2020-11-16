function sceneInit.minigame()
	BG.set("space")
end

WIDGET.init("minigame",{
	WIDGET.newButton({name="15p",		x=240,	y=250,w=350,h=120,font=40,code=WIDGET.lnk_goScene("mg_15p")}),
	WIDGET.newButton({name="schulteG",	x=640,	y=250,w=350,h=120,font=40,code=WIDGET.lnk_goScene("mg_schulteG")}),
	WIDGET.newButton({name="pong",		x=1040,	y=250,w=350,h=120,font=40,code=WIDGET.lnk_goScene("mg_pong")}),
	WIDGET.newButton({name="AtoZ",		x=240,	y=400,w=350,h=120,font=40,code=WIDGET.lnk_goScene("mg_AtoZ")}),
	WIDGET.newButton({name="UTTT",		x=640,	y=400,w=350,h=120,font=30,code=WIDGET.lnk_goScene("mg_UTTT")}),
	WIDGET.newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK}),
})