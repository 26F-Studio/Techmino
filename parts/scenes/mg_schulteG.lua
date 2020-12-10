local gc=love.graphics
local ms=love.mouse
local Timer=love.timer.getTime

local setFont=setFont
local mStr=mStr

local int=math.floor
local rnd=math.random
local format=string.format
local rem=table.remove

local scene={}

local board
local rank
local blind
local disappear
local tapFX
local startTime
local time
local mistake
local state
local progress
function scene.sceneInit()
	BGM.play("way")
	board={}
	rank=3
	blind=false
	disappear=false
	tapFX=true

	startTime=0
	time=0
	mistake=0
	state=0
	progress=0
end

local function newBoard()
	local L={}
	for i=1,rank^2 do
		L[i]=i
	end
	for i=1,rank^2 do
		board[i]=rem(L,rnd(#L))
	end
end
local function tapBoard(x,y)
	local R=rank
	if x>320 and x<960 and y>40 and y<680 then
		if state==0 then
			newBoard()
			state=1
			startTime=Timer()
			progress=0
		elseif state==1 then
			local X=int((x-320)/640*R)
			local Y=int((y-40)/640*R)
			x=R*Y+X+1
			if board[x]==progress+1 then
				progress=progress+1
				if progress<R^2 then
					SFX.play("lock")
				else
					time=Timer()-startTime+mistake
					state=2
					SFX.play("reach")
				end
				if tapFX then
					SYSFX.newShade(3,320+640/R*X,40+640/R*Y,640/R,640/R,.6,.8,1)
				end
			else
				mistake=mistake+1
				if tapFX then
					SYSFX.newShade(2,320+640/R*X,40+640/R*Y,640/R,640/R,1,.4,.5)
				end
				SFX.play("finesseError")
			end
		end
	end
end

function scene.mouseDown(x,y)
	tapBoard(x,y)
end
function scene.touchDown(_,x,y)
	tapBoard(x,y)
end
function scene.keyDown(key)
	if key=="z"or key=="x"then
		love.mousepressed(ms.getPosition())
	elseif key=="space"then
		if state>0 then
			board={}
			time=0
			mistake=0
			state=0
			progress=0
		end
	elseif key=="q"then
		if state==0 then
			blind=not blind
		end
	elseif key=="w"then
		if state==0 then
			disappear=not disappear
		end
	elseif key=="e"then
		if state==0 then
			tapFX=not tapFX
		end
	elseif key=="3"or key=="4"or key=="5"or key=="6"then
		if state==0 then
			rank=tonumber(key)
		end
	elseif key=="escape"then
		SCN.back()
	end
end

function scene.update()
	if state==1 then
		time=Timer()-startTime+mistake
	end
end

function scene.draw()
	setFont(40)
	gc.setColor(1,1,1)
	gc.print(format("%.3f",time),1026,80)
	gc.print(mistake,1026,150)

	setFont(70)
	mStr(state==1 and progress or state==0 and"Ready"or state==2 and"Win",1130,300)

	if state==2 then
		--Draw no-setting area
		gc.setColor(1,0,0,.3)
		gc.rectangle("fill",15,295,285,250)

		gc.setColor(.9,.9,0)--win
	elseif state==1 then
		gc.setColor(.9,.9,.9)--game
	elseif state==0 then
		gc.setColor(.2,.8,.2)--ready
	end
	gc.setLineWidth(10)
	gc.rectangle("line",310,30,660,660)

	local width=640/rank
	local mono=state==0 or blind and state==1 and progress>0
	gc.setLineWidth(4)
	local f=180-rank*20
	setFont(f)
	for i=1,rank do
		for j=1,rank do
			local N=board[rank*(i-1)+j]
			if not(state==1 and disappear and N<=progress)then
				gc.setColor(.4,.5,.6)
				gc.rectangle("fill",320+(j-1)*width,(i-1)*width+40,width,width)
				gc.setColor(1,1,1)
				gc.rectangle("line",320+(j-1)*width,(i-1)*width+40,width,width)
				if not mono then
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

scene.widgetList={
	WIDGET.newButton{name="reset",		x=160,y=100,w=180,h=100,color="lGreen",font=40,code=WIDGET.lnk_pressKey("space"),hide=function()return state==0 end},
	WIDGET.newSlider{name="rank",		x=130,y=250,w=150,unit=3,show=false,font=40,disp=function()return rank-3 end,code=function(v)rank=v+3 end,hide=function()return state>0 end},
	WIDGET.newSwitch{name="blind",		x=240,y=330,w=60,		font=40,disp=function()return blind end,	code=WIDGET.lnk_pressKey("q"),hide=function()return state==1 end},
	WIDGET.newSwitch{name="disappear",	x=240,y=420,w=60,		font=40,disp=function()return disappear end,code=WIDGET.lnk_pressKey("w"),hide=function()return state==1 end},
	WIDGET.newSwitch{name="tapFX",		x=240,y=510,w=60,		font=40,disp=function()return tapFX end,	code=WIDGET.lnk_pressKey("e"),hide=function()return state==1 end},
	WIDGET.newButton{name="back",		x=1140,y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene