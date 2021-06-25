local gc=love.graphics

local scene={}

local tip=gc.newText(getFont(30),"")

function scene.sceneInit()
	tip:set(text.getTip())
	BG.set()
end

function scene.draw()
	gc.setColor(1,1,1)
	mDraw(TEXTURE.title_color,640,160)
	mDraw(tip,640,660)
end

scene.widgetList={
	WIDGET.newText{name="system",	x=750,y=280,color='Z',align='L',fText=SYSTEM},
	WIDGET.newText{name="version",	x=950,y=280,color='Z',align='L',fText=VERSION.string},
	WIDGET.newButton{name="sprint",	x=260,y=480,w=260,font=50,code=function()loadGame('sprint_40l',true)end},
	WIDGET.newButton{name="marathon",x=640,y=480,w=260,font=50,code=function()loadGame('marathon_n',true)end},
	WIDGET.newButton{name="setting",x=1000,y=400,w=120,fText=TEXTURE.setting,font=50,code=goScene'setting_game'},
	WIDGET.newButton{name="lang",	x=1000,y=560,w=120,fText=TEXTURE.language,font=40,code=goScene'lang'},
	WIDGET.newButton{name="manual",	x=1160,y=400,w=120,fText=TEXTURE.sure,font=80,code=goScene'manual'},
	WIDGET.newButton{name="quit",	x=1160,y=560,w=120,fText=TEXTURE.quit,font=70,code=function()VOC.play('bye')SCN.swapTo('quit','slowFade')end},
}

return scene