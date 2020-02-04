local gc=love.graphics
local int,rnd=math.floor,math.random
local rem=table.remove
function randomTarget(p)
	if #players.alive>1 then
		local r
		::L::
			r=players.alive[rnd(#players.alive)]
		if r==p then goto L end
		return r
	end
end
function freshMostDangerous()
	mostDangerous,secDangerous=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local h=#players.alive[i].field
		if h>=m then
			mostDangerous,secDangerous=players.alive[i],mostDangerous
			m,m2=h,m
		elseif h>=m2 then
			secDangerous=players.alive[i]
			m2=h
		end
	end
end
function freshMostBadge()
	mostBadge,secBadge=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local h=players.alive[i].badge
		if h>=m then
			mostBadge,secBadge=players.alive[i],mostBadge
			m,m2=h,m
		elseif h>=m2 then
			secBadge=players.alive[i]
			m2=h
		end
	end
end
function royaleLevelup()
	gameStage=gameStage+1
	local spd
	if(gameStage==3 or gameStage>4)and players[1].alive then
		players[1]:showText(text.royale_remain(#players.alive),"beat",50,-100,.3)
	end
	if gameStage==2 then
		spd=30
	elseif gameStage==3 then
		spd=15
		garbageSpeed=.6
		if players[1].alive then BGM("cruelty")end
	elseif gameStage==4 then
		spd=10
		pushSpeed=3
	elseif gameStage==5 then
		spd=5
		garbageSpeed=1
	elseif gameStage==6 then
		spd=3
		if players[1].alive then BGM("final")end
	end
	for i=1,#players.alive do
		players.alive[i].gameEnv.drop=spd
	end
	if curMode.lv==3 then
		for i=1,#players.alive do
			local P=players.alive[i]
			P.gameEnv.drop=int(P.gameEnv.drop*.3)
			if P.gameEnv.drop==0 then
				P.curY=P.y_img
				P.gameEnv._20G=true
				if P.AI_mode=="CC"then CC_switch20G(P)end--little cheating,never mind
			end
		end
	end
end
function loadGame(mode,level)
	--rec={}
	curMode={id=modeID[mode],lv=level}
	drawableText.modeName:set(text.modeName[mode])
	drawableText.levelName:set(modeLevel[modeID[mode]][level])
	needResetGameData=true
	gotoScene("play","deck")
end
function resetPartGameData()
	frame=30
	destroyPlayers()
	loadmode[curMode.id]()
	if modeEnv.task then
		for i=1,#players do
			newTask(Event_task[modeEnv.task],players[i])
		end
	end
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
	end
	for i=1,#virtualkey do
		virtualkey[i].press=false
	end
	collectgarbage()
end
function resetGameData()
	gamefinished=false
	frame=0
	garbageSpeed=1
	pushSpeed=3
	pauseTime=0--Time paused
	pauseCount=0--Times paused
	destroyPlayers()
	local E=defaultModeEnv[curMode.id]
	modeEnv=E[curMode.lv]or E[1]
	loadmode[curMode.id]()--bg/bgm need redefine in custom,so up here
	if modeEnv.task then
		for i=1,#players do
			newTask(Event_task[modeEnv.task],players[i])
		end
	end
	curBG=modeEnv.bg
	BGM(modeEnv.bgm)

	FX_badge={}
	FX_attack={}
	for _,v in next,PTC.dust do
		v:release()
	end
	for i=1,#players do
		if not players[i].small then
			PTC.dust[i]=PTC.dust0:clone()
			PTC.dust[i]:start()
		end
	end
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
		mostBadge,mostDangerous,secBadge,secDangerous=nil
		gameStage=1
		garbageSpeed=.3
		pushSpeed=2
	end
	for i=1,#virtualkey do
		virtualkey[i].press=false
	end
	stat.game=stat.game+1
	local m,p=#freeRow,40*#players+1
	while freeRow[p]do
		m,freeRow[m]=m-1
	end
	freeRow.L=#freeRow
	SFX("ready")
	collectgarbage()
end
function gameStart()
	SFX("start")
	for P=1,#players do
		P=players[P]
		P:resetblock()
		P.timing=true
		P.control=true
	end
end