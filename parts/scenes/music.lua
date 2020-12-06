local gc=love.graphics
local Timer=love.timer.getTime

local sin=math.sin

local scene={}

function scene.sceneInit()
	if BGM.nowPlay then
		for i=1,BGM.len do
			if BGM.list[i]==BGM.nowPlay then
				sceneTemp=i--Music selected
				return
			end
		end
	else
		sceneTemp=1
	end
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(key)
	local S=sceneTemp
	if key=="down"then
		if S<BGM.len then
			sceneTemp=S+1
			SFX.play("move",.7)
		end
	elseif key=="up"then
		if S>1 then
			sceneTemp=S-1
			SFX.play("move",.7)
		end
	elseif key=="return"or key=="space"then
		if BGM.nowPlay~=BGM.list[S]then
			BGM.play(BGM.list[S])
			if SETTING.bgm>0 then SFX.play("click")end
		else
			BGM.stop()
		end
	elseif key=="escape"then
		SCN.back()
	end
end

function scene.draw()
	gc.setColor(1,1,1)

	setFont(50)
	gc.print(BGM.list[sceneTemp],320,355)
	setFont(35)
	if sceneTemp>1 then			gc.print(BGM.list[sceneTemp-1],320,350-30)end
	if sceneTemp<BGM.len then	gc.print(BGM.list[sceneTemp+1],320,350+65)end
	setFont(20)
	if sceneTemp>2 then			gc.print(BGM.list[sceneTemp-2],320,350-50)end
	if sceneTemp<BGM.len-1 then	gc.print(BGM.list[sceneTemp+2],320,350+110)end

	gc.draw(IMG.title,840,220,nil,1.5,nil,206,35)
	if BGM.nowPlay then
		setFont(50)
		gc.setColor(sin(Timer()*.5)*.2+.8,sin(Timer()*.7)*.2+.8,sin(Timer())*.2+.8)
		gc.print(BGM.nowPlay,710,500)

		local t=-Timer()%2.3/2
		if t<1 then
			gc.setColor(1,1,1,t)
			gc.draw(IMG.title_color,840,220,nil,1.5+.1-.1*t,1.5+.3-.3*t,206,35)
		end
	end
end

scene.widgetList={
	WIDGET.newText{name="title",	x=30,	y=30,font=80,align="L"},
	WIDGET.newText{name="arrow",	x=270,	y=360,font=45,align="L"},
	WIDGET.newText{name="now",		x=700,	y=500,font=50,align="R",hide=function()return not BGM.nowPlay end},
	WIDGET.newSlider{name="bgm",	x=760,	y=80,w=400,			font=35,disp=WIDGET.lnk_SETval("bgm"),code=function(v)SETTING.bgm=v BGM.freshVolume()end},
	WIDGET.newButton{name="up",		x=200,	y=250,w=120,		font=55,code=WIDGET.lnk_pressKey("up"),hide=function()return sceneTemp==1 end},
	WIDGET.newButton{name="play",	x=200,	y=390,w=120,		font=35,code=WIDGET.lnk_pressKey("space")},
	WIDGET.newButton{name="down",	x=200,	y=530,w=120,		font=55,code=WIDGET.lnk_pressKey("down"),hide=function()return sceneTemp==BGM.len end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,	font=40,code=WIDGET.lnk_BACK},
}

return scene