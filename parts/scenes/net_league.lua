local gc=love.graphics
local leagueTitle=DOGC{600,110,
	{'setFT',100},
	{'origin'},{'shear',-.30,0},{'print',"T",27,-20},
	{'origin'},{'shear',-.25,0},{'print',"e",73,-20},
	{'origin'},{'shear',-.20,0},{'print',"c",127,-20},
	{'origin'},{'shear',-.15,0},{'print',"h",171,-20},
	{'origin'},{'shear',-.05,0},{'print',"L",268,-20},
	{'origin'},{'shear',.00,0},{'print',"e",313,-20},
	{'origin'},{'shear',.05,0},{'print',"a",363,-20},
	{'origin'},{'shear',.10,0},{'print',"g",414,-20},
	{'origin'},{'shear',.15,0},{'print',"u",466,-20},
	{'origin'},{'shear',.20,0},{'print',"e",518,-20},
}

local scene={}

function scene.sceneInit()
	BG.set('suitup')
	BGM.play('exploration')
end

function scene.draw()
	mDraw(leagueTitle,640,192,0,1.5)
	gc.setColor(1,1,1,.3)
	mDraw(leagueTitle,640,200,0,1.51,1.53)
	drawSelfProfile()
	drawOnlinePlayerCount()
end

scene.widgetList={
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=goScene'setting_game'},
	WIDGET.newKey{name="match",x=640,y=500,w=760,h=140,font=60,code=NULL},
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene