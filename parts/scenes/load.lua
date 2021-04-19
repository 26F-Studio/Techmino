local gc=love.graphics
local kb=love.keyboard

local int,sin=math.floor,math.sin

local scene={}

local blackTime,openTime
local shadePhase1,shadePhase2
local progress=0
local studioLogo--Studio logo text object
local logoColor1,logoColor2
local skip,locked,cmdLaunchKey

local light={}
for i=0,26 do
	table.insert(light,1050+60*int(i/9))
	table.insert(light,660-i%9*60)
	table.insert(light,false)
end
for _=1,3 do
	light[math.random(7,25)*3]=true
end
local function switchLight(i)
	light[3*i]=not light[3*i]
	if light[6*3]and light[26*3]then
		locked=false
		skip=0
	end
end

local function upFloor()
	progress=progress+1
	if light[3*progress+3]then
		light[3*progress+3]=false
		SFX.play("click",.3)
	end
end
local loadingThread=coroutine.wrap(function()
	for i=1,SFX.getCount()do
		SFX.loadOne()
		if i%3==0 then YIELD()end
	end

	upFloor()
	for i=1,BGM.getCount()do
		BGM.loadOne()
		if i%2==0 then YIELD()end
	end

	upFloor()
	for i=1,IMG.getCount()do
		IMG.loadOne()
		if i%2==0 then YIELD()end
	end

	upFloor()
	for i=1,SKIN.getCount()do
		SKIN.loadOne()
		if i%4==0 then YIELD()end
	end

	upFloor()
	for _=1,VOC.getCount()do
		VOC.loadOne()
		if _%5==0 then YIELD()end
	end

	upFloor()
	for i=1,17 do
		getFont(15+5*i)
		if i%2==0 then YIELD()end
	end

	upFloor()
	local modeIcons={}
	modeIcons.marathon=DOGC{32,32,
		{"trans",3,1},
		{"fRect",10,4,-2,23},
		{"fPoly",10,4,24,10,10,16.5},
		{"fRect",4,24,10,3},
	}YIELD()
	modeIcons.infinite=DOGC{64,64,
		{"setLW",4},
		{"dCirc",32,32,28},
		{"dLine",32,32,32,14},
		{"dLine",32,32,41,41},
		{"trans",.5,.5},
		{"fRect",30,7,4,4},
		{"fRect",7,30,4,4},
		{"fRect",52,30,4,4},
		{"fRect",30,52,4,4},
	}YIELD()
	modeIcons.classic=DOGC{64,64,
		{"setLW",6},
		{"dRect",10,24,12,12},
		{"dRect",26,24,12,12},
		{"dRect",42,24,12,12},
		{"dRect",26,40,12,12},
	}YIELD()
	modeIcons.tsd=DOGC{64,64,
		{"fRect",7,7,16,16},
		{"fRect",7,41,16,16},
		{"fRect",41,41,16,16},
		{"trans",.5,.5},
		{"setLW",1},
		{"dPoly",7,24,56,24,56,39,39,39,39,56,24,56,24,39,7,39},
	}YIELD()
	modeIcons.t49=DOGC{64,64,
		{"setLW",2},
		{"dRect",05,05,10,20},{"dRect",49,05,10,20},
		{"dRect",05,39,10,20},{"dRect",49,39,10,20},
		{"dRect",20,10,23,43},
		{"setCL",1,1,1,.7},
		{"fRect",20,10,23,43},
	}YIELD()
	modeIcons.t99=DOGC{64,64,
		{"setLW",2},
		{"dRect",02,02,6,12},{"dRect",11,02,6,12},
		{"dRect",02,18,6,12},{"dRect",11,18,6,12},
		{"dRect",02,34,6,12},{"dRect",11,34,6,12},
		{"dRect",02,50,6,12},{"dRect",11,50,6,12},
		{"dRect",47,02,6,12},{"dRect",56,02,6,12},
		{"dRect",47,18,6,12},{"dRect",56,18,6,12},
		{"dRect",47,34,6,12},{"dRect",56,34,6,12},
		{"dRect",47,50,6,12},{"dRect",56,50,6,12},
		{"dRect",20,10,23,43},
		{"setCL",1,1,1,.7},
		{"fRect",20,10,23,43},
	}YIELD()

	upFloor()
	for i=1,#MODES do
		local m=MODES[i]--Mode template
		local M=require("parts.modes."..m.name)--Mode file
		MODES[m.name],MODES[i]=M
		for k,v in next,m do
			M[k]=v
		end
		M.records=FILE.load("record/"..m.name..".rec")or M.score and{}
		if m.icon then
			if not modeIcons[m.icon]then
				modeIcons[m.icon]=gc.newImage("media/image/modeicon/"..m.icon..".png")
			end
			M.icon=modeIcons[m.icon]
		end
		if i%5==0 then YIELD()end
	end

	upFloor()
	if not MODES[STAT.lastPlay]then
		STAT.lastPlay="sprint_10l"
	end

	upFloor()
	SKIN.change(SETTING.skinSet)
	if newVersionLaunch then--Delete old ranks & Unlock modes which should be locked
		for name,rank in next,RANKS do
			local M=MODES[name]
			if type(rank)~="number"then
				RANKS[name]=nil
			elseif M and M.unlock and rank>0 then
				for _,unlockName in next,M.unlock do
					if not RANKS[unlockName]then
						RANKS[unlockName]=0
					end
				end
			end
			if not(M and M.score)then
				RANKS[name]=nil
			end
		end
		FILE.save(RANKS,"conf/unlock","q")
	end

	DAILYLAUNCH=freshDate("q")
	if DAILYLAUNCH then
		logoColor1=COLOR.sea
		logoColor2=COLOR.lSea
	else
		local r=math.random()*6.2832
		logoColor1={COLOR.rainbow(r)}
		logoColor2={COLOR.rainbow_light(r)}
	end
	STAT.run=STAT.run+1

	--Connect to server
	TASK.new(NET.updateWS_app)
	TASK.new(NET.updateWS_user)
	TASK.new(NET.updateWS_play)
	NET.wsconn_app()

	while true do
		if math.random()<.126 then
			upFloor()
		end
		if progress==25 then
			SFX.play("welcome_sfx")
			VOC.play("welcome_voc")
			THEME.fresh()
			LOADED=true
			return
		end
		YIELD()
	end
end)

function scene.sceneInit()
	studioLogo=gc.newText(getFont(80),"26F Studio")
	blackTime=1
	openTime=0
	shadePhase1=6.26*math.random()
	shadePhase2=6.26*math.random()
	skip=0--Skip time
	locked=SETTING.appLock
	cmdLaunchKey=0
	if not locked then light[6*3],light[26*3]=true,true end
	kb.setKeyRepeat(false)
end
function scene.sceneBack()
	love.event.quit()
end

function scene.keyDown(key)
	if key=="escape"then
		SCN.back()
	elseif key=="s"then
		skip=999
	elseif key=="r"then
		cmdLaunchKey=cmdLaunchKey+1
	elseif locked and #key==1 and key:byte()>=97 and key:byte()<=122 then
		switchLight(key:byte()-96)
	else
		skip=skip+1
	end
end
function scene.mouseDown(x,y)
	if locked then
		for i=1,27 do
			if(x-light[3*i-2])^2+(y-light[3*i-1])^2<=626 then
				switchLight(i)
				return
			end
		end
	end
	scene.keyDown("mouse")
end
scene.touchDown=scene.mouseDown

function scene.update(dt)
	shadePhase1=shadePhase1+dt*2*(3.26-openTime)
	shadePhase2=shadePhase2+dt*3*(3.26-openTime)
	if blackTime>0 then
		blackTime=blackTime-dt
	end
	if not locked then
		if progress<25 then
			local p=progress
			repeat
				loadingThread()
			until LOADED or skip<=0 or progress~=p
			if skip>0 then skip=skip-1 end
		else
			openTime=openTime+dt
			if skip>0 then
				openTime=openTime+.26
				skip=skip-1
			end
			if openTime>=3.26 and not SCN.swapping then
				if cmdLaunchKey==2 then
					SCN.push("intro")
					SCN.swapTo("app_cmd")
				else
					SCN.swapTo("intro")
				end
				love.keyboard.setKeyRepeat(true)
			end
		end
	end
end

local function doorStencil()
	local dx=300*(1-math.min(openTime/1.26-1,0)^2)
	gc.rectangle("fill",640-dx,0,2*dx,720)
end
function scene.draw()
	--Wall
	gc.clear(.5,.5,.5)

	gc.push("transform")
	if openTime>2.26 then
		gc.translate(640,360)
		gc.scale(1+(openTime-2.26)^1.8)
		gc.translate(-640,-360)
	end

	--Logo
	if progress==25 then
		--Outside background
		gc.setColor(.15,.15,.15)
		gc.rectangle("fill",340,0,600,720)

		gc.stencil(doorStencil,"replace",1)
		gc.setStencilTest("equal",1)
		gc.push("transform")

		--Cool camera
		gc.translate(640,360)
		gc.rotate(.2/openTime)
		gc.scale(1.2+.5/openTime)

		--Logo layer 1
		gc.setColor(logoColor1)
		mDraw(studioLogo,0,(5+(3.26-openTime))*sin(shadePhase1))
		mDraw(studioLogo,(7+(3.26-openTime))*sin(shadePhase2),0)

		--Logo layer 2
		gc.setColor(logoColor2)
		mDraw(studioLogo,-2,2)
		mDraw(studioLogo,-2,-2)
		mDraw(studioLogo,2,2)
		mDraw(studioLogo,2,-2)

		--Logo layer 3
		gc.setColor(.2,.2,.2)
		mDraw(studioLogo,0,0)
		gc.pop()

		--Cool light
		if openTime>.3 and openTime<1.6 then
			local w=(1.6-openTime)/1.3
			gc.setColor(1,1,1,w^2)
			gc.rectangle("fill",340,360*w^2,600,720*(1-w^2))
		end
		gc.setStencilTest()
	end

	--Floor info frame
	gc.setColor(.1,.1,.1)
	gc.rectangle("fill",1020,25,180,100)
	gc.setColor(.7,.7,.7)
	gc.setLineWidth(4)
	gc.rectangle("line",1020,25,180,100)

	--Floor info
	if progress>=0 then
		local d1=(progress+1)%10
		local d2=int((progress+1)/10)
		gc.setColor(.6,.6,.6)
		gc.draw(TEXTURE.pixelNum[d2],1040,40-3,nil,8)
		gc.draw(TEXTURE.pixelNum[d1],1100,40-3,nil,8)
		gc.setColor(1,1,1)
		gc.draw(TEXTURE.pixelNum[d2],1040,40,nil,8)
		gc.draw(TEXTURE.pixelNum[d1],1100,40,nil,8)
		if not locked and progress~=25 then
			setFont(40)
			gc.setColor(1,.9,.8)
			gc.print("↑",1150,26)
		end
	end

	--Elevator buttons
	gc.setLineWidth(3)
	setFont(25)
	for i=0,26 do
		local x,y=light[3*i+1],light[3*i+2]
		gc.setColor(COLOR[i==progress and"gray"or light[3*i+3]and"dOrange"or"dGray"])
		gc.circle("fill",x,y,23)
		gc.setColor(.16,.16,.16)
		gc.circle("line",x,y,23)
		gc.setColor(1,1,1)
		mStr(i+1,x,y-18)
	end

	--Elevator door
	for i=1,0,-1 do
		gc.setColor(.3,.3,.3)
		local dx=300*(1-math.min(math.max(openTime-i*.1,0)/1.26-1,0)^2)
		gc.rectangle("fill",340,0,300-dx,720)
		gc.rectangle("fill",940,0,dx-300,720)

		gc.setColor(.16,.16,.16)
		gc.setLineWidth(4)
		gc.line(640-dx,0,640-dx,720)
		gc.line(640+dx,0,640+dx,720)
	end

	--Doorframe
	gc.setColor(0,0,0)
	gc.rectangle("line",340,0,600,720)

	--Black screen
	if blackTime>0 or openTime>3 then
		gc.push("transform")
		gc.origin()
		gc.setColor(0,0,0,blackTime+(openTime-3)*4)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
		gc.pop()
	end
	gc.pop()
end

return scene