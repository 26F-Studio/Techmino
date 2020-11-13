function sceneBack.lang()
	FILE.saveSetting()
end

local function setLang(n)return function()LANG.set(n)SETTING.lang=n end end
WIDGET.init("lang",{
	WIDGET.newButton({name="zh",	x=200,	y=100,w=200,h=120,font=45,code=setLang(1)}),
	WIDGET.newButton({name="zh2",	x=420,	y=100,w=200,h=120,font=45,code=setLang(2)}),
	WIDGET.newButton({name="en",	x=640,	y=100,w=200,h=120,font=45,code=setLang(3)}),
	WIDGET.newButton({name="fr",	x=860,	y=100,w=200,h=120,font=45,code=setLang(4)}),
	WIDGET.newButton({name="sp",	x=1080,	y=100,w=200,h=120,font=45,code=setLang(5)}),
	WIDGET.newButton({name="symbol",x=200,	y=250,w=200,h=120,font=45,code=setLang(6)}),
	WIDGET.newButton({name="yygq",	x=420,	y=250,w=200,h=120,font=45,code=setLang(7)}),
	WIDGET.newButton({name="back",	x=640,	y=600,w=200,h=80,font=35,code=WIDGET.lnk_BACK}),
})