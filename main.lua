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
			local t=gc.setNewFont("font.ttf",s-5)
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
	sequence="bag7",visible=1,
	_20G=false,target=1e99,
	freshLimit=15,
	ospin=true,
	reach=null,
	bg="none",
	bgm="race"
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
	end,
	marathon=function()
		createPlayer(1,340,15)
	end,
	classic=function()
		createPlayer(1,340,15)
	end,
	zen=function()
		createPlayer(1,340,15)
	end,
	infinite=function()
		createPlayer(1,340,15)
	end,
	solo=function()
		createPlayer(1,200,15)
		createPlayer(2,830,220,.7,customRange.opponent[3*curMode.lv])
	end,
	tsd=function()
		createPlayer(1,340,15)
	end,
	blind=function()
		createPlayer(1,340,15)
	end,
	dig=function()
		createPlayer(1,340,15)
		local P=players[1]
		if curMode.lv==1 then
			ins(players[1].task,Event.task.dig_normal)
			pushSpeed=1
		elseif curMode.lv==2 then
			ins(players[1].task,Event.task.dig_lunatic)
			pushSpeed=1
		end
	end,
	survivor=function()
		createPlayer(1,340,15)
		local P=players[1]
		ins(players[1].task,Event.task[curMode.lv==1 and"survivor_easy"or curMode.lv==2 and"survivor_normal"or curMode.lv==3 and"survivor_hard"or curMode.lv==4 and"survivor_lunatic"])
		pushSpeed=curMode.lv>2 and 2 or 1
	end,
	tech=function()
		createPlayer(1,340,15)
	end,
	pctrain=function()
		createPlayer(1,340,15)
		P=players[1]
		Event.newPC()
		P.freshNext()
	end,
	pcchallenge=function()
		createPlayer(1,340,15)
	end,
	techmino41=function()
		createPlayer(1,340,15)--Player
		if curMode.lv==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2
		if curMode.lv==1 then min,max=5,30
		elseif curMode.lv==2 then min,max=3,25
		elseif curMode.lv==3 then min,max=2,20
		elseif curMode.lv==4 then min,max=2,10
		elseif curMode.lv==5 then min,max=1,6
		end
		for i=1,4 do for j=1,5 do
			createPlayer(n,77*i-55,140*j-125,.2,rnd(min,max))
			n=n+1
		end end
		for i=9,12 do for j=1,5 do
			createPlayer(n,77*i+275,140*j-125,.2,rnd(min,max))
			n=n+1
		end end
		--AIs

	end,
	techmino99=function()
		createPlayer(1,340,15)--Player
		if curMode.lv==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2
		if curMode.lv==1 then min,max=5,32
		elseif curMode.lv==2 then min,max=3,25
		elseif curMode.lv==3 then min,max=2,18
		elseif curMode.lv==4 then min,max=2,12
		elseif curMode.lv==5 then min,max=1,12
		end
		for i=1,7 do for j=1,7 do
			createPlayer(n,46*i-36,97*j-72,.135,rnd(min,max))
			n=n+1
		end end
		for i=15,21 do for j=1,7 do
			createPlayer(n,46*i+264,97*j-72,.135,rnd(min,max))
			n=n+1
		end end
		--AIs

	end,
	drought=function()
		createPlayer(1,340,15)
	end,
	hotseat=function()
		if curMode.lv==1 then
			createPlayer(1,20,15)
			createPlayer(2,650,15)
		elseif curMode.lv==2 then
			createPlayer(1,20,100,.65)
			createPlayer(2,435,100,.65)
			createPlayer(3,850,100,.65)
		elseif curMode.lv==3 then
			createPlayer(1,25,160,.5)
			createPlayer(2,335,160,.5)
			createPlayer(3,645,160,.5)
			createPlayer(4,955,160,.5)
		end
	end,
	custom=function()
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
	end,
}
mesDisp={
	--Default:font=35,white
	sprint=function()
		setFont(70)
		mStr(max(P.gameEnv.target-P.cstat.row,0),-75,260)
	end,
	marathon=function()
		setFont(50)
		mStr(P.cstat.row,-75,320)
		mStr(P.gameEnv.target,-75,370)
		gc.rectangle("fill",-120,376,90,4)
	end,
	classic=function()
		setFont(80)
		local r=P.gameEnv.target*.1
		mStr(r<11 and 19+r or r==11 and"00"or r==12 and"0a"or format("%x",r*10-110),-75,210)
		setFont(20)
		mStr("speed level",-75,290)
		setFont(50)
		mStr(P.cstat.row,-75,320)
		mStr(P.gameEnv.target,-75,370)
		gc.rectangle("fill",-120,376,90,4)
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
		mStr("Attack",-75,363)
		mStr("Efficiency",-75,475)
	end,
	tsd=function()
		setFont(35)
		mStr("TSD",-75,405)
		setFont(80)
		mStr(P.cstat.event,-75,330)
	end,
	blind=function()
		setFont(25)
		mStr("Rows",-75,300)
		mStr("Techrash",-75,420)
		setFont(80)
		mStr(P.cstat.row,-75,220)
		mStr(P.cstat.techrash,-75,340)
	end,
	dig=function()
		setFont(70)
		mStr(P.cstat.event,-75,310)
		setFont(30)
		mStr("Wave",-75,375)
	end,
	survivor=function()
		setFont(70)
		mStr(P.cstat.event,-75,310)
		setFont(30)
		mStr("Wave",-75,375)
	end,
	pctrain=function()
		setFont(25)
		mStr("Perfect Clear",-75,410)
		setFont(80)
		mStr(P.cstat.pc,-75,330)
	end,
	pcchallenge=function()
		setFont(25)
		mStr("Perfect Clear",-75,430)
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
			local P=players.alive[1]
			P.alive=false
			P.control=false
			P.timing=false
			P.waiting=1e99
			P.b2b=0
			if modeEnv.royaleMode then
				P.rank=1
				P.result="WIN"
				showText(P,1,"appear",60,120,nil,true)
				changeAtk(P)
			end
			::L::if P.task[1]then
				rem(P.task)
				goto L
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
			showText(P,text.win,"beat",90,nil,nil,true)
			if P.id==1 and players[2]and players[2].ai then SFX("win")end
			ins(P.task,Event.task.win)
		end,
		lose=function()
			P.alive=false
			P.control=false
			P.timing=false
			P.waiting=1e99
			P.b2b=0
			::L::if P.task[1]then
				rem(P.task)
				goto L
			end
			for i=1,#players.alive do
				if players.alive[i]==P then
					rem(players.alive,i)
					break
				end
			end
			if modeEnv.royaleMode then
				changeAtk(P)
				P.result="K.O."
				P.rank=#players.alive+1
				showText(P,P.rank,"appear",60,120,nil,true)
				P.strength=0
				local A=P
				::L::
					A=A.lastRecv
				if A and not A.alive and A~=P then goto L end
				if A and A~=P then
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
					if P==mostBadge then
						mostBadge,secBadge=secBadge
					elseif P==secBadge then
						secBadge=nil
					end
					if mostBadge then
						if A.badge>mostBadge.badge then
							if A~=mostBadge then
								mostBadge,secBadge=A,mostBadge
							end
						elseif secBadge then
							if A.badge>secBadge.badge then
								secBadge=A
							end
						else
							secBadge=A
						end
					else
						mostBadge=A
					end
				end
				freshMostDangerous()
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
			showText(P,text.lose,"appear",90,nil,nil,true)
			if P.id==1 and players[2]and players[2].ai then SFX("fail")end
			ins(P.task,Event.task.lose)
			if #players.alive==1 then
				local t=P
				P=players.alive[1]
				Event.gameover.win()
				P=t
			end
		end,
	},
	marathon_reach=function()
		local s=int(P.cstat.row*.1)
		if s>=20 then
			P.cstat.row=200
			Event.gameover.win()
		else
			P.gameEnv.drop=marathon_drop[s]
			if s==18 then P.gameEnv._20G=true end
			P.gameEnv.target=s*10+10
			SFX("reach")
		end
	end,
	marathon_reach_lunatic=function()
		if P.gameEnv.target==250 then
			P.cstat.row=250
			Event.gameover.win()
		else
			P.gameEnv.target=P.gameEnv.target+50
			local t=P.gameEnv.target/50
			P.gameEnv.lock=rush_lock[t]
			P.gameEnv.wait=rush_wait[t]
			P.gameEnv.fall=rush_fall[t]
			showText(P,text.stage[t],"fly",80,-120)
			SFX("reach")
		end
	end,
	marathon_reach_ultimate=function()
		if P.cstat.event==5 then
			P.cstat.row=250
			Event.gameover.win()
		else
			local t=P.cstat.event+1
			if t==1 then t=2 end
			P.gameEnv.target=50*t
			P.cstat.event=t
			P.gameEnv.lock=death_lock[t]
			P.gameEnv.wait=death_wait[t]
			P.gameEnv.fall=death_fall[t]
			showText(P,text.stage[t],"fly",80,-120)
			SFX("reach")
		end
	end,
	classic_reach=function()
		P.gameEnv.target=P.gameEnv.target+10
		if P.gameEnv.target==100 then
			P.gameEnv.drop,P.gameEnv.lock=0,0
		end
		SFX("reach")
	end,
	tsd_reach=function()
		if P.lastClear~=52 then
			Event.gameover.lose()
		else
			P.gameEnv.target=P.gameEnv.target+20
			P.cstat.event=P.cstat.event+1
			if #P.field>11 and P.cstat.event%5~=1 then
				ins(P.clearing,1)
			end
		end
	end,
	tech_reach=function()
		if #P.clearing>0 and P.lastClear<10 then
			Event.gameover.lose()
		end
	end,
	tech_reach_hard=function()
		if #P.clearing>0 and P.lastClear<10 or P.lastClear==74 then
			Event.gameover.lose()
		end
	end,
	newPC=function()
		local P=players[1]
		if P.cstat.piece%4==0 then
			if #P.field==#P.clearing then
				P.counter=P.cstat.piece==0 and 20 or 0
				ins(P.task,Event.task.PC)
				if curMode.lv==2 then
					local s=P.cstat.pc*.5
					if int(s)==s and s>0 then
						P.gameEnv.drop=pc_drop[s]or 10
						P.gameEnv.lock=pc_lock[s]or 20
						P.gameEnv.fall=pc_fall[s]or 5
						if s==10 then
							showText(P,text.maxspeed,"appear",80,-140)
						else
							showText(P,text.speedup,"appear",30,-140)
						end
					end
				end
			else
				Event.gameover.lose()
			end
		end
	end,
	task={
		win=function()
			P.endCounter=P.endCounter+1
			if P.endCounter>80 then
				if P.gameEnv.visible==1 then
					for i=1,#P.field do
						for j=1,10 do
							if P.visTime[i][j]>0 then
								P.visTime[i][j]=P.visTime[i][j]-1
							end
						end
					end
					if P.endCounter==100 then
						for i=1,#P.field do
							removeRow(P.field)
							removeRow(P.visTime)
						end
						return true
					end
				elseif P.endCounter==100 then
					return true
				end
			end
		end,
		lose=function()
			P.endCounter=P.endCounter+1
			if P.endCounter>80 then
				if P.gameEnv.visible==1 then
					for i=1,#P.field do
						for j=1,10 do
							if P.visTime[i][j]>0 then
								P.visTime[i][j]=P.visTime[i][j]-1
							end
						end
					end
					if P.endCounter==100 then
						for i=1,#P.field do
							removeRow(P.field)
							removeRow(P.visTime)
						end
						return true
					end
				elseif P.endCounter==100 then
					return true
				end
			end
		end,
		dig_normal=function()
			local P=players[1]
			P.counter=P.counter+1
			if #P.clearing==0 and P.counter>=max(90,180-2*P.cstat.event)then
				ins(P.field,1,getNewRow(13))
				ins(P.visTime,1,getNewRow(1e99))
				P.field[1][rnd(10)]=0
				P.fieldBeneath=P.fieldBeneath+30
				P.cy,P.y_img=P.cy+1,P.y_img+1
				P.counter=0
				P.cstat.event=P.cstat.event+1
			end
		end,
		dig_lunatic=function()
			local P=players[1]
			P.counter=P.counter+1
			if #P.clearing==0 and P.counter>=max(40,60-.5*P.cstat.event)then
				ins(P.field,1,getNewRow(13))
				ins(P.visTime,1,getNewRow(1e99))
				P.field[1][rnd(10)]=0
				P.fieldBeneath=P.fieldBeneath+30
				P.cy,P.y_img=P.cy+1,P.y_img+1
				P.counter=0
				P.cstat.event=P.cstat.event+1
			end
		end,
		survivor_easy=function()
			local P=players[1]
			P.counter=P.counter+1
			if P.counter==max(60,180-2*P.cstat.event)then
				ins(P.atkBuffer,{rnd(10),amount=1,countdown=30,cd0=30,time=0,sent=false,lv=1})
				P.counter=0
				if P.cstat.event==60 then showText(P,text.maxspeed,"appear",80,-140)end
				P.cstat.event=P.cstat.event+1
			end
		end,
		survivor_normal=function()
			local P=players[1]
			P.counter=P.counter+1
			if P.counter==max(60,180-2*P.cstat.event)then
				local d=P.cstat.event+1
				if d%4==0 then ins	(P.atkBuffer,{rnd(10),amount=1,countdown=60,cd0=60,time=0,sent=false,lv=1})
				elseif d%4==1 then ins(P.atkBuffer,{rnd(10),amount=2,countdown=70,cd0=70,time=0,sent=false,lv=1})
				elseif d%4==2 then ins(P.atkBuffer,{rnd(10),amount=3,countdown=80,cd0=80,time=0,sent=false,lv=2})
				elseif d%4==3 then ins(P.atkBuffer,{rnd(10),amount=4,countdown=90,cd0=90,time=0,sent=false,lv=3})
				end
				P.counter=0
				if P.cstat.event==60 then showText(P,text.maxspeed,"appear",80,-140)end
				P.cstat.event=P.cstat.event+1
			end
		end,
		survivor_hard=function()
			local P=players[1]
			P.counter=P.counter+1
			if P.counter==max(60,180-2*P.cstat.event)then
				if P.cstat.event%3<2 then
					ins(P.atkBuffer,{rnd(10),amount=1,countdown=0,cd0=0,time=0,sent=false,lv=1})
				else
					ins(P.atkBuffer,{rnd(10),amount=3,countdown=60,cd0=60,time=0,sent=false,lv=2})
				end
				P.counter=0
				if P.cstat.event==45 then showText(P,text.maxspeed,"appear",80,-140)end
				P.cstat.event=P.cstat.event+1
			end
		end,
		survivor_lunatic=function()
			local P=players[1]
			P.counter=P.counter+1
			if P.counter==max(90,150-P.cstat.event)then
				local t=max(60,90-P.cstat.event)
				ins(P.atkBuffer,{rnd(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3})
				P.counter=0
				if P.cstat.event==30 then showText(P,text.maxspeed,"appear",80,-140)end
				P.cstat.event=P.cstat.event+1
			end
		end,
		PC=function()
			local P=players[1]
			P.counter=P.counter+1
			if P.counter==21 then
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
	lang=1,
	sfx=true,bgm=true,vib=3,
	fullscreen=false,
	bgblock=true,
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
virtualkey={
	{80,720-80,6400,80},--moveLeft
	{240,720-80,6400,80},--moveRight
	{1280-240,720-80,6400,80},--rotRight
	{1280-400,720-80,6400,80},--rotLeft
	{1280-240,720-240,6400,80},--rotFlip
	{1280-80,720-80,6400,80},--hardDrop
	{1280-80,720-240,6400,80},--softDrop
	{1280-80,720-400,6400,80},--hold
	{80,360,6400,80},--swap
	{80,80,6400,80},--restart
	--[[
	{x=0,y=0,r=0},--toLeft
	{x=0,y=0,r=0},--toRight
	{x=0,y=0,r=0},--toDown
	]]

}
virtualkeyDown={false,false,false,false,false,false,false,false,false,false,false,false,false}
virtualkeyPressTime={0,0,0,0,0,0,0,0,0,0,0,0,0}
--User Data&User Setting
require("toolfunc")
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

require("gamefunc")
require("ai")
require("timer")
require("paint")
require("call&sys")
require("list")
swapLanguage(setting.lang)
require("texture")