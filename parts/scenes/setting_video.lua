function sceneInit.setting_video()
	BG.set("space")
end
function sceneBack.setting_video()
	FILE.saveSetting()
end

WIDGET.init("setting_video",{
	WIDGET.newText({name="title",		x=640,y=15,font=80}),

	WIDGET.newButton({name="sound",		x=200,	y=80,w=240,h=80,color="lCyan",font=35,code=WIDGET.lnk.swapScene("setting_sound","swipeR")}),
	WIDGET.newButton({name="game",		x=1080,	y=80,w=240,h=80,color="lCyan",font=35,code=WIDGET.lnk.swapScene("setting_game","swipeL")}),

	WIDGET.newSwitch({name="block",		x=360,	y=180,				disp=WIDGET.lnk.SETval("block"),				code=WIDGET.lnk.SETrev("block")}),
	WIDGET.newSlider({name="ghost",		x=260,	y=250,w=200,unit=.6,disp=WIDGET.lnk.SETval("ghost"),show="percent",code=WIDGET.lnk.SETsto("ghost")}),
	WIDGET.newSlider({name="center",	x=260,	y=300,w=200,unit=1,	disp=WIDGET.lnk.SETval("center"),				code=WIDGET.lnk.SETsto("center")}),

	WIDGET.newSwitch({name="smooth",	x=700,	y=180,				disp=WIDGET.lnk.SETval("smooth"),	code=WIDGET.lnk.SETrev("smooth")}),
	WIDGET.newSwitch({name="grid",		x=700,	y=240,				disp=WIDGET.lnk.SETval("grid"),	code=WIDGET.lnk.SETrev("grid")}),
	WIDGET.newSwitch({name="bagLine",	x=700,	y=300,				disp=WIDGET.lnk.SETval("bagLine"),	code=WIDGET.lnk.SETrev("bagLine")}),

	WIDGET.newSlider({name="lockFX",	x=350,	y=350,w=373,unit=5,	disp=WIDGET.lnk.SETval("lockFX"),	code=WIDGET.lnk.SETsto("lockFX")}),
	WIDGET.newSlider({name="dropFX",	x=350,	y=400,w=373,unit=5,	disp=WIDGET.lnk.SETval("dropFX"),	code=WIDGET.lnk.SETsto("dropFX")}),
	WIDGET.newSlider({name="moveFX",	x=350,	y=450,w=373,unit=5,	disp=WIDGET.lnk.SETval("moveFX"),	code=WIDGET.lnk.SETsto("moveFX")}),
	WIDGET.newSlider({name="clearFX",	x=350,	y=500,w=373,unit=5,	disp=WIDGET.lnk.SETval("clearFX"),	code=WIDGET.lnk.SETsto("clearFX")}),
	WIDGET.newSlider({name="shakeFX",	x=350,	y=550,w=373,unit=5,	disp=WIDGET.lnk.SETval("shakeFX"),	code=WIDGET.lnk.SETsto("shakeFX")}),
	WIDGET.newSlider({name="atkFX",		x=350,	y=600,w=373,unit=5,	disp=WIDGET.lnk.SETval("atkFX"),	code=WIDGET.lnk.SETsto("atkFX")}),
	WIDGET.newSlider({name="frame",		x=350,	y=650,w=373,unit=10,
		disp=function()
			return SETTING.frameMul>35 and SETTING.frameMul/10 or SETTING.frameMul/5-4
		end,
		code=function(i)
			SETTING.frameMul=i<5 and 5*i+20 or 10*i
		end}),

	WIDGET.newSwitch({name="text",		x=1100,	y=180,font=35,disp=WIDGET.lnk.SETval("text"),code=WIDGET.lnk.SETrev("text")}),
	WIDGET.newSwitch({name="score",		x=1100,	y=240,font=35,disp=WIDGET.lnk.SETval("score"),code=WIDGET.lnk.SETrev("score")}),
	WIDGET.newSwitch({name="warn",		x=1100,	y=300,font=35,disp=WIDGET.lnk.SETval("warn"),code=WIDGET.lnk.SETrev("warn")}),
	WIDGET.newSwitch({name="highCam",	x=1100,	y=360,font=35,disp=WIDGET.lnk.SETval("highCam"),code=WIDGET.lnk.SETrev("highCam")}),
	WIDGET.newSwitch({name="nextPos",	x=1100,	y=420,font=35,disp=WIDGET.lnk.SETval("nextPos"),code=WIDGET.lnk.SETrev("nextPos")}),
	WIDGET.newSwitch({name="fullscreen",x=1100,	y=480,disp=WIDGET.lnk.SETval("fullscreen"),
		code=function()
			SETTING.fullscreen=not SETTING.fullscreen
			love.window.setFullscreen(SETTING.fullscreen)
			love.resize(love.graphics.getWidth(),love.graphics.getHeight())
		end}),
	WIDGET.newSwitch({name="bg",		x=1100,	y=540,font=35,disp=WIDGET.lnk.SETval("bg"),
		code=function()
			BG.set("none")
			SETTING.bg=not SETTING.bg
			BG.set("space")
		end}),
	WIDGET.newSwitch({name="power",		x=990,	y=640,font=35,disp=WIDGET.lnk.SETval("powerInfo"),
		code=function()
			SETTING.powerInfo=not SETTING.powerInfo
		end}),
	WIDGET.newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})