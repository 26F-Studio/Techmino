local gc=love.graphics
local Timer=love.timer.getTime

local setFont=setFont

local sin=math.sin

local floatWheel=0
local function wheelScroll(y)
	if y>0 then
		if floatWheel<0 then floatWheel=0 end
		floatWheel=floatWheel+y^1.2
	elseif y<0 then
		if floatWheel>0 then floatWheel=0 end
		floatWheel=floatWheel-(-y)^1.2
	end
	while floatWheel>=1 do
		love.keypressed("up")
		floatWheel=floatWheel-1
	end
	while floatWheel<=-1 do
		love.keypressed("down")
		floatWheel=floatWheel+1
	end
end

function sceneInit.music()
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

function wheelMoved.music(_,y)
	wheelScroll(y)
end
function keyDown.music(key)
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
			if SETTING.bgm>0 then
				SFX.play("click")
				BGM.play(BGM.list[S])
			end
		else
			BGM.stop()
		end
	elseif key=="escape"then
		SCN.back()
	end
end

function Pnt.music()
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