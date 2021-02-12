local gc=love.graphics
local int=math.floor

local scene={}

function scene.sceneInit()
	BG.set()
end
function scene.sceneBack()
	FILE.save(SETTING,"conf/settings")
end

function scene.draw()
	gc.setColor(1,1,1)
	gc.draw(SKIN.curText[int(TIME()*2)%16+1],710,540,TIME()%6.28319,2,nil,15,15)
end

scene.widgetList={
	WIDGET.newText{name="title",		x=640,y=15,font=80},

	WIDGET.newButton{name="graphic",	x=200,	y=80,	w=240,h=80,	color="lCyan",	font=35,code=swapScene"setting_video","swipeR"},
	WIDGET.newButton{name="sound",		x=1080,	y=80,	w=240,h=80,	color="lCyan",	font=35,code=swapScene"setting_sound","swipeL"},

	WIDGET.newButton{name="ctrl",		x=290,	y=220,	w=320,h=80,	color="lYellow",font=35,code=goScene"setting_control"},
	WIDGET.newButton{name="key",		x=640,	y=220,	w=320,h=80,	color="lGreen",	font=35,code=goScene"setting_key"},
	WIDGET.newButton{name="touch",		x=990,	y=220,	w=320,h=80,	color="lBlue",	font=35,code=goScene"setting_touch"},
	WIDGET.newSlider{name="reTime",		x=350,	y=340,	w=300,unit=10,disp=lnk_SETval("reTime"),code=lnk_SETsto("reTime"),show=function(S)return(.5+S.disp()*.25).."s"end},
	WIDGET.newSelector{name="RS",		x=500,	y=420,	w=300,color="sea",list={"TRS","SRS","C2","C2sym","Classic","None"},disp=lnk_SETval("RS"),code=lnk_SETsto("RS")},
	WIDGET.newButton{name="layout",		x=550,	y=540,	w=200,h=70,					font=35,code=goScene"setting_skin"},
	WIDGET.newSwitch{name="autoPause",	x=1060,	y=310,	font=20,disp=lnk_SETval("autoPause"),code=lnk_SETrev("autoPause")},
	WIDGET.newSwitch{name="swap",		x=1060,	y=370,	font=20,disp=lnk_SETval("swap"),	code=lnk_SETrev("swap")},
	WIDGET.newSwitch{name="fine",		x=1060,	y=430,	font=20,disp=lnk_SETval("fine"),	code=function()SETTING.fine=not SETTING.fine if SETTING.fine then SFX.play("finesseError",.6) end end},
	WIDGET.newSwitch{name="appLock",	x=1060,	y=490,	font=20,disp=lnk_SETval("appLock"),	code=lnk_SETrev("appLock")},
	WIDGET.newSwitch{name="simpMode",	x=1060,	y=550,	font=25,disp=lnk_SETval("simpMode"),code=lnk_SETrev("simpMode")},
	WIDGET.newButton{name="calc",		x=1195,	y=490,	w=150,h=60,color="dGrey",	font=25,code=goScene"calculator",hide=function()return not SETTING.appLock end},
	WIDGET.newButton{name="back",		x=1140,	y=640,	w=170,h=80,					font=40,code=backScene},
}

return scene