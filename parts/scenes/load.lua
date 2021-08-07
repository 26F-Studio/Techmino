local gc=love.graphics

local max,min,sin,cos=math.max,math.min,math.sin,math.cos
local rnd=math.random

local scene={}

local loading,progress,maxProgress
local t1,t2,animeType
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
	YIELD('loadVoice')VOC.loadAll()
	YIELD('loadFont')for i=1,17 do getFont(15+5*i)end

	YIELD('loadModeIcon')
	local modeIcons={}
	modeIcons.marathon=GC.DO{32,32,
		{'move',3,1},
		{'fRect',10,4,-2,23},
		{'fPoly',10,4,24,10,10,16.5},
		{'fRect',4,24,10,3},
	}
	modeIcons.infinite=GC.DO{64,64,
		{'setLW',4},
		{'dCirc',32,32,28},
		{'line',32,32,32,14},
		{'line',32,32,41,41},
		{'move',.5,.5},
		{'fRect',30,7,4,4},
		{'fRect',7,30,4,4},
		{'fRect',52,30,4,4},
		{'fRect',30,52,4,4},
	}
	modeIcons.classic=GC.DO{64,64,
		{'setLW',6},
		{'dRect',10,24,12,12},
		{'dRect',26,24,12,12},
		{'dRect',42,24,12,12},
		{'dRect',26,40,12,12},
	}
	modeIcons.tsd=GC.DO{64,64,
		{'fRect',7,7,16,16},
		{'fRect',7,41,16,16},
		{'fRect',41,41,16,16},
		{'move',.5,.5},
		{'setLW',1},
		{'dPoly',7,24,56,24,56,39,39,39,39,56,24,56,24,39,7,39},
	}
	modeIcons.t49=GC.DO{64,64,
		{'setLW',2},
		{'dRect',05,05,10,20},{'dRect',49,05,10,20},
		{'dRect',05,39,10,20},{'dRect',49,39,10,20},
		{'dRect',20,10,23,43},
		{'setCL',1,1,1,.7},
		{'fRect',20,10,23,43},
	}
	modeIcons.t99=GC.DO{64,64,
		{'setLW',2},
		{'dRect',02,02,6,12},{'dRect',11,02,6,12},
		{'dRect',02,18,6,12},{'dRect',11,18,6,12},
		{'dRect',02,34,6,12},{'dRect',11,34,6,12},
		{'dRect',02,50,6,12},{'dRect',11,50,6,12},
		{'dRect',47,02,6,12},{'dRect',56,02,6,12},
		{'dRect',47,18,6,12},{'dRect',56,18,6,12},
		{'dRect',47,34,6,12},{'dRect',56,34,6,12},
		{'dRect',47,50,6,12},{'dRect',56,50,6,12},
		{'dRect',20,10,23,43},
		{'setCL',1,1,1,.7},
		{'fRect',20,10,23,43},
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
	STAT.run=STAT.run+1

	--Connect to server
	NET.wsconn_app()

	SFX.play('enter',.8)
	SFX.play('welcome_sfx')
	VOC.play('welcome_voc')
	THEME.fresh()
	LOADED=true
	return'finish'
end)

function scene.sceneInit()
	studioLogo=gc.newText(getFont(90),"26F Studio")
	progress=0
	maxProgress=10
	t1,t2=0,0--Timer
	animeType={}for i=1,8 do animeType[i]=rnd(5)end--Random animation type
end
function scene.sceneBack()
	love.event.quit()
end

function scene.mouseDown()
	if LOADED then
		if FIRSTLAUNCH then
			SCN.push('main')
			SCN.swapTo('lang')
		else
			SCN.swapTo(SETTING.simpMode and'main_simple'or'main')
		end
	end
end
scene.touchDown=scene.mouseDown
function scene.keyDown(key)
	if key=="escape"then
		love.event.quit()
	else
		scene.mouseDown()
	end
end

function scene.update()
	if not LOADED then
		loading=loadingThread()or loading
		progress=progress+1
	else
		t1,t2=t1+1,t2+1
	end
end

local titleTransform={
	function(t)gc.translate(0,max(50-t,0)^2/25)end,
	function(t)gc.translate(0,-max(50-t,0)^2/25)end,
	function(t,i)local d=max(50-t,0)gc.translate(sin(TIME()*3+626*i)*d,cos(TIME()*3+626*i)*d)end,
	function(t,i)local d=max(50-t,0)gc.translate(sin(TIME()*3+626*i)*d,-cos(TIME()*3+626*i)*d)end,
	function(t)gc.setColor(1,1,1,min(t*.02,1)+rnd()*.2)end,
}
local titleColor={COLOR.lP,COLOR.lC,COLOR.lB,COLOR.lO,COLOR.lF,COLOR.lM,COLOR.lG,COLOR.lY}
function scene.draw()
	gc.clear(.08,.08,.084)

	local T=(t1+110)%300
	if T<30 then
		gc.setLineWidth(4+(30-T)^1.626/62)
	else
		gc.setLineWidth(4)
	end
	local L=title
	gc.push('transform')
	gc.translate(126,100)
	for i=1,8 do
		local t=t1-i*15
		if t>0 then
			gc.push('transform')
			titleTransform[animeType[i]](t,i)
			local dt=(t1+62-5*i)%300
			if dt<20 then
				gc.translate(0,math.abs(10-dt)-10)
			end
			gc.setColor(titleColor[i][1],titleColor[i][2],titleColor[i][3],min(t*.025,1)*.26)
			gc.polygon('fill',L[i])
			gc.setColor(1,1,1,min(t*.025,1))
			gc.polygon('line',L[i])
			gc.pop()
		end
	end
	gc.pop()

	gc.setColor(logoColor1[1],logoColor1[2],logoColor1[3],progress/maxProgress)mDraw(studioLogo,640,400)
	gc.setColor(logoColor2[1],logoColor2[2],logoColor2[3],progress/maxProgress)for dx=-2,2,2 do for dy=-2,2,2 do mDraw(studioLogo,640+dx,400+dy)end end
	gc.setColor(.2,.2,.2,progress/maxProgress)mDraw(studioLogo,640,400)

	gc.setColor(COLOR.Z)
	setFont(30)
	mStr(text.loadText[loading],640,530)
end

return scene