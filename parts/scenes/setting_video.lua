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

	WIDGET.newSwitch{name="block",		x=340,	y=150,		disp=lnk_SETval("block"),	code=lnk_SETrev("block")},
	WIDGET.newSwitch{name="smooth",		x=340,	y=210,		disp=lnk_SETval("smooth"),	code=lnk_SETrev("smooth")},
	WIDGET.newSwitch{name="upEdge",		x=340,	y=270,		disp=lnk_SETval("upEdge"),	code=lnk_SETrev("upEdge")},
	WIDGET.newSwitch{name="bagLine",	x=340,	y=330,		disp=lnk_SETval("bagLine"),	code=lnk_SETrev("bagLine")},

	WIDGET.newSlider{name="ghost",		x=630,	y=180,w=200,unit=.6,disp=lnk_SETval("ghost"),show="percent",code=lnk_SETsto("ghost")},
	WIDGET.newSlider{name="grid",		x=630,	y=240,w=200,unit=.4,disp=lnk_SETval("grid"),show="percent",	code=lnk_SETsto("grid")},
	WIDGET.newSlider{name="center",		x=630,	y=300,w=200,unit=1,	disp=lnk_SETval("center"),				code=lnk_SETsto("center")},

	WIDGET.newSlider{name="lockFX",		x=350,	y=375,w=373,unit=5,	disp=lnk_SETval("lockFX"),	code=lnk_SETsto("lockFX")},
	WIDGET.newSlider{name="dropFX",		x=350,	y=420,w=373,unit=5,	disp=lnk_SETval("dropFX"),	code=lnk_SETsto("dropFX")},
	WIDGET.newSlider{name="moveFX",		x=350,	y=465,w=373,unit=5,	disp=lnk_SETval("moveFX"),	code=lnk_SETsto("moveFX")},
	WIDGET.newSlider{name="clearFX",	x=350,	y=510,w=373,unit=5,	disp=lnk_SETval("clearFX"),	code=lnk_SETsto("clearFX")},
	WIDGET.newSlider{name="splashFX",	x=350,	y=555,w=373,unit=5,	disp=lnk_SETval("splashFX"),code=lnk_SETsto("splashFX")},
	WIDGET.newSlider{name="shakeFX",	x=350,	y=600,w=373,unit=5,	disp=lnk_SETval("shakeFX"),	code=lnk_SETsto("shakeFX")},
	WIDGET.newSlider{name="atkFX",		x=350,	y=645,w=373,unit=5,	disp=lnk_SETval("atkFX"),	code=lnk_SETsto("atkFX")},
	WIDGET.newSlider{name="frame",		x=350,	y=690,w=373,unit=10,
		disp=function()
			return SETTING.frameMul>35 and SETTING.frameMul/10 or SETTING.frameMul/5-4
		end,
		code=function(i)
			SETTING.frameMul=i<5 and 5*i+20 or 10*i
		end},

	WIDGET.newSwitch{name="text",		x=1100,	y=180,font=35,disp=lnk_SETval("text"),	code=lnk_SETrev("text")},
	WIDGET.newSwitch{name="score",		x=1100,	y=240,font=35,disp=lnk_SETval("score"),	code=lnk_SETrev("score")},
	WIDGET.newSwitch{name="warn",		x=1100,	y=300,font=35,disp=lnk_SETval("warn"),	code=lnk_SETrev("warn")},
	WIDGET.newSwitch{name="highCam",	x=1100,	y=360,font=35,disp=lnk_SETval("highCam"),code=lnk_SETrev("highCam")},
	WIDGET.newSwitch{name="nextPos",	x=1100,	y=420,font=35,disp=lnk_SETval("nextPos"),code=lnk_SETrev("nextPos")},
	WIDGET.newSwitch{name="fullscreen",x=1100,	y=480,disp=lnk_SETval("fullscreen"),	code=switchFullscreen},
	WIDGET.newSwitch{name="bg",			x=1100,	y=540,font=35,disp=lnk_SETval("bg"),
		code=function()
			BG.set("none")
			SETTING.bg=not SETTING.bg
			BG.set()
		end},
	WIDGET.newSwitch{name="power",		x=990,	y=610,font=35,disp=lnk_SETval("powerInfo"),code=lnk_SETrev("powerInfo")},
	WIDGET.newSwitch{name="clean",		x=990,	y=670,font=35,disp=lnk_SETval("cleanCanvas"),code=lnk_SETrev("cleanCanvas")},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene