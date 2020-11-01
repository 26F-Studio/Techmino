local gc=love.graphics
local kb=love.keyboard

local setFont=setFont
local mStr=mStr

local abs=math.abs
local max,min=math.max,math.min
local rnd=math.random

function sceneInit.pong()
	BG.set("none")
	BGM.play("way")
	sceneTemp={
		state=0,

		x=640,y=360,
		vx=0,vy=0,
		ry=0,

		p1={
			score=0,
			y=360,
			vy=0,
			y0=false,
		},
		p2={
			score=0,
			y=360,
			vy=0,
			y0=false,
		},
	}
end

local function start()
	sceneTemp.state=1
	sceneTemp.vx=rnd()>.5 and 6 or -6
	sceneTemp.vy=rnd()*6-3
end
function keyDown.pong(key)
	local S=sceneTemp
	if key=="space"then
		if S.state==0 then
			start()
		end
	elseif key=="r"then
		S.state=0
		S.x,S.y=640,360
		S.vx,S.vy=0,0
		S.ry=0
		S.p1.score,S.p2.score=0,0
	elseif key=="w"or key=="s"then
		S.p1.y0=false
	elseif key=="up"or key=="down"then
		S.p2.y0=false
	elseif key=="escape"then
		SCN.back()
	end
end
function touchDown.pong(id,x,y)
	touchMove.pong(id,x,y)
	if sceneTemp.state==0 then
		start()
	end
end
function touchMove.pong(_,x,y)
	sceneTemp[x<640 and"p1"or"p2"].y0=y
end
function mouseMove.pong(x,y)
	sceneTemp[x<640 and"p1"or"p2"].y0=y
end

--Rect Area X:150~1130 Y:20~700
function Tmr.pong()
	local S=sceneTemp

	--Update pads
	local P=S.p1
	while P do
		if P.y0 then
			if P.y>P.y0 then
				P.y=max(P.y-8,P.y0,70)
				P.vy=-8
			elseif P.y<P.y0 then
				P.y=min(P.y+8,P.y0,650)
				P.vy=8
			else
				P.vy=P.vy*.5
			end
		else
			if kb.isDown(P==S.p1 and"w"or"up")then P.vy=max(P.vy-1,-8)end
			if kb.isDown(P==S.p1 and"s"or"down")then P.vy=min(P.vy+1,8)end
			P.y=P.y+P.vy
			P.vy=P.vy*.9
			if P.y>650 then
				P.vy=-P.vy*.5
				P.y=650
			elseif P.y<70 then
				P.vy=-P.vy*.5
				P.y=70
			end
		end
		P=P==S.p1 and S.p2
	end

	--Update ball
	local x,y,vx,vy,ry=S.x,S.y,S.vx,S.vy,S.ry
	x,y=x+vx,y+vy
	if ry~=0 then
		if ry>0 then
			ry=max(ry-.1,0)
			vy=vy-.1
		else
			ry=min(ry+.1,0)
			vy=vy+.1
		end
	end
	if S.state==1 then--Playing
		if x<160 or x>1120 then
			P=x<160 and S.p1 or S.p2
			local d=y-P.y
			if abs(d)<60 then
				vx=-vx-(vx>0 and .05 or -.5)
				vy=vy+d*.08+P.vy*.5
				ry=P.vy
				SFX.play("collect")
			else
				S.state=2
			end
		end
		if y<30 or y>690 then
			y=y<30 and 30 or 690
			vy,ry=-vy,-ry
			SFX.play("collect")
		end
	elseif S.state==2 then--Game over
		if x<-120 or x>1400 or y<-40 or y>760 then
			P=x>640 and S.p1 or S.p2
			P.score=P.score+1
			TEXT.show("+1",x>1400 and 470 or 810,226,50,"score")
			SFX.play("reach")

			S.state=0
			x,y=640,360
			vx,vy=0,0
		end
	end
	S.x,S.y,S.vx,S.vy,S.ry=x,y,vx,vy,ry
end

function Pnt.pong()
	local S=sceneTemp

	--Draw score
	setFont(100)
	gc.setColor(.4,.4,.4)
	mStr(S.p1.score,470,20)
	mStr(S.p2.score,810,20)

	--Draw boundary
	gc.setColor(1,1,1)
	gc.setLineWidth(6)
	gc.line(130,20,1160,20)
	gc.line(130,700,1160,700)

	--Draw ball & speed line
	gc.setColor(1,1,1-abs(S.ry)*.16)
	gc.circle("fill",S.x,S.y,10)
	gc.setColor(1,1,1,.1)
	gc.line(S.x+S.vx*22,S.y+S.vy*22,S.x+S.vx*30,S.y+S.vy*30)

	--Draw pads
	gc.setColor(1,.8,.8)
	gc.rectangle("fill",130,S.p1.y-50,20,100)
	gc.setColor(.8,.8,1)
	gc.rectangle("fill",1130,S.p2.y-50,20,100)
end