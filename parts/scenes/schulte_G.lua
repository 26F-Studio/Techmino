local gc=love.graphics
local ms=love.mouse
local Timer=love.timer.getTime

local setFont=setFont
local mStr=mStr

local int=math.floor
local rnd=math.random
local format=string.format
local rem=table.remove

function sceneInit.schulte_G()
	BGM.play("way")
	sceneTemp={
		board={},
		rank=3,
		blind=false,
		disappear=false,
		tapFX=true,

		startTime=0,
		time=0,
		error=0,
		state=0,
		progress=0,
	}
end

local function newBoard()
	local S=sceneTemp
	local L={}
	for i=1,S.rank^2 do
		L[i]=i
	end
	for i=1,S.rank^2 do
		S.board[i]=rem(L,rnd(#L))
	end
end
local function tapBoard(x,y)
	local S=sceneTemp
	local R=S.rank
	if x>320 and x<960 and y>40 and y<680 then
		if S.state==0 then
			newBoard()
			S.state=1
			S.startTime=Timer()
			S.progress=0
		elseif S.state==1 then
			local X=int((x-320)/640*R)
			local Y=int((y-40)/640*R)
			x=R*Y+X+1
			if S.board[x]==S.progress+1 then
				S.progress=S.progress+1
				if S.progress<R^2 then
					SFX.play("lock")
				else
					S.time=Timer()-S.startTime+S.error
					S.state=2
					SFX.play("reach")
				end
				if S.tapFX then
					sysFX.newShade(.3,.6,.8,1,320+640/R*X,40+640/R*Y,640/R,640/R)
				end
			else
				S.error=S.error+1
				if S.tapFX then
					sysFX.newShade(.5,1,.4,.5,320+640/R*X,40+640/R*Y,640/R,640/R)
				end
				SFX.play("finesseError")
			end
		end
	end
end

function mouseDown.schulte_G(x,y)
	tapBoard(x,y)
end
function touchDown.schulte_G(_,x,y)
	tapBoard(x,y)
end
function keyDown.schulte_G(key)
	local S=sceneTemp
	if key=="z"or key=="x"then
		love.mousepressed(ms.getPosition())
	elseif key=="space"then
		if sceneTemp.state>0 then
			S.board={}
			S.time=0
			S.error=0
			S.state=0
			S.progress=0
		end
	elseif key=="q"then
		if S.state==0 then
			S.blind=not S.blind
		end
	elseif key=="w"then
		if S.state==0 then
			S.disappear=not S.disappear
		end
	elseif key=="e"then
		if S.state==0 then
			S.tapFX=not S.tapFX
		end
	elseif key=="3"or key=="4"or key=="5"or key=="6"then
		if S.state==0 then
			S.rank=tonumber(key)
		end
	elseif key=="escape"then
		SCN.back()
	end
end

function Tmr.schulte_G()
	local S=sceneTemp
	if S.state==1 then
		S.time=Timer()-S.startTime+S.error
	end
end

function Pnt.schulte_G()
	local S=sceneTemp

	setFont(40)
	gc.setColor(1,1,1)
	gc.print(format("%.3f",S.time),1026,80)
	gc.print(S.error,1026,150)

	setFont(70)
	mStr(S.state==1 and S.progress or S.state==0 and"Ready"or S.state==2 and"Win",1130,300)

	if S.state==2 then
		--Draw no-setting area
		gc.setColor(1,0,0,.3)
		gc.rectangle("fill",15,295,285,250)

		gc.setColor(.9,.9,0)--win
	elseif S.state==1 then
		gc.setColor(.9,.9,.9)--game
	elseif S.state==0 then
		gc.setColor(.2,.8,.2)--ready
	end
	gc.setLineWidth(10)
	gc.rectangle("line",310,30,660,660)

	local rank=S.rank
	local width=640/rank
	local blind=S.state==0 or S.blind and S.state==1 and S.progress>0
	gc.setLineWidth(4)
	local f=180-rank*20
	setFont(f)
	for i=1,rank do
		for j=1,rank do
			local N=S.board[rank*(i-1)+j]
			if not(S.state==1 and S.disappear and N<=S.progress)then
				gc.setColor(.4,.5,.6)
				gc.rectangle("fill",320+(j-1)*width,(i-1)*width+40,width,width)
				gc.setColor(1,1,1)
				gc.rectangle("line",320+(j-1)*width,(i-1)*width+40,width,width)
				if not blind then
					local x,y=320+(j-.5)*width,40+(i-.5)*width-f*.67
					gc.setColor(.1,.1,.1)
					mStr(N,x-3,y-1)
					mStr(N,x-1,y-3)
					gc.setColor(1,1,1)
					mStr(N,x,y)
				end
			end
		end
	end
end

WIDGET.init("schulte_G",{
	WIDGET.newButton({name="reset",		x=160,y=100,w=180,h=100,color="lGreen",font=40,code=WIDGET.lnk_pressKey("space"),hide=function()return sceneTemp.state==0 end}),
	WIDGET.newSlider({name="rank",		x=130,y=250,w=150,unit=3,show=false,font=40,disp=function()return sceneTemp.rank-3 end,code=function(v)sceneTemp.rank=v+3 end,hide=function()return sceneTemp.state>0 end}),
	WIDGET.newSwitch({name="blind",		x=240,y=330,w=60,					font=40,disp=WIDGET.lnk_STPval("blind"),	code=WIDGET.lnk_pressKey("q"),hide=WIDGET.lnk_STPeq("state",1)}),
	WIDGET.newSwitch({name="disappear",	x=240,y=420,w=60,					font=40,disp=WIDGET.lnk_STPval("disappear"),code=WIDGET.lnk_pressKey("w"),hide=WIDGET.lnk_STPeq("state",1)}),
	WIDGET.newSwitch({name="tapFX",		x=240,y=510,w=60,					font=40,disp=WIDGET.lnk_STPval("tapFX"),	code=WIDGET.lnk_pressKey("e"),hide=WIDGET.lnk_STPeq("state",1)}),
	WIDGET.newButton({name="back",		x=1140,y=640,w=170,h=80,			font=40,code=WIDGET.lnk_BACK}),
})