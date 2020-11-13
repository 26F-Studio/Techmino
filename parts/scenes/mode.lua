local mt=love.math
local gc=love.graphics
local ms,kb,tc=love.mouse,love.keyboard,love.touch
local Timer=love.timer.getTime

local max,min=math.max,math.min
local int,abs=math.floor,math.abs
local sin=math.sin

local mapCam={
	sel=nil,--Selected mode ID

	xOy=mt.newTransform(0,0,0,1),

	--If controlling with key
	keyCtrl=false,

	--For auto zooming when enter/leave scene
	zoomMethod=nil,
	zoomK=nil,
}
local touchDist=nil

function sceneInit.mode(org)
	BG.set("space")
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
				if abs(x-M.x)+abs(y-M.y)<s then return name end
			elseif M.shape==3 then
				if(x-M.x)^2+(y-M.y)^2<s^2 then return name end
			end
		end
	end
end
local function moveMap(dx,dy)
	local k=getK()
	local x,y=getPos()
	if x>1300 and dx<0 or x<-1200 and dx>0 then dx=0 end
	if y>420 and dy<0 or y<-1900 and dy>0 then dy=0 end
	mapCam.xOy:translate(dx/k,dy/k)
end
function wheelMoved.mode(_,dy)
	mapCam.keyCtrl=false
	local k=getK()
	k=min(max(k+dy*.1,.3),1.6)/k
	mapCam.xOy:scale(k)

	local x,y=getPos()
	mapCam.xOy:translate(x*(1-k),y*(1-k))
end
function mouseMove.mode(_,_,dx,dy)
	if ms.isDown(1)then
		moveMap(dx,dy)
	end
	mapCam.keyCtrl=false
end
function mouseClick.mode(x,y)
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
				mapCam.sel=nil
			end
		elseif _ then
			keyDown.mode("return")
		end
	end
	mapCam.keyCtrl=false
end
function touchDown.mode()
	touchDist=nil
end
function touchMove.mode(_,x,y,dx,dy)
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
				wheelMoved.mode(nil,(d-touchDist)*.02)
			end
			touchDist=d
		end
	end
	mapCam.keyCtrl=false
end
function touchClick.mode(x,y)
	mouseClick.mode(x,y)
end
function keyDown.mode(key)
	if key=="return"then
		if mapCam.sel then
			mapCam.keyCtrl=false
			SCN.push()
			loadGame(mapCam.sel)
		end
	elseif key=="escape"then
		if mapCam.sel then
			mapCam.sel=nil
		else
			SCN.back()
		end
	end
end

function Tmr.mode()
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

function Pnt.mode()
	local _
	gc.push("transform")
	gc.translate(640,360)
	gc.scale(mapCam.zoomK)
	gc.rotate((mapCam.zoomK^.8-1)*.6)
	gc.shear((mapCam.zoomK-1)*.0626,0)
	gc.applyTransform(mapCam.xOy);

	local R=RANKS
	local sel=mapCam.sel

	--Draw lines connecting modes
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

	setFont(60)
	for name,M in next,MODES do
		if R[name]then
			local c=rankColor[R[M.name]]
			if c then
				gc.setColor(c)
			else
				c=.5+sin(Timer()*6.26)*.2
				gc.setColor(c,c,c)
			end

			local S=M.size
			if M.shape==1 then--Rectangle
				gc.rectangle("fill",M.x-S,M.y-S,2*S,2*S)
				if sel==name then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.rectangle("line",M.x-S+5,M.y-S+5,2*S-10,2*S-10)
				end
			elseif M.shape==2 then--Diamond
				gc.circle("fill",M.x,M.y,S+5,4)
				if sel==name then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.circle("line",M.x,M.y,S+5,4)
				end
			elseif M.shape==3 then--Octagon
				gc.circle("fill",M.x,M.y,S,8)
				if sel==name then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.circle("line",M.x,M.y,S,8)
				end
			end
			name=text.ranks[R[M.name]]
			if name then
				gc.setColor(0,0,0,.26)
				mStr(name,M.x,M.y-40)
			end
			--[[
			if M.icon then
				local i=M.icon
				local l=i:getWidth()*.5
				local k=S/l*.8
				gc.setColor(0,0,0,2)
				gc.draw(i,M.x-1,M.y-1,nil,k,nil,l,l)
				gc.draw(i,M.x-1,M.y+1,nil,k,nil,l,l)
				gc.draw(i,M.x+1,M.y-1,nil,k,nil,l,l)
				gc.draw(i,M.x+1,M.y+1,nil,k,nil,l,l)
				gc.setColor(1,1,1)
				gc.draw(i,M.x,M.y,nil,k,nil,l,l)
			end
			]]
		end
	end
	gc.pop()

	if sel then
		local M=MODES[sel]
		gc.setColor(.7,.7,.7,.5)
		gc.rectangle("fill",920,0,360,720)--Info board
		gc.setColor(M.color)
		setFont(40)mStr(text.modes[sel][1],1100,5)
		setFont(30)mStr(text.modes[sel][2],1100,50)
		gc.setColor(1,1,1)
		setFont(28)gc.printf(text.modes[sel][3],920,110,360,"center")
		if M.slowMark then
			gc.draw(IMG.ctrlSpeedLimit,1230,50,nil,.4)
		end
		if M.score then
			mText(drawableText.highScore,1100,240)
			gc.setColor(.4,.4,.4,.8)
			gc.rectangle("fill",940,290,320,280)--Highscore board
			local L=M.records
			gc.setColor(1,1,1)
			if L[1]then
				for i=1,#L do
					local t=M.scoreDisp(L[i])
					local s=#t
					local dy
					if s<15 then		dy=0
					elseif s<25 then	dy=2
					else				dy=4
					end
					setFont(int((26-s*.4)/3)*3)
					gc.print(t,955,275+dy+25*i)
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

WIDGET.init("mode",{
	WIDGET.newButton({name="start",	x=1040,	y=655,w=180,h=80,	font=40,code=WIDGET.lnk_pressKey("return"),hide=function()return not mapCam.sel end}),
	WIDGET.newButton({name="back",	x=1200,	y=655,w=120,h=80,	font=40,code=WIDGET.lnk_BACK}),
})