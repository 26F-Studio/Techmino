local gc=love.graphics
local kb=love.keyboard
local tc=love.touch

local function sign(a)return a>0 and 1 or -1 end
local rnd,int,abs=math.random,math.floor,math.abs
local max,min,sin,cos=math.max,math.min,math.sin,math.cos
local Timer=love.timer.getTime
local setFont=setFont

local cubeColor={
	{.88,.75,.00},
	{.50,.50,.97},
	{.50,.50,.50},
	{.50,.97,.00},
	{.94,.94,.94},
	{.40,.40,.40},
	{.31,.88,.97},
	{.97,.97,.50},
	{.91,.50,.97},
	{.97,.63,.31},
	{0,0,0},
}

local cubesX,cubesY
local lastCube
local player,moveDir
local life,life1,inv
local level,speed
local menu,ct,play
local score
local sunH,color,rot

local function near(o,t)
	return o>t and max(o-.01,t)or o<t and min(o+.01,t)or o
end
local function hurt(i)
	life=life-i
	if life<0 then
		life=-100
		menu,play=1,false
		speed=speed*.5
		moveDir=0
		score=int(score)
		SFX.play("clear_4")
	else
		SFX.play("clear_2")
	end
end

function sceneInit.mg_cubefield()
	cubesX={}for i=1,40 do cubesX[i]=rnd()*16-8 end
	cubesY={}for i=1,40 do cubesY[i]=i/40*9 end
	lastCube=1
	player,moveDir=0,0
	life,life1,inv=0,0,false
	level,speed=1,1
	menu,ct,play=false,60,false
	score=0
	sunH,color,rot=0,{.878,.752,0},0

	gc.setLineJoin("bevel")
	BG.set("none")
end

function touchDown.mg_cubefield(_,x)
	if play then
		if x<640 then
			moveDir=-1
		else
			moveDir=1
		end
	else
		keyDown.mg_cubefield("space")
	end
end
function touchUp.mg_cubefield(_,x)
	if play then
		local L=tc.getTouches()
		if x<640 then
			for i=1,#L do
				if tc.getPosition(L[i])>640 then
					moveDir=1
					return
				end
			end
		else
			for i=1,#L do
				if tc.getPosition(L[i])<640 then
					moveDir=-1
					return
				end
			end
		end
		moveDir=0
	end
end
function keyDown.mg_cubefield(key)
	if key=="escape"then
		SCN.back()
		return
	end

	if play then
		if key=="left"or key=="a"then
			moveDir=-1
		elseif key=="right"or key=="d"then
			moveDir=1
		end
	else
		if key=="space"and ct==60 then
			menu=-1
			speed=1
			level=1
		end
	end
end
function keyUp.mg_cubefield(key)
	if play then
		if key=="left"or key=="a"then
			moveDir=kb.isDown("right","d")and 1 or 0
		elseif key=="right"or key=="d"then
			moveDir=kb.isDown("left","a")and -1 or 0
		end
	end
end

function Tmr.mg_cubefield(dt)
	dt=dt*600
	
	--Update cubes' position
	local cy=cubesY
	local step=speed*dt*.005
	for i=1,40 do
		cy[i]=cy[i]+step
		if cy[i]>10 then
			if score%1000<820 then
				cubesX[i]=rnd()*16-8+player
			else
				cubesX[i]=player+i%2*6-3
			end
			cy[i]=cy[i]-9
			lastCube=(lastCube-2)%40+1
		end
	end

	--Screen rotation
	if moveDir~=0 then
		player=player+moveDir*dt*.003*speed^.8
		if abs(rot)<.16 or moveDir*rot>0 then
			rot=rot-moveDir*dt*.0003*speed
		end
	elseif rot~=0 then
		local d=dt*.0002*speed
		if rot>0 then
			rot=max(rot-d,0)
		else
			rot=min(rot+d,0)
		end
	end

	life1=life1*.7+life*.3

	if play then
		if inv>0 then inv=inv-1 end
		score=score+dt*.03+life/2000
		life=min(life+dt*.04,1000)
		if score>1000*level then
			if speed<3 then speed=speed+.2 end
			level=level+1
		end
		sunH=sunH+.01
	elseif menu==1 then
		ct=ct+1
		if ct==60 then menu=false end
	elseif menu==-1 then
		for i=1,3 do color[i]=near(color[i],cubeColor[1][i])end
		for i=1,40 do cubesY[i]=cubesY[i]-(70-ct)*.003 end
		if sunH>0 then sunH=max(sunH*.85-1,0)end
		ct=ct-1
		if ct==0 then
			score=0
			life=1000
			play,menu=true,false
			inv=90
		end
	end
end

function Pnt.mg_cubefield()
	--Health bar
	if life1>0 then
		gc.setColor(1,0,0)
		gc.rectangle("fill",640-life1*.64,710,life1*1.28,10)
	end

	--Draw player
	if play and inv%8<4 then
		gc.setColor(1,1,1)
		gc.rectangle("fill",620,670,40,40)
	end

	--Set screen rotation
	gc.push("transform")
	gc.translate(640,690)
	gc.rotate(rot)

	--Draw sun
	gc.setColor(.7,.5,.3)
	gc.circle("fill",0,-380-sunH,60)

	--Draw sun-board
	gc.setColor(.15,.15,.15)
	gc.rectangle("fill",-60,-440,120,120)

	--Draw direction
	if play then
		gc.setLineWidth(3)
		gc.setColor(1,1,1,.4)
		gc.line(-18,-20,0,-440,18,-20)
	end

	--Draw Horizon/Direction
	gc.setColor(1,1,1)
	gc.line(-942,-440,942,-440)

	--Draw cubes
	for j=1,40 do
		local i=(j+lastCube-2)%40+1
		local Y=cubesY[i]
		if Y<8.8 then
			local size=100/(10-Y)
			local x=(cubesX[i]-player)/(10-Y)*200-size*.5
			local y=5/(10-Y)*150-50
			if Y>1 then
				gc.setColor(color)
				gc.rectangle("fill",x,y-485,size,size)
				gc.setLineWidth(size*.05)
				gc.setColor(1,1,1)
				gc.rectangle("line",x,y-485,size,size)
			end

			if play and y>420 and y<480 and x<8 and x+size>-8 and inv==0 then
				cubesX[i]=cubesX[i]-3
				hurt(650)
				inv=40
			end
		end
	end
	gc.pop()

	--Draw menu
	if play then
		setFont(60)
		gc.print(int(score),40,50)
		if score%1000>920 then
			setFont(35)
			gc.setColor(1,1,1,abs(score%1000-970)*8)
			setFont(70)
			if level<11 then
				mStr("++SPEED++",640,40)
				for i=1,3 do
					color[i]=near(color[i],cubeColor[level+1][i])
				end
			else
				mStr("!!MAXSPEED!!",640,40)
			end
		end
	else
		gc.setColor(1,1,1)
		gc.rectangle("fill",620,670+ct,40,40)

		gc.setLineWidth(3)
		gc.setColor(1,1,1,.4*(1-ct/60))
		gc.line(622,670,640,250,658,670)
		
		gc.setColor(1,1,1,ct/60)

		setFont(90)
		mStr("CubeField",640,40)

		setFont(20)
		gc.print("Original game by Max Abernethy",680,140)
		gc.print("Original CX-CAS version by Par Loic Pujet",680,165)
		gc.print("Ported / Rewritten / Balanced by MrZ",680,190)

		setFont(45)
		if score>0 then
			mStr("Score : "..score,640,340)
		end
		
		mStr(MOBILE and"Touch to Start"or"Press space",640,530)
	end
end