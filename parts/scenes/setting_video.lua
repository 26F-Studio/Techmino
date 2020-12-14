local scene={}

function scene.sceneInit()
	BG.set("space")
end
function scene.sceneBack()
	FILE.save(SETTING,"settings")
end

scene.widgetList={
	WIDGET.newText{name="title",		x=640,	y=15,font=80},

	WIDGET.newButton{name="sound",		x=200,	y=80,w=240,h=80,color="lCyan",font=35,code=WIDGET.lnk_swapScene("setting_sound","swipeR")},
	WIDGET.newButton{name="game",		x=1080,	y=80,w=240,h=80,color="lCyan",font=35,code=WIDGET.lnk_swapScene("setting_game","swipeL")},

	WIDGET.newSwitch{name="block",		x=360,	y=180,				disp=WIDGET.lnk_SETval("block"),				code=WIDGET.lnk_SETrev("block")},
	WIDGET.newSlider{name="ghost",		x=260,	y=250,w=200,unit=.6,disp=WIDGET.lnk_SETval("ghost"),show="percent",	code=WIDGET.lnk_SETsto("ghost")},
	WIDGET.newSlider{name="center",		x=260,	y=300,w=200,unit=1,	disp=WIDGET.lnk_SETval("center"),				code=WIDGET.lnk_SETsto("center")},

	WIDGET.newSwitch{name="smooth",		x=700,	y=180,				disp=WIDGET.lnk_SETval("smooth"),	code=WIDGET.lnk_SETrev("smooth")},
	WIDGET.newSwitch{name="grid",		x=700,	y=240,				disp=WIDGET.lnk_SETval("grid"),		code=WIDGET.lnk_SETrev("grid")},
	WIDGET.newSwitch{name="bagLine",	x=700,	y=300,				disp=WIDGET.lnk_SETval("bagLine"),	code=WIDGET.lnk_SETrev("bagLine")},

	WIDGET.newSlider{name="lockFX",		x=350,	y=365,w=373,unit=5,	disp=WIDGET.lnk_SETval("lockFX"),	code=WIDGET.lnk_SETsto("lockFX")},
	WIDGET.newSlider{name="dropFX",		x=350,	y=410,w=373,unit=5,	disp=WIDGET.lnk_SETval("dropFX"),	code=WIDGET.lnk_SETsto("dropFX")},
	WIDGET.newSlider{name="moveFX",		x=350,	y=455,w=373,unit=5,	disp=WIDGET.lnk_SETval("moveFX"),	code=WIDGET.lnk_SETsto("moveFX")},
	WIDGET.newSlider{name="clearFX",	x=350,	y=500,w=373,unit=5,	disp=WIDGET.lnk_SETval("clearFX"),	code=WIDGET.lnk_SETsto("clearFX")},
	WIDGET.newSlider{name="splashFX",	x=350,	y=545,w=373,unit=5,	disp=WIDGET.lnk_SETval("splashFX"),	code=WIDGET.lnk_SETsto("splashFX")},
	WIDGET.newSlider{name="shakeFX",	x=350,	y=590,w=373,unit=5,	disp=WIDGET.lnk_SETval("shakeFX"),	code=WIDGET.lnk_SETsto("shakeFX")},
	WIDGET.newSlider{name="atkFX",		x=350,	y=635,w=373,unit=5,	disp=WIDGET.lnk_SETval("atkFX"),	code=WIDGET.lnk_SETsto("atkFX")},
	WIDGET.newSlider{name="frame",		x=350,	y=680,w=373,unit=10,
		disp=function()
			return SETTING.frameMul>35 and SETTING.frameMul/10 or SETTING.frameMul/5-4
		end,
		code=function(i)
			SETTING.frameMul=i<5 and 5*i+20 or 10*i
		end},

	WIDGET.newSwitch{name="text",		x=1100,	y=180,font=35,disp=WIDGET.lnk_SETval("text"),	code=WIDGET.lnk_SETrev("text")},
	WIDGET.newSwitch{name="score",		x=1100,	y=240,font=35,disp=WIDGET.lnk_SETval("score"),	code=WIDGET.lnk_SETrev("score")},
	WIDGET.newSwitch{name="warn",		x=1100,	y=300,font=35,disp=WIDGET.lnk_SETval("warn"),	code=WIDGET.lnk_SETrev("warn")},
	WIDGET.newSwitch{name="highCam",	x=1100,	y=360,font=35,disp=WIDGET.lnk_SETval("highCam"),code=WIDGET.lnk_SETrev("highCam")},
	WIDGET.newSwitch{name="nextPos",	x=1100,	y=420,font=35,disp=WIDGET.lnk_SETval("nextPos"),code=WIDGET.lnk_SETrev("nextPos")},
	WIDGET.newSwitch{name="fullscreen",x=1100,	y=480,disp=WIDGET.lnk_SETval("fullscreen"),
		code=function()
			SETTING.fullscreen=not SETTING.fullscreen
			love.window.setFullscreen(SETTING.fullscreen)
			love.resize(love.graphics.getWidth(),love.graphics.getHeight())
		end},
	WIDGET.newSwitch{name="bg",		x=1100,	y=540,font=35,disp=WIDGET.lnk_SETval("bg"),
		code=function()
			BG.set("none")
			SETTING.bg=not SETTING.bg
			BG.set("space")
		end},
	WIDGET.newSwitch{name="power",		x=990,	y=640,font=35,disp=WIDGET.lnk_SETval("powerInfo"),
		code=function()
			SETTING.powerInfo=not SETTING.powerInfo
		end},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene