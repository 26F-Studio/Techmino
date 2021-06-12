local gc=love.graphics

local scene={}

function scene.sceneInit()
	BG.set('league')
	BGM.play('exploration')
end

function scene.draw()
	gc.setColor(1,1,1)
	setFont(100)
	mStr("Tech League",640,120)
	drawSelfProfile()
	drawOnlinePlayerCount()
end
scene.widgetList={
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=goScene'setting_game'},
	WIDGET.newKey{name="match",x=640,y=500,w=760,h=140,font=60,code=function()MES.new("Coming soon 开发中,敬请期待")end},
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene