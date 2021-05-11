local gc=love.graphics
local ins,rem=table.insert,table.remove



--System
function switchFullscreen()
	SETTING.fullscreen=not SETTING.fullscreen
	love.window.setFullscreen(SETTING.fullscreen)
	love.resize(love.graphics.getWidth(),love.graphics.getHeight())
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
			drawableText.modeName:set(text.modes[M][1].."   "..text.modes[M][2])
			SCN.go('game',ifQuickPlay and'swipeD'or'fade_togame')
			SFX.play('enter')
		end
	end
end
function gameOver()--Save record
	if GAME.replaying then return end
	FILE.save(STAT,'conf/data')
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
function initPlayerPosition(sudden)--Set initial position for every player
	local L=PLY_ALIVE
	if not sudden then
		for i=1,#L do
			L[i]:setPosition(640,#L<=5 and 360 or -62,0)
		end
	end

	local method=sudden and'setPosition'or'movePosition'
	L[1][method](L[1],340,75,1)
	if #L<=5 then
		if L[2]then L[2][method](L[2],965,390,.5)end
		if L[3]then L[3][method](L[3],965, 30,.5)end
		if L[4]then L[4][method](L[4], 20,390,.5)end
		if L[5]then L[5][method](L[5], 20, 30,.5)end
	elseif #L<=17 then
		for i=1,4 do if L[i+1]then	L[i+1][method](L[i+1],	15,	-160+180*i,.25)else return end end
		for i=1,4 do if L[i+5]then	L[i+5][method](L[i+5],	180,-160+180*i,.25)else return end end
		for i=1,4 do if L[i+9]then	L[i+9][method](L[i+9],	950,-160+180*i,.25)else return end end
		for i=1,4 do if L[i+13]then	L[i+13][method](L[i+13],1120,-160+180*i,.25)else return end end
	elseif #L<=31 then
		for i=1,5 do if L[i+1]then	L[i+1][method](L[i+1],	10,	-100+135*i,.18)else return end end
		for i=1,5 do if L[i+6]then	L[i+6][method](L[i+6],	120,-100+135*i,.18)else return end end
		for i=1,5 do if L[i+11]then	L[i+11][method](L[i+11],230,-100+135*i,.18)else return end end
		for i=1,5 do if L[i+16]then	L[i+16][method](L[i+16],940,-100+135*i,.18)else return end end
		for i=1,5 do if L[i+21]then	L[i+21][method](L[i+21],1050,-100+135*i,.18)else return end end
		for i=1,5 do if L[i+26]then	L[i+26][method](L[i+26],1160,-100+135*i,.18)else return end end
	elseif #L<=49 then
		local n=2
		for i=1,4 do for j=1,6 do
			if not L[n]then return end
			L[n][method](L[n],78*i-54,115*j-98,.09)
			n=n+1
		end end
		for i=9,12 do for j=1,6 do
			if not L[n]then return end
			L[n][method](L[n],78*i+267,115*j-98,.09)
			n=n+1
		end end
	elseif #L<=99 then
		local n=2
		for i=1,7 do for j=1,7 do
			if not L[n]then return end
			L[n][method](L[n],46*i-36,97*j-72,.068)
			n=n+1
		end end
		for i=15,21 do for j=1,7 do
			if not L[n]then return end
			L[n][method](L[n],46*i+264,97*j-72,.068)
			n=n+1
		end end
	else
		error("TOO MANY PLAYERS!")
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
		if PLAYERS[1]and not GAME.replaying and(PLAYERS[1].frameRun>400 or GAME.result)then
			mergeStat(STAT,PLAYERS[1].stat)
			STAT.todayTime=STAT.todayTime+PLAYERS[1].stat.time
		end

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
			GAME.replaying=false
			GAME.rank=0
			math.randomseed(TIME())
		end

		destroyPlayers()
		GAME.curMode.load()
		initPlayerPosition(args:find'q')
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
		STAT.game=STAT.game+1
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
			SFX.fplay("warning",SETTING.sfx_warn)
		end
	end
end



--Game draw
do--function drawFWM()
	local m={
		string.char(230,184,184,230,136,143,228,189,156,232,128,133,58,77,114,90,95,50,54,10,228,187,187,228,189,149,232,167,134,233,162,145,47,231,155,180,230,146,173,228,184,141,229,190,151,229,135,186,231,142,176,230,173,164,230,176,180,229,141,176,10,228,187,187,228,189,149,232,189,172,232,191,176,229,163,176,230,152,142,230,151,160,230,149,136),
		string.char(230,184,184,230,136,143,228,189,156,232,128,133,58,77,114,90,95,50,54,10,228,187,187,228,189,149,232,167,134,233,162,145,47,231,155,180,230,146,173,228,184,141,229,190,151,229,135,186,231,142,176,230,173,164,230,176,180,229,141,176,10,228,187,187,228,189,149,232,189,172,232,191,176,229,163,176,230,152,142,230,151,160,230,149,136),
		string.char(230,184,184,230,136,143,228,189,156,232,128,133,58,77,114,90,95,50,54,10,228,187,187,228,189,149,232,167,134,233,162,145,47,231,155,180,230,146,173,228,184,141,229,190,151,229,135,186,231,142,176,230,173,164,230,176,180,229,141,176,10,228,187,187,228,189,149,232,189,172,232,191,176,229,163,176,230,152,142,230,151,160,230,149,136),
		string.char(65,117,116,104,111,114,58,32,77,114,90,95,50,54,10,82,101,99,111,114,100,105,110,103,115,32,99,111,110,116,97,105,110,105,110,103,32,116,104,105,115,10,119,97,116,101,114,109,97,114,107,32,97,114,101,32,117,110,97,117,116,104,111,114,105,122,101,100),
		string.char(67,114,195,169,97,116,101,117,114,32,100,117,32,106,101,117,58,32,77,114,90,95,50,54,10,69,110,114,101,103,105,115,116,114,101,109,101,110,116,32,110,111,110,32,97,117,116,111,114,105,115,195,169,10,99,111,110,116,101,110,97,110,116,32,99,101,32,102,105,108,105,103,114,97,110,101),
		string.char(65,117,116,111,114,58,32,77,114,90,95,50,54,10,71,114,97,98,97,99,105,195,179,110,32,110,111,32,97,117,116,111,114,105,122,97,100,97,32,113,117,101,10,99,111,110,116,105,101,110,101,32,101,115,116,97,32,109,97,114,99,97,32,100,101,32,97,103,117,97),
		string.char(65,117,116,111,114,32,100,111,32,106,111,103,111,58,32,77,114,90,95,50,54,10,71,114,97,118,97,195,167,195,181,101,115,32,99,111,110,116,101,110,100,111,32,101,115,116,97,32,77,97,114,99,97,10,100,101,32,195,161,103,117,97,32,110,195,163,111,32,115,195,163,111,32,97,117,116,111,114,105,122,97,100,97,115),
		string.char(65,117,116,104,111,114,58,32,77,114,90,95,50,54,10,82,101,99,111,114,100,105,110,103,115,32,99,111,110,116,97,105,110,105,110,103,32,116,104,105,115,10,119,97,116,101,114,109,97,114,107,32,97,114,101,32,117,110,97,117,116,104,111,114,105,122,101,100),
	}
	--你竟然找到了这里!那么在动手之前读读下面这些吧。
	--【魔幻错别字躲关键字搜索警告，看得懂就行】
	--千万不要为了在网络公共场合发视屏或者直播需要而擅自删除这部分代码!
	--录制视屏上传到公共场合(包括但不限于任何视屏平台/论坛/好几十个人及以上的非方块社区/群等)很可能会对Techmino未来的发展有负面影响
	--如果被TTC发现，随时可能被他们用DMCA从法律层面强迫停止开发，到时候谁都没得玩。这是真的，已经有几个方块这么死了…
	--氵印限制还可以减少低质量视屏泛滥，也能减轻过多不是真的感兴趣路人玩家入坑可能带来的压力
	--想发视屏的话请先向作者申请，描述录制的大致内容，同意了才可以去关闭氵印
	--等Techmino发展到一定程度之后会解除这个限制
	--最后，别把藏在这里的东西截图/复制出去哦~
	--感谢您对Techmino的支持!!!
	local sin=math.sin
	local setFont,TIME,mStr=setFont,TIME,mStr
	function drawFWM()
		local t=TIME()
		setFont(25)
		gc.setColor(1,1,1,.2+.1*(sin(3*t)+sin(2.6*t)))
		mStr(m[_G["\83\69\84\84\73\78\71"]["\108\97\110\103"]or m[1]],240,60+26*sin(t))
	end
end
do--function drawSelfProfile()
	local name
	local textObject,scaleK,width,offY
	function drawSelfProfile()
		local selfAvatar=USERS.getAvatar(USER.uid)
		gc.push('transform')
		gc.translate(1280,0)

		--Draw avatar
		gc.setLineWidth(2)
		gc.setColor(.3,.3,.3,.8)gc.rectangle('fill',-300,0,300,80)
		gc.setColor(1,1,1)gc.rectangle('line',-300,0,300,80)
		gc.rectangle('line',-73,7,66,66,2)
		gc.draw(selfAvatar,-72,8,nil,.5)

		--Draw username
		if name~=USERS.getUsername(USER.uid)then
			name=USERS.getUsername(USER.uid)
			textObject=gc.newText(getFont(30),name)
			width=textObject:getWidth()
			scaleK=210/math.max(width,210)
			offY=textObject:getHeight()/2
		end
		gc.draw(textObject,-82,26,nil,scaleK,nil,width,offY)

		--Draw lv. & xp.
		gc.draw(TEXTURE.lvIcon[USER.lv],-295,50)
		gc.line(-270,55,-80,55,-80,70,-270,70)
		gc.rectangle('fill',-210,55,150*USER.xp/USER.lv/USER.lv,15)

		gc.pop()
	end
end
function drawOnlinePlayerCount()
	setFont(20)
	gc.setColor(1,1,1)
	gc.printf(("%s: %s/%s/%s"):format(text.onlinePlayerCount,NET.UserCount,NET.PlayCount,NET.StreamCount),0,80,1272,'right')
end
do--function drawWarning()
	local SETTING,GAME,shader_warning,SCR=SETTING,GAME,SHADER.warning,SCR
	function drawWarning()
		if SETTING.warn and GAME.warnLVL>0 then
			gc.push('transform')
			gc.origin()
			shader_warning:send("level",GAME.warnLVL)
			gc.setShader(shader_warning)
			gc.rectangle('fill',0,0,SCR.w,SCR.h)
			gc.setShader()
			gc.pop()
		end
	end
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
	local c,s=CUSTOMENV,SETTING
	function CUSval(k)return function()return c[k]end end
	function SETval(k)return function()return s[k]end end
	function CUSrev(k)return function()c[k]=not c[k]end end
	function SETrev(k)return function()s[k]=not s[k]end end
	function CUSsto(k)return function(i)c[k]=i end end
	function SETsto(k)return function(i)s[k]=i end end
end