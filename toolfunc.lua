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
	gc.printf(s,x-320,y,640,"center")
end
function mDraw(s,x,y)
	gc.draw(s,x-s:getWidth()*.5,y)
end
function destroyPlayers()
	for i=#players,1,-1 do
		local P=players[i]
		if P.canvas then P.canvas:release()end
		if P.dust then P.dust:release()end
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
local langID={"chi","chi_full","eng"}
local drawableTextLoad={
	"next","hold",
	"win","finish","lose","pause",
	"custom",
	"setting_game",
	"setting_graphic",
	"setting_sound",
	"setting_sound",
	"setting_control",
	"setting_skin",
	"keyboard","joystick",
	"ctrlSetHelp",
	"musicRoom",
	"nowPlaying",
	"VKTchW","VKOrgW","VKCurW",
	"noScore",
	"highScore",
}
function changeLanguage(l)
	text=require("language/"..langID[l])
	for S,L in next,Widget do
		for N,W in next,L do
			W.text=text.WidgetText[S][N]
		end
	end
	gc.push("transform")
	gc.origin()
		royaleCtrlPad=gc.newCanvas(300,100)
		gc.setCanvas(royaleCtrlPad)
		gc.setColor(1,1,1)
		setFont(20)
		gc.setLineWidth(2)
		for i=1,4 do
			gc.rectangle("line",RCPB[2*i-1],RCPB[2*i],90,35,8,4)
			mStr(text.atkModeName[i],RCPB[2*i-1]+45,RCPB[2*i]+3)
		end
	gc.pop()
	gc.setCanvas()
	for _,s in next,drawableTextLoad do
		drawableText[s]:set(text[s])
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
				goto L
			end
		end
	end
	::L::
	for y=1,H do
		local S=""
		local L=preField[y]
		for x=1,10 do
			local _=L[x]+1
			S=S..char(_)
		end
		str=str..S
	end
	love.system.setClipboardText("Techmino sketchpad:"..data.encode("string","base64",data.compress("string","deflate",str)))
	TEXT(text.copySuccess,350,360,40,"appear",.5)
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
	::LOOP::
		_=byte(str,p)--1byte
		if not _ then
			if fX~=1 then goto ERROR
			else goto FINISH
			end
		end--str end
		__=_%32-1--block id
		if __>16 then goto ERROR end--illegal blockid
		_=int(_/32)--mode id
		preField[fY][fX]=__
		if fX<10 then
			fX=fX+1
		else
			if fY==20 then goto FINISH end
			fX=1;fY=fY+1
		end
		p=p+1
	goto LOOP

	::FINISH::
		for y=fY+1,20 do
			for x=1,10 do
				preField[y][x]=0
			end
		end
	goto END
	::ERROR::
		TEXT(text.dataCorrupted,350,360,35,"flicker",.5)
	::END::
end

function updateStat()
	local S=players[1].stat
	for k,v in next,S do
		stat[k]=stat[k]+S[k]
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
	TEXT(text.royale_remain(#players.alive),640,200,40,"beat",.3)
	if gameStage==2 then
		spd=30
	elseif gameStage==3 then
		spd=15
		garbageSpeed=.6
		if players[1].alive then BGM.play("cruelty")end
	elseif gameStage==4 then
		spd=10
		local _=players.alive
		for i=1,#_ do
			_[i].gameEnv.pushSpeed=3
		end
	elseif gameStage==5 then
		spd=5
		garbageSpeed=1
	elseif gameStage==6 then
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
	if not scene.swapping then
		restartCount=0--Avoid strange darkness
		if not gameResult then
			pauseCount=pauseCount+1
		end
		for i=1,#players do
			local l=players[i].keyPressing
			for j=1,#l do
				if l[j]then
					players[i]:releaseKey(j)
				end
			end
		end
		scene.swapTo("pause","none")
	end
end
function resumeGame()
	scene.swapTo("play","none")
end
function loadGame(M)
	--rec={}
	stat.lastPlay=M
	M=modes[M]
	curMode=M
	local lang=setting.lang
	drawableText.modeName:set(M.name[lang])
	drawableText.levelName:set(M.level[lang])
	needResetGameData=true
	scene.swapTo("play","fade_togame")
	SFX.play("enter")
end
function resetPartGameData()
	gameResult=false
	frame=150-setting.reTime*15
	destroyPlayers()
	curMode.load()
	texts={}
	for i=1,#players do
		if players.dust then
			players.dust:reset()
		end
	end
	if modeEnv.task then
		for i=1,#players do
			newTask(modeEnv.task,players[i])
		end
	end
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
	end
	curBG=modeEnv.bg
	BGM.play(modeEnv.bgm)
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
		mostBadge,mostDangerous,secBadge,secDangerous=nil
		gameStage=1
		garbageSpeed=.3
	end
	restoreVirtualKey()
	collectgarbage()
end
function resetGameData()
	gameResult=false
	frame=150-setting.reTime*15
	garbageSpeed=1
	pauseTime=0--Time paused
	pauseCount=0--Times paused
	destroyPlayers()
	modeEnv=curMode.env
	curMode.load()--bg/bgm need redefine in custom,so up here
	if modeEnv.task then
		for i=1,#players do
			newTask(modeEnv.task,players[i])
		end
	end
	curBG=modeEnv.bg
	BGM.play(modeEnv.bgm)

	texts={}
	FX_badge={}
	FX_attack={}
	if modeEnv.royaleMode then
		for i=1,#players do
			players[i]:changeAtk(randomTarget(players[i]))
		end
		mostBadge,mostDangerous,secBadge,secDangerous=nil
		gameStage=1
		garbageSpeed=.3
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
		P:freshNext()
		P.timing=true
		P.control=true
	end
end