local langList={
	"中文",
	"全中文",
	"就这?",
	"English",
	"Français",
	"Español",
	"Português",
	"?????",
}

local scene={}

function scene.sceneBack()
	FILE.save(SETTING,'conf/settings')
end

local function setLang(n)
	SETTING.lang=n
	LANG.set(n)
	TEXT.show(langList[n],640,500,100,'appear',.626)
end
local function _setLang(n)return function()setLang(n)end end
scene.widgetList={
	WIDGET.newButton{name="zh",		x=200,	y=100,w=200,h=120,fText=langList[1],color='R',font=35,code=_setLang(1)},
	WIDGET.newButton{name="zh2",	x=420,	y=100,w=200,h=120,fText=langList[2],color='dR',font=35,code=_setLang(2)},
	WIDGET.newButton{name="yygq",	x=640,	y=100,w=200,h=120,fText=langList[3],color='D',font=35,code=_setLang(3)},
	WIDGET.newButton{name="en",		x=860,	y=100,w=200,h=120,fText=langList[4],color='N',font=35,code=_setLang(4)},
	WIDGET.newButton{name="fr",		x=1080,	y=100,w=200,h=120,fText=langList[5],color='lW',font=35,code=_setLang(5)},
	WIDGET.newButton{name="sp",		x=200,	y=250,w=200,h=120,fText=langList[6],color='O',font=35,code=_setLang(6)},
	WIDGET.newButton{name="pt",		x=420,	y=250,w=200,h=120,fText=langList[7],color='Y',font=35,code=_setLang(7)},
	WIDGET.newKey{name="symbol",	x=640,	y=250,w=200,h=120,fText=langList[8],color='dH',font=35,code=_setLang(8)},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene