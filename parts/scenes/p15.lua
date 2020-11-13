local gc=love.graphics
local Timer=love.timer.getTime

local mStr=mStr

local int=math.floor
local rnd=math.random
local format=string.format

function sceneInit.p15()
	BG.set("rainbow")
	BGM.play("push")
	sceneTemp={
		board={{1,2,3,4},{5,6,7,8},{9,10,11,12},{13,14,15,16}},
		x=4,y=4,
		startTime=0,
		time=0,
		move=0,
		state=2,

		color=0,
		blind=false,
		slide=true,
		pathVis=true,
		revKB=false,
	}
end

local function moveU(S,b,x,y)
	if y<4 then
		b[y][x],b[y+1][x]=b[y+1][x],b[y][x]
		S.y=y+1
	end
end
local function moveD(S,b,x,y)
	if y>1 then
		b[y][x],b[y-1][x]=b[y-1][x],b[y][x]
		S.y=y-1
	end
end
local function moveL(S,b,x,y)
	if x<4 then
		b[y][x],b[y][x+1]=b[y][x+1],b[y][x]
		S.x=x+1
	end
end
local function moveR(S,b,x,y)
	if x>1 then
		b[y][x],b[y][x-1]=b[y][x-1],b[y][x]
		S.x=x-1
	end
end
local function shuffleBoard(S,b)
	for i=1,300 do
		i=rnd()
		if i<.25 then moveU(S,b,S.x,S.y)
		elseif i<.5 then moveD(S,b,S.x,S.y)
		elseif i<.75 then moveL(S,b,S.x,S.y)
		else moveR(S,b,S.x,S.y)
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
	local S=sceneTemp
	if S.state<2 then
		if not key then
			if S.pathVis then
				sysFX.newRipple(.16,x,y,10)
			end
			x,y=int((x-320)/160)+1,int((y-40)/160)+1
		end
		local b=S.board
		local moves=0
		if S.x==x then
			if y>S.y and y<5 then
				for i=S.y,y-1 do
					moveU(S,b,x,i)
					moves=moves+1
				end
			elseif y<S.y and y>0 then
				for i=S.y,y+1,-1 do
					moveD(S,b,x,i)
					moves=moves+1
				end
			end
		elseif S.y==y then
			if x>S.x and x<5 then
				for i=S.x,x-1 do
					moveL(S,b,i,y)
					moves=moves+1
				end
			elseif x<S.x and x>0 then
				for i=S.x,x+1,-1 do
					moveR(S,b,i,y)
					moves=moves+1
				end
			end
		end
		if moves>0 then
			S.move=S.move+moves
			if S.state==0 then
				S.state=1
				S.startTime=Timer()
			end
			if checkBoard(b)then
				S.state=2
				S.time=Timer()-S.startTime
				if S.time<1 then		LOG.print("不是人",COLOR.lBlue)
				elseif S.time<2 then	LOG.print("还是人",COLOR.lBlue)
				elseif S.time<3 then	LOG.print("神仙",COLOR.lBlue)
				elseif S.time<5 then	LOG.print("太强了",COLOR.lBlue)
				elseif S.time<7.5 then	LOG.print("很强",COLOR.lBlue)
				elseif S.time<10 then	LOG.print("可以的",COLOR.lBlue)
				elseif S.time<20 then	LOG.print("马上入门了",COLOR.lBlue)
				elseif S.time<30 then	LOG.print("入门不远了",COLOR.lBlue)
				elseif S.time<60 then	LOG.print("多加练习",COLOR.lBlue)
				else					LOG.print("第一次玩?加油",COLOR.lBlue)
				end
				SFX.play("win")
			end
			SFX.play("move")
		end
	end
end
function keyDown.p15(key)
	local S=sceneTemp
	local b=S.board
	if key=="up"then
		tapBoard(S.x,S.y-(S.revKB and 1 or -1),true)
	elseif key=="down"then
		tapBoard(S.x,S.y+(S.revKB and 1 or -1),true)
	elseif key=="left"then
		tapBoard(S.x-(S.revKB and 1 or -1),S.y,true)
	elseif key=="right"then
		tapBoard(S.x+(S.revKB and 1 or -1),S.y,true)
	elseif key=="space"then
		shuffleBoard(S,b)
		S.state=0
		S.time=0
		S.move=0
	elseif key=="q"then
		if S.state~=1 then
			S.color=(S.color+1)%5
		end
	elseif key=="w"then
		if S.state==0 then
			S.blind=not S.blind
		end
	elseif key=="e"then
		if S.state==0 then
			S.slide=not S.slide
			if not S.slide then
				S.pathVis=false
			end
		end
	elseif key=="r"then
		if S.state==0 and S.slide then
			S.pathVis=not S.pathVis
		end
	elseif key=="t"then
		if S.state==0 then
			S.revKB=not S.revKB
		end
	elseif key=="escape"then
		SCN.back()
	end
end
function mouseDown.p15(x,y)
	tapBoard(x,y)
end
function mouseMove.p15(x,y)
	if sceneTemp.slide then
		tapBoard(x,y)
	end
end
function touchDown.p15(_,x,y)
	tapBoard(x,y)
end
function touchMove.p15(_,x,y)
	if sceneTemp.slide then
		tapBoard(x,y)
	end
end

function Tmr.p15()
	local S=sceneTemp
	if S.state==1 then
		S.time=Timer()-S.startTime
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
function Pnt.p15()
	local S=sceneTemp

	setFont(40)
	gc.setColor(1,1,1)
	gc.print(format("%.3f",S.time),1026,80)
	gc.print(S.move,1026,150)

	if S.state==2 then
		--Draw no-setting area
		gc.setColor(1,0,0,.3)
		gc.rectangle("fill",15,295,285,340)

		gc.setColor(.9,.9,0)--win
	elseif S.state==1 then
		gc.setColor(.9,.9,.9)--game
	elseif S.state==0 then
		gc.setColor(.2,.8,.2)--ready
	end
	gc.setLineWidth(10)
	gc.rectangle("line",313,33,654,654,18)

	gc.setLineWidth(4)
	local x,y=S.x,S.y
	local blind=S.blind and S.state==1
	setFont(80)
	for i=1,4 do
		for j=1,4 do
			if x~=j or y~=i then
				local N=S.board[i][j]

				local C=blind and 1 or S.color
				local back=backColor[C]
				local front=frontColor[C]

				gc.setColor(back[N])
				gc.rectangle("fill",j*160+163,i*160-117,154,154,8)
				gc.setColor(front[N])
				gc.rectangle("line",j*160+163,i*160-117,154,154,8)
				if not blind then
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
	gc.rectangle("line",x*160+173,y*160-107,134,134,50)
end

WIDGET.init("p15",{
	WIDGET.newButton({name="reset",		x=160,y=100,w=180,h=100,color="lGreen",font=40,code=WIDGET.lnk_pressKey("space")}),
	WIDGET.newSlider({name="color",		x=110,y=250,w=170,unit=4,show=false,font=30,disp=WIDGET.lnk_STPval("color"),	code=function(v)if sceneTemp.state~=1 then sceneTemp.color=v end end,hide=WIDGET.lnk_STPeq("state",1)}),
	WIDGET.newSwitch({name="blind",		x=240,y=330,w=60,					font=40,disp=WIDGET.lnk_STPval("blind"),	code=WIDGET.lnk_pressKey("w"),	hide=WIDGET.lnk_STPeq("state",1)}),
	WIDGET.newSwitch({name="slide",		x=240,y=420,w=60,					font=40,disp=WIDGET.lnk_STPval("slide"),	code=WIDGET.lnk_pressKey("e"),	hide=WIDGET.lnk_STPeq("state",1)}),
	WIDGET.newSwitch({name="pathVis",	x=240,y=510,w=60,					font=40,disp=WIDGET.lnk_STPval("pathVis"),	code=WIDGET.lnk_pressKey("r"),	hide=function()return sceneTemp.state==1 or not sceneTemp.slide end}),
	WIDGET.newSwitch({name="revKB",		x=240,y=600,w=60,					font=40,disp=WIDGET.lnk_STPval("revKB"),	code=WIDGET.lnk_pressKey("t"),	hide=WIDGET.lnk_STPeq("state",1)}),
	WIDGET.newButton({name="back",		x=1140,y=640,w=170,h=80,			font=40,code=WIDGET.lnk_BACK}),
})