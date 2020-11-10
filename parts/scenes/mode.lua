local gc=love.graphics
local ms,kb,tc=love.mouse,love.keyboard,love.touch
local Timer=love.timer.getTime

local int,abs=math.floor,math.abs
local sin=math.sin

mapCam={
	sel=nil,--Selected mode ID

	--Basic paragrams
	x=0,y=0,k=1,--Camera pos/k
	x1=0,y1=0,k1=1,--Camera pos/k shown

	--If controlling with key
	keyCtrl=false,

	--For auto zooming when enter/leave scene
	zoomMethod=nil,
	zoomK=nil,
}
local mapCam=mapCam
local touchDist=nil
function sceneInit.mode(org)
	BG.set("space")
	destroyPlayers()
	local cam=mapCam
	cam.zoomK=org=="main"and 5 or 1
	if cam.sel then
		local M=MODES[cam.sel]
		cam.x,cam.y=M.x*cam.k+180,M.y*cam.k
		cam.x1,cam.y1=cam.x,cam.y
	end
end

local function onMode(x,y)
	local cam=mapCam
	x=(cam.x1-640+x)/cam.k1
	y=(cam.y1-360+y)/cam.k1
	for name,M in next,MODES do
		if RANKS[name]then
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
function wheelMoved.mode(_,y)
	local cam=mapCam
	local t=cam.k
	local k=t+y*.1
	if k>1.5 then k=1.5
	elseif k<.3 then k=.3
	end
	t=k/t
	if cam.sel then
		cam.x=(cam.x-180)*t+180
		cam.y=cam.y*t
	else
		cam.x=cam.x*t
		cam.y=cam.y*t
	end
	cam.k=k
	cam.keyCtrl=false
end
function mouseMove.mode(_,_,dx,dy)
	if ms.isDown(1)then
		mapCam.x,mapCam.y=mapCam.x-dx,mapCam.y-dy
	end
	mapCam.keyCtrl=false
end
function mouseClick.mode(x,y)
	local cam=mapCam
	local _=cam.sel
	if not _ or x<920 then
		local SEL=onMode(x,y)
		if _~=SEL then
			if SEL then
				cam.moving=true
				_=MODES[SEL]
				cam.x=_.x*cam.k+180
				cam.y=_.y*cam.k
				cam.sel=SEL
				SFX.play("click")
			else
				cam.sel=nil
				cam.x=cam.x-180
			end
		elseif _ then
			keyDown.mode("return")
		end
	end
	cam.keyCtrl=false
end
function touchDown.mode()
	touchDist=nil
end
function touchMove.mode(_,x,y,dx,dy)
	local L=tc.getTouches()
	if not L[2]then
		mapCam.x,mapCam.y=mapCam.x-dx,mapCam.y-dy
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
	local cam=mapCam
	local x,y,k=cam.x,cam.y,cam.k
	local F
	if not SCN.swapping then
		if kb.isDown("up",	"w")then	y=y-10*k F=true end
		if kb.isDown("down","s")then	y=y+10*k F=true end
		if kb.isDown("left","a")then	x=x-10*k F=true end
		if kb.isDown("right","d")then	x=x+10*k F=true end
		local js1=joysticks[1]
		if js1 then
			local dir=js1:getAxis(1)
			if dir~="c"then
				if dir=="u"or dir=="ul"or dir=="ur"then y=y-10*k F=true end
				if dir=="d"or dir=="dl"or dir=="dl"then y=y+10*k F=true end
				if dir=="l"or dir=="ul"or dir=="dl"then x=x-10*k F=true end
				if dir=="r"or dir=="ur"or dir=="dr"then x=x+10*k F=true end
			end
		end
	end
	if F or cam.keyCtrl and(x-cam.x1)^2+(y-cam.y1)^2>2.6 then
		if F then
			cam.keyCtrl=true
		end
		local x1,y1=(cam.x1-180)/cam.k1,cam.y1/cam.k1
		for name,M in next,MODES do
			if RANKS[name]then
				local SEL
				local s=M.size
				if M.shape==1 then
					if x1>M.x-s and x1<M.x+s and y1>M.y-s and y1<M.y+s then SEL=name end
				elseif M.shape==2 then
					if abs(x1-M.x)+abs(y1-M.y)<s then SEL=name end
				elseif M.shape==3 then
					if(x1-M.x)^2+(y1-M.y)^2<s^2 then SEL=name end
				end
				if SEL and cam.sel~=SEL then
					cam.sel=SEL
					SFX.play("click")
				end
			end
		end
	end

	if x>1850*k then x=1850*k
	elseif x<-1000*k then x=-1000*k
	end
	if y>500*k then y=500*k
	elseif y<-1900*k then y=-1900*k
	end
	cam.x,cam.y=x,y
	--Keyboard controlling

	cam.x1=cam.x1*.85+x*.15
	cam.y1=cam.y1*.85+y*.15
	cam.k1=cam.k1*.85+k*.15
	local _=SCN.stat.tar
	cam.zoomMethod=_=="play"and 1 or _=="mode"and 2
	if cam.zoomMethod==1 then
		if cam.sel then
			local M=MODES[cam.sel]
			cam.x=cam.x*.8+M.x*cam.k*.2
			cam.y=cam.y*.8+M.y*cam.k*.2
		end
		_=cam.zoomK
		if _<.8 then _=_*1.05 end
		if _<1.1 then _=_*1.05 end
		cam.zoomK=_*1.05
	elseif cam.zoomMethod==2 then
		cam.zoomK=cam.zoomK^.9
	end
end

function Pnt.mode()
	local _
	local cam=mapCam
	gc.push("transform")
	gc.translate(640,360)
	gc.scale(cam.zoomK)
	gc.translate(-cam.x1,-cam.y1)
	gc.scale(cam.k1)
	local R=RANKS
	local sel=cam.sel

	--Draw lines connecting modes
	gc.setLineWidth(8)
	gc.setColor(1,1,1,.2)
	for name,M in next,MODES do
		if R[name]and M.unlock then
			for _=1,#M.unlock do
				local m=MODES[M.unlock[_]]
				gc.line(M.x,M.y,m.x,m.y)
			end
		end
	end

	setFont(60)
	for name,M in next,MODES do
		if R[name]then
			local S=M.size
			local d=((M.x-(cam.x1+(sel and -180 or 0))/cam.k1)^2+(M.y-cam.y1/cam.k1)^2)^.55
			if d<500 then S=S*(1.25-d*0.0005) end
			local c=rankColor[R[M.name]]
			if c then
				gc.setColor(c)
			else
				c=.5+sin(Timer()*6.26)*.2
				S=S*(.9+c*.4)
				gc.setColor(c,c,c)
			end
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
	if cam.keyCtrl then
		gc.setColor(1,1,1)
		gc.draw(TEXTURE.mapCross,460-20,360-20)
	end
end

WIDGET.init("mode",{
	WIDGET.newButton({name="start",	x=1040,	y=655,w=180,h=80,	font=40,code=WIDGET.lnk.pressKey("return"),hide=function()return not mapCam.sel end}),
	WIDGET.newButton({name="back",		x=1200,	y=655,w=120,h=80,	font=40,code=WIDGET.lnk.BACK}),
})