local tm=love.timer
local gc=love.graphics
local kb=love.keyboard
local data=love.data
local int,abs,rnd,max,min=math.floor,math.abs,math.random,math.max,math.min
local sub,find,format,char,byte=string.sub,string.find,string.format,string.char,string.byte
local ins,rem=table.insert,table.remove
local toN,toS=tonumber,tostring
local concat=table.concat

local function splitS(s,sep)
	local t,n={},1
	repeat
		local p=find(s,sep)or #s+1
		t[n]=sub(s,1,p-1)
		n=n+1
		s=sub(s,p+#sep)
	until #s==0
	return t
end

function toTime(s)
	if s<60 then
		return format("%.3fs",s)
	elseif s<3600 then
		return format("%d:%.2f",int(s/60),s%60)
	else
		local h=int(s/3600)
		return format("%d:%d:%.2f",h,int(s-h/60),s%60)
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
			removeRow(P.field)
			removeRow(P.visTime)
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
function getNewRow(val)
	local t=rem(freeRow)
	for i=1,10 do
		t[i]=val
	end
	freeRow.L=freeRow.L-1
	--get a row from buffer
	if not freeRow[1]then
		for i=1,10 do
			freeRow[i]={0,0,0,0,0,0,0,0,0,0}
		end
		freeRow.L=freeRow.L+10
	end
	--prepare new rows
	return t
end
function removeRow(t,k)
	freeRow[#freeRow+1]=rem(t,k)
	freeRow.L=freeRow.L+1
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
	"keyboard","joystick",
	"ctrlSetHelp",
	"musicRoom",
	"nowPlaying",
	"warning",
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
function changeBlockSkin(n)
	n=n-1
	gc.push("transform")
	gc.origin()
	gc.setColor(1,1,1)
	for i=1,13 do
		gc.setCanvas(blockSkin[i])
		gc.draw(blockImg,30-30*i,-30*n)
		gc.setCanvas(blockSkinmini[i])
		gc.draw(blockImg,6-6*i,-6*n,nil,.2)
	end
	gc.pop()
	gc.setCanvas()
end
function restoreVirtualKey()
	for i=1,#VK_org do
		local B,O=virtualkey[i],VK_org[i]
		B.ava=O.ava
		B.x=O.x
		B.y=O.y
		B.r=O.r
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
		for x=1,10,2 do
			local H=L[x]
			local L=L[x+1]
			if H<8 then H=H+1 end
			if L<8 then L=L+1 end
			S=S..char(H*16+L)
		end
		str=str..S
	end
	love.system.setClipboardText("Techmino sketchpad:"..data.encode("string","base64",data.compress("string","deflate",str)))
	TEXT(text.copySuccess,350,360,40,"appear",.5)
end
function pasteBoard()
	local str=love.system.getClipboardText()
	local fX,fY=1,1--*ptr for Field(r*10+(c-1))
	local _,__
	local p=find(str,":")--ptr*
	if p then str=sub(str,p+1)end
	str=data.decompress("string","deflate",data.decode("string","base64",str))
	p=1
	::LOOP::
		_=byte(str,p)--1byte
		if not _ then
			if fX~=1 then goto ERROR
			else goto FINISH
			end
		end--str end
		__=_%16--low4b
		_=(_-__)/16--high4b
		if _>12 or __>12 then goto ERROR end--illegal blockid
		if _<9 then _=_-1 end if __<9 then __=__-1 end
		preField[fY][fX]=_;preField[fY][fX+1]=__
		if fX<9 then
			fX=fX+2
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
		if players[1].alive then BGM("cruelty")end
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
function pauseGame()
	restartCount=0--Avoid strange darkness
	pauseTimer=0--Pause timer for animation
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
function resumeGame()
	scene.swapTo("play","fade")
end
function loadGame(M)
	--rec={}
	M=modes[M]
	curMode=M
	local lang=setting.lang
	drawableText.modeName:set(M.name[lang])
	drawableText.levelName:set(M.level[lang])
	needResetGameData=true
	scene.swapTo("play","fade_togame")
	SFX("enter")
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
	BGM(modeEnv.bgm)

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
	local m,p=#freeRow,40*#players+1
	while freeRow[p]do
		m,freeRow[m]=m-1
	end
	for i=1,20 do
		virtualkeyDown[i]=X
		virtualkeyPressTime[i]=0
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
local fs=love.filesystem
function loadRecord(N)
	local F=fs.newFile(N..".dat")
	if F:open("r")then
		local s=loadstring(F:read())
		local T={}
		setfenv(s,T)
		T[1]=s()
		return T[1]
	end
end
local function dumpTable(L)
	local s="{\n"
	for k,v in next,L do
		local T
		T=type(k)
			if T=="number"then k="["..k.."]="
			elseif T=="string"then k=k.."="
			else error("Error data type!")
			end
		T=type(v)
			if T=="number"then v=tostring(v)
			elseif T=="string"then v="\""..v.."\""
			elseif T=="table"then v=dumpTable(v)
			else error("Error data type!")
			end
		s=s..k..v..",\n"
	end
	print(s)
	print("---")
	return s.."}"
end
function saveRecord(N,L)
	local F=fs.newFile(N..".dat")
	F:open("w")
	local _=F:write("return"..dumpTable(L))
	F:flush()
	F:close()
	if not _ then
		TEXT(text.recSavingError..mes,640,480,40,"appear",.4)
	end
end
function delRecord(N)
	fs.remove(N..".dat")
end

function saveUnlock()
	local t={}
	local RR=modeRanks
	for i=1,#RR do
		t[i]=RR[i]or"X"
	end
	t=concat(t,",")
	local F=FILE.unlock
	F:open("w")
	local _=F:write(t)
	F:flush()
	F:close()
	if not _ then
		TEXT(text.unlockSavingError..mes,640,480,40,"appear",.4)
	end
end
function loadUnlock()
	local F=FILE.unlock
	F:open("r")
	local t=F:read()
	F:close()
	t=splitS(t,",")
	for i=1,#modeRanks do
		local v=toN(t[i])
		if not v or v<0 or v>6 or v~=int(v)then v=false end
		modeRanks[i]=v
	end
end

local statOpy={
	"run","game","time",
	"extraPiece","extraRate",
	"key","rotate","hold","piece","row",
	"atk","send","recv","pend",
	"clear_1","clear_2","clear_3","clear_4",
	"spin_0","spin_1","spin_2","spin_3",
	"b2b","b3b","pc","score",
}
function loadStat()
	local F=FILE.data
	F:open("r")
	local t=F:read()
	F:close()
	t=splitS(t,"\r\n")
	for i=1,#t do
		local p=find(t[i],"=")
		if p then
			local t,v=sub(t[i],1,p-1),sub(t[i],p+1)
			for i=1,#statOpy do
				if t==statOpy[i]then
					v=toN(v)if not v or v<0 then v=0 end
					stat[t]=v
					break
				end
			end
		end
	end
end
function saveStat()
	local t={}
	for i=1,#statOpy do
		t[i]=statOpy[i].."="..toS(stat[statOpy[i]])
	end

	local R={}
	local RR=modeRanks
	for i=1,#RR do
		R[i]=RR[i]or"X"
	end
	t[#t+1]="rank="..concat(R,",")
	--Save unlock infos

	t=concat(t,"\r\n")
	local F=FILE.data
	F:open("w")
	local _=F:write(t)
	F:flush()
	F:close()
	if not _ then
		TEXT(text.statSavingError..mes,640,480,40,"appear",.4)
	end
end

function loadSetting()
	local F=FILE.setting
	F:open("r")
	local t=F:read()
	F:close()
	t=splitS(t,"\r\n")
	for i=1,#t do
		local p=find(t[i],"=")
		if p then
			local t,v=sub(t[i],1,p-1),sub(t[i],p+1)
			if--10档的设置
				--声音
				t=="sfx"or t=="bgm"or t=="voc"or t=="stereo"or
				--三个触摸设置项
				t=="VKTchW"or t=="VKCurW"or t=="VKAlpha"or
				--重开时间
				t=="reTime"
			then
				v=toN(v)
				if v and v==int(v)and v>=0 and v<=10 then
					setting[t]=v
				end
			elseif t=="vib"then
				setting.vib=toN(v:match("[012345]"))or 0
			elseif t=="fullscreen"then
				setting.fullscreen=v=="true"
				love.window.setFullscreen(setting.fullscreen)
			elseif
				--开关设置们
				t=="bg"or
				t=="ghost"or t=="center"or t=="grid"or t=="swap"or
				t=="quickR"or t=="fine"or t=="bgspace"or t=="smo"or
				t=="VKSwitch"or t=="VKTrack"or t=="VKDodge"or t=="VKIcon"
			then
				setting[t]=v=="true"
			elseif t=="frameMul"then
				setting.frameMul=min(max(toN(v)or 100,0),100)
			elseif t=="das"or t=="arr"or t=="sddas"or t=="sdarr"then
				v=toN(v)if not v or v<0 then v=0 end
				setting[t]=int(v)
			elseif t=="dropFX"or t=="shakeFX"or t=="atkFX"then
				setting[t]=toN(v:match("[012345]"))or 0
			elseif t=="lang"then
				setting[t]=toN(v:match("[123]"))or 1
			elseif t=="skin"then
				setting[t]=toN(v:match("[12345678]"))or 1
			elseif t=="keymap"then
				v=splitS(v,"/")
				for i=1,16 do
					local v1=splitS(v[i],",")
					for j=1,#v1 do
						setting.keyMap[i][j]=v1[j]
					end
				end
			elseif t=="VK"then
				v=splitS(v,"/")
				local SK
				for i=1,#v do
					if v[i]then
						SK=splitS(v[i],",")
						local K=VK_org[i]
						K.ava=SK[1]=="T"
						K.x,K.y,K.r=toN(SK[2]),toN(SK[3]),toN(SK[4])
					end
				end
			end
		end
	end
end
local saveOpt={
	"das","arr",
	"sddas","sdarr",
	"reTime",
	"quickR",
	"swap",
	"fine",

	"ghost","center",
	"smo","grid",
	"dropFX",
	"shakeFX",
	"atkFX",
	"frameMul",

	"fullscreen",
	"bg",
	"bgspace",
	"lang",
	"skin",

	"sfx","bgm",
	"vib","voc",
	"stereo",

	"VKSwitch",
	"VKTrack",
	"VKDodge",
	"VKTchW",
	"VKCurW",
	"VKIcon",
	"VKAlpha",
}
function saveSetting()
	local vk={}--virtualkey table
	for i=1,#VK_org do
		local V=VK_org[i]
		vk[i]=concat({
			V.ava and"T"or"F",
			int(V.x+.5),
			int(V.y+.5),
			V.r,
		},",")
	end--pre-pack virtualkey setting
	local map={}
	for i=1,16 do
		map[i]=concat(setting.keyMap[i],",")
	end
	local t={
		"keymap="..toS(concat(map,"/")),
		"VK="..toS(concat(vk,"/")),
	}
	for i=1,#saveOpt do
		t[#t+1]=saveOpt[i].."="..toS(setting[saveOpt[i]])
	end
	t=concat(t,"\r\n")
	local F=FILE.setting
	F:open("w")
	local _,mes=F:write(t)
	F:flush()
	F:close()
	if _ then
		TEXT(text.settingSaved,370,330,30,"appear")
	else
		TEXT(text.settingSavingError.."123",370,350,20,"appear",.3)
	end
end