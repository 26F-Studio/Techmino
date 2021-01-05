local scene={}

function scene.sceneInit()
	BG.set()
end

scene.widgetList={
	WIDGET.newButton{name="mg_15p",		x=240,	y=250,w=350,h=120,font=40,code=goScene"mg_15p"},
	WIDGET.newButton{name="mg_schulteG",x=640,	y=250,w=350,h=120,font=40,code=goScene"mg_schulteG"},
	WIDGET.newButton{name="mg_pong",	x=1040,	y=250,w=350,h=120,font=40,code=goScene"mg_pong"},
	WIDGET.newButton{name="mg_AtoZ",	x=240,	y=400,w=350,h=120,font=40,code=goScene"mg_AtoZ"},
	WIDGET.newButton{name="mg_UTTT",	x=640,	y=400,w=350,h=120,font=30,code=goScene"mg_UTTT"},
	WIDGET.newButton{name="mg_cubefield",x=1040,y=400,w=350,h=120,font=40,code=goScene"mg_cubefield"},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene