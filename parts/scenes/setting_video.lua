local scene={}

function scene.sceneInit()
	BG.set()
end
function scene.sceneBack()
	FILE.save(SETTING,"conf/settings")
end

scene.widgetList={
	WIDGET.newText{name="title",		x=640,	y=15,font=80},

	WIDGET.newButton{name="sound",		x=200,	y=80,w=240,h=80,color="lCyan",font=35,code=swapScene"setting_sound","swipeR"},
	WIDGET.newButton{name="game",		x=1080,	y=80,w=240,h=80,color="lCyan",font=35,code=swapScene"setting_game","swipeL"},

	WIDGET.newSwitch{name="block",		x=290,	y=165,	disp=SETval("block"),	code=SETrev("block")},
	WIDGET.newSwitch{name="smooth",		x=290,	y=215,	disp=SETval("smooth"),	code=SETrev("smooth")},
	WIDGET.newSwitch{name="upEdge",		x=290,	y=265,	disp=SETval("upEdge"),	code=SETrev("upEdge")},
	WIDGET.newSwitch{name="bagLine",	x=290,	y=315,	disp=SETval("bagLine"),	code=SETrev("bagLine")},

	WIDGET.newSlider{name="ghost",		x=600,	y=180,w=200,unit=.6,disp=SETval("ghost"),show="percent",code=SETsto("ghost")},
	WIDGET.newSlider{name="grid",		x=600,	y=240,w=200,unit=.4,disp=SETval("grid"),show="percent",	code=SETsto("grid")},
	WIDGET.newSlider{name="center",		x=600,	y=300,w=200,unit=1,	disp=SETval("center"),				code=SETsto("center")},

	WIDGET.newSlider{name="lockFX",		x=250,	y=375,w=373,unit=5,	disp=SETval("lockFX"),	code=SETsto("lockFX")},
	WIDGET.newSlider{name="dropFX",		x=250,	y=420,w=373,unit=5,	disp=SETval("dropFX"),	code=SETsto("dropFX")},
	WIDGET.newSlider{name="moveFX",		x=250,	y=465,w=373,unit=5,	disp=SETval("moveFX"),	code=SETsto("moveFX")},
	WIDGET.newSlider{name="clearFX",	x=250,	y=510,w=373,unit=5,	disp=SETval("clearFX"),	code=SETsto("clearFX")},
	WIDGET.newSlider{name="splashFX",	x=250,	y=555,w=373,unit=5,	disp=SETval("splashFX"),code=SETsto("splashFX")},
	WIDGET.newSlider{name="shakeFX",	x=250,	y=600,w=373,unit=5,	disp=SETval("shakeFX"),	code=SETsto("shakeFX")},
	WIDGET.newSlider{name="atkFX",		x=250,	y=645,w=373,unit=5,	disp=SETval("atkFX"),	code=SETsto("atkFX")},
	WIDGET.newSlider{name="frame",		x=350,	y=690,w=373,unit=10,
		disp=function()
			return SETTING.frameMul>35 and SETTING.frameMul/10 or SETTING.frameMul/5-4
		end,
		code=function(i)
			SETTING.frameMul=i<5 and 5*i+20 or 10*i
		end},

	WIDGET.newSwitch{name="text",		x=1160,	y=180,font=35,disp=SETval("text"),	code=SETrev("text")},
	WIDGET.newSwitch{name="score",		x=1160,	y=230,font=35,disp=SETval("score"),	code=SETrev("score")},
	WIDGET.newSwitch{name="warn",		x=1160,	y=280,font=35,disp=SETval("warn"),	code=SETrev("warn")},
	WIDGET.newSwitch{name="highCam",	x=1160,	y=330,font=35,disp=SETval("highCam"),code=SETrev("highCam")},
	WIDGET.newSwitch{name="nextPos",	x=1160,	y=380,font=35,disp=SETval("nextPos"),code=SETrev("nextPos")},
	WIDGET.newSwitch{name="fullscreen",	x=1160,	y=430,disp=SETval("fullscreen"),	code=switchFullscreen},
	WIDGET.newSwitch{name="bg",			x=1160,	y=480,font=35,disp=SETval("bg"),
		code=function()
			BG.set("none")
			SETTING.bg=not SETTING.bg
			BG.set()
		end},
	WIDGET.newSwitch{name="power",		x=990,	y=610,font=35,disp=SETval("powerInfo"),code=SETrev("powerInfo")},
	WIDGET.newSwitch{name="clean",		x=990,	y=670,font=35,disp=SETval("cleanCanvas"),code=SETrev("cleanCanvas")},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene