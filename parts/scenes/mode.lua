local mt=love.math
local gc=love.graphics
local ms,kb,tc=love.mouse,love.keyboard,love.touch

local max,min=math.max,math.min
local int,abs=math.floor,math.abs

local mapCam={
	sel=false,--Selected mode ID
	xOy=mt.newTransform(0,0,0,1),--Transformation for map display
	keyCtrl=false,--If controlling with key

	--For auto zooming when enter/leave scene
	zoomMethod=false,
	zoomK=false,
}
local touchDist

local scene={}

function scene.sceneInit(org)
	BG.set()
	destroyPlayers()
	local cam=mapCam
	cam.zoomK=org=="main"and 5 or 1
end

local function getK()
	return abs(mapCam.xOy:transformPoint(1,0)-mapCam.xOy:transformPoint(0,0))
end
local function getPos()
	return mapCam.xOy:inverseTransformPoint(0,0)
end

local function onMode(x,y)
	x,y=x-640,y-360
	x,y=mapCam.xOy:inverseTransformPoint(x,y)
	for name,M in next,MODES do
		if RANKS[name]and M.x then
			local s=M.size
			if M.shape==1 then
				if x>M.x-s and x<M.x+s and y>M.y-s and y<M.y+s then return name end
			elseif M.shape==2 then
				if abs(x-M.x)+abs(y-M.y)<s+12 then return name end
			elseif M.shape==3 then
				if(x-M.x)^2+(y-M.y)^2<(s+6)^2 then return name end
			end
		end
	end
end
local function moveMap(dx,dy)
	local k=getK()
	local x,y=getPos()
	if x>1300 and dx<0 or x<-1500 and dx>0 then dx=0 end
	if y>420 and dy<0 or y<-1900 and dy>0 then dy=0 end
	mapCam.xOy:translate(dx/k,dy/k)
end
function scene.wheelMoved(_,dy)
	mapCam.keyCtrl=false
	local k=getK()
	k=min(max(k+dy*.1,.3),1.6)/k
	mapCam.xOy:scale(k)

	local x,y=getPos()
	mapCam.xOy:translate(x*(1-k),y*(1-k))
end
function scene.mouseMove(_,_,dx,dy)
	if ms.isDown(1)then
		moveMap(dx,dy)
	end
	mapCam.keyCtrl=false
end
function scene.mouseClick(x,y)
	local _=mapCam.sel
	if not _ or x<920 then
		local SEL=onMode(x,y)
		if _~=SEL then
			if SEL then
				mapCam.moving=true
				_=MODES[SEL]
				mapCam.sel=SEL
				SFX.play("click")
			else
				mapCam.sel=false
			end
		elseif _ then
			scene.keyDown("return")
		end
	end
	mapCam.keyCtrl=false
end
function scene.touchDown()
	touchDist=false
end
function scene.touchMove(x,y,dx,dy)
	local L=tc.getTouches()
	if not L[2]then
		moveMap(dx,dy)
	elseif not L[3]then
		x,y=SCR.xOy:inverseTransformPoint(tc.getPosition(L[1]))
		dx,dy=SCR.xOy:inverseTransformPoint(tc.getPosition(L[2]))--Not delta!!!
		local d=(x-dx)^2+(y-dy)^2
		if d>100 then
			d=d^.5
			if touchDist then
				scene.wheelMoved(nil,(d-touchDist)*.02)
			end
			touchDist=d
		end
	end
	mapCam.keyCtrl=false
end
function scene.touchClick(x,y)
	scene.mouseClick(x,y)
end
function scene.keyDown(key)
	if key=="return"then
		if mapCam.sel then
			mapCam.keyCtrl=false
			loadGame(mapCam.sel)
		end
	elseif key=="f1"then
		SCN.go("mod")
	elseif key=="escape"then
		if mapCam.sel then
			mapCam.sel=false
		else
			SCN.back()
		end
	end
end

function scene.update()
	local dx,dy=0,0
	local F
	if not SCN.swapping then
		if kb.isDown("up",	"w")then	dy=dy+10 F=true end
		if kb.isDown("down","s")then	dy=dy-10 F=true end
		if kb.isDown("left","a")then	dx=dx+10 F=true end
		if kb.isDown("right","d")then	dx=dx-10 F=true end
		local js1=joysticks[1]
		if js1 then
			local dir=js1:getAxis(1)
			if dir~="c"then
				if dir=="u"or dir=="ul"or dir=="ur"then dy=dy+10 F=true end
				if dir=="d"or dir=="dl"or dir=="dl"then dy=dy-10 F=true end
				if dir=="l"or dir=="ul"or dir=="dl"then dx=dx+10 F=true end
				if dir=="r"or dir=="ur"or dir=="dr"then dx=dx-10 F=true end
			end
		end
	end
	if F then
		mapCam.keyCtrl=true
		moveMap(dx,dy)
		local x,y=getPos()
		for name,M in next,MODES do
			if RANKS[name]and M.x then
				local SEL
				local s=M.size
				if M.shape==1 then
					if x>M.x-s and x<M.x+s and y>M.y-s and y<M.y+s then SEL=name end
				elseif M.shape==2 then
					if abs(x-M.x)+abs(y-M.y)<s then SEL=name end
				elseif M.shape==3 then
					if(x-M.x)^2+(y-M.y)^2<s^2 then SEL=name end
				end
				if SEL and mapCam.sel~=SEL then
					mapCam.sel=SEL
					SFX.play("click")
				end
			end
		end
	end

	local _=SCN.stat.tar
	mapCam.zoomMethod=_=="play"and 1 or _=="mode"and 2
	if mapCam.zoomMethod==1 then
		_=mapCam.zoomK
		if _<.8 then _=_*1.05 end
		if _<1.1 then _=_*1.05 end
		mapCam.zoomK=_*1.05
	elseif mapCam.zoomMethod==2 then
		mapCam.zoomK=mapCam.zoomK^.9
	end
end

--D/C/B/A/S/special
local baseRankColor={
	[0]={0,0,0,.3},
	{.4,.1,.1,.3},
	{.4,.35,.3,.3},
	{.6,.4,.2,.3},
	{.7,.75,.85,.3},
	{.85,.8,.3,.3},
	{.4,.7,.4,.3},
}
function scene.draw()
	local _
	gc.push("transform")
	gc.translate(640,360)
	gc.rotate((mapCam.zoomK^.6-1))
	gc.scale(mapCam.zoomK^.7)
	gc.applyTransform(mapCam.xOy);

	local R=RANKS
	local sel=mapCam.sel

	--Lines connecting modes
	gc.setLineWidth(8)
	gc.setColor(1,1,1,.2)
	for name,M in next,MODES do
		if R[name]and M.unlock and M.x then
			for _=1,#M.unlock do
				local m=MODES[M.unlock[_]]
				gc.line(M.x,M.y,m.x,m.y)
			end
		end
	end

	--Modes
	setFont(80)
	gc.setLineWidth(6)
	for name,M in next,MODES do
		if R[name]then
			local rank=R[name]
			local S=M.size

			--Frame & fill
			gc.setColor(baseRankColor[rank])
			local drawType="fill"
			::again::
			if M.shape==1 then--Rectangle
				gc.rectangle(drawType,M.x-S,M.y-S,2*S,2*S)
			elseif M.shape==2 then--Diamond
				gc.circle(drawType,M.x,M.y,S+12,4)
			elseif M.shape==3 then--Octagon
				gc.circle(drawType,M.x,M.y,S+6,8)
			end
			if drawType=="fill"then
				gc.setColor(1,1,sel==name and 0 or 1)
				drawType="line"
				goto again
			end

			--Icon
			local icon=M.icon
			if icon then
				gc.setColor(.8,.8,.8)
				local length=icon:getWidth()*.5
				gc.draw(icon,M.x,M.y,nil,S/length,nil,length,length)
			end

			--Rank
			name=text.ranks[rank]
			if name then
				gc.setColor(0,0,0,.8)
				mStr(name,M.x+M.size*.7,M.y-50-M.size*.7)
				gc.setColor(rankColor[rank])
				mStr(name,M.x+M.size*.7+4,M.y-50-M.size*.7-4)
			end
		end
	end
	gc.pop()

	--Score board
	if sel then
		local M=MODES[sel]
		gc.setColor(.5,.5,.5,.8)
		gc.rectangle("fill",920,0,360,720)--Info board
		gc.setColor(M.color)
		setFont(40)mStr(text.modes[sel][1],1100,5)
		setFont(30)mStr(text.modes[sel][2],1100,50)
		gc.setColor(1,1,1)
		setFont(25)gc.printf(text.modes[sel][3],920,110,360,"center")
		if M.slowMark then
			gc.draw(IMG.ctrlSpeedLimit,1230,50,nil,.4)
		end
		if M.score then
			mText(drawableText.highScore,1100,240)
			gc.setColor(.3,.3,.3,.7)
			gc.rectangle("fill",940,290,320,280)--Highscore board
			local L=M.records
			gc.setColor(1,1,1)
			if L[1]then
				for i=1,#L do
					local t=M.scoreDisp(L[i])
					local s=#t
					local f=int((30-s*.4)/5)*5
					setFont(f)
					gc.print(t,955,275+25*i+17-f*.7)
					setFont(10)
					_=L[i].date
					if _ then gc.print(_,1155,284+25*i)end
				end
			else
				mText(drawableText.noScore,1100,370)
			end
		end
	end
	if mapCam.keyCtrl then
		gc.setColor(1,1,1)
		gc.draw(TEXTURE.mapCross,640-20,360-20)
	end
end

scene.widgetList={
	WIDGET.newKey{name="mod",		x=140,y=655,w=220,h=80,font=35,code=goScene"mod"},
	WIDGET.newButton{name="start",	x=1040,y=655,w=180,h=80,font=40,code=pressKey"return",hide=function()return not mapCam.sel end},
	WIDGET.newButton{name="back",	x=1200,y=655,w=120,h=80,font=40,code=backScene},
}

return scene