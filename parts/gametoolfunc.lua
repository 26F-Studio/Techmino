local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_origin,gc_replaceTransform=gc.origin,gc.replaceTransform
local gc_setLineWidth,gc_setColor=gc.setLineWidth,gc.setColor
local gc_setShader=gc.setShader
local gc_draw,gc_rectangle,gc_line,gc_printf=gc.draw,gc.rectangle,gc.line,gc.printf

local ins,rem=table.insert,table.remove

local SETTING,GAME,SCR=SETTING,GAME,SCR



--System
function switchFullscreen()
	SETTING.fullscreen=not SETTING.fullscreen
	love.window.setFullscreen(SETTING.fullscreen)
	love.resize(gc.getWidth(),gc.getHeight())
end



--Royale mode
function randomTarget(P)--Return a random opponent for P
	local rnd=math.random
	if #PLY_ALIVE>1 then
		local R
		repeat
			R=PLY_ALIVE[rnd(#PLY_ALIVE)]
		until R~=P
		return R
	end
end
function freshMostDangerous()
	GAME.mostDangerous,GAME.secDangerous=false,false
	local m,m2=0,0
	for i=1,#PLY_ALIVE do
		local h=#PLY_ALIVE[i].field
		if h>=m then
			GAME.mostDangerous,GAME.secDangerous=PLY_ALIVE[i],GAME.mostDangerous
			m,m2=h,m
		elseif h>=m2 then
			GAME.secDangerous=PLY_ALIVE[i]
			m2=h
		end
	end

	for i=1,#PLY_ALIVE do
		if PLY_ALIVE[i].atkMode==3 then
			PLY_ALIVE[i]:freshTarget()
		end
	end
end
function freshMostBadge()
	GAME.mostBadge,GAME.secBadge=false,false
	local m,m2=0,0
	for i=1,#PLY_ALIVE do
		local P=PLY_ALIVE[i]
		local b=P.badge
		if b>=m then
			GAME.mostBadge,GAME.secBadge=P,GAME.mostBadge
			m,m2=b,m
		elseif b>=m2 then
			GAME.secBadge=P
			m2=b
		end
	end

	for i=1,#PLY_ALIVE do
		if PLY_ALIVE[i].atkMode==4 then
			PLY_ALIVE[i]:freshTarget()
		end
	end
end
function royaleLevelup()
	GAME.stage=GAME.stage+1
	local spd
	TEXT.show(text.royale_remain:gsub("$1",#PLY_ALIVE),640,200,40,'beat',.3)
	if GAME.stage==2 then
		spd=30
	elseif GAME.stage==3 then
		spd=15
		for _,P in next,PLY_ALIVE do
			P.gameEnv.garbageSpeed=.6
		end
		if PLAYERS[1].alive then BGM.play('cruelty')end
	elseif GAME.stage==4 then
		spd=10
		for _,P in next,PLY_ALIVE do
			P.gameEnv.pushSpeed=3
		end
	elseif GAME.stage==5 then
		spd=5
		for _,P in next,PLY_ALIVE do
			P.gameEnv.garbageSpeed=1
		end
	elseif GAME.stage==6 then
		spd=3
		if PLAYERS[1].alive then BGM.play('final')end
	end
	for _,P in next,PLY_ALIVE do
		P.gameEnv.drop=spd
	end
	if GAME.curMode.name:find("_u")then
		local int=math.floor
		for i=1,#PLY_ALIVE do
			local P=PLY_ALIVE[i]
			P.gameEnv.drop=int(P.gameEnv.drop*.3)
			if P.gameEnv.drop==0 then
				P.curY=P.ghoY
				P:set20G(true)
			end
		end
	end
end



--Game
function generateLine(hole)
	return 1023-2^(hole-1)
end
function freshDate(mode)
	if not mode then mode=""end
	local date=os.date("%Y/%m/%d")
	if STAT.date~=date then
		STAT.date=date
		STAT.todayTime=0
		if not mode:find'q'then
			LOG.print(text.newDay,'message')
		end
		return true
	end
end
function legalGameTime()--Check if today's playtime is legal
	if
		(SETTING.lang==1 or SETTING.lang==2 or SETTING.lang==7)and
		RANKS.sprint_10l<4 and
		(not RANKS.sprint_40l or RANKS.sprint_40l<3)
	then
		if STAT.todayTime<14400 then
			return true
		elseif STAT.todayTime<21600 then
			LOG.print(text.playedLong,'warn')
			return true
		else
			LOG.print(text.playedTooMuch,'warn')
			return false
		end
	end
	return true
end

function mergeStat(stat,delta)--Merge delta stat. to global stat.
	for k,v in next,delta do
		if type(v)=='table'then
			if type(stat[k])=='table'then
				mergeStat(stat[k],v)
			end
		else
			if stat[k]then
				stat[k]=stat[k]+v
			end
		end
	end
end
function scoreValid()--Check if any unranked mods are activated
	for _,M in next,GAME.mod do
		if M.unranked then
			return false
		end
	end
	return true
end
function destroyPlayers()--Destroy all player objects, restore freerows and free CCs
	for i=#PLAYERS,1,-1 do
		local P=PLAYERS[i]
		if P.canvas then P.canvas:release()end
		while P.field[1]do
			FREEROW.discard(rem(P.field))
			FREEROW.discard(rem(P.visTime))
		end
		if P.AI_mode=='CC'then
			CC.free(P.bot_opt)
			CC.free(P.bot_wei)
			CC.destroy(P.AI_bot)
			P.AI_mode=false
		end
		PLAYERS[i]=nil
	end
	TABLE.cut(PLY_ALIVE)
	collectgarbage()
end
function pauseGame()
	if not SCN.swapping then
		if not GAME.replaying then
			for i=1,#PLAYERS do
				local l=PLAYERS[i].keyPressing
				for j=1,#l do
					if l[j]then
						PLAYERS[i]:releaseKey(j)
					end
				end
			end
		end
		if not(GAME.result or GAME.replaying)then
			GAME.pauseCount=GAME.pauseCount+1
		end
		SCN.swapTo('pause','none')
	end
end
function applyCustomGame()--Apply CUSTOMENV, BAG, MISSION
	for k,v in next,CUSTOMENV do
		GAME.modeEnv[k]=v
	end
	if BAG[1]then
		GAME.modeEnv.seqData=BAG
	else
		GAME.modeEnv.seqData=nil
	end
	if MISSION[1]then
		GAME.modeEnv.mission=MISSION
	else
		GAME.modeEnv.mission=nil
	end
end
function loadGame(M,ifQuickPlay,ifNet)--Load a mode and go to game scene
	freshDate()
	if legalGameTime()then
		if MODES[M].score then STAT.lastPlay=M end
		GAME.curModeName=M
		GAME.curMode=MODES[M]
		GAME.modeEnv=GAME.curMode.env
		GAME.init=true
		GAME.net=ifNet
		if ifNet then
			SCN.go('net_game','swipeD')
		else
			drawableText.modeName:set((text.modes[M][1]or M).."   "..(text.modes[M][2]or""))
			SCN.go('game',ifQuickPlay and'swipeD'or'fade_togame')
			SFX.play('enter')
		end
	end
end
function gameOver()--Save record
	if GAME.replaying then return end
	trySave()

	local M=GAME.curMode
	local R=M.getRank
	if R then
		local P=PLAYERS[1]
		R=R(P)--New rank
		if R then
			if R>0 then
				GAME.rank=R
			end
			if scoreValid()and M.score then
				if RANKS[M.name]then--Old rank exist
					local needSave
					if R>RANKS[M.name]then
						RANKS[M.name]=R
						needSave=true
					end
					if R>0 then
						if M.unlock then
							for i=1,#M.unlock do
								local m=M.unlock[i]
								local n=MODES[m].name
								if not RANKS[n]then
									RANKS[n]=MODES[m].getRank and 0 or 6
									needSave=true
								end
							end
						end
					end
					if needSave then
						FILE.save(RANKS,'conf/unlock','q')
					end
				end
				local D=M.score(P)
				local L=M.records
				local p=#L--Rank-1
				if p>0 then
					while M.comp(D,L[p])do--If higher rank
						p=p-1
						if p==0 then break end
					end
				end
				if p<10 then
					if p==0 then
						P:showTextF(text.newRecord,0,-100,100,'beat',.5)
					end
					D.date=os.date("%Y/%m/%d %H:%M")
					ins(L,p+1,D)
					if L[11]then L[11]=nil end
					FILE.save(L,('record/%s.rec'):format(M.name),'lq')
				end
			end
		end
	end
end
function trySave()
	if not GAME.statSaved and PLAYERS[1]and(PLAYERS[1].frameRun>300 or GAME.result)then
		GAME.statSaved=true
		STAT.game=STAT.game+1
		mergeStat(STAT,PLAYERS[1].stat)
		STAT.todayTime=STAT.todayTime+PLAYERS[1].stat.time
		FILE.save(STAT,'conf/data')
	end
end
do--function freshPlayerPosition(sudden)
	local posLists={
		--1~5
		{
			{340,75,1},
			{965,390,.5},
			{965,30,.5},
			{20,390,.5},
			{20,30,.5},
		},
		--6~17
		(function()
			local L={{340,75,1}}
			for i=1,4 do ins(L,{15,-160+180*i,.25})end
			for i=1,4 do ins(L,{180,-160+180*i,.25})end
			for i=1,4 do ins(L,{950,-160+180*i,.25})end
			for i=1,4 do ins(L,{1120,-160+180*i,.25})end
			return L
		end)(),
		--18~31
		(function()
			local L={{340,75,1}}
			for i=1,5 do ins(L,{10,	-100+135*i,.18})end
			for i=1,5 do ins(L,{120,-100+135*i,.18})end
			for i=1,5 do ins(L,{230,-100+135*i,.18})end
			for i=1,5 do ins(L,{940,-100+135*i,.18})end
			for i=1,5 do ins(L,{1050,-100+135*i,.18})end
			for i=1,5 do ins(L,{1160,-100+135*i,.18})end
			return L
		end)(),
		--32~49
		(function()
			local L={{340,75,1}}
			for i=1,4 do for j=1,6 do ins(L,{78*i-54,115*j-98,.09})end end
			for i=9,12 do for j=1,6 do ins(L,{78*i+267,115*j-98,.09})end end
			return L
		end)(),
		--50~99
		(function()
			local L={{340,75,1}}
			for i=1,7 do for j=1,7 do ins(L,{46*i-36,97*j-72,.068})end end
			for i=15,21 do for j=1,7 do ins(L,{46*i+264,97*j-72,.068})end end
			return L
		end)(),
	}
	function freshPlayerPosition(sudden)--Set initial position for every player
		local L=PLY_ALIVE
		if not sudden then
			for i=1,#L do
				L[i]:setPosition(640,#L<=5 and 360 or -62,0)
			end
		end

		local posList
		if #L<=5 then posList=posLists[1]
		elseif #L<=17 then posList=posLists[2]
		elseif #L<=31 then posList=posLists[3]
		elseif #L<=49 then posList=posLists[4]
		elseif #L<=99 then posList=posLists[5]
		else error("TOO MANY PLAYERS!")
		end
		local method=sudden and'setPosition'or'movePosition'
		for i=1,#L do L[i][method](L[i],unpack(posList[i]))end
	end
end
do--function dumpBasicConfig()
	local gameSetting={
		--Tuning
		'das','arr','dascut','sddas','sdarr',
		'ihs','irs','ims','RS','swap',

		--System
		'skin','face',

		--Graphic
		'block','ghost','center','bagLine',
		'dropFX','moveFX','shakeFX',
		'text','highCam','nextPos',

		--Unnecessary graphic
		-- 'grid','smooth',
		-- 'lockFX','clearFX','splashFX','atkFX',
		-- 'score',
	}
	function dumpBasicConfig()
		local S={}
		for _,key in next,gameSetting do
			S[key]=SETTING[key]
		end
		return JSON.encode(S)
	end
end
do--function resetGameData(args)
	local function tick_showMods()
		local time=0
		while true do
			YIELD()
			time=time+1
			if time%20==0 then
				local M=GAME.mod[time/20]
				if M then
					TEXT.show(M.id,700+(time-20)%120*4,36,45,'spin',.5)
				else
					return
				end
			end
		end
	end
	local gameSetting={
		--Tuning
		'das','arr','dascut','sddas','sdarr',
		'ihs','irs','ims','RS','swap',

		--System
		'skin','face',

		--Graphic
		'block','ghost','center','smooth','grid','bagLine',
		'lockFX','dropFX','moveFX','clearFX','splashFX','shakeFX','atkFX',
		'text','score','warn','highCam','nextPos',
	}
	local function copyGameSetting()
		local S={}
		for _,key in next,gameSetting do
			if type(SETTING[key])=='table'then
				S[key]=TABLE.shift(SETTING[key])
			else
				S[key]=SETTING[key]
			end
		end
		return S
	end
	function resetGameData(args,seed)
		if not args then args=""end
		trySave()

		GAME.result=false
		GAME.warnLVL0=0
		GAME.warnLVL=0
		if args:find'r'then
			GAME.frameStart=0
			GAME.recording=false
			GAME.replaying=1
		else
			GAME.frameStart=args:find'n'and 0 or 150-SETTING.reTime*15
			GAME.seed=seed or math.random(1046101471,2662622626)
			GAME.pauseTime=0
			GAME.pauseCount=0
			GAME.saved=false
			GAME.setting=copyGameSetting()
			GAME.rep={}
			GAME.recording=true
			GAME.statSaved=false
			GAME.replaying=false
			GAME.rank=0
			math.randomseed(TIME())
		end

		destroyPlayers()
		GAME.curMode.load()
		freshPlayerPosition(args:find'q')
		VK.restore()
		if GAME.modeEnv.task then
			local task=GAME.modeEnv.task
			if type(task)=='function'then
				for i=1,#PLAYERS do
					PLAYERS[i]:newTask(task)
				end
			elseif type(task)=='table'then
				for i=1,#PLAYERS do
					for _,t in ipairs(task)do
						PLAYERS[i]:newTask(t)
					end
				end
			else
				LOG.print("Wrong task type",'warn')
			end
		end
		BG.set(GAME.modeEnv.bg)
		local bgm=GAME.modeEnv.bgm
		BGM.play(type(bgm)=='string'and bgm or type(bgm)=='table'and bgm[math.random(#bgm)])

		TEXT.clear()
		if GAME.modeEnv.royaleMode then
			for i=1,#PLAYERS do
				PLAYERS[i]:changeAtk(randomTarget(PLAYERS[i]))
			end
			GAME.stage=false
			GAME.mostBadge=false
			GAME.secBadge=false
			GAME.mostDangerous=false
			GAME.secDangerous=false
			GAME.stage=1
		end
		FREEROW.reset(30*#PLAYERS)
		TASK.removeTask_code(tick_showMods)
		if GAME.setting.allowMod then
			TASK.new(tick_showMods)
		end
		SFX.play('ready')
		collectgarbage()
	end
end
do--function checkWarning()
	local max=math.max
	function checkWarning()
		local P1=PLAYERS[1]
		if P1.alive then
			if P1.frameRun%26==0 then
				local F=P1.field
				local height=0--Max height of row 4~7
				for x=4,7 do
					for y=#F,1,-1 do
						if F[y][x]>0 then
							if y>height then
								height=y
							end
							break
						end
					end
				end
				GAME.warnLVL0=math.log(height-(P1.gameEnv.fieldH-5)+P1.atkBufferSum*.8)
			end
			local _=GAME.warnLVL
			if _<GAME.warnLVL0 then
				_=_*.95+GAME.warnLVL0*.05
			elseif _>0 then
				_=max(_-.026,0)
			end
			GAME.warnLVL=_
		elseif GAME.warnLVL>0 then
			GAME.warnLVL=max(GAME.warnLVL-.026,0)
		end
		if GAME.warnLVL>1.126 and P1.frameRun%30==0 then
			SFX.fplay('warning',SETTING.sfx_warn)
		end
	end
end



--Game draw
do--function drawSelfProfile()
	local lvIcon=setmetatable({},{__index=function(self,lv)
		local img={25,25}

		ins(img,{"clear",0,0,0})
		ins(img,{"setLW",4})
		ins(img,{"setCL",.5,.8,1})
		ins(img,{"dRect",2,2,21,21})
		--TODO: draw with lv

		img=DOGC(img)
		rawset(self,lv,img)
		return img
	end})
	local name
	local textObject,scaleK,width,offY
	function drawSelfProfile()
		local selfAvatar=USERS.getAvatar(USER.uid)
		gc_push('transform')
		gc_replaceTransform(SCR.xOy_ur)

		--Draw avatar
		gc_setLineWidth(2)
		gc_setColor(.3,.3,.3,.8)gc_rectangle('fill',-300,0,300,80)
		gc_setColor(1,1,1)gc_rectangle('line',-300,0,300,80)
		gc_rectangle('line',-73,7,66,66,2)
		gc_draw(selfAvatar,-72,8,nil,.5)

		--Draw username
		if name~=USERS.getUsername(USER.uid)then
			name=USERS.getUsername(USER.uid)
			textObject=gc.newText(getFont(30),name)
			width=textObject:getWidth()
			scaleK=210/math.max(width,210)
			offY=textObject:getHeight()/2
		end
		gc_draw(textObject,-82,26,nil,scaleK,nil,width,offY)

		--Draw lv. & xp.
		gc_draw(lvIcon[USER.lv],-295,50)
		gc_line(-270,55,-80,55,-80,70,-270,70)
		gc_rectangle('fill',-210,55,150*USER.xp/USER.lv/USER.lv,15)

		gc_pop()
	end
end
function drawOnlinePlayerCount()
	setFont(20)
	gc_setColor(1,1,1)
	gc_push('transform')
	gc_replaceTransform(SCR.xOy_ur)
	gc_printf(("%s: %s/%s/%s"):format(text.onlinePlayerCount,NET.UserCount,NET.PlayCount,NET.StreamCount),-600,80,594,'right')
	gc_pop()
end
do--function drawWarning()
	local shader_warning=SHADER.warning
	function drawWarning()
		if SETTING.warn and GAME.warnLVL>0 then
			gc_push('transform')
			gc_origin()
			shader_warning:send("level",GAME.warnLVL)
			gc_setShader(shader_warning)
			gc_rectangle('fill',0,0,SCR.w,SCR.h)
			gc_setShader()
			gc_pop()
		end
	end
end
do--function drawSystemInfo(
	--你竟然找到了這裏!那麽在動手之前讀讀下面這些吧。
	--千萬不要為了在網絡公共場合發視頻或者直播需要而擅自刪除這部分代碼!
	--錄製視頻上傳到公共場合(包括但不限於任何視頻平臺/論壇/好幾十個人及以上的非方塊社區/群等)很可能會對Techmino未來的發展有負面影響
	--如果被TTC發現，隨時可能被他們用DMCA從法律層面強迫停止開發，到時候誰都沒得玩。這是真的，已經有幾個方塊這麽死了…
	--氵印限製還可以減少低質量視頻泛濫，也能減輕過多不是真的感興趣路人玩家入坑可能帶來的壓力
	--想發視頻的話請先向作者申請，描述錄製的大致內容，同意了才可以去關閉氵印
	--等Techmino發展到一定程度之後會解除這個限製
	--最後，別把藏在這裏的東西截圖/復製出去哦~
	--感謝您對Techmino的支持!!!
	loadstring(love.data.decode('string','base64',"CWxvY2FsIGc9bG92ZS5ncmFwaGljcztsb2NhbCB4LHMsVCxkLGM9Zy5uZXdUZXh0KGdldEZvbnQoMjUpKSxtYXRoLnNpbixUSU1FLGcuZHJhdyxnLnNldENvbG9yO3g6c2V0ZigiQXV0aOS9nOiAhTpNclpfMjZcbkFscGhh5YaF5rWL56aB5q2i5b2V5bGPL+ebtOaSrVxuTm8gcmVjb3JkaW5nL3N0cmVhbWluZyIsMzAwLCdjZW50ZXInKWZ1bmN0aW9uIGRyYXdGV00oKWxvY2FsIHQ9VCgpYygxLDEsMSwuMTYrLjA2KihzKDMuNTUqdCkrcygyLjYqdCkpKWQoeCwzMCw3Mys1MypzKHQqLjI2KSllbmQK"))()
end



--Widget function shortcuts
function backScene()SCN.back()end
do--function goScene(name,style)
	local cache={}
	function goScene(name,style)
		local hash=style and name..style or name
		if not cache[hash]then
			cache[hash]=function()SCN.go(name,style)end
		end
		return cache[hash]
	end
end
do--function swapScene(name,style)
	local cache={}
	function swapScene(name,style)
		local hash=style and name..style or name
		if not cache[hash]then
			cache[hash]=function()SCN.swapTo(name,style)end
		end
		return cache[hash]
	end
end
do--function pressKey(k)
	local cache={}
	function pressKey(k)
		if not cache[k]then
			cache[k]=function()love.keypressed(k)end
		end
		return cache[k]
	end
end
do--CUS/SETXXX(k)
	local CUSTOMENV=CUSTOMENV
	function CUSval(k)return function()return CUSTOMENV[k]end end
	function ROOMval(k)return function()return ROOMENV[k]end end
	function SETval(k)return function()return SETTING[k]end end
	function CUSrev(k)return function()CUSTOMENV[k]=not CUSTOMENV[k]end end
	function ROOMrev(k)return function()ROOMENV[k]=not ROOMENV[k]end end
	function SETrev(k)return function()SETTING[k]=not SETTING[k]end end
	function CUSsto(k)return function(i)CUSTOMENV[k]=i end end
	function ROOMsto(k)return function(i)ROOMENV[k]=i end end
	function SETsto(k)return function(i)SETTING[k]=i end end
end