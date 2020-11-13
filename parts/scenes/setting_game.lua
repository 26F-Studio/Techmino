local gc=love.graphics
local Timer=love.timer.getTime

local int=math.floor

function sceneInit.setting_game()
	BG.set("space")
end
function sceneBack.setting_game()
	FILE.saveSetting()
end

function Pnt.setting_game()
	gc.setColor(1,1,1)
	gc.draw(SKIN.curText[int(Timer()*2)%16+1],590,540,Timer()%6.28319,2,nil,15,15)
end

WIDGET.init("setting_game",{
	WIDGET.newText({name="title",		x=640,y=15,font=80}),

	WIDGET.newButton({name="graphic",	x=200,	y=80,	w=240,h=80,	color="lCyan",	font=35,code=WIDGET.lnk_swapScene("setting_video","swipeR")}),
	WIDGET.newButton({name="sound",		x=1080,	y=80,	w=240,h=80,	color="lCyan",	font=35,code=WIDGET.lnk_swapScene("setting_sound","swipeL")}),

	WIDGET.newButton({name="ctrl",		x=290,	y=220,	w=320,h=80,	color="lYellow",font=35,code=WIDGET.lnk_goScene("setting_control")}),
	WIDGET.newButton({name="key",		x=640,	y=220,	w=320,h=80,	color="lGreen",	font=35,code=WIDGET.lnk_goScene("setting_key")}),
	WIDGET.newButton({name="touch",		x=990,	y=220,	w=320,h=80,	color="lBlue",	font=35,code=WIDGET.lnk_goScene("setting_touch")}),
	WIDGET.newSlider({name="reTime",	x=350,	y=340,	w=300,unit=10,				font=30,disp=WIDGET.lnk_SETval("reTime"),	code=WIDGET.lnk_SETsto("reTime"),show=function(S)return(.5+S.disp()*.25).."s"end}),
	WIDGET.newSlider({name="maxNext",	x=350,	y=440,	w=300,unit=6,				font=30,disp=WIDGET.lnk_SETval("maxNext"),	code=WIDGET.lnk_SETsto("maxNext")}),
	WIDGET.newButton({name="layout",	x=460,	y=540,	w=140,h=70,					font=35,code=WIDGET.lnk_goScene("setting_skin")}),
	WIDGET.newSwitch({name="autoPause",	x=1080,	y=320,	font=20,disp=WIDGET.lnk_SETval("autoPause"),code=WIDGET.lnk_SETrev("autoPause")}),
	WIDGET.newSwitch({name="swap",		x=1080,	y=380,	font=20,disp=WIDGET.lnk_SETval("swap"),		code=WIDGET.lnk_SETrev("swap")}),
	WIDGET.newSwitch({name="fine",		x=1080,	y=440,	font=20,disp=WIDGET.lnk_SETval("fine"),		code=function()SETTING.fine=not SETTING.fine if SETTING.fine then SFX.play("finesseError",.6) end end}),
	WIDGET.newSwitch({name="appLock",	x=1080,	y=500,	font=20,disp=WIDGET.lnk_SETval("appLock"),	code=WIDGET.lnk_SETrev("appLock")}),
	WIDGET.newButton({name="calc",		x=970,	y=550,	w=150,h=60,color="dGrey",	font=25,code=WIDGET.lnk_goScene("calculator"),hide=function()return not SETTING.appLock end}),
	WIDGET.newButton({name="back",		x=1140,	y=640,	w=170,h=80,					font=40,code=WIDGET.lnk_BACK}),
})