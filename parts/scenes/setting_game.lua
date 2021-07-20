local gc=love.graphics

local scene={}

function scene.sceneInit()
	BG.set()
end
function scene.sceneBack()
	FILE.save(SETTING,'conf/settings')
end

function scene.draw()
	local t=TIME()
	local b=math.floor(t*2)%16+1
	gc.setColor(1,1,1)
	gc.draw(SKIN.lib[SETTING.skinSet][b],410,540-WIDGET.scrollPos,t%6.2832,2,nil,15,15)
	gc.setColor(1,1,1,t*2%1)
	gc.draw(SKIN.lib[SETTING.skinSet][b%16+1],410,540-WIDGET.scrollPos,t%6.2832,2,nil,15,15)
end

scene.widgetScrollHeight=200
scene.widgetList={
	WIDGET.newText{name="title",		x=640,y=15,font=80},

	WIDGET.newButton{name="graphic",	x=200,	y=80,	w=240,h=80,	color='lC',font=35,code=swapScene('setting_video','swipeR')},
	WIDGET.newButton{name="sound",		x=1080,	y=80,	w=240,h=80,	color='lC',font=35,code=swapScene('setting_sound','swipeL')},

	WIDGET.newButton{name="ctrl",		x=290,	y=220,	w=320,h=80,	color='lY',font=35,code=goScene'setting_control'},
	WIDGET.newButton{name="key",		x=640,	y=220,	w=320,h=80,	color='lG',font=35,code=goScene'setting_key'},
	WIDGET.newButton{name="touch",		x=990,	y=220,	w=320,h=80,	color='lB',font=35,code=goScene'setting_touch'},
	WIDGET.newSlider{name="reTime",		x=330,	y=320,	w=300,unit=10,disp=SETval("reTime"),code=SETsto("reTime"),show=function(S)return(.5+S.disp()*.25).."s"end},
	WIDGET.newSelector{name="RS",		x=300,	y=420,	w=300,color='S',list={'TRS','SRS','ZRS','ASC','ASCplus','C2','C2sym','Classic','None'},disp=SETval("RS"),code=SETsto("RS")},
	WIDGET.newButton{name="layout",		x=250,	y=540,	w=200,h=70,font=35,			code=goScene'setting_skin'},
	WIDGET.newSwitch{name="autoPause",	x=1060,	y=350,	disp=SETval("autoPause"),	code=SETrev("autoPause")},
	WIDGET.newSwitch{name="swap",		x=1060,	y=460,	disp=SETval("swap"),		code=SETrev("swap")},
	WIDGET.newSwitch{name="simpMode",	x=1060,	y=800,	disp=SETval("simpMode"),
		code=function()
			SETTING.simpMode=not SETTING.simpMode
			for i=1,#SCN.stack,2 do
				if SCN.stack[i]=='main'or SCN.stack[i]=='main_simple'then
					SCN.stack[i]=SETTING.simpMode and'main_simple'or'main'
					break
				end
			end
		end},
	WIDGET.newButton{name="back",		x=1140,	y=640,	w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene