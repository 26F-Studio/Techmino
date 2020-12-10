local gc=love.graphics
local Timer=love.timer.getTime

local mStr=mStr

local int=math.floor
local rnd=math.random
local format=string.format

local scene={}

local board
local cx,cy
local startTime
local time
local move
local state

local color
local blind
local slide
local pathVis
local revKB

function scene.sceneInit()
	BG.set("rainbow")
	BGM.play("push")
	board={{1,2,3,4},{5,6,7,8},{9,10,11,12},{13,14,15,16}}
	cx,cy=4,4
	startTime=0
	time=0
	move=0
	state=2

	color=0
	blind=false
	slide=true
	pathVis=true
	revKB=false
end

local function moveU(x,y)
	if y<4 then
		board[y][x],board[y+1][x]=board[y+1][x],board[y][x]
		cy=cy+1
	end
end
local function moveD(x,y)
	if y>1 then
		board[y][x],board[y-1][x]=board[y-1][x],board[y][x]
		cy=cy-1
	end
end
local function moveL(x,y)
	if x<4 then
		board[y][x],board[y][x+1]=board[y][x+1],board[y][x]
		cx=cx+1
	end
end
local function moveR(x,y)
	if x>1 then
		board[y][x],board[y][x-1]=board[y][x-1],board[y][x]
		cx=cx-1
	end
end
local function shuffleBoard()
	for i=1,300 do
		i=rnd()
		if i<.25 then moveU(cx,cy)
		elseif i<.5 then moveD(cx,cy)
		elseif i<.75 then moveL(cx,cy)
		else moveR(cx,cy)
		end
	end
end
local function checkBoard(b)
	for i=4,1,-1 do
		for j=1,4 do
			if b[i][j]~=4*i+j-4 then return false end
		end
	end
	return true
end
local function tapBoard(x,y,key)
	if state<2 then
		if not key then
			if pathVis then
				SYSFX.newRipple(6,x,y,10)
			end
			x,y=int((x-320)/160)+1,int((y-40)/160)+1
		end
		local b=board
		local moves=0
		if cx==x then
			if y>cy and y<5 then
				for i=cy,y-1 do
					moveU(x,i)
					moves=moves+1
				end
			elseif y<cy and y>0 then
				for i=cy,y+1,-1 do
					moveD(x,i)
					moves=moves+1
				end
			end
		elseif cy==y then
			if x>cx and x<5 then
				for i=cx,x-1 do
					moveL(i,y)
					moves=moves+1
				end
			elseif x<cx and x>0 then
				for i=cx,x+1,-1 do
					moveR(i,y)
					moves=moves+1
				end
			end
		end
		if moves>0 then
			move=move+moves
			if state==0 then
				state=1
				startTime=Timer()
			end
			if checkBoard(b)then
				state=2
				time=Timer()-startTime
				if time<1 then		LOG.print("不是人",COLOR.lBlue)
				elseif time<2 then	LOG.print("还是人",COLOR.lBlue)
				elseif time<3 then	LOG.print("神仙",COLOR.lBlue)
				elseif time<5 then	LOG.print("太强了",COLOR.lBlue)
				elseif time<7.5 then LOG.print("很强",COLOR.lBlue)
				elseif time<10 then	LOG.print("可以的",COLOR.lBlue)
				elseif time<20 then	LOG.print("马上入门了",COLOR.lBlue)
				elseif time<30 then	LOG.print("入门不远了",COLOR.lBlue)
				elseif time<60 then	LOG.print("多加练习",COLOR.lBlue)
				else				LOG.print("第一次玩?加油",COLOR.lBlue)
				end
				SFX.play("win")
				return
			end
			SFX.play("move")
		end
	end
end
function scene.keyDown(key)
	if key=="up"then
		tapBoard(cx,cy-(revKB and 1 or -1),true)
	elseif key=="down"then
		tapBoard(cx,cy+(revKB and 1 or -1),true)
	elseif key=="left"then
		tapBoard(cx-(revKB and 1 or -1),cy,true)
	elseif key=="right"then
		tapBoard(cx+(revKB and 1 or -1),cy,true)
	elseif key=="space"then
		shuffleBoard()
		state=0
		time=0
		move=0
	elseif key=="q"then
		if state~=1 then
			color=(color+1)%5
		end
	elseif key=="w"then
		if state==0 then
			blind=not blind
		end
	elseif key=="e"then
		if state==0 then
			slide=not slide
			if not slide then
				pathVis=false
			end
		end
	elseif key=="r"then
		if state==0 and slide then
			pathVis=not pathVis
		end
	elseif key=="t"then
		if state==0 then
			revKB=not revKB
		end
	elseif key=="escape"then
		SCN.back()
	end
end
function scene.mouseDown(x,y)
	tapBoard(x,y)
end
function scene.mouseMove(x,y)
	if slide then
		tapBoard(x,y)
	end
end
function scene.touchDown(_,x,y)
	tapBoard(x,y)
end
function scene.touchMove(_,x,y)
	if slide then
		tapBoard(x,y)
	end
end

function scene.update()
	if state==1 then
		time=Timer()-startTime
	end
end

local frontColor={
	[0]={
		COLOR.lRed,COLOR.lRed,COLOR.lRed,COLOR.lRed,
		COLOR.lGreen,COLOR.lBlue,COLOR.lBlue,COLOR.lBlue,
		COLOR.lGreen,COLOR.lYellow,COLOR.lPurple,COLOR.lPurple,
		COLOR.lGreen,COLOR.lYellow,COLOR.lPurple,COLOR.lPurple,
	},--Colored(rank)
	{
		COLOR.lRed,COLOR.lRed,COLOR.lRed,COLOR.lRed,
		COLOR.lOrange,COLOR.lYellow,COLOR.lYellow,COLOR.lYellow,
		COLOR.lOrange,COLOR.lGreen,COLOR.lBlue,COLOR.lBlue,
		COLOR.lOrange,COLOR.lGreen,COLOR.lBlue,COLOR.lBlue,
	},--Rainbow(rank)
	{
		COLOR.lRed,COLOR.lRed,COLOR.lRed,COLOR.lRed,
		COLOR.lBlue,COLOR.lBlue,COLOR.lBlue,COLOR.lBlue,
		COLOR.lGreen,COLOR.lYellow,COLOR.lPurple,COLOR.lPurple,
		COLOR.lGreen,COLOR.lYellow,COLOR.lPurple,COLOR.lPurple,
	},--Colored(row)
	{
		COLOR.white,COLOR.white,COLOR.white,COLOR.white,
		COLOR.white,COLOR.white,COLOR.white,COLOR.white,
		COLOR.white,COLOR.white,COLOR.white,COLOR.white,
		COLOR.white,COLOR.white,COLOR.white,COLOR.white,
	},--Grey
	{
		COLOR.white,COLOR.white,COLOR.white,COLOR.white,
		COLOR.white,COLOR.white,COLOR.white,COLOR.white,
		COLOR.white,COLOR.white,COLOR.white,COLOR.white,
		COLOR.white,COLOR.white,COLOR.white,COLOR.white,
	},--Black
}
local backColor={
	[0]={
		COLOR.dRed,COLOR.dRed,COLOR.dRed,COLOR.dRed,
		COLOR.dGreen,COLOR.dBlue,COLOR.dBlue,COLOR.dBlue,
		COLOR.dGreen,COLOR.dYellow,COLOR.dPurple,COLOR.dPurple,
		COLOR.dGreen,COLOR.dYellow,COLOR.dPurple,COLOR.dPurple,
	},--Colored(rank)
	{
		COLOR.dRed,COLOR.dRed,COLOR.dRed,COLOR.dRed,
		COLOR.dOrange,COLOR.dYellow,COLOR.dYellow,COLOR.dYellow,
		COLOR.dOrange,COLOR.dGreen,COLOR.dBlue,COLOR.dBlue,
		COLOR.dOrange,COLOR.dGreen,COLOR.dBlue,COLOR.dBlue,
	},--Rainbow(rank)
	{
		COLOR.dRed,COLOR.dRed,COLOR.dRed,COLOR.dRed,
		COLOR.dBlue,COLOR.dBlue,COLOR.dBlue,COLOR.dBlue,
		COLOR.dGreen,COLOR.dYellow,COLOR.dPurple,COLOR.dPurple,
		COLOR.dGreen,COLOR.dYellow,COLOR.dPurple,COLOR.dPurple,
	},--Colored(row)
	{
		COLOR.dGrey,COLOR.dGrey,COLOR.dGrey,COLOR.dGrey,
		COLOR.dGrey,COLOR.dGrey,COLOR.dGrey,COLOR.dGrey,
		COLOR.dGrey,COLOR.dGrey,COLOR.dGrey,COLOR.dGrey,
		COLOR.dGrey,COLOR.dGrey,COLOR.dGrey,COLOR.dGrey,
	},--Grey
	{
		COLOR.black,COLOR.black,COLOR.black,COLOR.black,
		COLOR.black,COLOR.black,COLOR.black,COLOR.black,
		COLOR.black,COLOR.black,COLOR.black,COLOR.black,
		COLOR.black,COLOR.black,COLOR.black,COLOR.black,
	},--Black
}
function scene.draw()
	setFont(40)
	gc.setColor(1,1,1)
	gc.print(format("%.3f",time),1026,80)
	gc.print(move,1026,150)

	if state==2 then
		--Draw no-setting area
		gc.setColor(1,0,0,.3)
		gc.rectangle("fill",15,295,285,340)

		gc.setColor(.9,.9,0)--win
	elseif state==1 then
		gc.setColor(.9,.9,.9)--game
	elseif state==0 then
		gc.setColor(.2,.8,.2)--ready
	end
	gc.setLineWidth(10)
	gc.rectangle("line",313,33,654,654,18)

	gc.setLineWidth(4)
	local mono=blind and state==1
	setFont(80)
	for i=1,4 do
		for j=1,4 do
			if cx~=j or cy~=i then
				local N=board[i][j]

				local C=mono and 1 or color
				local back=backColor[C]
				local front=frontColor[C]

				gc.setColor(back[N])
				gc.rectangle("fill",j*160+163,i*160-117,154,154,8)
				gc.setColor(front[N])
				gc.rectangle("line",j*160+163,i*160-117,154,154,8)
				if not mono then
					gc.setColor(.1,.1,.1)
					mStr(N,j*160+240,i*160-96)
					mStr(N,j*160+242,i*160-98)
					gc.setColor(1,1,1)
					mStr(N,j*160+243,i*160-95)
				end
			end
		end
	end
	gc.setColor(0,0,0,.3)
	gc.setLineWidth(10)
	gc.rectangle("line",cx*160+173,cy*160-107,134,134,50)
end

local function Gaming()return state==1 end
scene.widgetList={
	WIDGET.newButton{name="reset",	x=160,y=100,w=180,h=100,color="lGreen",font=40,code=WIDGET.lnk_pressKey("space")},
	WIDGET.newSlider{name="color",	x=110,y=250,w=170,unit=4,show=false,font=30,disp=function()return color end,	code=function(v)if state~=1 then color=v end end,hide=Gaming},
	WIDGET.newSwitch{name="blind",	x=240,y=330,w=60,					font=40,disp=function()return blind end,	code=WIDGET.lnk_pressKey("w"),	hide=Gaming},
	WIDGET.newSwitch{name="slide",	x=240,y=420,w=60,					font=40,disp=function()return slide end,	code=WIDGET.lnk_pressKey("e"),	hide=Gaming},
	WIDGET.newSwitch{name="pathVis",x=240,y=510,w=60,					font=40,disp=function()return pathVis end,	code=WIDGET.lnk_pressKey("r"),	hide=function()return state==1 or not slide end},
	WIDGET.newSwitch{name="revKB",	x=240,y=600,w=60,					font=40,disp=function()return revKB end,	code=WIDGET.lnk_pressKey("t"),	hide=Gaming},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,			font=40,code=WIDGET.lnk_BACK},
}

return scene