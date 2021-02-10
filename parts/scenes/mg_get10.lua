local gc=love.graphics
local setColor,rectangle=gc.setColor,gc.rectangle

local int,rnd=math.floor,math.random
local min=math.min
local format=string.format
local ins,rem=table.insert,table.remove
local mStr=mStr

local scene={}

local tileColor={
	{.39, 1.0, .39},
	{.39, .39, 1.0},
	{1.0, .70, .31},
	{.94, .31, .31},
	{.00, .71, .12},
	{.90, .20, .90},
	{.94, .47, .39},
	{.90, .00, .00},
	{.86, .86, .31},
	{.78, .31, .00},
	{.78, .55, .04},
	{.12, .12, .51},
	{.78, .78, .78},
	{.40, .40, .40},
	{.20, .20, .20},
	{.00, .00, .00},
}
local newTile={0,2,2,2,3,3,3,3,4,4,4,5,5}

local board,cx,cy
local startTime,time
local maxTile,state
local fallingTimer
local score

local blind

local function reset()
	state=0
	score=0
	time=0
	maxTile=2
	for i=1,5 do for j=1,5 do
		board[i][j]=rnd(2)
	end end
	board[rnd(5)][rnd(5)]=2
	fallingTimer=false
end
function scene.sceneInit()
	BG.set("rainbow2")
	BGM.play("truth")
	board={{},{},{},{},{}}
	cx,cy=3,3
	startTime=0
	time=0
	score=0
	state=2

	blind=false
	for i=1,5 do for j=1,5 do
		board[i][j]=(i+j)%2+1
	end end
end

local function merge()
	if fallingTimer or state==2 or not cx then return end
	if state==0 then
		state=1
		startTime=TIME()
	end
	local chosen=board[cy][cx]
	local connected={{cy,cx}}
	local count=1
	repeat
		local y,x=unpack(rem(connected))
		if board[y][x]~=0 then
			board[y][x]=0
			SYSFX.newShade(2,320+x*128-128,40+y*128-128,128,128)
			if x>1 and board[y][x-1]==chosen then ins(connected,{y,x-1})count=count+1 end
			if x<5 and board[y][x+1]==chosen then ins(connected,{y,x+1})count=count+1 end
			if y>1 and board[y-1][x]==chosen then ins(connected,{y-1,x})count=count+1 end
			if y<5 and board[y+1][x]==chosen then ins(connected,{y+1,x})count=count+1 end
		end
	until not connected[1]
	if count>1 then
		board[cy][cx]=chosen+1
		local getScore=3^(chosen-1)*min(int(1+count/3),4)
		score=score+getScore
		TEXT.show(getScore,cx*128+256,cy*128-40,40,"score")
		SYSFX.newRectRipple(2,320+cx*128-128,40+cy*128-128,128,128)
		SFX.play("lock")
		if chosen==maxTile then
			maxTile=chosen+1
			SFX.play("reach")
		end
		if chosen>=5 then
			SFX.play(
				chosen>=9 and"ren_mega"or
				chosen>=8 and"spin_3"or
				chosen>=7 and"spin_2"or
				chosen>=6 and"spin_1"or
				"spin_0"
			)
		end
		fallingTimer=15
	else
		board[cy][cx]=chosen
	end
end
function scene.keyDown(key)
	if key=="up"or key=="down"or key=="left"or key=="right"then
		if state==2 then return end
		if not cx then
			cx,cy=3,3
		else
			if key=="up"then
				if cy>1 then cy=cy-1 end
			elseif key=="down"then
				if cy<5 then cy=cy+1 end
			elseif key=="left"then
				if cx>1 then cx=cx-1 end
			elseif key=="right"then
				if cx<5 then cx=cx+1 end
			end
		end
	elseif key=="z"or key=="space"then
		merge()
	elseif key=="r"then
		reset()
	elseif key=="q"then
		if state==0 then
			blind=not blind
		end
	elseif key=="escape"then
		SCN.back()
	end
end
function scene.mouseMove(x,y)
	cx=int((x-192)/128)
	cy=int((y+88)/128)
	if cx<1 or cx>5 or cy<1 or cy>5 then cx,cy=false end
end
function scene.mouseDown(x,y)
	scene.mouseMove(x,y)
	merge()
end

function scene.touchDown(x,y)
	scene.mouseMove(x,y)
end
function scene.touchMove(x,y)
	scene.mouseMove(x,y)
end
function scene.touchClick(x,y)
	scene.mouseDown(x,y)
end

function scene.update()
	if state==1 then
		time=TIME()-startTime
		if fallingTimer then
			fallingTimer=fallingTimer-1
			if fallingTimer==0 then
				for i=5,2,-1 do
					for j=1,5 do
						if board[i][j]==0 then
							board[i][j]=board[i-1][j]
							board[i-1][j]=0
						end
					end
				end
				local noNewTile=true
				for i=1,5 do
					if board[1][i]==0 then
						board[1][i]=rnd(newTile[maxTile])
						noNewTile=false
					end
				end
				if noNewTile then
					fallingTimer=false
					for i=1,4 do
						for j=1,4 do
							if board[i][j]==board[i+1][j]or board[i][j]==board[i][j+1]then
								return
							end
						end
					end
					state=2
					SFX.play("fail")
				else
					fallingTimer=6
					SFX.play("move")
				end
			end
		end
	end
end

function scene.draw()
	setFont(40)
	setColor(1,1,1)
	gc.print(format("%.3f",time),1026,50)
	gc.print(score,1026,100)

	if state==2 then
		--Draw no-setting area
		setColor(1,0,0,.3)
		gc.rectangle("fill",15,295,285,70)
	end
	gc.setLineWidth(10)
	setColor(1,1,1)
	gc.rectangle("line",315,35,650,650)

	gc.setLineWidth(4)
	setFont(70)
	for i=1,5 do
		for j=1,5 do
			local N=board[i][j]
			if N>0 then
				if blind and state==1 and N>newTile[maxTile]then
					setColor(COLOR.dGrey)
					rectangle("fill",320+j*128-128,40+i*128-128,128,128)
					setColor(1,1,1,.3)
					mStr("?",j*128+256,i*128-75)
				else
					setColor(tileColor[N])
					rectangle("fill",320+j*128-128,40+i*128-128,128,128)
					setColor(1,1,1,.9)
					mStr(N,j*128+256,i*128-75)
				end
			end
		end
	end
	if state<2 and cx then
		setColor(1,1,1,.6)
		gc.setLineWidth(10)
		gc.rectangle("line",325+cx*128-128,45+cy*128-128,118,118)
	end
	setFont(50)
	setColor(1,1,1)
	mStr("Just Get 10",160,580)
end

scene.widgetList={
	WIDGET.newButton{name="reset",	x=160,y=100,w=180,h=100,color="lGreen",font=40,code=pressKey"r"},
	WIDGET.newSwitch{name="blind",	x=240,y=330,w=60,font=40,disp=function()return blind end,code=pressKey"q",hide=function()return state==1 end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene