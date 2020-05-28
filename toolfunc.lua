local tm,gc=love.timer,love.graphics
local kb,data=love.keyboard,love.data
local int,abs,rnd=math.floor,math.abs,math.random
local max,min=math.max,math.min
local sub,find=string.sub,string.find
local format,char,byte=string.format,string.char,string.byte
local ins,rem=table.insert,table.remove

function toTime(s)
	if s<60 then
		return format("%.3fs",s)
	elseif s<3600 then
		return format("%d:%.2f",int(s/60),s%60)
	else
		local h=int(s/3600)
		return format("%d:%d:%.2f",h,int(s/60%60),s%60)
	end
end
function mStr(s,x,y)
	gc.printf(s,x-400,y,800,"center")
end
function mText(s,x,y)
	gc.draw(s,x-s:getWidth()*.5,y)
end
function mDraw(s,x,y,a,k)
	gc.draw(s,x,y,a,k,nil,s:getWidth()*.5,s:getHeight()*.5)
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
	players.human=0
	collectgarbage()
end
--Single-usage funcs

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
				goto L
			end
		end
	end
	::L::
	for y=1,H do
		local S=""
		local L=preField[y]
		for x=1,10 do
			S=S..char(L[x]+1)
		end
		str=str..S
	end
	love.system.setClipboardText("Techmino sketchpad:"..data.encode("string","base64",data.compress("string","deflate",str)))
	TEXT.show(text.copySuccess,350,360,40,"appear",.5)
end
function pasteBoard()
	local str=love.system.getClipboardText()
	local fX,fY=1,1--*ptr for Field(r*10+(c-1))
	local _,Bid
	local p=find(str,":")--ptr*
	if p then str=sub(str,p+1)end
	_,str=pcall(data.decode,"string","base64",str)
	if not _ then goto ERROR end
	_,str=pcall(data.decompress,"string","deflate",str)
	if not _ then goto ERROR end
	p=1
	while true do
		_=byte(str,p)--1byte
		if not _ then
			if fX~=1 then goto ERROR
			else break
			end
		end--str end
		__=_%32-1--block id
		if __>17 then goto ERROR end--illegal blockid
		_=int(_/32)--mode id
		preField[fY][fX]=__
		if fX<10 then
			fX=fX+1
		else
			if fY==20 then break end
			fX=1;fY=fY+1
		end
		p=p+1
	end

	for y=fY+1,20 do
		for x=1,10 do
			preField[y][x]=0
		end
	end
	do return end
	::ERROR::TEXT.show(text.dataCorrupted,350,360,35,"flicker",.5)
end

function mergeStat(stat,delta)
	for k,v in next,delta do
		if type(v)=="table"then
			mergeStat(stat[k],v)
		else
			stat[k]=stat[k]+v
		end
	end
end
function randomTarget(P)
	if #players.alive>1 then
		local R
		repeat
			R=players.alive[rnd(#players.alive)]
		until R~=P
		return R
	end
end--return a random opponent for P
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
				P.curY=P.y_img
				P.gameEnv._20G=true
				if P.AI_mode=="CC"then CC_switch20G(P)end--little cheating,never mind
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
function loadGame(M)
	--rec={}
	stat.lastPlay=M
	curMode=modes[M]
	local lang=setting.lang
	drawableText.modeName:set(text.modes[M][1])
	drawableText.levelName:set(text.modes[M][2])
	needResetGameData=true
	SCN.swapTo("play","fade_togame")
	SFX.play("enter")
end
function resetPartGameData()
	game={
		result=false,
		pauseTime=0,
		pauseCount=0,
		garbageSpeed=1,
		warnLVL0=0,
		warnLVL=0,
	}
	frame=150-setting.reTime*15
	destroyPlayers()
	curMode.load()
	TEXT.clear()
	if modeEnv.task then
		for i=1,#players do
			TASK.new(modeEnv.task,players[i])
		end
	end
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
	end
	BG.set(modeEnv.bg)
	BGM.play(modeEnv.bgm)
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
function resetGameData()
	game={
		result=false,
		pauseTime=0,--Time paused
		pauseCount=0,--Pausing count
		garbageSpeed=1,--garbage timing speed
		warnLVL0=0,
		warnLVL=0,
	}
	frame=150-setting.reTime*15
	destroyPlayers()
	modeEnv=curMode.env
	curMode.load()--bg/bgm need redefine in custom,so up here
	if modeEnv.task then
		for i=1,#players do
			TASK.new(modeEnv.task,players[i])
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
function gameStart()
	SFX.play("start")
	for P=1,#players do
		P=players[P]
		P:popNext()
		P.timing=true
		P.control=true
	end
end