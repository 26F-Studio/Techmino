local scene={
	cur="load",--Current scene
	swapping=false,--ifSwapping
	swap={
		tar=nil,	--Swapping target
		style=nil,	--Swapping target
		mid=nil,	--Loading point
		time=nil,	--Full swap time
		draw=nil,	--Swap draw
	},
	seq={"quit","slowFade"},--Back sequence
}
local sceneInit={
	quit=love.event.quit,
	load=function()
		loading=1--Loading mode
		loadnum=1--Loading counter
		loadprogress=0--Loading bar(0~1)
		loadTip=text.tips[math.random(#text.tips)]
	end,
	intro=function()
		count=0
		BGM("blank")
	end,
	main=function()
		curBG="none"
		BGM("blank")
		destroyPlayers()
		modeEnv={}
		if not players[1]then
			newDemoPlayer(1,900,35,1.1)
		end--create demo player
	end,
	music=function()
		if bgmPlaying then
			for i=1,#musicID do
				if musicID[i]==bgmPlaying then
					sel=i
					return
				end
			end
		else
			sel=1
		end
	end,
	mode=function()
		curBG="none"
		BGM("blank")
		destroyPlayers()
	end,
	custom=function()
		sel=sel or 1
		destroyPlayers()
		curBG=customRange.bg[customSel[12]]
		BGM(customRange.bgm[customSel[13]])
	end,
	draw=function()
		curBG="none"
		clearSureTime=0
		pen,sx,sy=1,1,1
	end,
	play=function()
		love.keyboard.setKeyRepeat(false)
		restartCount=0
		if needResetGameData then
			resetGameData()
			needResetGameData=nil
		else
			BGM(modeEnv.bgm)
		end
		curBG=modeEnv.bg
	end,
	pause=function()
		curBG=modeEnv.bg
	end,
	setting_game=function()
		curBG="none"
	end,
	setting_graphic=function()
		curBG="none"
	end,
	setting_sound=function()
		curBG="none"
	end,
	setting_key=function()
		curBoard=1
		keyboardSet=1
		joystickSet=1
		keyboardSetting=false
		joystickSetting=false
	end,
	setting_touch=function()
		curBG="game2"
		defaultSel=1
		sel=nil
		snapLevel=1
	end,
	setting_touchSwitch=function()
		curBG="matrix"
	end,
	help=function()
		curBG="none"
	end,
	history=function()
		updateLog=require"updateLog"
		curBG="lightGrey"
		sel=1
	end,
	quit=function()
		love.timer.sleep(.3)
		love.event.quit()
	end,
}
local swapDeck_data={
	{4,0,1,1},{6,0,15,1},{5,0,9,1},{6,0,6,1},
	{1,0,3,1},{3,0,12,1},{1,1,8,1},{2,1,4,2},
	{3,2,13,2},{4,1,12,2},{5,2,1,2},{7,1,11,2},
	{2,1,9,3},{3,0,6,3},{4,2,14,3},{1,0,4,4},
	{7,1,1,4},{6,0,2,4},{5,2,6,4},{6,0,14,5},
	{3,3,15,5},{4,0,7,6},{7,1,10,5},{5,0,2,6},
	{2,1,1,7},{1,0,4,6},{4,1,13,5},{1,1,6,7},
	{5,3,11,5},{3,2,11,7},{6,0,8,7},{4,2,12,8},
	{7,0,8,9},{1,0,2,8},{5,2,4,8},{6,0,15,8},
}--Block id [ZSLJTOI] ,dir,x,y
local gc=love.graphics
local swap={
	none={1,0,NULL},
	flash={8,1,function()gc.clear(1,1,1)end},
	fade={30,15,function(t)
		local t=t>15 and 2-t/15 or t/15
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,1280,720)
	end},
	slowFade={180,90,function(t)
		local t=t>90 and 2-t/90 or t/90
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,1280,720)
	end},
	deck={50,8,function(t)
		gc.setColor(1,1,1)
		if t>8 then
			local t=t<15 and 15 or t
			for i=1,51-t do
				local bn=swapDeck_data[i][1]
				local b=blocks[bn][swapDeck_data[i][2]]
				local cx,cy=swapDeck_data[i][3],swapDeck_data[i][4]
				for y=1,#b do for x=1,#b[1]do
					if b[y][x]then
						gc.draw(blockSkin[bn],80*(cx+x-2),80*(10-cy-y),nil,8/3)
					end
				end end
			end
		end
		if t<17 then
			gc.setColor(1,1,1,1-(t>8 and t-8 or 8-t)*.125)
			gc.rectangle("fill",0,0,1280,720)
		end
	end},
}--Scene swapping animations
local backFunc={
	load=love.event.quit,
	pause=function()
		love.keyboard.setKeyRepeat(true)
		updateStat()
		saveData()
		clearTask("play")
	end,
	setting_game=function()
		saveSetting()
	end,
}
function scene.init(s)
	if sceneInit[s]then sceneInit[s]()end
end
function scene.push(tar,style)
	if not scene.swapping then
		local m=#scene.seq
		scene.seq[m+1]=tar or scene.cur
		scene.seq[m+2]=style or"fade"
	end
end
function scene.pop()
	scene.seq={}
end
function scene.swapTo(tar,style)
	local S=scene.swap
	if not scene.swapping and tar~=scene.cur then
		scene.swapping=true
		if not style then style="fade"end
		S.tar=tar
		S.style=style
		S.time=swap[style][1]
		S.mid=swap[style][2]
		S.draw=swap[style][3]
		widget_sel=nil
		if style~="none"then SFX("swipe")end
	end
end
function scene.back()
	if not scene.swapping then
		if backFunc[scene.cur] then backFunc[scene.cur]()end
		--func when scene end
		local m=#scene.seq
		if m>0 then
			scene.swapTo(scene.seq[m-1],scene.seq[m])
			scene.seq[m],scene.seq[m-1]=nil
			--Poll&Back to preScene
		end
	end
end
return scene