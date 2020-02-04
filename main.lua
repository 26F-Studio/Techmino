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
gameMode=""
bgmPlaying=nil
curBG="none"
BGblock={ct=150,next=7}

kb.setKeyRepeat(false)
kb.setTextInput(false)
ms.setVisible(false)

Fonts={}
function setFont(s)
	if s~=currentFont then
		if Fonts[s]then
			gc.setFont(Fonts[s])
		else
			local t=gc.setNewFont("albbph.ttf",s-5)
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
	next=6,hold=true,oncehold=true,
	sequence=1,visible=1,
	_20G=false,target=1e99,
	freshLimit=15,
	virtualkey={},
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
loadmode={
	sprint=function()
		createPlayer(1,340,15)
		curBG="game1"
		BGM("race")
	end,
	marathon=function()
		createPlayer(1,340,15)
		curBG="strap"
		BGM("way")
	end,
	zen=function()
		createPlayer(1,340,15)
		curBG="strap"
		BGM("infinite")
	end,
	infinite=function()
		createPlayer(1,340,15)
		curBG="glow"
		BGM("infinite")
	end,
	solo=function()
		createPlayer(1,20,15)--Player
		createPlayer(2,660,85,.9,customRange.opponent[3*gameLevel])--AI
		curBG="game2"
		BGM("race")
	end,
	death=function()
		createPlayer(1,340,15)
		curBG="game2"
		BGM("push")
	end,
	tsd=function()
		createPlayer(1,340,15)
		curBG="matrix"
		BGM("infinite")
	end,
	blind=function()
		createPlayer(1,340,15)
		curBG="glow"
		BGM("push")
	end,
	sudden=function()
		createPlayer(1,340,15)
		curBG="matrix"
		BGM("way")
	end,
	pctrain=function()
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
	pcchallenge=function()
		createPlayer(1,340,15)
		curBG="matrix"
		BGM("infinite")
	end,
	techmino41=function()
		createPlayer(1,340,15)--Player
		if gameLevel==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2
		if gameLevel==1 then
			min,max=5,30
		elseif gameLevel==2 then
			min,max=3,25
		elseif gameLevel==3 then
			min,max=2,20
		elseif gameLevel==4 then
			min,max=2,10
		elseif gameLevel==5 then
			min,max=1,6
		end
		for i=1,4 do
			for j=1,5 do
				createPlayer(n,77*i-55,140*j-125,.2,rnd(min,max))
				n=n+1
			end
		end
		for i=9,12 do
			for j=1,5 do
				createPlayer(n,77*i+275,140*j-125,.2,rnd(min,max))
				n=n+1
			end
		end--AIs

		curBG="game3"
		BGM("race")
	end,
	techmino99=function()
		createPlayer(1,340,15)--Player
		if gameLevel==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2
		if gameLevel==1 then
			min,max=5,32
		elseif gameLevel==2 then
			min,max=3,25
		elseif gameLevel==3 then
			min,max=2,18
		elseif gameLevel==4 then
			min,max=2,12
		elseif gameLevel==5 then
			min,max=1,12
		end
		for i=1,7 do
			for j=1,7 do
				createPlayer(n,46*i-36,97*j-72,.135,rnd(min,max))
				n=n+1
			end
		end
		for i=15,21 do
			for j=1,7 do
				createPlayer(n,46*i+264,97*j-72,.135,rnd(min,max))
				n=n+1
			end
		end--AIs

		curBG="game3"
		BGM("race")
	end,
	drought=function()
		createPlayer(1,340,15)
		curBG="strap"
		BGM("reason")
	end,
	gmroll=function()
		createPlayer(1,340,15)
		curBG="glow"
		BGM("push")
	end,
	p2=function()
		createPlayer(1,20,15)
		createPlayer(2,650,15)

		curBG="game2"
		BGM("way")
	end,
	p3=function()
		createPlayer(1,20,100,.65)
		createPlayer(2,435,100,.65)
		createPlayer(3,850,100,.65)

		curBG="game2"
		BGM("way")
	end,
	p4=function()
		createPlayer(1,25,150,.5)
		createPlayer(2,335,150,.5)
		createPlayer(3,645,150,.5)
		createPlayer(4,955,150,.5)

		curBG="game2"
		BGM("way")
	end,
	custom=function()
		modeEnv={}
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
mesDisp={
	--Default:font=35,white
	sprint=function()
		setFont(70)
		mStr(max(P.gameEnv.target-P.cstat.row,0),-75,260)
	end,
	zen=function()
		setFont(75)
		mStr(max(200-P.cstat.row,0),-75,280)
	end,
	infinite=function()
		setFont(50)
		mStr(P.cstat.atk,-75,310)
		mStr(format("%.2f",2.5*P.cstat.atk/P.cstat.piece),-75,420)
		setFont(20)
		gc.print("Attack",-98,363)
		gc.print("Efficiency",-110,475)
	end,
	marathon=function()
		setFont(50)
		mStr(P.cstat.row,-75,320)
		mStr(P.gameEnv.target,-75,370)
		gc.rectangle("fill",-120,376,90,4)
	end,
	death=function()
		setFont(50)
		mStr(P.cstat.row,-75,320)
		mStr(P.gameEnv.target,-75,370)
		gc.rectangle("fill",-120,376,90,4)
	end,
	tsd=function()
		setFont(35)
		gc.print("TSD",-102,405)
		setFont(80)
		mStr((P.gameEnv.target-1)*.5,-75,330)
	end,
	blind=function()
		setFont(25)
		gc.print("Rows",-102,300)
		gc.print("Techrash",-123,420)
		setFont(80)
		mStr(P.cstat.row,-75,220)
		mStr(P.cstat.techrash,-75,340)
	end,
	pctrain=function()
		setFont(25)
		gc.print("Perfect Clear",-140,410)
		setFont(80)
		mStr(P.cstat.pc,-75,330)
	end,
	pcchallenge=function()
		setFont(25)
		gc.print("Perfect Clear",-140,430)
		setFont(80)
		mStr(P.cstat.pc,-75,350)
		setFont(50)
		mStr(max(100-P.cstat.row,0),-75,250)
	end,
	techmino41=function()
		setFont(40)
		mStr(#players.alive.."/41",-75,175)
		mStr(P.ko,-60,215)
		setFont(25)
		gc.print("KO",-115,225)
		gc.setColor(1,.5,0,.6)
		gc.print(P.badge,-35,227)
		gc.setColor(1,1,1)
		setFont(30)
		gc.print(up0to4[P.strength],-125,290)
		for i=1,P.strength do
			gc.draw(badgeIcon,16*i-130,260)
		end
	end,
	techmino99=function()
		setFont(40)
		mStr(#players.alive.."/99",-75,175)
		mStr(P.ko,-60,215)
		setFont(25)
		gc.print("KO",-115,225)
		gc.setColor(1,.5,0,.6)
		gc.print(P.badge,-35,227)
		gc.setColor(1,1,1)
		setFont(30)
		gc.print(up0to4[P.strength],-125,290)
		for i=1,P.strength do
			gc.draw(badgeIcon,16*i-130,260)
		end
	end,
	drought=function()
		setFont(75)
		mStr(max(100-P.cstat.row,0),-75,280)
	end,
	gmroll=function()
		setFont(25)
		gc.print("Techrash",-123,420)
		setFont(80)
		mStr(P.cstat.techrash,-75,340)
	end,
	custom=function()
		if P.gameEnv.target<1e4 then
			setFont(75)
			mStr(max(P.gameEnv.target-P.cstat.row,0),-75,280)
		end
	end
}
Event={
	gameover={
		win=function()
			P.alive=false
			P.control=false
			P.timing=false
			P.waiting=1e99
			P.b2b=0
			P.result="WIN"
			changeAtk(P)
			for i=1,#P.atkBuffer do
				P.atkBuffer[i].sent=true
				P.atkBuffer[i].time=0
			end
			for i=1,#P.field do
				for j=1,10 do
					P.visTime[i][j]=min(P.visTime[i][j],20)
				end
			end
			showText(P,"WIN","appear",90,nil,nil,true)
			if P.id==1 and players[2]and players[2].ai then SFX("win")end
			ins(P.task,Event.task.win)
		end,
		lose=function()
			P.alive=false
			P.control=false
			P.timing=false
			P.waiting=1e99
			P.b2b=0
			P.result="K.O."
			showText(P,"LOSE","appear",90,nil,nil,true)
			for i=1,#players.alive do
				if players.alive[i]==P then
					rem(players.alive,i)
					break
				end
			end
			changeAtk(P)
			if modeEnv.royaleMode then
				P.strength=0
				if P.lastRecv and P.lastRecv.alive then
					local A=P.lastRecv
					if P.id==1 or A.id==1 then
						throwBadge(P,A,P.badge)
						P.killMark=A.id==1
					end
					A.ko,A.badge=A.ko+1,A.badge+P.badge+1
					for i=A.strength+1,4 do
						if A.badge>=modeEnv.royalePowerup[i]then
							A.strength=i
						end
					end
				end
				freshRoyaleTarget()
				for i=1,#players.alive do
					if players.alive[i].atking==P then
						freshTarget(players.alive[i])
					end
				end
				if #players.alive==modeEnv.royaleRemain[gameStage]then
					royaleLevelup()
				end
			end
			for i=1,#P.atkBuffer do
				P.atkBuffer[i].sent=true
				P.atkBuffer[i].time=0
			end
			for i=1,#P.field do
				for j=1,10 do
					P.visTime[i][j]=min(P.visTime[i][j],20)
				end
			end
			if P.id==1 and players[2]and players[2].ai then SFX("fail")end
			ins(P.task,Event.task.lose)
			if #players.alive==1 then
				ins(players.alive[1].task,Event.task.winTrigger)
			end
		end,
	},
	marathon_reach=function()
		local s=int(P.cstat.row*.1)
		if s>=20 then
			Event.gameover.win()
		else
			P.gameEnv.drop=marathon_drop[s]
			if s==18 then P.gameEnv._20G=true end
			P.gameEnv.target=s*10+10
			SFX("reach")
		end
	end,
	death_reach=function()
		if P.gameEnv.target==250 then
			Event.gameover.win()
		else
			P.gameEnv.target=P.gameEnv.target+50
			local t=P.gameEnv.target/50
			P.gameEnv.lock=death_lock[t]
			P.gameEnv.wait=death_wait[t]
			P.gameEnv.fall=death_fall[t]
			showText(P,"STAGE "..t,"fly",80,-120)
			SFX("reach")
		end
	end,
	tsd_reach=function()
		if P.lastClear~=52 then
			Event.gameover.lose()
		else
			P.gameEnv.target=P.gameEnv.target+2
			if #P.field>10 and P.gameEnv.target%10~=0 then
				ins(P.clearing,1)
			end
		end
	end,
	sudden_reach=function()
		if #P.clearing>0 and P.lastClear<10 then
			Event.gameover.lose()
		end
	end,
	sudden_reach_HARD=function()
		if #P.clearing>0 and P.lastClear<10 and P.lastClear~=74 then
			Event.gameover.lose()
		end
	end,
	newPC=function()
		local P=players[1]
		if #P.field==#P.clearing then
			P.counter=P.cstat.piece==0 and 19 or 0
			ins(P.task,Event.task.PC)
			if gameLevel==2 then
				local s=P.cstat.pc*.5
				if int(s)==s and s>0 then
					P.gameEnv.drop=pc_drop[s]or 10
					P.gameEnv.lock=pc_lock[s]or 20
					P.gameEnv.fall=pc_fall[s]or 5
					if s==10 then
						showText(P,"Max speed","appear",80,-120)
					else
						showText(P,"Speed up","appear",30,-130)
					end
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
			if P.counter>80 then
				if P.gameEnv.visible==1 then
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
				elseif P.counter==100 then
					return true
				end
			end
		end,
		lose=function()
			P.counter=P.counter+1
			if P.counter>80 then
				if P.gameEnv.visible==1 then
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
				elseif P.counter==100 then
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
				P.gameEnv.target=P.gameEnv.target+4
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
--Game system Data
setting={
	sfx=true,bgm=true,vib=3,
	fullscreen=false,
	bgblock=true,
	lang="eng",
	das=10,arr=2,
	sddas=0,sdarr=2,
	ghost=true,center=true,
	keyMap={
		{"left","right","x","z","c","up","down","space","tab","r","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","x","leftshoulder","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
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