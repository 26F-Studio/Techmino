gc,kb,ms,tc,tm,fs,wd,sys=love.graphics,love.keyboard,love.mouse,love.touch,love.timer,love.filesystem,love.window,love.system
toN,toS=tonumber,tostring
int,ceil,abs,rnd,max,min,sin,cos,atan,pi=math.floor,math.ceil,math.abs,math.random,math.max,math.min,math.sin,math.cos,math.atan,math.pi
sub,gsub,find,format,byte,char=string.sub,string.gsub,string.find,string.format,string.byte,string.char
ins,rem,sort=table.insert,table.remove,table.sort

ww,wh=gc.getWidth(),gc.getHeight()
Timer=tm.getTime--Easy&Quick to get time!
mx,my,mouseShow=-20,-20,false
focus=true

system=sys.getOS()
touching=nil--1st touching ID

scene=""
gamemode=""
bgmPlaying=nil
curBG="none"
BGblock={ct=140,next=7}

kb.setKeyRepeat(false)
kb.setTextInput(false)
ms.setVisible(false)

Fonts={}
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
	--not all is actually used,some only provide a key
}
randomMethod={
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		if #P.nxt<6 then
			local bag={1,2,3,4,5,6,7}
			for i=1,7 do
				ins(P.nxt,rem(bag,rnd(8-i)))
			end
		end
		for i=6,#P.nxt do
			P.nb[i]=blocks[P.nxt[i]][0]
		end
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		for j=1,4 do
			local i,f=rnd(7)
			for k=1,4 do
				if i==P.his[k]then f=true end
			end
			if not f then break end
		end
		P.nxt[6],P.nb[6]=i,blocks[i][0]
		rem(P.his,1)ins(P.his,i)
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		repeat i=rnd(7)until i~=P.nxt[5]
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
	tetris41=function()
		modeEnv={
			wait=1,
			fall=1,
		}
		royaleMode=true
		createPlayer(1,340,15)--Player

		local n=2
		for i=1,4 do
			for j=1,5 do
				createPlayer(n,75*i-48,142*j-130,.19,1+rnd(14))
				n=n+1
			end
		end
		for i=9,12 do
			for j=1,5 do
				createPlayer(n,75*i+292,142*j-130,.19,1+rnd(14))
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
		createPlayer(2,660,85,.9,1)--AI

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
	p2=function()
		modeEnv={
			wait=1,
			fall=30,
			freshLimit=15,
		}
		createPlayer(1,20,15)
		createPlayer(2,650,15)

		curBG="game2"
		BGM("way")
	end,
	p3=function()
		modeEnv={
			wait=1,
			fall=30,
			freshLimit=15,
		}
		createPlayer(1,20,100,.65)
		createPlayer(2,435,100,.65)
		createPlayer(3,850,100,.65)

		curBG="game2"
		BGM("way")
	end,
	p4=function()
		modeEnv={
			wait=1,
			fall=30,
			freshLimit=15,
		}
		createPlayer(1,25,150,.5)
		createPlayer(2,335,150,.5)
		createPlayer(3,645,150,.5)
		createPlayer(4,955,150,.5)

		curBG="game2"
		BGM("way")
	end,
}
Event={
	gameover={
		win=function()
			P.alive=false
			P.control=false
			P.timing=false
			P.waiting=1e99
			P.result="WIN"
			P.b2b=0
			for i=1,#field do
				for j=1,10 do
					visTime[i][j]=min(visTime[i][j],20)
				end
			end
			showText("WIN","appear",100,nil,true)
			ins(task,Event.task.win)
		end,
		lose=function()
			P.alive=false
			P.control=false
			P.timing=false
			P.result=" K.O."
			P.waiting=1e99
			P.b2b=0
			showText("LOSE","appear",100,nil,true)
			if royaleMode and P.lastRecv then
				throwBadge(P.id,P.lastRecv,P.badge)
				players[P.lastRecv].badge=players[P.lastRecv].badge+P.badge+1
				players[P.lastRecv].strength=min(int(players[P.lastRecv].badge*.2),4)
			end
			for i=1,#players.alive do
				if players.alive[i]==P.id then
					rem(players.alive,i)
					if #players.alive==1 then
						ins(players[players.alive[1]].task,Event.task.winTrigger)
					end
					break
				end
			end
			for i=1,#P.atkBuffer do
				P.atkBuffer[i].sent=true
				P.atkBuffer[i].time=0
			end
			for i=1,#field do
				for j=1,10 do
					visTime[i][j]=min(visTime[i][j],20)
				end
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
		winTrigger=function()
			Event.gameover.win()
			return true
		end,
		win=function()
			P.counter=P.counter+1
			if P.counter>60 then
				for i=1,#field do
					for j=1,10 do
						if visTime[i][j]>0 then
							visTime[i][j]=visTime[i][j]-1
						end
					end
				end
				if P.counter==100 then
					for i=1,#field do
						removeRow(field)
						removeRow(visTime)
					end
					return true
				end
			end
		end,
		lose=function()
			P.counter=P.counter+1
			if P.counter>60 then
				for i=1,#P.field do
					for j=1,10 do
						if P.visTime[i][j]>0 then
							P.visTime[i][j]=P.visTime[i][j]-1
						end
					end
				end
				if P.counter==100 then
					for i=1,#P.field do
						removeRow(P.field)
						removeRow(P.visTime)
					end
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
		setFont(50)
		mStr(P.cstat.row,-75,330)
		mStr(gameEnv.target,-75,380)
		gc.line(-120,377,-30,377)
	end,
	death=function()
		setFont(50)
		mStr(P.cstat.row,-75,330)
		mStr(gameEnv.target,-75,380)
		gc.line(-120,377,-30,377)
	end,
	tetris41=function()
		gc.draw(badgeIcon,-120,150,nil,1.5)
		setFont(50)
		gc.print(badge,-65,150)
		mStr(cstat.atk,-75,320)
		mStr(#players.alive,-75,430)
		setFont(20)
		gc.print("Attack",-103,360)
		gc.print("Remain",-105,472)
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
	bgblock=true,
	lang="eng",
	das=10,arr=2,
	sddas=0,sdarr=2,
	ghost=true,center=true,
	keyMap={
		{"left","right","x","z","c","up","down","space","r","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","leftshoulder","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
		{"","","","","","","","","","","",""},
	},--keyboard & joystick
	keyLib={
		{1},
		{2},
		{3},
		{4},
	},--Players' key setting(s)
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
	virtualkeySwitch=false,
	frameMul=100,
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
--User Data&User Setting
--------------------------------Warning!_G is __indexed to players[n] when changing any player's data!
require("list")
require("texture")
require("ai")
require("toolfunc")
require("sysfunc")
require("gamefunc")
require("timer")
require("paint")
require("game_scene")
require("call&sys")

userData=fs.newFile("userdata")
userSetting=fs.newFile("usersetting")
if fs.getInfo("userdata")then
	loadData()
end
if fs.getInfo("usersetting")then
	loadSetting()
elseif system=="Android" or system=="iOS"then
	setting.virtualkeySwitch=true
end