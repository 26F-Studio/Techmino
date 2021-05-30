local scene={}

function scene.sceneBack()
	FILE.save(SETTING,'conf/settings')
end

local function setLang(n)return function()SETTING.lang=n LANG.set(n)end end
scene.widgetList={
	WIDGET.newButton{name="zh",		x=200,	y=100,w=200,h=120,fText="中文",			color='R',font=35,code=setLang(1)},
	WIDGET.newButton{name="zh2",	x=420,	y=100,w=200,h=120,fText="全中文",		color='dR',font=35,code=setLang(2)},
	WIDGET.newButton{name="yygq",	x=640,	y=100,w=200,h=120,fText="就这?",		color='D',font=35,code=setLang(3)},
	WIDGET.newButton{name="en",		x=860,	y=100,w=200,h=120,fText="English",		color='N',font=35,code=setLang(4)},
	WIDGET.newButton{name="fr",		x=1080,	y=100,w=200,h=120,fText="Français",		color='lW',font=35,code=setLang(5)},
	WIDGET.newButton{name="sp",		x=200,	y=250,w=200,h=120,fText="Español",		color='O',font=35,code=setLang(6)},
	WIDGET.newButton{name="pt",		x=420,	y=250,w=200,h=120,fText="Português",	color='Y',font=35,code=setLang(7)},
	WIDGET.newKey{name="symbol",	x=640,	y=250,w=200,h=120,fText="?????",		color='dH',font=35,code=setLang(8)},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene