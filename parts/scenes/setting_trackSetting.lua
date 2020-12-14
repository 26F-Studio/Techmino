local gc=love.graphics

local scene={}

function scene.Pnt()
	gc.setColor(1,1,1)
	mText(drawableText.VKTchW,140+50*SETTING.VKTchW,260)
	mText(drawableText.VKOrgW,140+50*SETTING.VKTchW+50*SETTING.VKCurW,320)
	mText(drawableText.VKCurW,640+50*SETTING.VKCurW,380)
end

scene.widgetList={
	WIDGET.newSwitch{name="VKDodge",x=400,	y=200,	font=35,				disp=WIDGET.lnk_SETval("VKDodge"),code=WIDGET.lnk_SETrev("VKDodge")},
	WIDGET.newSlider{name="VKTchW",	x=140,	y=310,	w=1000,	unit=10,font=35,disp=WIDGET.lnk_SETval("VKTchW"),code=function(i)SETTING.VKTchW=i SETTING.VKCurW=math.max(SETTING.VKCurW,i)end},
	WIDGET.newSlider{name="VKCurW",	x=140,	y=370,	w=1000,	unit=10,font=35,disp=WIDGET.lnk_SETval("VKCurW"),code=function(i)SETTING.VKCurW=i SETTING.VKTchW=math.min(SETTING.VKTchW,i)end},
	WIDGET.newButton{name="back",	x=1140,	y=640,	w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene