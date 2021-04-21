local gc=love.graphics
local int,rnd,abs,sin,cos=math.floor,math.random,math.abs,math.sin,math.cos

local pow,ang
local state,timer
local score,combo
local x,y
local vx,vy
local ex,ey

local scene={}
function scene.sceneInit()
	pow,ang=0,0
	state=0
	timer=0
	score,combo=0,0
	x,y=160,500
	ex,ey=626,260
	BG.set("matrix")
	BGM.play("hang out")
	love.keyboard.setKeyRepeat(false)
end
function scene.sceneBack()
	love.keyboard.setKeyRepeat(true)
end

function scene.keyDown(key)
	if key=="space"or key=="return"then
		if state==0 then
			state=1
		elseif state==1 then
			state=2
			vx=pow*cos(ang)/2.6
			vy=pow*sin(ang)/2.6
		end
	elseif key=="escape"then
		SCN.back()
	end
end
function scene.mouseDown(k)
	if k==1 then
		scene.keyDown("space")
	elseif k==2 then
		SCN.back()
	end
end
function scene.touchDown()
	scene.keyDown("space")
end

function scene.update()
	timer=timer+1
	if state==0 then
		pow=abs(100-TIME()*200%200)
	elseif state==1 then
		ang=(abs(110-TIME()*120%220)-30)/180*3.141592653589793
	else
		x,y=x+vx,y-vy
		vy=vy-.62
		local e
		if (x-ex)^2+(y-ey)^2<900 then
			score=math.min(score+4+combo*2,626)
			combo=combo+1
			ex,ey=rnd(626,1100),rnd(26,700)
			SFX.play("reach")
			e=true
		end
		if x>1280 or y>720 then
			if score>0 then
				score=score-int(score/10)
			end
			SFX.play("finesseError")
			combo=0
			e=true
		end
		if e then
			x,y=rnd(100,260),rnd(160,700)
			state=0
		end
	end
end

local scoreColor={
	"white",--0
	"aqua",--20
	"navy",--40
	"blue",--60
	"purple",--80
	"wine",--100
	"red","fire","orange","yellow","lAqua",--200
	"lNavy","lBlue","lPurple","lWine","lRed",--300
	"lFire","lOrange","lYellow","dAqua","dNavy",--400
	"dBlue","dPurple","dWine","dRed","dFire",--500
	"dYellow","lH","H","dH",--before 600, black after
}
function scene.draw()
	--Spawn area
	gc.setColor(1,1,1,.2)
	gc.rectangle("fill",85,0,190,720)

	--Power & Angle
	gc.setColor(1,1,1)
	if state~=2 then
		gc.setLineWidth(2)
		gc.rectangle("fill",x-80,y+20,pow*1.6,16)
		gc.rectangle("line",x-80,y+20,160,15)
		if state==1 then
			gc.setLineWidth(5)
			gc.line(x,y,x+(20+2*pow)*cos(ang),y-(20+2*pow)*sin(ang))
		end
	end

	--Info
	setFont(40)
	if combo>1 then
		gc.setColor(1,1,.6)
		gc.print("x"..combo,300,80)
	end
	gc.setColor(COLOR[scoreColor[int(score/20)+1]or"black"])
	gc.print(score,300,30)

	--Cannon ball
	gc.circle("fill",x,y,15)

	--Arrow
	if y<-15 then
		gc.print("↑",x-20.5,0)
	end

	--Target
	gc.setColor(1,1,.4)
	gc.circle("fill",ex,ey,15)
end

scene.widgetList={
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene