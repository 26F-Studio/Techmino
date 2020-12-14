local tm=love.timer
local data=love.data
local int,rnd=math.floor,math.random
local sub=string.sub
local char,byte=string.char,string.byte
local ins,rem=table.insert,table.remove

local default_setting={
	"das","arr",
	"sddas","sdarr",
	"ihs","irs","ims",
	"maxNext",
	"swap",
	--"face","skin",
}
local function copyGameSetting()
	local S={
		face=copyList(SETTING.face),
		skin=copyList(SETTING.skin),
	}
	for _,v in next,default_setting do
		S[v]=SETTING[v]
	end
	return S
end

function destroyPlayers()
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
			P.AI_mode=nil
		end
		PLAYERS[i]=nil
	end
	for i=#PLAYERS.alive,1,-1 do
		PLAYERS.alive[i]=nil
	end
	collectgarbage()
end

function restoreVirtualKey()
	for i=1,#VK_org do
		local B,O=virtualkey[i],VK_org[i]
		B.ava=O.ava
		B.x=O.x
		B.y=O.y
		B.r=O.r
		B.isDown=false
		B.pressTime=0
	end
	for k,v in next,PLAYERS[1].keyAvailable do
		if not v then
			virtualkey[k].ava=false
		end
	end
end

function copyQuestArgs()
	local ENV=CUSTOMENV
	local str=""..
		(ENV.hold>0 and"H"or"Z")..
		(ENV.ospin and"O"or"Z")..
		(ENV.missionKill and"M"or"Z")..
		ENV.sequence
	return str
end
function pasteQuestArgs(str)
	local ENV=CUSTOMENV
	ENV.holdCount=		byte(str,1)~=90 and 1 or 0
	ENV.ospin=			byte(str,2)~=90
	ENV.missionKill=	byte(str,3)~=90
	ENV.sequence=		sub(str,4)
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
				reg=nil
			end
		end
	end
	if reg then
		ins(bag,reg)
	end

	BAG=bag
	sceneTemp.cur=#bag
	return true
end

function newBoard(f)
	if f then
		return copyList(f)
	else
		local F={}
		for i=1,20 do F[i]={0,0,0,0,0,0,0,0,0,0}end
		return F
	end
end
function copyBoard(page)
	local F=FIELD[page or 1]
	local str=""
	local H=0

	for y=20,1,-1 do
		for x=1,10 do
			if F[y][x]~=0 then
				H=y
				goto topFound
			end
		end
	end
	::topFound::

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
function pasteBoard(str,page)
	local F=FIELD[page or 1]
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
				reg=nil
			end
		end
	end
	if reg then
		ins(mission,reg)
	end

	MISSION=mission
	sceneTemp.cur=#mission
	return true
end

function freshDate()
	local date=os.date("%Y/%m/%d")
	if STAT.date~=date then
		STAT.date=date
		STAT.todayTime=0
		LOG.print(text.newDay,"message")
	end
end
function legalGameTime()
	if
		(SETTING.lang==1 or SETTING.lang==2 or SETTING.lang==7)and
		RANKS.sprint_10<4 and
		(not RANKS.sprint_40 or RANKS.sprint_40<3)
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
function mergeStat(stat,delta)
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

function randomTarget(P)--Return a random opponent for P
	if #PLAYERS.alive>1 then
		local R
		repeat
			R=PLAYERS.alive[rnd(#PLAYERS.alive)]
		until R~=P
		return R
	end
end
function freshMostDangerous()
	GAME.mostDangerous,GAME.secDangerous=nil
	local m,m2=0,0
	for i=1,#PLAYERS.alive do
		local h=#PLAYERS.alive[i].field
		if h>=m then
			GAME.mostDangerous,GAME.secDangerous=PLAYERS.alive[i],GAME.mostDangerous
			m,m2=h,m
		elseif h>=m2 then
			GAME.secDangerous=PLAYERS.alive[i]
			m2=h
		end
	end

	for i=1,#PLAYERS.alive do
		if PLAYERS.alive[i].atkMode==3 then
			PLAYERS.alive[i]:freshTarget()
		end
	end
end
function freshMostBadge()
	GAME.mostBadge,GAME.secBadge=nil
	local m,m2=0,0
	for i=1,#PLAYERS.alive do
		local P=PLAYERS.alive[i]
		local b=P.badge
		if b>=m then
			GAME.mostBadge,GAME.secBadge=P,GAME.mostBadge
			m,m2=b,m
		elseif b>=m2 then
			GAME.secBadge=P
			m2=b
		end
	end

	for i=1,#PLAYERS.alive do
		if PLAYERS.alive[i].atkMode==4 then
			PLAYERS.alive[i]:freshTarget()
		end
	end
end
function royaleLevelup()
	GAME.stage=GAME.stage+1
	local spd
	TEXT.show(text.royale_remain:gsub("$1",#PLAYERS.alive),640,200,40,"beat",.3)
	if GAME.stage==2 then
		spd=30
	elseif GAME.stage==3 then
		spd=15
		GAME.garbageSpeed=.6
		if PLAYERS[1].alive then BGM.play("cruelty")end
	elseif GAME.stage==4 then
		spd=10
		local _=PLAYERS.alive
		for i=1,#_ do
			_[i].gameEnv.pushSpeed=3
		end
	elseif GAME.stage==5 then
		spd=5
		GAME.garbageSpeed=1
	elseif GAME.stage==6 then
		spd=3
		if PLAYERS[1].alive then BGM.play("final")end
	end
	for i=1,#PLAYERS.alive do
		PLAYERS.alive[i].gameEnv.drop=spd
	end
	if GAME.curMode.name:find("ultimate")then
		for i=1,#PLAYERS.alive do
			local P=PLAYERS.alive[i]
			P.gameEnv.drop=int(P.gameEnv.drop*.3)
			if P.gameEnv.drop==0 then
				P.curY=P.imgY
				P:set20G(true)
			end
		end
	end
end

function pauseGame()
	if not SCN.swapping then
		GAME.restartCount=0--Avoid strange darkness
		if not GAME.result then
			GAME.pauseCount=GAME.pauseCount+1
		end
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
		SCN.swapTo("pause","none")
	end
end
function resumeGame()
	SCN.swapTo("play","none")
end
function loadGame(M,ifQuickPlay)
	freshDate()
	if legalGameTime()then
		if M.score then STAT.lastPlay=M end
		GAME.curMode=MODES[M]
		GAME.modeEnv=GAME.curMode.env
		drawableText.modeName:set(text.modes[M][1])
		drawableText.levelName:set(text.modes[M][2])
		GAME.init=true
		SCN.push()
		SCN.swapTo("play",ifQuickPlay and"swipeD"or"fade_togame")
		SFX.play("enter")
	end
end
function resetGameData(replaying)
	if PLAYERS[1]and not GAME.replaying then
		mergeStat(STAT,PLAYERS[1].stat)
		STAT.todayTime=STAT.todayTime+PLAYERS[1].stat.time
	end

	GAME.result=false
	GAME.garbageSpeed=1
	GAME.warnLVL0=0
	GAME.warnLVL=0
	if replaying then
		GAME.frame=0
		GAME.recording=false
		GAME.replaying=1
	else
		GAME.frame=150-SETTING.reTime*15
		GAME.pauseTime=0
		GAME.pauseCount=0
		GAME.recording=true
		GAME.replaying=false
		GAME.setting=copyGameSetting()
		GAME.rec={}
		GAME.rank=0
		math.randomseed(tm.getTime())
		GAME.seed=rnd(1046101471,2662622626)
	end

	TASK.removeTask_code(TICK.autoPause)
	destroyPlayers()
	GAME.curMode.load()
	restoreVirtualKey()
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
		GAME.stage=nil
		GAME.mostBadge=nil
		GAME.secBadge=nil
		GAME.mostDangerous=nil
		GAME.secDangerous=nil
		GAME.stage=1
		GAME.garbageSpeed=.3
	end
	STAT.game=STAT.game+1
	FREEROW.reset(30*#PLAYERS)
	TASK.removeTask_code(TICK.showMods)
	TASK.new(TICK.showMods)
	SFX.play("ready")
	collectgarbage()
end
function gameStart()
	SFX.play("start")
	for P=1,#PLAYERS do
		P=PLAYERS[P]
		P.control=true
		P.timing=true
		P:popNext()
	end
end
function scoreValid()
	for _,M in next,GAME.mod do
		if M.unranked then
			return false
		end
	end
	return true
end
function dumpRecording(list)
	local out=""
	local buffer=""
	local prevFrm=0
	local p=1
	while list[p]do
		--Check buffer size
		if #buffer>10 then
			out=out..buffer
			buffer=""
		end

		--Encode time
		local t=list[p]-prevFrm
		prevFrm=list[p]
		while t>=255 do
			buffer=buffer.."\255"
			t=t-255
		end
		buffer=buffer..char(t)

		--Encode key
		t=list[p+1]
		buffer=buffer..char(t>0 and t or 256+t)

		--Step
		p=p+2
	end
	return data.encode("string","base64",out..buffer)
end
function pumpRecording(str,L)
	str=data.decode("string","base64",str)
	local len=#str
	local p=1

	local list,curFrm
	if L then
		list=L
		curFrm=L[#L-1]
	else
		list={}
		curFrm=0
	end

	while p<=len do
		--Read delta time
		::nextByte::
		local b=byte(str,p)
		if b==255 then
			curFrm=curFrm+255
			p=p+1
			goto nextByte
		end
		curFrm=curFrm+b
		list[#list+1]=curFrm
		p=p+1

		b=byte(str,p)
		if b>127 then
			b=b-256
		end
		list[#list+1]=b
		p=p+1
	end
	return list
end