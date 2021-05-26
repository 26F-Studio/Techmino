local scene={}

function scene.sceneInit()
	BG.set()
end
function scene.sceneBack()
	FILE.save(SETTING,'conf/settings')
end

scene.widgetBoxHeight=620
scene.widgetList={
	WIDGET.newText{name="title",		x=640,y=15,font=80},

	WIDGET.newButton{name="sound",		x=200,y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_sound','swipeR')},
	WIDGET.newButton{name="game",		x=1080,y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_game','swipeL')},

	WIDGET.newSwitch{name="block",		x=380,y=180,disp=SETval("block"),code=SETrev("block")},
	WIDGET.newSwitch{name="smooth",		x=380,y=230,disp=SETval("smooth"),code=SETrev("smooth")},
	WIDGET.newSwitch{name="upEdge",		x=380,y=280,disp=SETval("upEdge"),code=SETrev("upEdge")},
	WIDGET.newSwitch{name="bagLine",	x=380,y=330,disp=SETval("bagLine"),code=SETrev("bagLine")},

	WIDGET.newSlider{name="ghost",		x=740,y=180,w=350,unit=.6,	disp=SETval("ghost"),show="percent",code=SETsto("ghost")},
	WIDGET.newSlider{name="grid",		x=740,y=260,w=350,unit=.4,	disp=SETval("grid"),show="percent",	code=SETsto("grid")},
	WIDGET.newSlider{name="center",		x=740,y=340,w=350,unit=1,	disp=SETval("center"),				code=SETsto("center")},

	WIDGET.newSlider{name="lockFX",		x=330,y=400,w=540,unit=5,	disp=SETval("lockFX"),	code=SETsto("lockFX")},
	WIDGET.newSlider{name="dropFX",		x=330,y=460,w=540,unit=5,	disp=SETval("dropFX"),	code=SETsto("dropFX")},
	WIDGET.newSlider{name="moveFX",		x=330,y=520,w=540,unit=5,	disp=SETval("moveFX"),	code=SETsto("moveFX")},
	WIDGET.newSlider{name="clearFX",	x=330,y=580,w=540,unit=5,	disp=SETval("clearFX"),	code=SETsto("clearFX")},
	WIDGET.newSlider{name="splashFX",	x=330,y=640,w=540,unit=5,	disp=SETval("splashFX"),code=SETsto("splashFX")},
	WIDGET.newSlider{name="shakeFX",	x=330,y=700,w=540,unit=5,	disp=SETval("shakeFX"),	code=SETsto("shakeFX")},
	WIDGET.newSlider{name="atkFX",		x=330,y=760,w=540,unit=5,	disp=SETval("atkFX"),	code=SETsto("atkFX")},
	WIDGET.newSelector{name="frame",	x=600,y=830,w=460,list={8,10,13,17,22,29,37,47,62,80,100},disp=SETval("frameMul"),code=SETsto("frameMul")},

	WIDGET.newSwitch{name="text",		x=420,y=920,disp=SETval("text"),		code=SETrev("text")},
	WIDGET.newSwitch{name="score",		x=420,y=970,disp=SETval("score"),		code=SETrev("score")},
	WIDGET.newSwitch{name="bufferWarn",	x=420,y=1040,disp=SETval('bufferWarn'),	code=SETrev('bufferWarn')},
	WIDGET.newSwitch{name="showSpike",	x=420,y=1090,disp=SETval('showSpike'),	code=SETrev('showSpike')},
	WIDGET.newSwitch{name="nextPos",	x=420,y=1160,disp=SETval("nextPos"),		code=SETrev("nextPos")},
	WIDGET.newSwitch{name="highCam",	x=420,y=1210,disp=SETval("highCam"),	code=SETrev("highCam")},
	WIDGET.newSwitch{name="warn",		x=420,y=1280,disp=SETval("warn"),		code=SETrev("warn")},

	WIDGET.newSwitch{name="clickFX",	x=1000,y=920,disp=SETval("clickFX"),	code=SETrev("clickFX")},
	WIDGET.newSwitch{name="power",		x=1000,y=1010,disp=SETval("powerInfo"),	code=SETrev("powerInfo")},
	WIDGET.newSwitch{name="clean",		x=1000,y=1100,disp=SETval("cleanCanvas"),code=SETrev("cleanCanvas")},
	WIDGET.newSwitch{name="fullscreen",	x=1000,y=1190,disp=SETval("fullscreen"),	code=switchFullscreen},
	WIDGET.newSwitch{name="bg",			x=1000,y=1280,disp=SETval("bg"),
		code=function()
			BG.set('none')
			SETTING.bg=not SETTING.bg
			BG.set()
		end},
	WIDGET.newButton{name="back",		x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene