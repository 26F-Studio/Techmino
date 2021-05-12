local scene={}

function scene.sceneInit()
	BG.set()
end
function scene.sceneBack()
	FILE.save(SETTING,'conf/settings')
end

scene.widgetList={
	WIDGET.newText{name="title",		x=640,y=15,font=80},

	WIDGET.newButton{name="sound",		x=200,y=80,w=240,h=80,color='lC',font=35,code=swapScene("setting_sound",'swipeR')},
	WIDGET.newButton{name="game",		x=1080,y=80,w=240,h=80,color='lC',font=35,code=swapScene("setting_game",'swipeL')},

	WIDGET.newSwitch{name="block",		x=350,y=160,disp=SETval("block"),code=SETrev("block")},
	WIDGET.newSwitch{name="smooth",		x=350,y=210,disp=SETval("smooth"),code=SETrev("smooth")},
	WIDGET.newSwitch{name="upEdge",		x=350,y=260,disp=SETval("upEdge"),code=SETrev("upEdge")},
	WIDGET.newSwitch{name="bagLine",	x=350,y=310,disp=SETval("bagLine"),code=SETrev("bagLine")},

	WIDGET.newSlider{name="ghost",		x=700,y=180,w=380,unit=.6,	disp=SETval("ghost"),show="percent",code=SETsto("ghost")},
	WIDGET.newSlider{name="grid",		x=700,y=240,w=380,unit=.4,	disp=SETval("grid"),show="percent",	code=SETsto("grid")},
	WIDGET.newSlider{name="center",		x=700,y=300,w=380,unit=1,	disp=SETval("center"),				code=SETsto("center")},

	WIDGET.newSlider{name="lockFX",		x=220,y=365,w=380,unit=5,	disp=SETval("lockFX"),	code=SETsto("lockFX")},
	WIDGET.newSlider{name="dropFX",		x=220,y=405,w=380,unit=5,	disp=SETval("dropFX"),	code=SETsto("dropFX")},
	WIDGET.newSlider{name="moveFX",		x=220,y=445,w=380,unit=5,	disp=SETval("moveFX"),	code=SETsto("moveFX")},
	WIDGET.newSlider{name="clearFX",	x=220,y=485,w=380,unit=5,	disp=SETval("clearFX"),	code=SETsto("clearFX")},
	WIDGET.newSlider{name="splashFX",	x=220,y=525,w=380,unit=5,	disp=SETval("splashFX"),code=SETsto("splashFX")},
	WIDGET.newSlider{name="shakeFX",	x=220,y=565,w=380,unit=5,	disp=SETval("shakeFX"),	code=SETsto("shakeFX")},
	WIDGET.newSlider{name="atkFX",		x=220,y=605,w=380,unit=5,	disp=SETval("atkFX"),	code=SETsto("atkFX")},
	WIDGET.newSelector{name="frame",	x=410,y=660,w=360,list={8,10,13,17,22,29,37,47,62,80,100},disp=SETval("frameMul"),code=SETsto("frameMul")},

	WIDGET.newSwitch{name="text",		x=900,y=360,disp=SETval("text"),		code=SETrev("text")},
	WIDGET.newSwitch{name="score",		x=900,y=410,disp=SETval("score"),		code=SETrev("score")},
	WIDGET.newSwitch{name="warn",		x=900,y=460,disp=SETval('warn'),		code=SETrev('warn')},
	WIDGET.newSwitch{name="bufferWarn",	x=900,y=510,disp=SETval('bufferWarn'),	code=SETrev('bufferWarn')},
	WIDGET.newSwitch{name="highCam",	x=900,y=560,disp=SETval("highCam"),		code=SETrev("highCam")},

	WIDGET.newSwitch{name="nextPos",	x=1180,y=360,disp=SETval("nextPos"),	code=SETrev("nextPos")},
	WIDGET.newSwitch{name="fullscreen",	x=1180,y=410,disp=SETval("fullscreen"),	code=switchFullscreen},
	WIDGET.newSwitch{name="power",		x=1180,y=460,disp=SETval("powerInfo"),	code=SETrev("powerInfo")},
	WIDGET.newSwitch{name="clickFX",	x=1180,y=510,disp=SETval("clickFX"),	code=SETrev("clickFX")},
	WIDGET.newSwitch{name="bg",			x=1180,y=560,disp=SETval("bg"),
		code=function()
			BG.set('none')
			SETTING.bg=not SETTING.bg
			BG.set()
		end},
	WIDGET.newSwitch{name="clean",		x=990,y=640,font=35,disp=SETval("cleanCanvas"),code=SETrev("cleanCanvas")},
	WIDGET.newButton{name="back",		x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene