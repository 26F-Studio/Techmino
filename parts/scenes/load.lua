local gc=love.graphics

local scene={}

local loading,progress,maxProgress,waitTime
local studioLogo--Studio logo text object
local logoColor1,logoColor2

local loadingThread=coroutine.wrap(function()
	DAILYLAUNCH=freshDate'q'
	if DAILYLAUNCH then
		logoColor1=COLOR.S
		logoColor2=COLOR.lS
	else
		local r=math.random()*6.2832
		logoColor1={COLOR.rainbow(r)}
		logoColor2={COLOR.rainbow_light(r)}
	end
	YIELD('loadSFX')SFX.loadAll()
	YIELD('loadBGM')BGM.loadAll()
	YIELD('loadImage')IMG.loadAll()
	YIELD('loadSkin')
	for i=1,SKIN.getCount()do
		SKIN.loadOne()
		if i%math.floor(SKIN.getCount()/9)==0 then YIELD()end
	end
	YIELD('loadVoice')VOC.loadAll()
	YIELD('loadFont')for i=1,17 do getFont(15+5*i)end

	YIELD('loadModeIcon')
	local modeIcons={}
	modeIcons.marathon=DOGC{32,32,
		{"move",3,1},
		{"fRect",10,4,-2,23},
		{"fPoly",10,4,24,10,10,16.5},
		{"fRect",4,24,10,3},
	}
	modeIcons.infinite=DOGC{64,64,
		{"setLW",4},
		{"dCirc",32,32,28},
		{"line",32,32,32,14},
		{"line",32,32,41,41},
		{"move",.5,.5},
		{"fRect",30,7,4,4},
		{"fRect",7,30,4,4},
		{"fRect",52,30,4,4},
		{"fRect",30,52,4,4},
	}
	modeIcons.classic=DOGC{64,64,
		{"setLW",6},
		{"dRect",10,24,12,12},
		{"dRect",26,24,12,12},
		{"dRect",42,24,12,12},
		{"dRect",26,40,12,12},
	}
	modeIcons.tsd=DOGC{64,64,
		{"fRect",7,7,16,16},
		{"fRect",7,41,16,16},
		{"fRect",41,41,16,16},
		{"move",.5,.5},
		{"setLW",1},
		{"dPoly",7,24,56,24,56,39,39,39,39,56,24,56,24,39,7,39},
	}
	modeIcons.t49=DOGC{64,64,
		{"setLW",2},
		{"dRect",05,05,10,20},{"dRect",49,05,10,20},
		{"dRect",05,39,10,20},{"dRect",49,39,10,20},
		{"dRect",20,10,23,43},
		{"setCL",1,1,1,.7},
		{"fRect",20,10,23,43},
	}
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
	}

	YIELD('loadMode')
	for _,M in next,MODES do
		M.records=FILE.load("record/"..M.name..".rec")or M.score and{}
		if M.icon then
			if not modeIcons[M.icon]then
				modeIcons[M.icon]=gc.newImage("media/image/modeicon/"..M.icon..".png")
			end
			M.icon=modeIcons[M.icon]
		end
	end
	if not MODES[STAT.lastPlay]then
		STAT.lastPlay='sprint_10l'
	end
	local editFlag
	for name,rank in next,RANKS do
		local M=MODES[name]
		if type(rank)~='number'then
			RANKS[name]=nil
			editFlag=true
		elseif M and M.unlock and rank>0 then
			for _,unlockName in next,M.unlock do
				if not RANKS[unlockName]then
					RANKS[unlockName]=0
					editFlag=true
				end
			end
		end
		if not(M and M.x)then
			RANKS[name]=nil
			editFlag=true
		end
	end
	if editFlag then
		FILE.save(RANKS,'conf/unlock')
	end

	YIELD('loadOther')
	SKIN.change(SETTING.skinSet)
	STAT.run=STAT.run+1

	--Connect to server
	NET.wsconn_app()

	SFX.play('emit',.6)
	SFX.play('enter',.8)
	SFX.play('welcome_sfx')
	VOC.play('welcome_voc')
	THEME.fresh()
	LOADED=true
	return'finish'
end)

function scene.sceneInit()
	studioLogo=gc.newText(getFont(90),"26F Studio")
	waitTime=0
	progress=0
	maxProgress=10
end
function scene.sceneBack()
	love.event.quit()
end

function scene.update(dt)
	if not LOADED then
		loading=loadingThread()or loading
		progress=progress+1
	else
		waitTime=waitTime+dt
		if waitTime>1 then
			SCN.swapTo('intro')
		end
	end
end

function scene.draw()
	gc.clear(.1,.1,.1)

	gc.setColor(1,1,1,progress/maxProgress)
	mDraw(TEXTURE.title,640,240,0,.9)
	gc.setColor(1,1,1,waitTime/.626)
	mDraw(TEXTURE.title_color,640,240,0,.9)

	gc.setColor(logoColor1[1],logoColor1[2],logoColor1[3],progress/maxProgress)mDraw(studioLogo,640,400)
	gc.setColor(logoColor2[1],logoColor2[2],logoColor2[3],progress/maxProgress)for dx=-2,2,2 do for dy=-2,2,2 do mDraw(studioLogo,640+dx,400+dy)end end
	gc.setColor(.2,.2,.2,progress/maxProgress)mDraw(studioLogo,640,400)

	gc.setColor(1,1,1)
	setFont(30)
	mStr(text.loadText[loading],640,530)
end

return scene