local gc=love.graphics

local scene={}

function scene.draw()
	gc.setColor(1,1,1)
	setFont(30)
	mStr(text.VKTchW,140+500*SETTING.VKTchW,260)
	mStr(text.VKOrgW,140+500*SETTING.VKTchW+500*SETTING.VKCurW,330)
	mStr(text.VKCurW,640+500*SETTING.VKCurW,410)
end

scene.widgetList={
	WIDGET.newSwitch{name="VKDodge",x=400,	y=530,			font=35,disp=WIDGET.lnk_SETval("VKDodge"),code=WIDGET.lnk_SETrev("VKDodge")},
	WIDGET.newSlider{name="VKTchW",	x=140,	y=320,w=1000,	font=35,disp=WIDGET.lnk_SETval("VKTchW"),code=function(i)SETTING.VKTchW=i SETTING.VKCurW=math.max(SETTING.VKCurW,i)end},
	WIDGET.newSlider{name="VKCurW",	x=140,	y=390,w=1000,	font=35,disp=WIDGET.lnk_SETval("VKCurW"),code=function(i)SETTING.VKCurW=i SETTING.VKTchW=math.min(SETTING.VKTchW,i)end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene