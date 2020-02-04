gc,kb,ms,tc,tm,fs,wd=love.graphics,love.keyboard,love.mouse,love.touch,love.timer,love.filesystem,love.window
toN,toS=tonumber,tostring
int,ceil,abs,rnd,max,min,sin,cos,atan,pi=math.floor,math.ceil,math.abs,math.random,math.max,math.min,math.sin,math.cos,math.atan,math.pi
sub,gsub,find,format,byte,char=string.sub,string.gsub,string.find,string.format,string.byte,string.char
ins,rem,sort=table.insert,table.remove,table.sort

--{0,0,0,0,0,0,0,0,0,0}s in freeRow are reset in resetGameData()
function getNewRow(val)
	if not val then val=0 end
	local t=rem(freeRow)
	for i=1,10 do
		t[i]=val or 0
	end
	--clear a row and move to active list
	if #freeRow==0 then
		for i=1,20 do
			ins(freeRow,{0,0,0,0,0,0,0,0,0,0})
		end
	end
	--prepare new rows
	return t
end
function removeRow(t,k)
	ins(freeRow,rem(t,k))
end
function restockRow()
	for p=1,#players do
		local f,f2=players[p].field,players[p].visTime
		while #f>0 do
			removeRow(f,1)
			removeRow(f2,1)
		end
	end
end
--to save cache,all rows pruduced and removed here!

function sortByTime(a,b)
	return a.time>b.time
end

ww,wh=gc.getWidth(),gc.getHeight()

Timer=tm.getTime--Easy&Quick to get time!
mx,my,mouseShow=-20,-20,false
ms.setVisible(false)
focus=true

do
	local l={
		Windows=1,
		Android=2,
	}
	system=l[love.system.getOS()]
	l=nil
end
touching=nil--1st touching ID

scene=""
gamemode=""
bgmPlaying=nil
curBG="none"
BGblock={ct=140}

prevMenu={
	load=love.event.quit,
	ready="mode",
	play="mode",
	mode="main",
	help="main",
	stat="main",
	setting="main",
	setting2="setting",
	setting3="setting",
	intro="quit",
	main="quit",
}

kb.setKeyRepeat(false)
kb.setTextInput(false)
--Disable system key repeat

Text={
	load={"Loading textures","Loading BGM","Loading SFX","Finished",},
	stat={
		"Games run:",
		"Games played:",
		"Game time:",
		"Total block used:",
		"Total rows cleared:",
		"Total lines sent:",
		"Total key pressed:",
		"Total rotate:",
		"Total hold:",
		"Total spin:",
	},
	help={
		"I think you don't need \"help\".",
		"THIS IS NOT TETRIS,and doesn't use SRS.",
		"But just play like playing TOP/C2/KOS/TGM3",
		"Game is not public now,DO NOT DISTIRBUTE",
		"",
		"Powered by LOVE2D",
		"Author:MrZ   E-mail:1046101471@qq.com",
		"Programe:MrZ  Art:MrZ  Music:MrZ  SFX:MrZ",
		"Tool used:VScode,GFIE,Beepbox,Goldwave",
		"Special thanks:TOP,C2,KOS,TGM3,GFIE,and YOU!!",
		"Any bugs/suggestions to me.",
	},
}
numFonts={}
Fonts={}
function numFont(s)
	if numFonts[s]then
		gc.setFont(numFonts[s])
	else
		local t=gc.setNewFont("cb.ttf",s)
		numFonts[s]=t
		gc.setFont(t)
	end
	currentFont=s
end
function setFont(s)
	if s~=currentFont then
		if Fonts[s]then
			gc.setFont(Fonts[s])
		else
			local t=gc.setNewFont("cb.ttf",s)
			Fonts[s]=t
			gc.setFont(t)
		end
		currentFont=s
	end
end

sfx={
	"button",
	"ready","start",
	"move","rotate","rotatekick","hold",
	"prerotate","prehold",
	"drop","fall",
	"reach",
	"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11",
	"clear_1","clear_2","clear_3","clear_4",
	"spin_0","spin_1","spin_2","spin_3",
	"perfectclear",
}
bgm={
	"blank",
	"way",
	"race",
	"push",
	"reason",
}
FX={
	flash=0,--Black screen(frame)
	shake=0,--Screen shake(frame)
	beam={},--Attack beam
	appear=function(t)
		setFont(t.font)
		gc.setColor(1,1,1,min((30-abs(t.t-30))*.05,1)*(#field>9 and .7 or 1))
		mStr(t.text,150,250-t.font*.5+t.dy)
	end,
	fly=function(t)
		setFont(t.font)
		gc.setColor(1,1,1,min((30-abs(t.t-30))*.05,1)*(#field>9 and .7 or 1))
		mStr(t.text,150+(t.t-15)^3*.005,250-t.font*.5+t.dy)
	end,
	stretch=function(t)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,250+t.dy)
			gc.setColor(1,1,1,min((30-abs(t.t-30))*.1,1)*(#field>9 and .7 or 1))
			if t.t<20 then gc.scale((20-t.t)*.015+1,1)end
			mStr(t.text,0,-t.font*.5)
		gc.pop()
	end,
	drive=function(t)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,290+t.dy)
			gc.setColor(1,1,1,min((30-abs(t.t-30))*.1,1)*(#field>9 and .7 or 1))
			if t.t<20 then gc.shear((20-t.t)*.05,0)end
			mStr(t.text,0,-t.font*.5)
		gc.pop()
	end,
	spin=function(t)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,250+t.dy)
			gc.setColor(1,1,1,min((30-abs(t.t-30))*.1,1)*(#field>9 and .7 or 1))
			if t.t<20 then
				gc.rotate((20-t.t)^2*.0015)
			end
			mStr(t.text,0,-t.font*.5)
		gc.pop()
	end,
	flicker=function(t)
		setFont(t.font)
		gc.setColor(1,1,1,min((30-abs(t.t-30))*.05,1)*(#field>9 and .8 or 1)*(rnd()+.5))
		mStr(t.text,150,250-t.font*.5+t.dy)
	end,
}
function stencil_field()
	gc.rectangle("fill",0,-10,300,610)
end
--System data
color={
	red={1,0,0},
	green={0,1,0},
	blue={0,0,1},
	yellow={1,1,0},
	purple={1,0,1},
	cyan={0,1,1},
	white={1,1,1},
	grey={.6,.6,.6},
}
attackColor={
	{color.red,color.yellow},
	{color.red,color.purple},
	{color.blue,color.white},
	animate={
		function(t)
			gc.setColor(1,t,0)
		end,
		function(t)
			gc.setColor(1,0,t)
		end,
		function(t)
			gc.setColor(t,t,1)
		end,
	}--3 animation-colorsets of attack buffer bar
}

require("TRS")--load block&TRS kick
require("lists")--load lists

gameEnv0={
	das=10,arr=2,
	sddas=0,sdarr=2,
	ghost=true,center=true,
	drop=30,lock=45,
	wait=0,fall=20,
	next=6,hold=true,
	sequence=1,visible=1,
	_20G=false,target=9e99,
	freshLimit=9e99,

	key={"left","right","x","z","c","up","down","space","r","LEFT","RIGHT","DOWN"},
	gamepad={"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","leftshoulder","LEFT","RIGHT","DOWN"},
	virtualkey={
		{80,720-80,6400,80},--moveLeft
		{240,720-80,6400,80},--moveRight
		{1280-240,720-80,6400,80},--rotRight
		{1280-400,720-80,6400,80},--rotLeft
		{1280-240,720-240,6400,80},--rotFlip
		{1280-80,720-80,6400,80},--hardDrop
		{1280-80,720-240,6400,80},--softDrop
		{1280-80,720-400,6400,80},--hold
		{80,80,6400,80},--restart
	},
	reach=function()end,
	--these three is actually no use,only provide a key
}
randomMethod={
	function()
		P.bn,P.cb=rem(nxt,1),rem(nb,1)
		if #nxt<6 then
			local bag={1,2,3,4,5,6,7}
			for i=1,7 do
				ins(nxt,rem(bag,rnd(8-i)))
			end
		end
		for i=6,#nxt do
			nb[i]=blocks[nxt[i]][0]
		end
	end,
	function()
		P.bn,P.cb=rem(nxt,1),rem(nb,1)
		for j=1,4 do
			local i,f=rnd(7)
			for k=1,4 do
				if i==his[k]then f=true end
			end
			if not f then break end
		end
		P.nxt[6],P.nb[6]=i,blocks[i][0]
		rem(his,1)ins(his,i)
	end,
	function()
		P.bn,P.cb=rem(nxt,1),rem(nb,1)
		repeat i=rnd(7)until i~=nxt[5]
		P.nxt[6],P.nb[6]=i,blocks[i][0]
	end,
}
loadmode={
	sprint=function()
		modeEnv={
			wait=1,
			fall=1,
			target=40,
			reach=Event.gameover.win,
		}
		createPlayer(1,340,15)
		curBG="game1"
		BGM("race")
	end,
	zen=function()
		modeEnv={
			drop=1e99,
			lock=1e99,
			wait=1,
			fall=1,
			target=200,
			reach=Event.gameover.win,
		}
		createPlayer(1,340,15)
		curBG="strap"
		BGM("reason")
	end,
	gmroll=function()
		modeEnv={
			drop=0,
			lock=15,
			wait=10,
			fall=15,
			_20G=true,
			visible=0,
			freshLimit=15,
			arr=1,
		}
		createPlayer(1,340,15)
		curBG="glow"
		BGM("push")
	end,
	marathon=function()
		modeEnv={
			drop=60,
			wait=1,
			fall=20,
			target=10,
			reach=Event.marathon_reach,
			freshLimit=15,
		}
		createPlayer(1,340,15)
		curBG="strap"
		BGM("way")
	end,
	death=function()
		modeEnv={
			_20G=true,
			drop=0,
			lock=10,
			wait=6,
			fall=10,
			target=50,
			reach=Event.death_reach,
			freshLimit=15,
			arr=1,
		}
		createPlayer(1,340,15)
		curBG="game2"
		BGM("push")
	end,
	tetris21=function()
		modeEnv={
			wait=1,
			fall=1,
		}
		createPlayer(1,340,15)--Player

		local n=2
		for i=1,2 do
			for j=1,5 do
				createPlayer(n,150*i-115,142*j-130,.19,rnd(4)+1)
				n=n+1
			end
		end
		for i=8,9 do
			for j=1,5 do
				createPlayer(n,150*i-210,142*j-130,.19,rnd(4)+1)
				n=n+1
			end
		end--AIs

		curBG="game3"
		BGM("race")
	end,
	solo=function()
		modeEnv={
			wait=1,
			fall=1,
			freshLimit=15,
		}
		createPlayer(1,20,15)--Player
		createPlayer(2,660,85,.9,2)--AI

		curBG="game2"
		BGM("race")
	end,
	blind=function()
		modeEnv={
			drop=15,
			lock=30,
			wait=1,
			fall=1,
			visible=0,
			freshLimit=10,
		}
		createPlayer(1,340,15)

		curBG="glow"
		BGM("push")
	end,
	asymsolo=function()
		modeEnv={
			wait=1,
			fall=1,
			visible=2,
			freshLimit=15,
		}
		createPlayer(1,20,15)--Player
		createPlayer(2,660,85,.9,2)--AI

		curBG="game2"
		BGM("race")
	end,
}
Event={
	gameover={
		win=function()
			P.alive=false
			P.control=false
			P.timing=false
			P.waiting=1e99
			gameover=0
			P.control=false
			ins(task,Event.task.win)
		end,
		lose=function()
			P.alive=false
			P.control=false
			P.timing=false
			P.waiting=1e99
			gameover=0
			for i=1,#players.alive do
				if players.alive[i]==P.id then
					rem(players.alive,i)
					break
				end
			end
			for i=1,#P.atkBuffer do
				P.atkBuffer[i].sent=true
				P.atkBuffer[i].time=0
			end
			ins(task,Event.task.lose)
		end,
	},
	marathon_reach=function()
		local s=int(P.cstat.row*.1)
		if s>=20 then
			Event.gameover.win()
		else
			gameEnv.drop=marathon_drop[s]
			if s==18 then gameEnv._20G=true end
			gameEnv.target=s*10+10
		end
	end,
	death_reach=function()
		if gameEnv.target==250 then
			Event.gameover.win()
		else
			gameEnv.target=gameEnv.target+50
			local t=gameEnv.target/50
			gameEnv.lock=death_lock[t]
			gameEnv.wait=death_wait[t]
			gameEnv.fall=death_fall[t]
			showText("STAGE "..t,"fly",80,-120)
			SFX("reach")
		end
	end,
	task={
		win=function()
			gameover=gameover+1
			if gameover%3==0 then
				local j=gameover/3
				if j<=#field then
					for i=1,10 do
						if field[j][i]>0 then field[j][i]=13 end
					end
					if j==#field then gameover=50 end
				end
			end
			if gameover>80 then
				return true
			end
		end,
		lose=function()
			gameover=gameover+1
			if gameover%3==0 then
				local j=gameover/3
				if field[j]then
					for i=1,10 do
						if field[j][i]>0 then field[j][i]=13 end
					end
				else
					return true
				end
			end
		end,
	},
}
mesDisp={
	--Default:font=40,white
	sprint=function()
		setFont(75)
		mStr(max(40-P.cstat.row,0),-75,280)
	end,
	zen=function()
		setFont(75)
		mStr(max(200-P.cstat.row,0),-75,280)
	end,
	gmroll=function()
		setFont(35)
		gc.print("Tetris",-120,390)
		setFont(80)
		mStr(cstat.tetris,-75,420)
	end,
	marathon=function()
		mStr(P.cstat.row.."/"..gameEnv.target,-75,250)
	end,
	death=function()
		mStr(P.cstat.row.."/"..gameEnv.target,-75,250)
	end,
	tetris21=function()
		gc.print("Remain",-140,450)
		gc.print("Attack",-130,305)
		setFont(80)
		mStr(#players.alive,-75,380)
		mStr(cstat.atk,-75,240)
	end,
	blind=function()
		setFont(35)
		gc.print("Rows",-115,220)
		gc.print("Tetris",-120,390)
		setFont(80)
		mStr(P.cstat.row,-75,250)
		mStr(cstat.tetris,-75,420)
	end,
	solo=function()
		gc.print("Attack",-130,365)
		setFont(80)
		mStr(cstat.atk,-75,300)
	end,
	asymsolo=function()
		gc.print("Attack",-132,365)
		setFont(80)
		mStr(cstat.atk,-75,300)
	end,
}
--Game system Data

setting={
	sfx=true,bgm=true,
	fullscreen=false,
	lang="eng",
	das=10,arr=2,
	sddas=0,sdarr=2,
	ghost=true,center=true,
	key={"left","right","x","z","c","up","down","space","r","LEFT","RIGHT","DOWN"},
	gamepad={"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","leftshoulder","LEFT","RIGHT","DOWN"},
	virtualkey={
		{80,720-80,6400,80},--moveLeft
		{240,720-80,6400,80},--moveRight
		{1280-240,720-80,6400,80},--rotRight
		{1280-400,720-80,6400,80},--rotLeft
		{1280-240,720-240,6400,80},--rotFlip
		{1280-80,720-80,6400,80},--hardDrop
		{1280-80,720-240,6400,80},--softDrop
		{1280-80,720-400,6400,80},--hold
		{80,80,6400,80},--restart
	},
	virtualkeyAlpha=3,
	virtualkeyIcon=true,
}
stat={
	run=0,
	game=0,
	gametime=0,
	piece=0,
	row=0,
	atk=0,
	key=0,
	hold=0,
	rotate=0,
	spin=0,
}
--Userdata tables
require("button")

function string.splitS(s,sep)
	sep=sep or"/"
	local t={}
	repeat
		local i=find(s,sep)or #s+1
		ins(t,sub(s,1,i-1))
		s=sub(s,i+#sep)
	until #s==0
	return t
end
function sgn(i)return i>0 and 1 or i<0 and -1 or 0 end--Row numbe is A-uth-or's id!
function stringPack(s,v)return s..toS(v)end
function without(t,v)
	for i=1,#t do
		if t[i]==v then return nil end
	end
	return true
end
function mStr(s,x,y)gc.printf(s,x-500,y,1000,"center")end
function convert(x,y)
	return x*screenK,(y-screenM)*screenK
end
function sysSFX(s,v)
	if setting.sfx then
		local n=1
		while sfx[s][n]:isPlaying()do
			n=n+1
			if not sfx[s][n]then
				sfx[s][n]=sfx[s][n-1]:clone()
				sfx[s][n]:seek(0)
			end
		end
		sfx[s][n]:setVolume(v or 1)
		sfx[s][n]:play()
	end
end
function SFX(s,v)
	if setting.sfx then
		local n=1
		while sfx[s][n]:isPlaying()do
			n=n+1
			if not sfx[s][n]then
				sfx[s][n]=sfx[s][n-1]:clone()
				sfx[s][n]:seek(0)
			end
		end
		if P.id>1 then
			v=1/(#players.alive-1)
		end
		sfx[s][n]:setVolume(v or 1)
		sfx[s][n]:play()
	end
end
function BGM(s)
	if setting.bgm and bgmPlaying~=s then
		for k,v in pairs(bgm)do v:stop()end
		if s then bgm[s]:play()end
		bgmPlaying=s
	end
end
--System functions

function gotoScene(s,style)
	if not sceneSwaping and s~=scene then
		style=style or"deck"
		sceneSwaping={
			tar=s,style=style,
			time=swap[style][1],mid=swap[style][2],
			draw=swap[style].d
		}
		Buttons.sel=nil
	end
end
function resetGameData()
	if players then restockRow()end--Avoid first start game error
	players={alive={}}
	loadmode[gamemode]()

	frame=0
	count=179
	FX.beam={}
	for i=1,#PTC.dust do PTC.dust[i]=nil end
	for i=1,#players do
		PTC.dust[i]=PTC.dust[0]:clone()
		PTC.dust[i]:start()
	end
	for i=1,#virtualkey do
		virtualkey[i].press=false
	end
	stat.game=stat.game+1

	freeRow={}
	collectgarbage()
	for i=1,50*#players do
		freeRow[i]={0,0,0,0,0,0,0,0,0,0}
	end
end
function startGame(mode)
	--rec=""
	gamemode=mode
	gotoScene("play")
end
function back()
	local t=prevMenu[scene]
	if type(t)=="string"then
		gotoScene(t)
	else
		t()
	end
end
function loaddata()
	userdata:open("r")
    --local t=string.splitS(love.math.decompress(userdata,"zlib"),"\r\n")
	local t=string.splitS(userdata:read(),"\r\n")
	userdata:close()
	for i=1,#t do
		local i=t[i]
		if find(i,"=")then
			local t=sub(i,1,find(i,"=")-1)
			local v=sub(i,find(i,"=")+1)
			if t=="sfx"or t=="bgm"then
				setting[t]=v=="true"
			elseif t=="fullscreen"then
				setting.fullscreen=v=="true"
				love.window.setFullscreen(setting.fullscreen)
			elseif t=="keyset"then
				v=string.splitS(v)
				for i=#v+1,8 do v[i]="N/A"end
				setting.key=v
			elseif t=="virtualkey"then
				v=string.splitS(v,"/")
				for i=1,9 do
					virtualkey[i]=string.splitS(v[i],",")
					for j=1,4 do
						virtualkey[i][j]=toN(virtualkey[i][j])
					end
				end
			elseif t=="virtualkeyAlpha"then
				setting.virtualkeyAlpha=int(abs(toN(v)))
			elseif t=="virtualkeyIcon"then
				setting.virtualkeyIcon=v=="true"
			--Settings
			elseif t=="das"or t=="arr"or t=="sddas"or t=="sdarr"then
				v=toN(v)if not v or v<0 then v=0 end
				setting[t]=int(v)
			elseif t=="ghost"or t=="center"then
				setting[t]=v=="true"
			elseif t=="run"or t=="game"or t=="gametime"or t=="piece"or t=="row"or t=="atk"or t=="key"or t=="rotate"or t=="hold"or t=="spin"then
				v=toN(v)if not v or v<0 then v=0 end
				stat[t]=v
			--Statistics
			end
		end
	end
end
function savedata()
	local vk={}
	for i=1,9 do
		for j=1,4 do
			virtualkey[i][j]=int(virtualkey[i][j]+.5)
		end--Saving a integer is better?
		vk[i]=table.concat(virtualkey[i],",")
	end--pre-pack virtualkey setting

	local t=table.concat({
		stringPack("sfx=",setting.sfx),
		stringPack("bgm=",setting.bgm),
		stringPack("fullscreen=",setting.fullscreen),

		stringPack("run=",stat.run),
		stringPack("game=",stat.game),
		stringPack("gametime=",stat.gametime),
		stringPack("piece=",stat.piece),
		stringPack("row=",stat.row),
		stringPack("atk=",stat.atk),
		stringPack("key=",stat.key),
		stringPack("rotate=",stat.rotate),
		stringPack("hold=",stat.hold),
		stringPack("spin=",stat.spin),
		stringPack("das=",setting.das),
		stringPack("arr=",setting.arr),
		stringPack("sddas=",setting.sddas),
		stringPack("sdarr=",setting.sdarr),
		stringPack("keyset=",table.concat(setting.key,"/")),
		stringPack("virtualkey=",table.concat(vk,"/")),
		stringPack("virtualkeyAlpha=",setting.virtualkeyAlpha),
		stringPack("virtualkeyIcon=",setting.virtualkeyIcon),
	},"\r\n")
	--t=love.math.compress(t,"zlib"):getString()
	userdata:open("w")
	userdata:write(t)
	userdata:close()
end
--System events
function createPlayer(id,x,y,size,AIspeed,data)
	players[id]={id=id}
	ins(players.alive,id)
	local P=players[id]
	P.index={__index=P}
	P.x,P.y,P.size=x,y,size or 1

	if AIspeed then
		P.ai={
			controls={},
			controlDelay=60,
			controlDelay0=AIspeed,
		}
	end

	P.alive=true
	P.control=false
	P.timing=false
	P.time=0
	P.cstat={key=0,piece=0,row=0,atk=0,tetris=0}--Current gamestat
	P.keyTime={}for i=1,10 do P.keyTime[i]=-1e5 end P.keySpeed=0
	P.dropTime={}for i=1,10 do P.dropTime[i]=-1e5 end P.dropSpeed=0

	P.gameEnv={}--Game setting vars,like dropDelay setting
	for k,v in pairs(gameEnv0)do
		if data and data[k]~=nil then
			P.gameEnv[k]=data[k]
		elseif modeEnv[k]~=nil then
			P.gameEnv[k]=modeEnv[k]
		elseif setting[k]~=nil then
			P.gameEnv[k]=setting[k]
		else
			P.gameEnv[k]=v
		end
	end--reset current game settings

	P.field,P.visTime,P.atkBuffer={},{},{}
	P.hn,P.hb,P.holded=0,{{}},false
	P.nxt,P.nb={},{}
	P.dropDelay,P.lockDelay=P.gameEnv.drop,P.gameEnv.lock
	P.freshTime=0
	P.lastSpin=false

	local bag1={1,2,3,4,5,6,7}
	for i=1,7 do
		P.nxt[i]=rem(bag1,rnd(#bag1))
		P.nb[i]=blocks[P.nxt[i]][0]
	end--First bag

	if P.gameEnv.sequence==1 then P.bag={}--Bag7
	elseif P.gameEnv.sequence==2 then P.his={}for i=1,4 do P.his[i]=P.nxt[i+3]end--History4
	elseif P.gameEnv.sequence==3 then--Pure random
	end
	P.showTime=P.gameEnv.visible==1 and 1e99 or P.gameEnv.visible==2 and 300 or 20
	P.freshNext=randomMethod[P.gameEnv.sequence]
	P.cb,P.sc,P.bn,P.r,P.c,P.cx,P.cy,P.dir,P.y_img={{}},{0,0},1,0,0,0,0,0,0
	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.moving,P.downing=0,0
	P.waiting,P.falling=0,0
	P.clearing={}
	P.fieldBeneath=0

	P.combo=0
	P.b2b=0
	P.b2b1=0

	P.task={}
	P.bonus={}
end
function showText(text,type,font,dy)
	ins(P.bonus,{t=0,text=text,draw=FX[type],font=font,dy=dy or 0})
end
function createBeam(s,r,level)--Player id
	s,r=players[s],players[r]
	ins(FX.beam,{
		s.x+(30*(cx+sc[2]-1)-30+15+150)*s.size,
		s.y+(600-30*(cy+sc[1]-1)+15+70)*s.size,
		r.x+308*r.size,
		r.y+450*r.size,
		t=0,
		lv=level,
	})
end
function freshgho()
	if not P.gameEnv._20G then
		P.y_img=P.cy>#field+1 and #field+1 or P.cy
		while not ifoverlap(cb,cx,y_img-1)do
			P.y_img=P.y_img-1
		end
	else
		while not ifoverlap(cb,cx,cy-1)do
			P.cy=P.cy-1
			P.spinLast=false
		end
		P.y_img=P.cy
	end
end
function freshLockDelay()
	if P.lockDelay<gameEnv.lock and P.freshTime<=gameEnv.freshLimit then
		P.lockDelay=gameEnv.lock
		P.freshTime=P.freshTime+1
	end
end
function ifoverlap(bk,x,y)
	if x<1 or x+#bk[1]>11 or y<1 then return true end
	if y>#field then return nil end
	for i=1,#bk do for j=1,#bk[1]do
		if field[y+i-1]and bk[i][j]>0 and field[y+i-1][x+j-1]>0 then return true end
	end end
end
function ckfull(i)
	for j=1,10 do if field[i][j]==0 then return nil end end
	return true
end
function checkrow(s,num)--(cy,r)
	local c=0--rows cleared
	for i=s,s+num-1 do if ckfull(i)then
		ins(clearing,1,i)
		P.falling=gameEnv.fall
		c=c+1--row cleared+1
		for k=1,250 do
			PTC.dust[P.id]:setPosition(rnd(300),600-30*i+rnd(30))
			PTC.dust[P.id]:emit(1)
		end
	end end
	return c
end
function solid(x,y)
	if x<1 or x>10 or y<1 then return true end
	if y>#field then return false end
	return field[y][x]>0
end
function resetblock()
	P.holded=false
	P.spinLast=false
	P.freshNext()
	P.sc,P.dir=scs[bn][0],0
	P.r,P.c=#cb,#cb[1]
	P.cx,P.cy=blockPos[bn],21+ceil(fieldBeneath/30)
	P.dropDelay,P.lockDelay,P.freshTime=gameEnv.drop,gameEnv.lock,0
	if keyPressing[8]then hold(true)end
	if keyPressing[3]then spin(1,true)end
	if keyPressing[4]then spin(-1,true)end
	if keyPressing[5]then spin(2,true)end
	if ifoverlap(cb,cx,cy)then lock()Event.gameover.lose()end
	freshgho()
	if keyPressing[6]then act.hardDrop()P.keyPressing[6]=false end
end
function pressKey(i,player)
	P=player or players[1]
	setmetatable(_G,P.index)
	P.keyPressing[i]=true
	if i==9 then
		act.restart()
	elseif alive then
		if control and waiting<=0 then
			act[actName[i]]()
			if i>2 and i<6 then keyPressing[i]=false end
		elseif i==1 then
			P.moving=-1
		elseif i==2 then
			P.moving=1
		end

		ins(keyTime,1,frame)rem(keyTime,11)
		cstat.key=cstat.key+1
		if not player then stat.key=stat.key+1 end
		--Key count
	end
	-- if playmode=="recording"then ins(rec,{i,frame})end
end
function releaseKey(i,player)
	P=player or players[1]
	setmetatable(_G,P.index)
	P.keyPressing[i]=false
	-- if playmode=="recording"then ins(rec,{-i,frame})end
end
function spin(d,ifpre)
	-- if bn==6 then return nil end--Ignore O spin
	local icb=blocks[bn][(dir+d)%4]
	local isc=d==1 and{c-sc[2]+1,sc[1]}or d==-1 and{sc[2],r-sc[1]+1}or{r-sc[1]+1,c-sc[2]+1}
	local ir,ic=#icb,#icb[1]
	local ix,iy=cx+sc[2]-isc[2],cy+sc[1]-isc[1]
	local t=false--if spin available
	local iki=TRS[bn][dir*10+(dir+d)%4]
	for i=1,#iki do
		if not ifoverlap(icb,ix+iki[i][1],iy+iki[i][2])then
			ix,iy=ix+iki[i][1],iy+iki[i][2]
			t=true
			break
		end
	end
	if t then
		P.cx,P.cy=ix,iy
		P.sc,P.cb=isc,icb
		P.r,P.c=ir,ic
		P.dir=(dir+d)%4
		P.spinLast=true
		freshgho()--May cancel spinLast
		freshLockDelay()
		SFX(ifpre and"prerotate"or ifoverlap(cb,cx,cy+1)and ifoverlap(cb,cx-1,cy)and ifoverlap(cb,cx+1,cy)and"rotatekick"or"rotate")
		stat.rotate=stat.rotate+1
	end
end
function hold(ifpre)
	if not holded and waiting<=0 and gameEnv.hold then
		P.hn,P.bn=bn,hn
		P.hb,P.cb=blocks[hn][0],hb

		if bn==0 then freshNext()end
		P.sc,P.dir=scs[bn][0],0
		P.r,P.c=#cb,#cb[1]
		P.cx,P.cy=blockPos[bn],21+ceil(fieldBeneath/30)
		freshgho()
		P.dropDelay,P.lockDelay,P.freshTime=gameEnv.drop,gameEnv.lock,0
		if ifoverlap(cb,cx,cy) then lock()Event.gameover.lose()end
		P.holded=true
		SFX(ifpre and"prehold"or"hold")
		stat.hold=stat.hold+1
	end
end
function drop()
	if cy==y_img then
		ins(dropTime,1,frame)rem(dropTime,11)--update speed dial
		P.waiting=gameEnv.wait
		local dospin=bn~=6 and ifoverlap(cb,cx-1,cy)and ifoverlap(cb,cx+1,cy)and ifoverlap(cb,cx,cy+1)
		if bn<6 and not dospin and bn<6 and spinLast then
			local x,y=cx+sc[2]-1,cy+sc[1]-1
			local c=0
			if solid(x-1,y+1)then c=c+1 end
			if solid(x+1,y+1)then c=c+1 end
			if c>0 then
				if solid(x-1,y-1)then c=c+1 end
				if solid(x+1,y-1)then c=c+1 end
				if c>2 then
					dospin=true
				end
			end
		end--Triangle spin system
		lock()
		local cc,csend,sendTime=checkrow(cy,r),0,0--Currect clear&send&sendTime
		local mini=dospin and cc<r

		P.combo=P.combo+1--combo=0 is under
		if cc==4 then
			if b2b>480 then
				showText("Tetris B2B2B","fly",70)
				csend=7
			elseif b2b>=100 then
				showText("Tetris B2B","drive",70)
				csend=5
			else
				showText("Tetris","stretch",80)
				csend=4
			end
			P.b2b=P.b2b+100
			sendTime=120
			P.cstat.tetris=P.cstat.tetris+1
		elseif cc>0 then
			if dospin then
				local t=blockName[bn].." spin "..clearName[cc]
				if b2b>480 then
					t=t.." B2B2B"
					showText(t,"spin",40)
					csend=b2bATK[cc]+1
				elseif b2b>=100 then
					t=t.." B2B"
					showText(t,"spin",40)
					csend=b2bATK[cc]
				else
					showText(t,"spin",50)
					csend=2*cc
				end
				sendTime=csend*35
				if mini then
					showText("Mini","drive",40,10)
					sendTime=sendTime+60
					P.b2b=P.b2b+90+10*cc
				else
					P.b2b=P.b2b+80+20*cc
				end
				SFX("spin_"..cc)
				stat.spin=stat.spin+1
			elseif #clearing<#field then
				P.b2b=P.b2b-300
				showText(clearName[cc],"appear",50)
				csend=cc-1
				sendTime=20+csend*20
			end
		else
			P.combo=0
			if dospin then
				showText(blockName[bn].." spin","appear",50)
				SFX("spin_0")
				P.b2b=b2b+30
			end
		end

		if cc>0 and #clearing==#field then
			showText("Perfect Clear","flicker",70)
			csend=csend+6
			sendTime=sendTime+30
			SFX("perfectclear")
			P.b2b=b2b+100
		end
		csend=csend+(renATK[combo]or 4)
		sendTime=sendTime+20*combo
		if cc>0 then
			SFX("clear_"..cc)
			SFX("ren_"..min(combo,11))
		end

		if b2b<0 then
			P.b2b=0
		elseif b2b>600 then
			P.b2b=600
		end

		if csend>0 then
			if mini then csend=int(csend*.7)end
			--mini attack decrease

			stat.atk=stat.atk+csend
			P.cstat.atk=P.cstat.atk+csend
			--ATK statistics

			while csend>0 and P.atkBuffer[1]do
				csend=csend-1
				P.atkBuffer[1].amount=P.atkBuffer[1].amount-1
				if P.atkBuffer[1].amount==0 then
					rem(P.atkBuffer,1)
				end
			end
			if csend>0 and #players.alive>1 then garbageSend(P.id,csend,sendTime)end
		elseif cc==0 then
			garbageRelease()
		end--Send attack
		stat.piece,stat.row=stat.piece+1,stat.row+cc
		P.cstat.piece,P.cstat.row=P.cstat.piece+1,P.cstat.row+cc
		if P.cstat.row>=gameEnv.target then
			gameEnv.reach()
			if control then SFX("reach")end
		end
	else
		P.cy=cy-1
		P.spinLast=false
	end
end
function lock()
	for i=1,r do
		local y=cy+i-1
		if not P.field[y]then P.field[y],P.visTime[y]=getNewRow(),getNewRow()end
		for j=1,c do
			if cb[i][j]~=0 then
				P.field[y][cx+j-1]=P.bn
				P.visTime[y][cx+j-1]=P.showTime
			end
		end
	end
end
function garbageSend(sender,send,time)
	local pos,r=rnd(10)
	local level=send<4 and 1 or send<7 and 2 or 3
	repeat
		r=players.alive[rnd(#players.alive)]
	until r~=P.id
	createBeam(sender,r,level)
	ins(players[r].atkBuffer,{pos,amount=send,countdown=time,cd0=time,time=0,sent=false,lv=level})
	sort(players[r].atkBuffer,sortByTime)
end
function garbageRelease()
	local t=P.showTime*2
	for i=1,#P.atkBuffer do
		local atk=P.atkBuffer[i]
		if not atk.sent and atk.countdown==0 then
			for j=1,atk.amount do
				ins(P.field,1,getNewRow(13))
				ins(P.visTime,1,getNewRow(t))
				for k=1,#atk do
					P.field[1][atk[k]]=0
				end
			end
			atk.sent=true
			atk.time=0
			P.fieldBeneath=P.fieldBeneath+atk.amount*30
		end
	end
end

--------------------------------Warning!_G is __indexed to players[n]!

require("user_actions")--Game control functions

mouseDown={}
keyDown={}
function keyDown.play(key)
	local k=players[1].gameEnv.key
	for i=1,11 do
		if key==k[i]then
			pressKey(i)
			break
		end
	end
	if key=="escape"then back()end
end
function keyDown.setting2(key)
	if key=="escape"then
		back()
		keysetting,gamepadsetting=nil
	elseif keysetting then
		setting.key[keysetting]=key
		keysetting,gamepadsetting=nil
	else
		buttonControl_key(key)
	end
end
keyUp={}
function keyUp.play(key)
	local k=players[1].gameEnv.key
	for i=1,10 do
		if key==k[i]then
			releaseKey(i,players[1])
			break
		end
	end
end
gamepadDown={}
function gamepadDown.play(key)
	local k=players[1].gameEnv.gamepad
	for i=1,11 do
		if key==k[i]then
			pressKey(i)
			break
		end
	end
	if key=="escape"then back()end
end
function gamepadDown.setting2(key)
	if key=="back"then
		back()
		keysetting,gamepadsetting=nil
	elseif gamepadsetting then
		setting.gamepad[gamepadsetting]=key
		keysetting,gamepadsetting=nil
	else
		buttonControl_gamepad(key)
	end
end
gamepadUp={}
function gamepadUp.play(key)
	local k=players[1].gameEnv.gamepad
	for i=1,10 do
		if key==k[i]then
			releaseKey(i,players[1])
			break
		end
	end
end
wheelmoved={}
--Warning,these are not system callbacks!

require("BGblock")--BG block module
require("ai")--AI module
require("timer")--Timer
require("paint")--Paint
require("game_scene")--Game scenes swapping
require("control")--User system control

function love.update(dt)
	--[[
	if players then
		for k,v in pairs(players[1])do
			if rawget(_G,k)then print(k)end
		end
	end--check player data flew(debugging)
	]]
	for i=#BGblock,1,-1 do
		BGblock[i].y=BGblock[i].y+BGblock[i].v
		if BGblock[i].y>720 then rem(BGblock,i)end
	end
	BGblock.ct=BGblock.ct-1
	if BGblock.ct==0 then
		ins(BGblock,getNewBlock())
		BGblock.ct=rnd(20,30)
	end
	--Background blocks update

	if sceneSwaping then
		sceneSwaping.time=sceneSwaping.time-1
		if sceneSwaping.time==sceneSwaping.mid then
			for i=1,#Buttons[scene]do
				Buttons[scene][i].alpha=0
			end--Reset buttons' state
			game[sceneSwaping.tar]()
			Buttons.sel=nil
		elseif sceneSwaping.time==0 then
			sceneSwaping=nil
		end
	elseif Tmr[scene]then
		Tmr[scene](dt)
	end
	--scene swapping & Timer
end
function love.draw()
	Pnt.BG[curBG]()
	gc.setColor(1,1,1,.3)
	for n=1,#BGblock do
		local b,img=BGblock[n].b,blockSkin[BGblock[n].bn]
		local size=BGblock[n].size
		for i=1,#b do for j=1,#b[1]do
			if b[i][j]>0 then
				gc.draw(img,BGblock[n].x+(j-1)*30*size,BGblock[n].y+(i-1)*30*size,nil,size)
			end
		end end--Block
	end
	if Pnt[scene]then Pnt[scene]()end
	setFont(40)
	drawButton()
	if mouseShow and not touching then
		gc.setColor(1,1,1)
		gc.draw(mouseIcon,mx,my,nil,nil,nil,10,10)
	end
	if sceneSwaping then sceneSwaping.draw()end

	gc.setColor(0,0,0)
	if screenM>0 then
		gc.rectangle("fill",0,0,1280,-screenM)
		gc.rectangle("fill",0,720,1280,screenM)
	end--Draw black side

	numFont(20)gc.setColor(1,1,1)
	gc.print(tm.getFPS(),0,700)
	gc.print(gcinfo(),0,680)
	--if gcinfo()>500 then collectgarbage()end
end
function love.resize(x,y)
	screenK=1280/gc.getWidth()
	screenM=(gc.getHeight()*16/9-gc.getWidth())/2
	gc.origin()
	gc.scale(1/screenK,1/screenK)
	gc.translate(0,screenM)
end 
function love.run()
	local frameT=Timer()
	tm.step()
	love.resize(nil,gc.getHeight())
	game.load()--System scene Launch
	math.randomseed(os.time()*626)--true  A-lthour's  ID!
	return function()
		love.event.pump()
		for name,a,b,c,d,e,f in love.event.poll()do
			if name=="quit"then return 0 end
			love.handlers[name](a,b,c,d,e,f)
		end
		if focus then
			tm.step()
			love.update(tm.getDelta())
			gc.clear()
			love.draw()
			gc.present()
			if not wd.hasFocus()then
				focus=false
				ms.setVisible(true)
				if bgmPlaying then bgm[bgmPlaying]:pause()end
				if scene=="play"then
					for i=1,#players[1].keyPressing do
						if players[1].keyPressing[i]then
							releaseKey(i)
						end
					end
				end
			end
		else
			tm.sleep(.1)
			if wd.hasFocus()then
				focus=true
				ms.setVisible(false)
				if bgmPlaying then bgm[bgmPlaying]:play()end
			end
		end
		while Timer()-frameT<1/60 do end
		frameT=Timer()
	end
end
--System callbacks

do--Texture/Image
	titleImage=gc.newImage("/image/title.png")
	mouseIcon=gc.newImage("/image/mouseIcon.png")
	blockSkin={}
	for i=1,13 do
		blockSkin[i]=gc.newImage("/image/block/1/"..i..".png")
	end
	background={}
	gc.setColor(1,1,1)
	background={}
	for i=1,2 do
		background[i]=gc.newImage("/image/BG/"..i..".png")
	end
	virtualkeyIcon={}
	for i=1,9 do
		virtualkeyIcon[i]=gc.newImage("/image/virtualkey/"..(actName[i])..".png")
	end
end
do--Particle
	PTC={dust={}}--Particle systems
	c=gc.newCanvas(6,6)gc.setCanvas(c)
	gc.clear(1,1,1)
	PTC.dust[0]=gc.newParticleSystem(c,1000)
	PTC.dust[0]:setParticleLifetime(.2,.3)
	PTC.dust[0]:setEmissionRate(0)
	PTC.dust[0]:setLinearAcceleration(-1500,-200,1500,200)
	PTC.dust[0]:setColors(1,1,1,.5,1,1,1,0)
	c:release()
	--Dust particles

	PTC.attack={}
	PTC.attack[1]=gc.newParticleSystem(gc.newImage("/image/attack/1.png"),200)
	PTC.attack[1]:setParticleLifetime(.25)
	PTC.attack[1]:setEmissionRate(0)
	PTC.attack[1]:setSpin(10)
	PTC.attack[1]:setColors(1,1,1,.7,1,1,1,0)

	PTC.attack[2]=gc.newParticleSystem(gc.newImage("/image/attack/2.png"),200)
	PTC.attack[2]:setParticleLifetime(.3)
	PTC.attack[2]:setEmissionRate(0)
	PTC.attack[2]:setSpin(8)
	PTC.attack[2]:setColors(1,1,1,.7,1,1,1,0)

	PTC.attack[3]=gc.newParticleSystem(gc.newImage("/image/attack/3.png"),200)
	PTC.attack[3]:setParticleLifetime(.4)
	PTC.attack[3]:setEmissionRate(0)
	PTC.attack[3]:setSpin(6)
	PTC.attack[3]:setColors(1,1,1,.7,1,1,1,0)
	--Attack particles

	gc.setCanvas()
end
c=nil

userdata=fs.newFile("userdata")
if fs.getInfo("userdata")then
	loaddata()
end

stat.run=stat.run+1