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