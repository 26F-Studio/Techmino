local scene={}

function scene.sceneBack()
	FILE.save(SETTING,"conf/settings")
end

local function setLang(n)return function()SETTING.lang=n LANG.set(n)end end
scene.widgetList={
	WIDGET.newButton{name="zh",		x=200,	y=100,w=200,h=120,fText="中文",			font=35,code=setLang(1)},
	WIDGET.newButton{name="zh2",	x=420,	y=100,w=200,h=120,fText="全中文",		font=35,code=setLang(2)},
	WIDGET.newButton{name="yygq",	x=640,	y=100,w=200,h=120,fText="就这?",		font=35,code=setLang(3)},
	WIDGET.newButton{name="en",		x=860,	y=100,w=200,h=120,fText="English",		font=35,code=setLang(4)},
	WIDGET.newButton{name="fr",		x=1080,	y=100,w=200,h=120,fText="Français",		font=35,code=setLang(5)},
	WIDGET.newButton{name="sp",		x=200,	y=250,w=200,h=120,fText="Español",		font=35,code=setLang(6)},
	WIDGET.newButton{name="pt",		x=420,	y=250,w=200,h=120,fText="Português",	font=35,code=setLang(7)},
	WIDGET.newButton{name="symbol",	x=640,	y=250,w=200,h=120,fText="?????",		font=35,code=setLang(8)},
	WIDGET.newButton{name="back",	x=640,	y=600,w=200,h=80,font=35,code=backScene},
}

return scene