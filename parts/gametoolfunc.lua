local data=love.data

local gc=love.graphics
local gc_setColor,gc_setLineWidth,gc_setShader=gc.setColor,gc.setLineWidth,gc.setShader
local gc_push,gc_pop,gc_origin=gc.push,gc.pop,gc.origin
local gc_draw,gc_rectangle,gc_circle=gc.draw,gc.rectangle,gc.circle
local max,int,rnd=math.max,math.floor,math.random
local sin=math.sin
local sub=string.sub
local char,byte=string.char,string.byte
local ins,rem=table.insert,table.remove
local YIELD=YIELD



--System
function switchFullscreen()
	SETTING.fullscreen=not SETTING.fullscreen
	love.window.setFullscreen(SETTING.fullscreen)
	love.resize(love.graphics.getWidth(),love.graphics.getHeight())
end



--Encoding Functions
--Sep symbol: 33 (!)
--Safe char: 34~126
--[[
	Count: 34~96
	Block: 97~125
	Encode: A[B] sequence, A = block ID, B = repeat times, no B means do not repeat.
	Example: "abcdefg" is [SZJLTOI], "a^aDb)" is [Z*63,Z*37,S*10]
]]
function copySequence()
	local BAG=BAG
	local str=""

	local count=1
	for i=1,#BAG+1 do
		if BAG[i+1]~=BAG[i]or count==64 then
			str=str..char(96+BAG[i])
			if count>1 then
				str=str..char(32+count)
				count=1
			end
		else
			count=count+1
		end
	end

	return str
end
function pasteSequence(str)
	local b

	local bag={}
	local reg
	for i=1,#str do
		b=byte(str,i)
		if not reg then
			if b>=97 and b<=125 then
				reg=b-96
			else
				return
			end
		else
			if b>=97 and b<=125 then
				ins(bag,reg)
				reg=b-96
			elseif b>=34 and b<=96 then
				for _=1,b-32 do
					ins(bag,reg)
				end
				reg=false
			end
		end
	end
	if reg then
		ins(bag,reg)
	end

	BAG=bag
	return true
end

function newBoard(f)--Generate a new board
	if f then
		return TABLE.shift(f)
	else
		local F={}
		for i=1,20 do F[i]={0,0,0,0,0,0,0,0,0,0}end
		return F
	end
end
function copyBoard(page)--Copy the [page] board
	local F=FIELD[page or 1]
	local str=""
	local H=0

	for y=20,1,-1 do
		for x=1,10 do
			if F[y][x]~=0 then
				H=y
				goto BREAK_topFound
			end
		end
	end
	::BREAK_topFound::

	--Encode field
	for y=1,H do
		local S=""
		local L=F[y]
		for x=1,10 do
			S=S..char(L[x]+1)
		end
		str=str..S
	end
	return data.encode("string","base64",data.compress("string","zlib",str))
end
function copyBoards()
	local out={}
	for i=1,#FIELD do
		out[i]=copyBoard(i)
	end
	return table.concat(out,"!")
end
function pasteBoard(str,page)--Paste [str] data to [page] board
	if not page then page=1 end
	if not FIELD[page]then FIELD[page]=newBoard()end
	local F=FIELD[page]
	local _,__

	--Decode
	_,str=pcall(data.decode,"string","base64",str)
	if not _ then return end
	_,str=pcall(data.decompress,"string","zlib",str)
	if not _ then return end

	local fX,fY=1,1--*ptr for Field(r*10+(c-1))
	local p=1
	while true do
		_=byte(str,p)--1byte

		--Str end
		if not _ then
			if fX~=1 then
				return
			else
				break
			end
		end

		__=_%32-1--Block id
		if __>26 then return end--Illegal blockid
		_=int(_/32)--Mode id

		F[fY][fX]=__
		if fX<10 then
			fX=fX+1
		else
			fY=fY+1
			if fY>20 then break end
			fX=1
		end
		p=p+1
	end

	for y=fY,20 do
		for x=1,10 do
			F[y][x]=0
		end
	end

	return true
end

--[[
	Mission: 34~114
	Count: 115~126
	Encode: [A] or [AB] sequence, A = mission ID, B = repeat times, no B means do not repeat.

	_1=01,_2=02,_3=03,_4=04,
	A1=05,A2=06,A3=07,A4=08,
	PC=09,
	Z1=11,Z2=12,Z3=13,
	S1=21,S2=22,S3=23,
	J1=31,J2=32,J3=33,
	L1=41,L2=42,L3=43,
	T1=51,T2=52,T3=53,
	O1=61,O2=62,O3=63,O4=64,
	I1=71,I2=72,I3=73,I4=74,
]]
function copyMission()
	local _
	local MISSION=MISSION
	local str=""

	local count=1
	for i=1,#MISSION+1 do
		if MISSION[i+1]~=MISSION[i]or count==13 then
			_=33+MISSION[i]
			str=str..char(_)
			if count>1 then
				str=str..char(113+count)
				count=1
			end
		else
			count=count+1
		end
	end

	return str
end
function pasteMission(str)
	local b
	local mission={}
	local reg
	for i=1,#str do
		b=byte(str,i)
		if not reg then
			if b>=34 and b<=114 then
				reg=b-33
			else
				return
			end
		else
			if b>=34 and b<=114 then
				if missionEnum[reg]then
					ins(mission,reg)
					reg=b-33
				else
					return
				end
			elseif b>=115 and b<=126 then
				for _=1,b-113 do
					ins(mission,reg)
				end
				reg=false
			end
		end
	end
	if reg then
		ins(mission,reg)
	end

	MISSION=mission
	return true
end

function copyQuestArgs()
	local ENV=CUSTOMENV
	local str=""..
		ENV.holdCount..
		(ENV.ospin and"O"or"Z")..
		(ENV.missionKill and"M"or"Z")..
		ENV.sequence
	return str
end
function pasteQuestArgs(str)
	if #str<4 then return end
	local ENV=CUSTOMENV
	ENV.holdCount=		byte(str,1)-48
	ENV.ospin=			byte(str,2)~=90
	ENV.missionKill=	byte(str,3)~=90
	ENV.sequence=		sub(str,4)
	return true
end



--Royale mode
function randomTarget(P)--Return a random opponent for P
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
	TEXT.show(text.royale_remain:gsub("$1",#PLY_ALIVE),640,200,40,"beat",.3)
	if GAME.stage==2 then
		spd=30
	elseif GAME.stage==3 then
		spd=15
		for _,P in next,PLY_ALIVE do
			P.gameEnv.garbageSpeed=.6
		end
		if PLAYERS[1].alive then BGM.play("cruelty")end
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
		if PLAYERS[1].alive then BGM.play("final")end
	end
	for _,P in next,PLY_ALIVE do
		P.gameEnv.drop=spd
	end
	if GAME.curMode.name:find("_u")then
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



--Virtualkey
local VK=virtualkey
function drawVirtualkeys()
	if SETTING.VKSwitch then
		local a=SETTING.VKAlpha
		local _
		if SETTING.VKIcon then
			local icons=TEXTURE.VKIcon
			for i=1,#VK do
				if VK[i].ava then
					local B=VK[i]
					gc_setColor(1,1,1,a)
					gc_setLineWidth(B.r*.07)
					gc_circle("line",B.x,B.y,B.r,10)--Button outline
					_=VK[i].pressTime
					gc_setColor(B.color[1],B.color[2],B.color[3],a)
					gc_draw(icons[i],B.x,B.y,nil,B.r*.026+_*.08,nil,18,18)--Icon
					if _>0 then
						gc_setColor(1,1,1,a*_*.08)
						gc_circle("fill",B.x,B.y,B.r*.94,10)--Glow when press
						gc_circle("line",B.x,B.y,B.r*(1.4-_*.04),10)--Ripple
					end
				end
			end
		else
			for i=1,#VK do
				if VK[i].ava then
					local B=VK[i]
					gc_setColor(1,1,1,a)
					gc_setLineWidth(B.r*.07)
					gc_circle("line",B.x,B.y,B.r,10)
					_=VK[i].pressTime
					if _>0 then
						gc_setColor(1,1,1,a*_*.08)
						gc_circle("fill",B.x,B.y,B.r*.94,10)
						gc_circle("line",B.x,B.y,B.r*(1.4-_*.04),10)
					end
				end
			end
		end
	end
end
function onVirtualkey(x,y)
	local dist,nearest=1e10
	for K=1,#VK do
		local B=VK[K]
		if B.ava then
			local d1=(x-B.x)^2+(y-B.y)^2
			if d1<B.r^2 then
				if d1<dist then
					nearest,dist=K,d1
				end
			end
		end
	end
	return nearest
end
function pressVirtualkey(t,x,y)
	local SETTING=SETTING
	local B=VK[t]
	B.isDown=true
	B.pressTime=10

	if x then
		if SETTING.VKTrack then
			--Auto follow
			local O=VK_org[t]
			local _FW,_CW=SETTING.VKTchW,1-SETTING.VKCurW
			local _OW=1-_FW-_CW
			--(finger+current+origin)
			B.x=x*_FW+B.x*_CW+O.x*_OW
			B.y=y*_FW+B.y*_CW+O.y*_OW

			--Button collision (not accurate)
			if SETTING.VKDodge then
				for i=1,#VK do
					local b=VK[i]
					local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5--Hit depth(Neg means distance)
					if d>0 then
						b.x=b.x+(b.x-B.x)*d*b.r*2.6e-5
						b.y=b.y+(b.y-B.y)*d*b.r*2.6e-5
					end
				end
			end
		end
		SFX.play("virtualKey",SETTING.VKSFX)
		VIB(SETTING.VKVIB)
	end
end
function updateVirtualkey()
	if SETTING.VKSwitch then
		for i=1,#VK do
			local _=VK[i]
			if _.pressTime>0 then
				_.pressTime=_.pressTime-1
			end
		end
	end
end



--Game
function generateLine(hole)
	-- return 2^10-1-2^(hole-1)
	return 1023-2^(hole-1)
end
function freshDate(mode)
	if not mode then mode=""end
	local date=os.date("%Y/%m/%d")
	if STAT.date~=date then
		STAT.date=date
		STAT.todayTime=0
		if not mode:find("q")then
			LOG.print(text.newDay,"message")
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
			LOG.print(text.playedLong,"warning")
			return true
		else
			LOG.print(text.playedTooMuch,"warning")
			return false
		end
	end
	return true
end
function mergeStat(stat,delta)--Merge delta stat. to global stat.
	for k,v in next,delta do
		if type(v)=="table"then
			if type(stat[k])=="table"then
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
		if P.AI_mode=="CC"then
			CC.free(P.bot_opt)
			CC.free(P.bot_wei)
			CC.destroy(P.AI_bot)
			P.AI_mode=false
		end
		PLAYERS[i]=nil
	end
	for i=#PLY_ALIVE,1,-1 do
		PLY_ALIVE[i]=nil
	end
	collectgarbage()
end
function restoreVirtualkey()
	for i=1,#VK_org do
		local B,O=virtualkey[i],VK_org[i]
		B.ava=O.ava
		B.x=O.x
		B.y=O.y
		B.r=O.r
		B.color=O.color
		B.isDown=false
		B.pressTime=0
	end
	for k,v in next,PLAYERS[1].keyAvailable do
		if not v then
			virtualkey[k].ava=false
		end
	end
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
		SCN.swapTo("pause","none")
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
			SCN.go("net_game","swipeD")
		else
			drawableText.modeName:set(text.modes[M][1].."   "..text.modes[M][2])
			SCN.go("play",ifQuickPlay and"swipeD"or"fade_togame")
			SFX.play("enter")
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

	local method=sudden and"setPosition"or"movePosition"
	L[1][method](L[1],340,75,1)
	if #L<=5 then
		if L[2]then L[2][method](L[2],965,390,.5)end
		if L[3]then L[3][method](L[3],965,30,.5)end
		if L[4]then L[4][method](L[4],20,390,.5)end
		if L[5]then L[5][method](L[5],20,30,.5)end
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
		"das","arr","dascut","sddas","sdarr",
		"ihs","irs","ims","RS","swap",

		--System
		"skin","face",

		--Graphic
		"block","ghost","center","smooth","grid","bagLine",
		"lockFX","dropFX","moveFX","clearFX","splashFX","shakeFX","atkFX",
		"text","score","warn","highCam","nextPos",
	}
	function dumpBasicConfig()
		local S={}
		for _,key in next,gameSetting do
			S[key]=SETTING[key]
		end
		return data.encode("string","base64",JSON.encode(S))
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
					TEXT.show(M.id,700+(time-20)%120*4,36,45,"spin",.5)
				else
					return
				end
			end
		end
	end
	local gameSetting={
		--Tuning
		"das","arr","dascut","sddas","sdarr",
		"ihs","irs","ims","RS","swap",

		--System
		"skin","face",

		--Graphic
		"block","ghost","center","smooth","grid","bagLine",
		"lockFX","dropFX","moveFX","clearFX","splashFX","shakeFX","atkFX",
		"text","score","warn","highCam","nextPos",
	}
	local function copyGameSetting()
		local S={}
		for _,key in next,gameSetting do
			if type(SETTING[key])=="table"then
				S[key]=TABLE.shift(SETTING[key])
			else
				S[key]=SETTING[key]
			end
		end
		return S
	end
	function resetGameData(args,seed)
		if not args then args=""end
		if PLAYERS[1]and not GAME.replaying and(GAME.frame>400 or GAME.result)then
			mergeStat(STAT,PLAYERS[1].stat)
			STAT.todayTime=STAT.todayTime+PLAYERS[1].stat.time
		end

		GAME.result=false
		GAME.warnLVL0=0
		GAME.warnLVL=0
		if args:find("r")then
			GAME.frame=0
			GAME.recording=false
			GAME.replaying=1
		else
			GAME.frame=args:find("n")and 0 or 150-SETTING.reTime*15
			GAME.seed=seed or rnd(1046101471,2662622626)
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
		initPlayerPosition(args:find("q"))
		restoreVirtualkey()
		if GAME.modeEnv.task then
			for i=1,#PLAYERS do
				PLAYERS[i]:newTask(GAME.modeEnv.task)
			end
		end
		BG.set(GAME.modeEnv.bg)
		BGM.play(GAME.modeEnv.bgm)

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
		TASK.new(tick_showMods)
		SFX.play("ready")
		collectgarbage()
	end
end
function gameStart()--Call when countdown finish (GAME.frame==180)
	SFX.play("start")
	for P=1,#PLAYERS do
		P=PLAYERS[P]
		P.control=true
		P.timing=true
		P:popNext()
	end
end
function checkStart()
	if GAME.frame<=180 then
		if GAME.frame==180 then
			gameStart()
		elseif GAME.frame==60 or GAME.frame==120 then
			SFX.play("ready")
		end
		for p=1,#PLAYERS do
			local P=PLAYERS[p]
			if P.movDir~=0 then
				if P.moving<P.gameEnv.das then
					P.moving=P.moving+1
				end
			else
				P.moving=0
			end
		end
		return true
	end
end
function checkWarning()
	local P1=PLAYERS[1]
	if P1.alive then
		if GAME.frame%26==0 then
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
			GAME.warnLVL0=math.log(height-(P1.gameEnv.fieldH-5)+P1.atkBuffer.sum*.8)
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
	if GAME.warnLVL>1.126 and GAME.frame%30==0 then
		SFX.fplay("warning",SETTING.sfx_warn)
	end
end

--[[
	Table data format:
		{frame,event, frame,event, ...}

	Byte data format: (1 byte each period)
		dt, event, dt, event, ...
	all data range from 0 to 127
	large value will be encoded as 1xxxxxxx(high)-1xxxxxxx-...-0xxxxxxx(low)

	Example (decoded):
		6,1, 20,-1, 0,2, 26,-2, 872,4, ...
	This means:
		Press key1 at 6f
		Release key1 at 26f (6+20)
		Press key2 at the same time (26+0)
		Release key 2 after 26 frame (26+26)
		Press key 4 after 872 frame (52+872)
		...
]]
function dumpRecording(list,ptr)
	local out=""
	local buffer,buffer2=""
	if not ptr then ptr=1 end
	local prevFrm=list[ptr-2]or 0
	while list[ptr]do
		--Flush buffer
		if #buffer>10 then
			out=out..buffer
			buffer=""
		end

		--Encode time
		local t=list[ptr]-prevFrm
		prevFrm=list[ptr]
		if t>=128 then
			buffer2=char(t%128)
			t=int(t/128)
			while t>=128 do
				buffer2=char(128+t%128)..buffer2
				t=int(t/128)
			end
			buffer=buffer..char(128+t)..buffer2
		else
			buffer=buffer..char(t)
		end

		--Encode event
		t=list[ptr+1]
		if t>=128 then
			buffer2=char(t%128)
			t=int(t/128)
			while t>=128 do
				buffer2=char(128+t%128)..buffer2
				t=int(t/128)
			end
			buffer=buffer..char(128+t)..buffer2
		else
			buffer=buffer..char(t)
		end

		--Step
		ptr=ptr+2
	end
	return out..buffer,ptr
end
function pumpRecording(str,L)
	local len=#str
	local p=1

	local curFrm=L[#L-1]or 0
	local code
	while p<=len do
		--Read delta time
		code=0
		local b=byte(str,p)
		while b>=128 do
			code=code*128+b-128
			p=p+1
			b=byte(str,p)
		end
		curFrm=curFrm+code*128+b
		L[#L+1]=curFrm
		p=p+1

		local event=0
		b=byte(str,p)
		while b>=128 do
			event=event*128+b-128
			p=p+1
			b=byte(str,p)
		end
		L[#L+1]=event*128+b
		p=p+1
	end
end
do--function saveRecording()
	local noRecList={"custom","solo","round","techmino"}
	local function getModList()
		local res={}
		for _,v in next,GAME.mod do
			if v.sel>0 then
				ins(res,{v.no,v.sel})
			end
		end
		return res
	end
	function saveRecording()
		--Filtering modes that cannot be saved
		for _,v in next,noRecList do
			if GAME.curModeName:find(v)then
				LOG.print("Cannot save recording of this mode now!",COLOR.sky)
				return
			end
		end

		--File contents
		local fileName="replay/"..os.date("%Y_%m_%d_%a_%H%M%S.rep")
		local fileHead=
			os.date("%Y/%m/%d %A %H:%M:%S\n")..
			GAME.curModeName.."\n"..
			VERSION_NAME.."\n"..
			(USER.name or"Player")
		local fileBody=
			GAME.seed.."\n"..
			JSON.encode(GAME.setting).."\n"..
			JSON.encode(getModList()).."\n"..
			dumpRecording(GAME.rep)

		--Write file
		if not love.filesystem.getInfo(fileName)then
			love.filesystem.write(fileName,fileHead.."\n"..data.compress("string","zlib",fileBody))
			ins(REPLAY,fileName)
			FILE.save(REPLAY,"conf/replay")
			return true
		else
			LOG.print("Save failed: File already exists")
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
	--你竟然找到了这里！那么在动手之前读读下面这些吧。
	--【魔幻躲关键字搜索警告，看得懂就行】
	--千万不要为了在网络公共场合发视屏或者直播需要而擅自删除这部分代码！
	--录制视屏上传到公共场合(包括但不限于任何视屏平台/论坛/几十个人以上的社区群等)很可能会对Techmino未来的发展有负面影响
	--如果被TTC发现，TTC随时可以用DMCA从法律层面强迫停止开发，到时候谁都没得玩。这是真的，已经有几个方块这么死了…
	--氵印限制还可以减少低质量视屏泛滥，也能减轻过多不是真的感兴趣路人玩家入坑可能带来的压力
	--想发视屏的话请先向作者申请，描述录制的大致内容，同意了才可以去关闭氵印
	--等Techmino发展到一定程度之后会解除这个限制
	--最后，别把藏在这里的东西截图/复制出去哦~
	--感谢您对Techmino的支持！！！
	local setFont,TIME,mStr=setFont,TIME,mStr
	function drawFWM()
		local t=TIME()
		setFont(25)
		gc_setColor(1,1,1,.2+.1*(sin(3*t)+sin(2.6*t)))
		mStr(m[SETTING.lang]or m[1],240,60+26*sin(t))
	end
end
function drawWarning()
	if SETTING.warn and GAME.warnLVL>0 then
		gc_push("transform")
		gc_origin()
		SHADER.warning:send("level",GAME.warnLVL)
		gc_setShader(SHADER.warning)
		gc_rectangle("fill",0,0,SCR.w,SCR.h)
		gc_setShader()
		gc_pop()
	end
end



--Widget function shortcuts
function backScene()SCN.back()end
do--function goScene(name,style)
	local cache={}
	function goScene(name,style)
		if not cache[name]then
			cache[name]=function()SCN.go(name,style)end
		end
		return cache[name]
	end
end
do--function swapScene(name,style)
	local cache={}
	function swapScene(name,style)
		if not cache[name]then
			cache[name]=function()SCN.swapTo(name,style)end
		end
		return cache[name]
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