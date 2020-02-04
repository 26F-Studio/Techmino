lib={
	gc=love.graphics,
	kb=love.keyboard,
	ms=love.mouse,
	tc=love.touch,
	tm=love.timer,
	fs=love.filesystem,
	wd=love.window,
	mt=love.math,
	sys=love.system,
}for k,v in pairs(lib)do _G[k]=v end lib=nil
toN,toS=tonumber,tostring
int,ceil,abs,rnd,max,min,sin,cos,atan,pi=math.floor,math.ceil,math.abs,math.random,math.max,math.min,math.sin,math.cos,math.atan,math.pi
sub,gsub,find,format,byte,char=string.sub,string.gsub,string.find,string.format,string.byte,string.char
ins,rem,sort=table.insert,table.remove,table.sort
null=function()end

ww,wh=gc.getWidth(),gc.getHeight()
Timer=tm.getTime--Easy&Quick to get time!
mx,my,mouseShow=-20,-20,false
xOy=love.math.newTransform()
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
			local t=gc.setNewFont("siyuanhei.otf",s-5)
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
	wait=1,fall=1,
	next=6,hold=true,
	sequence=1,visible=1,
	_20G=false,target=1e99,
	freshLimit=1e99,
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
	reach=null,
	--not all is actually used,some only provide a key
}
customSel={
	drop=20,
	lock=20,
	wait=1,
	fall=1,
	next=7,
	hold=1,
	sequence=1,
	visible=1,
	target=4,
	freshLimit=3,
	opponent=1,
}
freshMethod={
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		if #P.nxt<6 then
			local bag={1,2,3,4,5,6,7}
			for i=1,7 do
				ins(P.nxt,rem(bag,rnd(8-i)))
				ins(P.nb,blocks[P.nxt[#P.nxt]][0])
			end
		end
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		local i,j=nil,0
		repeat
			i,j=rnd(7),j+1
		until not(i==P.his[1]or i==P.his[2]or i==P.his[3]or i==P.his[4])
		P.nxt[6],P.nb[6]=i,blocks[i][0]
		rem(P.his,1)ins(P.his,i)
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		repeat i=rnd(7)until i~=P.nxt[5]
		P.nxt[6],P.nb[6]=i,blocks[i][0]
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		if #P.nxt<6 then
			local bag={1,2,3,4,5,6,7}
			repeat
				local i=rem(bag,rnd(#bag))
				ins(P.nxt,i)
				ins(P.nb,blocks[i][0])
			until #bag==0
			bag={1,2,3,4,5,6,7,5}
			repeat
				local i=rem(bag,rnd(#bag))
				ins(P.nxt,i)
				ins(P.nb,blocks[i][0])
			until #bag==0
		end
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		if P.cstat.piece%4==0 then
			local r=rnd(#PClist)
			local P=players[1]
			local f=P.cstat.pc%2==0
			for i=1,4 do
				local b=PClist[r][i]
				if f then
					if b<3 then b=3-b
					elseif b<5 then b=7-b
					end
				end
				ins(P.nxt,b)
				ins(P.nb,blocks[b][0])
			end
		end
	end,
}
loadmode={
	sprint=function()
		modeEnv={
			drop=60,
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
			target=200,
			reach=Event.gameover.win,
		}
		createPlayer(1,340,15)
		curBG="strap"
		BGM("infinite")
	end,
	infinite=function()
		modeEnv={
			drop=1e99,
			lock=1e99,
		}
		createPlayer(1,340,15)
		curBG="glow"
		BGM("infinite")
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
	tsd=function()
		modeEnv={
			drop=60,
			lock=60,
			sequence=4,
			target=1,
			reach=Event.tsd_reach,
			freshLimit=10,
		}
		createPlayer(1,340,15)
		curBG="matrix"
		BGM("infinite")
	end,
	pc=function()
		modeEnv={
			next=4,
			hold=false,
			drop=60,
			lock=60,
			fall=20,
			sequence=5,
			target=0,
			reach=Event.newPC,
			freshLimit=5,
		}
		createPlayer(1,340,15)
		local r=rnd(#PClist)
		local P=players[1]
		for i=1,4 do
			local b=PClist[r][i]
			ins(P.nxt,b)
			ins(P.nb,blocks[b][0])
		end
		Event.newPC()
		curBG="matrix"
		BGM("infinite")
	end,
	techmino41=function()
		modeEnv={
			freshLimit=15,
			royaleMode=true,
			royale={2,5,10,20},
		}
		createPlayer(1,340,15)--Player

		local n=2
		for i=1,4 do
			for j=1,5 do
				createPlayer(n,75*i-48,142*j-130,.19,rnd(15))
				n=n+1
			end
		end
		for i=9,12 do
			for j=1,5 do
				createPlayer(n,75*i+292,142*j-130,.19,rnd(15))
				n=n+1
			end
		end--AIs

		curBG="game3"
		BGM("race")
	end,
	techmino99=function()
		modeEnv={
			freshLimit=15,
			royaleMode=true,
			royale={2,6,14,30},
		}
		createPlayer(1,340,15)--Player

		local n=2
		for i=1,7 do
			for j=1,7 do
				createPlayer(n,46*i-36,97*j-72,.135,rnd()<.1 and rnd(4)or rnd(10,20))
				n=n+1
			end
		end
		for i=15,21 do
			for j=1,7 do
				createPlayer(n,46*i+264,97*j-72,.135,rnd()<.1 and rnd(4)or rnd(10,20))
				n=n+1
			end
		end--AIs

		curBG="game3"
		BGM("race")
	end,
	solo=function()
		modeEnv={
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
			visible=0,
			freshLimit=10,
		}
		createPlayer(1,340,15)

		curBG="glow"
		BGM("push")
	end,
	p2=function()
		modeEnv={
			freshLimit=15,
		}
		createPlayer(1,20,15)
		createPlayer(2,650,15)

		curBG="game2"
		BGM("way")
	end,
	p3=function()
		modeEnv={
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
			freshLimit=15,
		}
		createPlayer(1,25,150,.5)
		createPlayer(2,335,150,.5)
		createPlayer(3,645,150,.5)
		createPlayer(4,955,150,.5)

		curBG="game2"
		BGM("way")
	end,
	custom=function()
		modeEnv={reach=Event.gameover.win}
		for i=1,#customID do
			local k=customID[i]
			modeEnv[k]=customRange[k][customSel[k]]
		end
		modeEnv._20G=modeEnv.drop==-1
		if modeEnv.opponent==0 then
			createPlayer(1,340,15)
		else
			modeEnv.target=nil
			createPlayer(1,20,15)
			createPlayer(2,660,85,.9,modeEnv.opponent)
		end
		curBG="matrix"
		BGM("reason")
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
			if P.id==1 and players[2]and players[2].ai then SFX("win")end
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
			if modeEnv.royaleMode and P.lastRecv then
				throwBadge(P.id,P.lastRecv,P.badge)
				players[P.lastRecv].badge=players[P.lastRecv].badge+P.badge+1
				local atker=players[P.lastRecv]
				while atker.strength<4 and atker.badge>modeEnv.royale[atker.strength+1]do
					atker.strength=atker.strength+1
				end
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
			if P.id==1 and players[2]and players[2].ai then SFX("fail")end
			ins(task,Event.task.lose)
		end,
	},
	marathon_reach=function()
		local s=int(cstat.row*.1)
		if s>=20 then
			Event.gameover.win()
		else
			gameEnv.drop=marathon_drop[s]
			if s==18 then gameEnv._20G=true end
			gameEnv.target=s*10+10
			SFX("reach")
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
	tsd_reach=function()
		if not(#clearing==2 and bn==5 and P.spinLast)then
			Event.gameover.lose()
		else
			P.gameEnv.target=P.gameEnv.target+2
		end
	end,
	newPC=function()
		local P=players[1]
		if #P.field==#P.clearing then
			P.counter=P.cstat.piece==0 and 19 or 0
			ins(P.task,Event.task.PC)
			local s=P.cstat.pc*.5
			if int(s)==s and s>0 then
				P.gameEnv.drop=pc_drop[s]or 0
				P.gameEnv.lock=pc_lock[s]or 10
				P.gameEnv.fall=pc_fall[s]or 5
				if s==15 then
					showText("Max speed","appear",80,-120)
				else
					showText("Speed up","appear",30,-130)
				end
			end
		else
			Event.gameover.lose()
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
		garbagepush=function()
			
		end,
		PC=function()
			local P=players[1]
			P.counter=P.counter+1
			if P.counter==21 then
				gameEnv.target=gameEnv.target+4
				local t=P.cstat.pc%2
				for i=1,4 do
					local r=getNewRow()
					for j=1,10 do
						r[j]=PCbase[4*t+i][j]
					end
					ins(P.field,1,r)
					ins(P.visTime,1,getNewRow(P.showTime))
				end
				P.fieldBeneath=P.fieldBeneath+120
				-- P.cy=P.cy+4
				P.y_img=P.y_img+4
				freshgho()
				return true
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
	infinite=function()
		setFont(50)
		mStr(cstat.atk,-75,320)
		mStr(format("%.2f",2.5*cstat.atk/cstat.piece),-75,430)
		setFont(20)
		gc.print("Attack",-100,360)
		gc.print("Efficiency",-108,472)
	end,
	solo=function()
		setFont(50)
		mStr(cstat.atk,-75,320)
		setFont(20)
		gc.print("Attack",-100,360)
	end,
	gmroll=function()
		setFont(25)
		gc.print("Techrash",-120,420)
		setFont(80)
		mStr(cstat.techrash,-75,350)
	end,
	marathon=function()
		setFont(50)
		mStr(P.cstat.row,-75,330)
		mStr(gameEnv.target,-75,380)
		gc.rectangle("fill",-120,376,90,4)
	end,
	death=function()
		setFont(50)
		mStr(P.cstat.row,-75,330)
		mStr(gameEnv.target,-75,380)
		gc.rectangle("fill",-120,376,90,4)
	end,
	tsd=function()
		setFont(35)
		gc.print("TSD",-105,405)
		setFont(80)
		mStr((P.gameEnv.target-1)*.5,-75,330)
	end,
	pc=function()
		setFont(25)
		gc.print("Perfect Clear",-138,400)
		setFont(80)
		mStr(cstat.pc,-75,330)
	end,
	techmino41=function()
		gc.draw(badgeIcon,-120,150,nil,1.5)
		setFont(50)
		gc.print(badge,-65,150)
		mStr(cstat.atk,-75,320)
		mStr(#players.alive,-75,430)
		setFont(20)
		gc.print("Attack",-100,360)
		gc.print("Remain",-105,472)
	end,
	techmino99=function()
		gc.draw(badgeIcon,-120,150,nil,1.5)
		setFont(50)
		gc.print(badge,-65,150)
		mStr(cstat.atk,-75,320)
		mStr(#players.alive,-75,430)
		setFont(20)
		gc.print("Attack",-100,360)
		gc.print("Remain",-105,472)
	end,
	blind=function()
		setFont(25)
		gc.print("Rows",-100,300)
		gc.print("Techrash",-120,420)
		setFont(80)
		mStr(P.cstat.row,-75,230)
		mStr(cstat.techrash,-75,350)
	end,
	custom=function()
		if gameEnv.target<1e4 then
			setFont(75)
			mStr(max(gameEnv.target-P.cstat.row,0),-75,280)
		end
	end
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
--------------------------------Wrning!_G __index Plyr[n] when chng any playr's val!
require("toolfunc")
require("gamefunc")
require("list")
require("texture")
require("ai")
require("timer")
require("paint")
require("scene")
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