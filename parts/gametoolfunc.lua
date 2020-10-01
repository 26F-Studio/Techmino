local tm,gc=love.timer,love.graphics
local kb,data=love.keyboard,love.data
local int,abs,rnd=math.floor,math.abs,math.random
local max,min=math.max,math.min
local sub,find=string.sub,string.find
local char,byte=string.char,string.byte
local ins,rem=table.insert,table.remove

local default_setting={
	"das","arr",
	"sddas","sdarr",
	"ihs","irs","ims",
	"maxNext",
	"swap",
	-- "face",
}
local function copyGameSetting()
	local S={face={}}
	for _,v in next,default_setting do
		S[v]=setting[v]
	end
	for i=1,25 do
		S.face[i]=setting.face[i]
	end
	return S
end

function destroyPlayers()
	for i=#players,1,-1 do
		local P=players[i]
		if P.canvas then P.canvas:release()end
		while P.field[1]do
			freeRow.discard(rem(P.field))
			freeRow.discard(rem(P.visTime))
		end
		if P.AI_mode=="CC"then
			CC.free(P.bot_opt)
			CC.free(P.bot_wei)
			CC.destroy(P.AI_bot)
			P.AI_mode=nil
		end
		players[i]=nil
	end
	for i=#players.alive,1,-1 do
		players.alive[i]=nil
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
	if not modeEnv.Fkey then
		virtualkey[9].ava=false
	end
end

function copyQuestArgs()
	local ENV=customEnv
	local str=""
	str=str..(ENV.hold and"H"or"Z")
	str=str..(ENV.ospin and"O"or"Z")
	str=str..(ENV.missionKill and"M"or"Z")
	str=str..ENV.sequence
	return str
end
function pasteQuestArgs(str)
	local ENV=customEnv
	ENV.hold=			byte(str,1)~=90
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
	Encode: [A] or [AB] sequence, A = block ID, B = repeat times, no B means do not repeat.
	Example: "abcdefg" is [SZJLTOI], "a^aDb)" is [Z*63,Z*37,S*10]
]]
function copySequence()
	local preBag=preBag
	local str=""

	local count=1
	for i=1,#preBag+1 do
		if preBag[i+1]~=preBag[i]or count==64 then
			str=str..char(96+preBag[i])
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
	local _

	local bag={}
	local reg
	for i=1,#str do
		_=byte(str,i)
		if not reg then
			if _>=97 and _<=125 then
				reg=_-96
			else
				return
			end
		else
			if _>=97 and _<=125 then
				ins(bag,reg)
				reg=_-96
			elseif _>=34 and _<=96 then
				for i=1,_-32 do
					ins(bag,reg)
				end
				reg=nil
			end
		end
	end
	if reg then
		ins(bag,reg)
	end

	preBag=bag
	sceneTemp.cur=#bag
	return true
end

function copyBoard()
	local str=""
	local H=0

	for y=20,1,-1 do
		for x=1,10 do
			if preField[y][x]~=0 then
				H=y
				goto topFound
			end
		end
	end
	::topFound::

	--Encode field
	for y=1,H do
		local S=""
		local L=preField[y]
		for x=1,10 do
			S=S..char(L[x]+1)
		end
		str=str..S
	end
	return data.encode("string","base64",data.compress("string","zlib",str))
end
function pasteBoard(str)
	local _

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
		if __>17 then return end--Illegal blockid
		_=int(_/32)--Mode id

		preField[fY][fX]=__
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
			preField[y][x]=0
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
	local preMission=preMission
	local str=""

	local count=1
	for i=1,#preMission+1 do
		if preMission[i+1]~=preMission[i]or count==13 then
			_=33+preMission[i]
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
	local _
	local mission={}
	local reg
	for i=1,#str do
		_=byte(str,i)
		if not reg then
			if _>=34 and _<=114 then
				reg=_-33
			else
				return
			end
		else
			if _>=34 and _<=114 then
				ins(mission,reg)
				reg=_-33
			elseif _>=115 and _<=126 then
				for i=1,_-113 do
					ins(mission,reg)
				end
				reg=nil
			end
		end
	end
	if reg then
		ins(mission,reg)
	end

	preMission=mission
	sceneTemp.cur=#mission
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
	if #players.alive>1 then
		local R
		repeat
			R=players.alive[rnd(#players.alive)]
		until R~=P
		return R
	end
end
function freshMostDangerous()
	game.mostDangerous,game.secDangerous=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local h=#players.alive[i].field
		if h>=m then
			game.mostDangerous,game.secDangerous=players.alive[i],game.mostDangerous
			m,m2=h,m
		elseif h>=m2 then
			game.secDangerous=players.alive[i]
			m2=h
		end
	end

	for i=1,#players.alive do
		if players.alive[i].atkMode==3 then
			players.alive[i]:freshTarget()
		end
	end
end
function freshMostBadge()
	game.mostBadge,game.secBadge=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local P=players.alive[i]
		local b=P.badge
		if b>=m then
			game.mostBadge,game.secBadge=P,game.mostBadge
			m,m2=b,m
		elseif b>=m2 then
			game.secBadge=P
			m2=b
		end
	end

	for i=1,#players.alive do
		if players.alive[i].atkMode==4 then
			players.alive[i]:freshTarget()
		end
	end
end
function royaleLevelup()
	game.stage=game.stage+1
	local spd
	TEXT.show(text.royale_remain(#players.alive),640,200,40,"beat",.3)
	if game.stage==2 then
		spd=30
	elseif game.stage==3 then
		spd=15
		game.garbageSpeed=.6
		if players[1].alive then BGM.play("cruelty")end
	elseif game.stage==4 then
		spd=10
		local _=players.alive
		for i=1,#_ do
			_[i].gameEnv.pushSpeed=3
		end
	elseif game.stage==5 then
		spd=5
		game.garbageSpeed=1
	elseif game.stage==6 then
		spd=3
		if players[1].alive then BGM.play("final")end
	end
	for i=1,#players.alive do
		players.alive[i].gameEnv.drop=spd
	end
	if curMode.lv==3 then
		for i=1,#players.alive do
			local P=players.alive[i]
			P.gameEnv.drop=int(P.gameEnv.drop*.3)
			if P.gameEnv.drop==0 then
				P.curY=P.imgY
				P._20G=true
				if P.AI_mode=="CC"then CC_switch20G(P)end
			end
		end
	end
end

function pauseGame()
	if not SCN.swapping then
		restartCount=0--Avoid strange darkness
		if not game.result then
			game.pauseCount=game.pauseCount+1
		end
		if not game.replaying then
			for i=1,#players do
				local l=players[i].keyPressing
				for j=1,#l do
					if l[j]then
						players[i]:releaseKey(j)
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
	stat.lastPlay=M
	curMode=Modes[M]
	local lang=setting.lang
	drawableText.modeName:set(text.modes[M][1])
	drawableText.levelName:set(text.modes[M][2])
	needResetGameData=true
	SCN.swapTo("play",ifQuickPlay and"swipeD"or"fade_togame")
	SFX.play("enter")
end
function resetGameData()
	if players[1]and not game.replaying then
		mergeStat(stat,players[1].stat)
	end

	game.frame=150-setting.reTime*15
	game.result=false
	game.pauseTime=0
	game.pauseCount=0
	game.garbageSpeed=1
	game.warnLVL0=0
	game.warnLVL=0
	game.recording=true
	game.replaying=false
	game.setting=copyGameSetting()
	game.rec={}
	math.randomseed(tm.getTime())
	game.seed=rnd(261046101471026)

	destroyPlayers()
	restoreVirtualKey()
	modeEnv=curMode.env
	curMode.load()--BG/BGM need redefine in custom,so up here
	if modeEnv.task then
		for i=1,#players do
			players[i]:newTask(modeEnv.task)
		end
	end
	BG.set(modeEnv.bg)
	BGM.play(modeEnv.bgm)

	TEXT.clear()
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
		game.stage=nil
		game.mostBadge=nil
		game.secBadge=nil
		game.mostDangerous=nil
		game.secDangerous=nil
		game.stage=1
		game.garbageSpeed=.3
	end
	stat.game=stat.game+1
	freeRow.reset(30*#players)
	SFX.play("ready")
	collectgarbage()
end
function resetPartGameData(replaying)
	TASK.removeTask_code(TICK.autoPause)
	if players[1]and not game.replaying then
		mergeStat(stat,players[1].stat)
	end

	game.result=false
	game.garbageSpeed=1
	game.warnLVL0=0
	game.warnLVL=0
	if replaying then
		game.frame=0
		game.recording=false
		game.replaying=1
	else
		game.frame=150-setting.reTime*15
		game.pauseTime=0
		game.pauseCount=0
		game.recording=true
		game.replaying=false
		game.setting=copyGameSetting()
		game.rec={}
		math.randomseed(tm.getTime())
		game.seed=rnd(1046101471,2662622626)
	end

	destroyPlayers()
	restoreVirtualKey()
	modeEnv=curMode.env
	curMode.load()
	if modeEnv.task then
		for i=1,#players do
			players[i]:newTask(modeEnv.task)
		end
	end
	BG.set(modeEnv.bg)
	BGM.play(modeEnv.bgm)

	TEXT.clear()
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
		game.stage=nil
		game.mostBadge=nil
		game.secBadge=nil
		game.mostDangerous=nil
		game.secDangerous=nil
		game.stage=1
		game.garbageSpeed=.3
	end
	collectgarbage()
end
function gameStart()
	SFX.play("start")
	for P=1,#players do
		P=players[P]
		P.control=true
		P.timing=true
		P:popNext()
	end
end