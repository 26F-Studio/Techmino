local tm,gc=love.timer,love.graphics
local kb,data=love.keyboard,love.data
local int,abs,rnd=math.floor,math.abs,math.random
local max,min=math.max,math.min
local sub,find=string.sub,string.find
local char,byte=string.char,string.byte
local ins,rem=table.insert,table.remove

function destroyPlayers()
	for i=#players,1,-1 do
		local P=players[i]
		if P.canvas then P.canvas:release()end
		while P.field[1]do
			freeRow.discard(rem(P.field))
			freeRow.discard(rem(P.visTime))
		end
		if P.AI_mode=="CC"then
			BOT.free(P.bot_opt)
			BOT.free(P.bot_wei)
			BOT.destroy(P.AI_bot)
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
	return data.encode("string","base64",data.compress("string","deflate",str))
end
function pasteBoard(str)
	local _

	--Decode
	_,str=pcall(data.decode,"string","base64",str)
	if not _ then return end
	_,str=pcall(data.decompress,"string","deflate",str)
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
				fY=fY+1
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

function copySequence()
	local str=""

	for i=1,#preBag do
		str=str..char(preBag[i]-1)
	end

	return data.encode("string","base64",data.compress("string","deflate",str))
end
function pasteSequence(str)
	local _

	--Decode
	_,str=pcall(data.decode,"string","base64",str)
	if not _ then return end
	_,str=pcall(data.decompress,"string","deflate",str)
	if not _ then return end

	local bag={}
	for i=1,#str do
		_=byte(str,i)
		if _<25 then
			bag[i]=_+1
		else
			return
		end
	end

	preBag=bag
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
end
function freshMostBadge()
	game.mostBadge,game.secBadge=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local h=players.alive[i].badge
		if h>=m then
			game.mostBadge,game.secBadge=players.alive[i],game.mostBadge
			m,m2=h,m
		elseif h>=m2 then
			game.secBadge=players.alive[i]
			m2=h
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
				P.gameEnv._20G=true
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
		for i=1,#players do
			local l=players[i].keyPressing
			for j=1,#l do
				if l[j]then
					players[i]:releaseKey(j)
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
	SCN.swapTo("play",ifQuickPlay and"swipe"or"fade_togame")
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
	game.rec={}
	math.randomseed(tm.getTime())
	game.seed=rnd(261046101471026)

	destroyPlayers()
	modeEnv=curMode.env
	math.randomseed(game.seed)
	curMode.load()--BG/BGM need redefine in custom,so up here
	if modeEnv.task then
		for i=1,#players do
			players[i]:newTask(modeEnv.task)
		end
	end
	BG.set(modeEnv.bg)
	BGM.play(modeEnv.bgm)

	TEXT.clear()
	FX_badge={}
	FX_attack={}
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
		game.stage=1
		game.garbageSpeed=.3
	end
	restoreVirtualKey()
	stat.game=stat.game+1
	freeRow.reset(30*#players)
	SFX.play("ready")
	collectgarbage()
end
function resetPartGameData(replaying)
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
		game.rec={}
		math.randomseed(tm.getTime())
		game.seed=rnd(1046101471,2662622626)
	end

	destroyPlayers()
	modeEnv=curMode.env
	math.randomseed(game.seed)
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
		game.stage=1
		game.garbageSpeed=.3
	end
	restoreVirtualKey()
	collectgarbage()
end
function gameStart()
	SFX.play("start")
	for P=1,#players do
		P=players[P]
		P:popNext()
		P.timing=true
		P.control=true
	end
end