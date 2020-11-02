local gc=love.graphics
local Timer=love.timer.getTime

local setFont=setFont
local mStr=mStr
local sin=math.sin

function sceneInit.help()
	BG.set("space")
end

function Pnt.help()
	setFont(20)
	gc.setColor(1,1,1)
	for i=1,#text.help do
		gc.printf(text.help[i],150,35*i+40,1000,"center")
	end
	setFont(15)
	gc.print(text.used,30,330)
	gc.draw(IMG.title,280,610,.1,1+.05*sin(Timer()*2.6),nil,206,35)
	gc.setLineWidth(3)
	gc.rectangle("line",18,18,263,263)
	gc.rectangle("line",1012,18,250,250)
	setFont(20)
	mStr(text.group,640,490)
	gc.setColor(1,1,1,sin(Timer()*20)*.3+.6)
	setFont(30)
	mStr(text.support,150+sin(Timer()*4)*20,283)
	mStr(text.support,1138-sin(Timer()*4)*20,270)
end

WIDGET.init("help",{
	WIDGET.newImage({name="pay1",	x=20,	y=20}),
	WIDGET.newImage({name="pay2",	x=1014,	y=20}),
	WIDGET.newButton({name="dict",	x=1140,	y=410,w=220,h=70,font=35,code=WIDGET.lnk.goScene("dict")}),
	WIDGET.newButton({name="staff",	x=1140,	y=490,w=220,h=70,font=35,code=WIDGET.lnk.goScene("staff")}),
	WIDGET.newButton({name="his",	x=1140,	y=570,w=220,h=70,font=35,code=WIDGET.lnk.goScene("history")}),
	WIDGET.newButton({name="qq",	x=1140,	y=650,w=220,h=70,font=35,code=function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,hide=MOBILE}),
	WIDGET.newButton({name="back",	x=640,	y=600,w=170,h=80,font=35,code=WIDGET.lnk.BACK}),
})