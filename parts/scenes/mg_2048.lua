local gc=love.graphics
local rectangle=gc.rectangle

local int,abs=math.floor,math.abs
local rnd,min=math.random,math.min
local format=string.format
local ins=table.insert
local setFont=setFont
local mStr=mStr

local scene={}

local board
local blind
local startTime,time
local state,progress
local skipCD,skipUsed
local nextTile,nextCD
local nextPos,prevPos
local prevSpawnTime=0
local maxTile
local score

--[[Tiles' value:
	-1: black tile, cannot move
	0: X tile, cannot merge
	1/2/3/...: 2/4/8/... tile
]]
local tileColor={
	[-1]=COLOR.black,
	[0]={.5,.3,.3},
	{.93,.89,.85},
	{.93,.88,.78},
	{.95,.69,.47},
	{.96,.58,.39},
	{.96,.49,.37},
	{.96,.37,.23},
	{.93,.81,.45},
	{.93,.80,.38},
	{.93,.78,.31},
	{.93,.77,.25},
	{.93,.76,.18},
	{.40,.37,.33},
	{.22,.19,.17},
}
local tileFont={
	80,80,80,--2/4/8
	70,70,70,--16/32/64
	60,60,60,--128/256/512
	55,55,55,55,--1024/2048/4096/8192
	50,50,50,--16384/32768/65536
	45,45,45,--131072/262144/524288
	30,--1048576
}
local tileName={[0]="X","2","4","8","16","32","64","128","256","512","1024","2048","4096","8192","16384","32768","65536","131072","262144","524288","2^20"}
local function airExist()
	for i=1,16 do
		if not board[i]then
			return true
		end
	end
end
local function newTile()
	nextPos=(nextPos+6)%16+1
	local p=nextPos
	while board[p]do
		p=(p-4)%16+1
	end
	board[p]=nextTile
	prevPos=p
	prevSpawnTime=0

	nextCD=nextCD-1
	if nextCD>0 then
		nextTile=1
	else
		nextTile=rnd()>.1 and 2 or rnd()>.1 and 3 or 4
		nextCD=rnd(8,12)
	end

	--Fresh score
	score=0
	for i=1,16 do
		if board[i]and board[i]>0 then
			score=score+2^board[i]
		end
	end
	TEXT.show("+"..2^nextTile,1130+rnd(-60,60),555+rnd(-40,40),30,"score",1.5)

	--Check if board is full
	if airExist()then return end

	--Check if board is locked in all-directions
	for i=1,12 do
		if board[i]==board[i+4]then
			return
		end
	end
	for i=1,13,4 do
		if
			board[i+0]==board[i+1]or
			board[i+1]==board[i+2]or
			board[i+2]==board[i+3]
		then
			return
		end
	end

	--Die.
	state=2
	SFX.play(maxTile>=10 and"win"or"fail")
end
local function freshMaxTile()
	maxTile=maxTile+1
	if maxTile==12 then skipCD=0 end
	SFX.play("reach")
	ins(progress,format("%s - %.3fs",tileName[maxTile],TIME()-startTime))
end
local function squash(L)
	local p1,p2=1
	local moved
	while p1<4 do
		p2=p1+1
		while not L[p2]do
			p2=p2+1
			if p2==5 then
				p1=p1+1
				goto continue
			end
		end
		if not L[p1]then--air←2
			L[p1]=L[p2]
			moved=true
		elseif L[p1]==L[p2]then--2←2
			L[p1]=L[p1]+1
			if L[p1]>maxTile then
				freshMaxTile()
			end
			moved=true
			p1=p1+1
		elseif p1+1~=p2 then--2←4
			L[p1+1]=L[p2]
			moved=true
			p1=p1+1
		else--2,4
			p1=p1+1
		end
		if moved then L[p2]=false end
		::continue::
	end
	return L[1],L[2],L[3],L[4],moved
end
local function reset()
	for i=1,16 do board[i]=false end
	progress={}
	state=0
	score=0
	time=0
	maxTile=6
	nextTile,nextPos=1,rnd(16)
	nextCD=32
	skipCD,skipUsed=false,false
	newTile()
end

local function moveUp()
	local moved
	for i=1,4 do
		local m
		board[i],board[i+4],board[i+8],board[i+12],m=squash({board[i],board[i+4],board[i+8],board[i+12]})
		if m then moved=true end
	end
	return moved
end
local function moveDown()
	local moved
	for i=1,4 do
		local m
		board[i+12],board[i+8],board[i+4],board[i],m=squash({board[i+12],board[i+8],board[i+4],board[i]})
		if m then moved=true end
	end
	return moved
end
local function moveLeft()
	local moved
	for i=1,13,4 do
		local m
		board[i],board[i+1],board[i+2],board[i+3],m=squash({board[i],board[i+1],board[i+2],board[i+3]})
		if m then moved=true end
	end
	return moved
end
local function moveRight()
	local moved
	for i=1,13,4 do
		local m
		board[i+3],board[i+2],board[i+1],board[i],m=squash({board[i+3],board[i+2],board[i+1],board[i]})
		if m then moved=true end
	end
	return moved
end
local function skip()
	if state==1 and skipCD==0 then
		if airExist()then
			skipCD=1024
			skipUsed=true
			newTile()
			SFX.play("hold")
		else
			SFX.play("finesseError")
		end
	end
end

function scene.sceneInit()
	BG.set("cubes")
	BGM.play("truth")
	board={}

	blind=false
	startTime,time=0,0
	state=0
	reset()
end

function scene.mouseDown(x,y,k)
	if k==2 then
		skip()
	else
		local dx,dy=x-640,y-360
		if abs(dx)<320 and abs(dy)<320 and(abs(dx)>60 or abs(dy)>60)then
			scene.keyDown(abs(dx)-abs(dy)>0 and
				(dx>0 and"right"or"left")or
				(dy>0 and"down"or"up")
			)
		end
	end
end
function scene.touchDown(_,x,y)
	scene.mouseDown(x,y)
end
local moveFunc={
	up=moveUp,
	down=moveDown,
	left=moveLeft,
	right=moveRight,
}
function scene.keyDown(key)
	if key=="up"or key=="down"or key=="left"or key=="right"then
		if moveFunc[key]()then
			if state==0 then
				startTime=TIME()
				state=1
			end
			if skipCD and skipCD>0 then
				skipCD=skipCD-1
				if skipCD==0 then
					SFX.play("spin_0")
				end
			end
			newTile()
			SFX.play("move")
		end
	elseif key=="space"then skip()
	elseif key=="r"then reset()
	elseif key=="q"then if state==0 then blind=not blind end
	elseif key=="escape"then SCN.back()
	end
end

function scene.update(dt)
	if state==1 then
		time=TIME()-startTime
	end
	if prevSpawnTime<1 then
		prevSpawnTime=min(prevSpawnTime+3*dt,1)
	end
end

function scene.draw()
	setFont(40)
	gc.setColor(1,1,1)
	gc.print(format("%.3f",time),1026,80)

	--Progress time list
	setFont(30)
	gc.setColor(.7,.7,.7)
	for i=1,#progress do
		gc.print(progress[i],1000,130+32*i)
	end

	--Score
	setFont(40)
	gc.setColor(1,.7,.7)
	mStr(score,1130,490)

	--Messages
	if state==2 then
		--Draw no-setting area
		gc.setColor(1,0,0,.3)
		rectangle("fill",15,335,285,250)

		gc.setColor(.9,.9,0)--win
	elseif state==1 then
		gc.setColor(.9,.9,.9)--game
	elseif state==0 then
		gc.setColor(.2,.8,.2)--ready
	end
	gc.setLineWidth(10)
	rectangle("line",310,30,660,660)

	--Board
	for i=1,16 do
		if board[i]then
			local x,y=1+(i-1)%4,int((i+3)/4)
			local N=board[i]
			if i~=prevPos or prevSpawnTime==1 then
				gc.setColor(tileColor[N]or COLOR.black)
				rectangle("fill",x*160+163,y*160-117,154,154,15)
				if N>=0 and not blind or i==prevPos then
					gc.setColor(N<3 and COLOR.black or COLOR.W)
					local fontSize=tileFont[N]
					setFont(fontSize)
					mStr(tileName[N],320+(x-.5)*160,40+(y-.5)*160-7*(fontSize/5+1)/2)
				end
			else
				local c=tileColor[N]
				gc.setColor(c[1],c[2],c[3],prevSpawnTime)
				rectangle("fill",x*160+163,y*160-117,154,154,15)
				c=N<3 and 0 or 1
				gc.setColor(c,c,c,prevSpawnTime)
				local fontSize=tileFont[N]
				setFont(fontSize)
				mStr(tileName[N],320+(x-.5)*160,40+(y-.5)*160-7*(fontSize/5+1)/2)
			end
		end
	end

	--Next indicator
	gc.setColor(1,1,1)
	if nextCD<=12 then
		for i=1,nextCD do
			rectangle("fill",140+i*16-nextCD*8,170,12,12)
		end
	end

	--Next
	setFont(40)
	mStr("Next",153,185)
	if nextTile>1 then
		gc.setColor(1,.5,.4)
	end
	setFont(70)
	mStr(tileName[nextTile],153,220)

	--Skip CoolDown
	if skipCD and skipCD>0 then
		setFont(50)
		gc.setColor(1,1,.5)
		mStr(skipCD,160,600)
	end

	--Skip mark
	if skipUsed then
		gc.setColor(1,1,.5)
		gc.circle("fill",280,675,10)
	end

	--New tile position
	local x,y=1+(prevPos-1)%4,int((prevPos+3)/4)
	gc.setLineWidth(8)
	gc.setColor(.2,.8,0,prevSpawnTime)
	local d=25-prevSpawnTime*25
	rectangle("line",x*160+163-d,y*160-117-d,154+2*d,154+2*d,15)
end

scene.widgetList={
	WIDGET.newButton{name="reset",		x=160,y=100,w=180,h=100,color="lGreen",font=40,code=pressKey"r"},
	WIDGET.newKey{name="skip",			x=160,y=640,w=180,h=100,color="lYellow",font=40,code=pressKey"space",hide=function()return state~=1 or not skipCD or skipCD>0 end},
	WIDGET.newSwitch{name="blind",		x=240,y=370,w=60,		font=40,disp=function()return blind end,	code=pressKey"q",hide=function()return state==1 end},
	WIDGET.newButton{name="back",		x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene