local gc=love.graphics
local Timer=love.timer.getTime

local sin=math.sin

local scene={}

local selected--Music selected

local bgmList=BGM.getList()
function scene.sceneInit()
	if BGM.nowPlay then
		for i=1,BGM.getCount()do
			if bgmList[i]==BGM.nowPlay then
				selected=i
				return
			end
		end
	else
		selected=1
	end
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(key)
	local S=selected
	if key=="down"then
		if S<BGM.getCount()then
			selected=S+1
			SFX.play("move",.7)
		end
	elseif key=="up"then
		if S>1 then
			selected=S-1
			SFX.play("move",.7)
		end
	elseif key=="return"or key=="space"then
		if BGM.nowPlay~=bgmList[S]then
			BGM.play(bgmList[S])
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
	gc.print(bgmList[selected],320,355)
	setFont(35)
	if selected>1 then			gc.print(bgmList[selected-1],320,350-30)end
	if selected<BGM.getCount()then	gc.print(bgmList[selected+1],320,350+65)end
	setFont(20)
	if selected>2 then			gc.print(bgmList[selected-2],320,350-50)end
	if selected<BGM.getCount()-1 then	gc.print(bgmList[selected+2],320,350+110)end

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
	WIDGET.newButton{name="up",		x=200,	y=250,w=120,		font=55,code=WIDGET.lnk_pressKey("up"),hide=function()return selected==1 end},
	WIDGET.newButton{name="play",	x=200,	y=390,w=120,		font=35,code=WIDGET.lnk_pressKey("space")},
	WIDGET.newButton{name="down",	x=200,	y=530,w=120,		font=55,code=WIDGET.lnk_pressKey("down"),hide=function()return selected==BGM.getCount()end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,	font=40,code=WIDGET.lnk_BACK},
}

return scene