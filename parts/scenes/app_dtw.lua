local gc=love.graphics

local int,rnd=math.floor,math.random
local ins,rem=table.insert,table.remove

local targets={
	[40]=true,
	[100]=true,
	[200]=true,
	[400]=true,
	[620]=true,
	[1000]=true,
	[2600]=true,
}

local state,progress
local startTime,time
local keyTime
local speed,maxSpeed
local arcade,rollSpeed


local tileColor={
	{.0,.0,.0},
	{.3,.0,.0},
	{.0,.3,.0},
	{.0,.0,.3},
	{.3,.3,.0},
	{.0,.1,.3},
	{.2,.0,.3},
}
local modeName={
	"Normal",
	"Split",
	"Mess",
	"Short",
	"Stairs",
	"Double",
	"Mixed",
}
local mode=1
local score
local pos,height
local diePos

local function newTile()
	local r
	if mode==1 then
		r=rnd(4)
	elseif mode==2 then
		r=pos[#pos]<=2 and rnd(3,4)or rnd(2)
	elseif mode==3 then
		r=rnd(3)
		if r>=pos[#pos]then r=r+1 end
	elseif mode==4 then
		if pos[#pos]==pos[#pos-1]then
			r=rnd(3)
			if r>=pos[#pos]then r=r+1 end
		else
			r=rnd(4)
		end
	elseif mode==5 then
		r=pos[#pos]+(rnd(2)*2-3)
		if r<1 then
			r=r+2
		elseif r>4 then
			r=r-2
		end
	elseif mode==6 then
		local i=rnd(4)
		r=rnd(3)
		if r>=i then
			r=r+1
		end
		r=10*i+r
	elseif mode==7 then
		if rnd()<.126 then
			local i=rnd(4)
			r=rnd(3)
			if r>=i then
				r=r+1
			end
			r=10*i+r
		else
			r=rnd(4)
		end
	end
	ins(pos,r)
end
local function reset()
	keyTime={}for i=1,40 do keyTime[i]=-1e99 end
	speed,maxSpeed=0,0
	progress={}
	state,time=0,0
	score=0
	rollSpeed=6.26

	pos={rnd(4)}for _=1,6 do newTile()end
	height=0
	diePos=false
end

local scene={}

function scene.sceneInit()
	mode=1
	arcade=true
	reset()
	BG.set('gray')
	BGM.play('way')
end

local function touch(n)
	if state==0 then
		state=1
		startTime=TIME()
	end
	local a,b=pos[1]%10,int(pos[1]/10)
	if n==a or n==b then
		if a>0 and b>0 then
			pos[1]=n==a and b or a
			SFX.play('move')
		else
			rem(pos,1)
			newTile()
			ins(keyTime,1,TIME())
			keyTime[21]=nil
			score=score+1
			if not arcade and targets[score]then
				ins(progress,("%s - %.3fs"):format(score,TIME()-startTime))
				if score==2600 then
					for i=1,#pos do
						pos[i]=626
					end
					time=TIME()-startTime
					state=2
					SFX.play('win')
				else
					SFX.play('reach',.5)
				end
			end
			height=height+120
			SFX.play('move')
		end
	else
		time=TIME()-startTime
		state=2
		diePos=n
		SFX.play('clear_2')
	end
end
function scene.keyDown(key,isRep)
	if isRep then return end
	if key=="r"then reset()
	elseif key=="escape"then SCN.back()
	elseif state~=2 then
		if key=="d"or key=="c"then touch(1)
		elseif key=="f"or key=="v"then touch(2)
		elseif key=="j"or key=="n"then touch(3)
		elseif key=="k"or key=="m"then touch(4)
		elseif(key=="q"or key=="tab")and state==0 then
			mode=mode%#modeName+1
			reset()
		elseif key=="w"and state==0 then
			arcade=not arcade
		end
	end
end
function scene.mouseDown(x)
	scene.touchDown(x)
end
function scene.touchDown(x)
	if state==2 then return end
	x=int((x-300)/170+1)
	if x>=1 and x<=4 then
		touch(x)
	end
end

function scene.update()
	if state==1 then
		local t=TIME()
		time=t-startTime
		local v=0
		for i=2,20 do v=v+i*(i-1)*.3/(t-keyTime[i])end
		speed=speed*.99+v*.01
		if speed>maxSpeed then maxSpeed=speed end

		if arcade then
			height=height-rollSpeed
			rollSpeed=rollSpeed+.00355
			if height<-120 then
				state=2
				SFX.play('clear_2')
			end
		else
			height=height*.6
		end
	end
end

function scene.draw()
	--Draw mode
	gc.setColor(COLOR.Z)
	setFont(50)
	mStr(modeName[mode],155,380)

	if arcade then
		--Draw rolling speed
		mStr(("%.2f/s"):format(rollSpeed/2),155,490)
	else
		--Draw speed
		setFont(45)
		gc.setColor(1,.6,.6)
		mStr(("%.2f"):format(maxSpeed/60),155,460)
		gc.setColor(COLOR.Z)
		mStr(("%.2f"):format(speed/60),155,520)

		--Progress time list
		setFont(30)
		gc.setColor(.6,.6,.6)
		for i=1,#progress do
			gc.print(progress[i],1030,120+25*i)
		end

		--Draw time
		gc.setColor(COLOR.Z)
		setFont(45)
		gc.print(("%.3f"):format(time),1030,70)
	end

	--Draw tiles
	gc.rectangle('fill',300,0,680,720)
	gc.setColor(tileColor[mode])
	gc.push('transform')
	gc.translate(0,720-height+8)
	for i=1,#pos do
		if pos[i]<10 then
			gc.rectangle('fill',130+170*pos[i]+8,-i*120,170-16,120-16)
		else
			gc.rectangle('fill',130+170*(pos[i]%10)+8,-i*120,170-16,120-16)
			gc.rectangle('fill',130+170*int(pos[i]/10)+8,-i*120,170-16,120-16)
		end
	end
	gc.pop()

	--Draw track line
	gc.setColor(COLOR.D)
	gc.setLineWidth(2)
	for x=1,5 do
		x=130+170*x
		gc.line(x,0,x,720)
	end
	for y=0,6 do
		y=720-120*y-height%120
		gc.line(300,y,980,y)
	end

	--Draw red tile
	if diePos then
		gc.setColor(1,.2,.2)
		gc.rectangle('fill',130+170*diePos+8,600-height+8,170-16,120-16)
	end

	--Draw score
	setFont(100)
	gc.push('transform')
	gc.translate(640,26)
	gc.scale(1.6)
	gc.setColor(.5,.5,.5,.6)
	mStr(score,0,0)
	gc.pop()
end

scene.widgetList={
	WIDGET.newButton{name="reset",	x=155,y=100,w=180,h=100,color='lG',font=40,code=pressKey"r"},
	WIDGET.newButton{name="mode",	x=155,y=220,w=180,h=100,font=40,code=pressKey"q",hideF=function()return state~=0 end},
	WIDGET.newSwitch{name="arcade",	x=230,y=330,font=40,disp=function()return arcade end,code=pressKey"w",hideF=function()return state~=0 end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene