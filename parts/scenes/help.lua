local gc=love.graphics

local sin=math.sin

local scene={}

function scene.sceneInit()
	BG.set()
end

function scene.draw()
	--Draw all texts
	setFont(20)
	gc.setColor(1,1,1)
	for i=1,#text.help do
		gc.printf(text.help[i],150,35*i+40,1000,"center")
	end

	--Lib used
	setFont(15)
	gc.print(text.used,30,330)

	local t=TIME()
	--Sponsor code
	gc.draw(IMG.title,280,610,.1,1+.05*sin(t*2.6),nil,206,35)
	gc.setLineWidth(3)
	gc.rectangle("line",18,18,263,263)
	gc.rectangle("line",1012,18,250,250)

	--Group code
	setFont(20)
	mStr(text.group,640,490)

	--Support text
	gc.setColor(1,1,1,sin(t*20)*.3+.6)
	setFont(30)
	mStr(text.support,150+sin(t*4)*20,283)
	mStr(text.support,1138-sin(t*4)*20,270)
end

scene.widgetList={
	WIDGET.newImage{name="pay1",	x=20,	y=20},
	WIDGET.newImage{name="pay2",	x=1014,	y=20},
	WIDGET.newButton{name="manual",	x=1140,	y=350,w=220,h=70,font=35,code=goScene"manual"},
	WIDGET.newButton{name="dict",	x=1140,	y=430,w=220,h=70,font=35,code=goScene"dict"},
	WIDGET.newButton{name="staff",	x=1140,	y=510,w=220,h=70,font=35,code=goScene"staff"},
	WIDGET.newButton{name="his",	x=1140,	y=590,w=220,h=70,font=35,code=goScene"history"},
	WIDGET.newButton{name="qq",		x=1140,	y=670,w=220,h=70,font=35,code=function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,hide=MOBILE},
	WIDGET.newButton{name="back",	x=640,	y=600,w=170,h=80,font=35,code=backScene},
}

return scene