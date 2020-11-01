local gc=love.graphics

function Pnt.setting_trackSetting()
	gc.setColor(1,1,1)
	mText(drawableText.VKTchW,140+50*SETTING.VKTchW,260)
	mText(drawableText.VKOrgW,140+50*SETTING.VKTchW+50*SETTING.VKCurW,320)
	mText(drawableText.VKCurW,640+50*SETTING.VKCurW,380)
end