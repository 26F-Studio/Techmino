local PCbase={
	{3,3,3,0,0,0,0,0,2,2},
	{3,6,6,0,0,0,0,2,2,5},
	{4,6,6,0,0,0,1,1,5,5},
	{4,4,4,0,0,0,0,1,1,5},
	{1,1,0,0,0,0,0,3,3,3},
	{5,1,1,0,0,0,0,6,6,3},
	{5,5,2,2,0,0,0,6,6,4},
	{5,2,2,0,0,0,0,4,4,4},
}
local PClist={
	{7,7,4,5},{7,7,6,4},{7,7,2,4},{7,7,1,3},{7,7,5,6},{7,7,5,2},{7,7,5,4},{7,7,5,3},
	{7,4,1,2},{7,3,5,7},{7,5,4,3},{7,5,1,2},{7,1,4,2},{7,4,2,5},{7,6,4,5},{7,5,4,2},
	{7,5,6,4},{7,5,3,6},{7,2,5,6},{7,2,6,4},{7,2,1,3},{7,5,2,7},{7,5,7,2},{7,5,2,3},
	{7,5,3,2},{7,6,5,4},{7,3,1,5},{7,3,2,5},{7,4,1,5},{7,4,5,2},{7,7,3,6},{7,3,7,6},
	{7,3,6,2},{7,3,7,1},{7,6,4,2},{3,2,7,6},{3,2,6,7},{7,7,4,5},{7,5,3,4},{7,3,6,5},
	{7,3,2,5},{7,4,6,5},{7,5,2,3},{7,3,5,7},{7,3,2,5},{7,3,5,1},{7,5,2,3},{3,6,2,5},
	{3,1,2,5},{3,1,1,5},{3,1,5,2},{3,1,5,1},{3,5,1,2},{4,5,3,2},{4,2,6,5},{6,5,3,2},
	{1,4,2,5},{1,5,3,6},{5,2,6,3},{5,2,1,3},{5,2,7,4},{2,4,1,5},{2,4,5,1},{2,1,4,5},
	{2,5,4,3},{2,5,6,7},{7,5,4,2},{4,5,3,5},
}
local marathon_drop={[0]=60,48,40,30,24,18,15,12,10,8,7,6,5,4,3,2,1,1,0,0}
local rush_lock={20,18,16,14,12}
local rush_wait={12,10,9,8,7}
local rush_fall={12,11,10,9,8}
local death_lock={12,11,10,9,8}
local death_wait={9,8,7,6,5}
local death_fall={10,9,8,7,6}
local pc_drop={50,45,40,35,30,26,22,18,15,12}
local pc_lock={55,50,45,40,36,32,30}
local pc_fall={18,16,14,12,10,9,8,7,6}
freshMethod={
	bag7=function()
		if #P.nextID<6 then
			local bag={1,2,3,4,5,6,7}
			for i=1,7 do
				newNext(rem(bag,rnd(#bag)))
			end
		end
	end,
	his4=function()
		if #P.nextID<6 then
			local j,i=0
			::L::
				i,j=rnd(7),j+1
			if(i==P.his[1]or i==P.his[2]or i==P.his[3]or i==P.his[4])then goto L end
			newNext(i)
			rem(P.his,1)ins(P.his,i)
		end
	end,
	rnd=function()
		local i
		::L::
			i=rnd(7)
		if i==P.nextID[5]then goto L end
		newNext(i)
	end,--random
	pc=function()
		if P.cstat.piece%4==0 then
			local r=rnd(#PClist)
			local f=P.cstat.event==1
			for i=1,4 do
				local b=PClist[r][i]
				if f then
					if b<3 then b=3-b
					elseif b<5 then b=7-b
					end
				end
				newNext(b)
			end
			P.cstat.event=(P.cstat.event+1)%2
		end
	end,
	drought1=function()
		if #P.nextID<6 then
			local bag={1,2,3,4,5,6}
			for i=1,6 do
				newNext(rem(bag,rnd(#bag)))
			end
		end
	end,
	drought2=function()
		if #P.nextID<6 then
			local bag={1,1,1,2,2,2,3,3,3,4,4,4,6,6,6,5,7}
			::L::
				newNext(rem(bag,rnd(#bag)))
			if bag[1]then goto L end
		end
	end,
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
						P.killMark=A.id==1
					end
					A.ko,A.badge=A.ko+1,A.badge+P.badge+1
					for i=A.strength+1,4 do
						if A.badge>=modeEnv.royalePowerup[i]then
							A.strength=i
						end
					end
					P.lastRecv=A
					if P.id==1 or A.id==1 then
						ins(P.task,Event.task.throwBadge)
					end
					freshMostBadge()
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
			if t==4 then P.gameEnv.bone=true end
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
			if t==4 then P.gameEnv.bone=true end
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
		elseif #P.clearing>0 then
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
				if P.gameEnv.visible=="show"then
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
				if P.gameEnv.visible=="show"then
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
		throwBadge=function()
			if P.badge%2==0 then
				throwBadge(P,P.lastRecv)
				if P.badge%16==0 then
					sysSFX("collect")
				end
			end
			P.badge=P.badge-1
			if P.badge<=0 then return true end
		end,
		dig_normal=function()
			local P=players[1]
			P.counter=P.counter+1
			if #P.clearing==0 and P.counter>=max(90,180-2*P.cstat.event)then
				ins(P.field,1,getNewRow(10))
				ins(P.visTime,1,getNewRow(1e99))
				P.field[1][rnd(10)]=0
				P.fieldBeneath=P.fieldBeneath+30
				P.curY,P.y_img=P.curY+1,P.y_img+1
				P.counter=0
				P.cstat.event=P.cstat.event+1
			end
		end,
		dig_lunatic=function()
			local P=players[1]
			P.counter=P.counter+1
			if #P.clearing==0 and P.counter>=max(45,80-.4*P.cstat.event)then
				ins(P.field,1,getNewRow(11+P.cstat.event%3))
				ins(P.visTime,1,getNewRow(1e99))
				P.field[1][rnd(10)]=0
				P.fieldBeneath=P.fieldBeneath+30
				P.curY,P.y_img=P.curY+1,P.y_img+1
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
				-- P.curY=P.curY+4
				P.y_img=P.y_img+4
				freshgho()
				return true
			end
		end,
	},
}
defaultModeEnv={
	sprint={
		{
			drop=60,
			target=10,
			reach=Event.gameover.win,
			bg="strap",
			bgm="race",
		},
		{
			drop=60,
			target=20,
			reach=Event.gameover.win,
			bg="strap",
			bgm="race",
		},
		{
			drop=60,
			target=40,
			reach=Event.gameover.win,
			bg="strap",
			bgm="race",
		},
		{
			drop=60,
			target=100,
			reach=Event.gameover.win,
			bg="strap",
			bgm="race",
		},
		{
			drop=60,
			target=400,
			reach=Event.gameover.win,
			bg="strap",
			bgm="push",
		},
		{
			drop=60,
			target=1000,
			reach=Event.gameover.win,
			bg="strap",
			bgm="push",
		},
	},
	marathon={
		{
			drop=60,
			lock=60,
			fall=30,
			target=200,
			reach=Event.marathon_reach,
			bg="strap",
			bgm="way",
		},
		{
			drop=60,
			fall=20,
			target=10,
			reach=Event.marathon_reach,
			bg="strap",
			bgm="way",
		},
		{
			_20G=true,
			fall=15,
			target=200,
			reach=Event.marathon_reach,
			bg="strap",
			bgm="race",
		},
		{
			_20G=true,
			drop=0,
			lock=rush_lock[1],
			wait=rush_wait[1],
			fall=rush_fall[1],
			target=50,
			reach=Event.marathon_reach_lunatic,
			arr=2,
			freshLimit=15,
			bg="game2",
			bgm="secret8th",
		},
		{
			_20G=true,
			drop=0,
			lock=death_lock[1],
			wait=death_wait[1],
			fall=death_fall[1],
			target=50,
			reach=Event.marathon_reach_ultimate,
			arr=1,
			freshLimit=15,
			bg="game2",
			bgm="secret7th",
		},
	},
	classic={
		{
			das=15,arr=3,
			sddas=2,sdarr=2,
			ghost=false,center=false,
			drop=1,lock=1,
			wait=10,fall=25,
			next=1,hold=false,
			sequence="rnd",
			freshLimit=0,
			target=10,
			reach=Event.classic_reach,
			bg="rgb",
			bgm="rockblock",
		},
	},
	zen={
		{
			drop=1e99,
			lock=1e99,
			oncehold=false,
			target=200,
			reach=Event.gameover.win,
			bg="strap",
			bgm="infinite",
		},
	},
	infinite={
		{
			drop=1e99,
			lock=1e99,
			oncehold=false,
			bg="glow",
			bgm="infinite",
		},
	},
	solo={
		{
			freshLimit=15,
			bg="game2",
			bgm="race",
		},
	},
	tsd={
		{
			oncehold=false,
			drop=1e99,
			lock=1e99,
			freshLimit=15,
			target=1,
			reach=Event.tsd_reach,
			ospin=false,
			bg="matrix",
			bgm="reason",
		},
		{
			drop=60,
			lock=60,
			freshLimit=15,
			target=1,
			reach=Event.tsd_reach,
			ospin=false,
			bg="matrix",
			bgm="reason",
		},
	},
	blind={
		{
			drop=30,
			lock=60,
			freshLimit=15,
			ghost=false,
			visible="time",
			bg="glow",
			bgm="newera",
		},
		{
			drop=15,
			lock=60,
			freshLimit=15,
			visible="fast",
			freshLimit=10,
			bg="glow",
			bgm="reason",
		},
		{
			fall=10,
			lock=60,
			center=false,
			ghost=false,
			visible="none",
			freshLimit=15,
			bg="rgb",
			bgm="secret7th",
		},
		{
			fall=5,
			lock=60,
			block=false,
			center=false,
			ghost=false,
			visible="none",
			freshLimit=15,
			bg="rgb",
			bgm="secret7th",
		},
		{
			_20G=true,
			drop=0,
			lock=15,
			wait=10,
			fall=15,
			visible="fast",
			freshLimit=15,
			arr=1,
			bg="game3",
			bgm="secret8th",
		},
	},
	dig={
		{
			drop=60,
			lock=120,
			fall=20,
			freshLimit=15,
			bg="game2",
			bgm="push",
		},
		{
			drop=10,
			lock=30,
			freshLimit=15,
			bg="game2",
			bgm="secret7th",
		},
	},
	survivor={
		{
			drop=60,
			lock=120,
			fall=30,
			freshLimit=15,
			bg="game2",
			bgm="push",
		},
		{
			drop=30,
			lock=60,
			fall=20,
			freshLimit=15,
			bg="game2",
			bgm="newera",
		},
		{
			drop=10,
			lock=60,
			fall=15,
			freshLimit=15,
			bg="game2",
			bgm="secret8th",
		},
		{
			drop=5,
			lock=60,
			fall=10,
			freshLimit=15,
			bg="game3",
			bgm="secret7th",
		},
	},
	tech={
		{
			oncehold=false,
			drop=1e99,
			lock=1e99,
			target=0,
			reach=Event.tech_reach,
			bg="matrix",
			bgm="way",
		},
		{
			drop=30,
			lock=60,
			target=0,
			reach=Event.tech_reach,
			bg="matrix",
			bgm="way",
		},
		{
			drop=15,
			lock=60,
			target=0,
			reach=Event.tech_reach_hard,
			freshLimit=15,
			bg="matrix",
			bgm="way",
		},
		{
			drop=5,
			lock=40,
			target=0,
			freshLimit=15,
			reach=Event.tech_reach_hard,
			bg="matrix",
			bgm="way",
		},
		{
			drop=1,
			lock=40,
			target=0,
			freshLimit=15,
			reach=Event.tech_reach_hard,
			bg="matrix",
			bgm="secret7th",
		},
	},
	pctrain={
		{
			next=4,
			hold=false,
			drop=120,
			lock=120,
			fall=20,
			sequence="pc",
			target=0,
			reach=Event.newPC,
			ospin=false,
			bg="rgb",
			bgm="newera",
		},
		{
			next=4,
			hold=false,
			drop=60,
			lock=60,
			fall=20,
			sequence="pc",
			target=0,
			freshLimit=15,
			reach=Event.newPC,
			ospin=false,
			bg="rgb",
			bgm="newera",
		},
	},
	pcchallenge={
		{
			oncehold=false,
			drop=300,
			lock=1e99,
			target=100,
			reach=Event.gameover.win,
			ospin=false,
			bg="rgb",
			bgm="newera",
		},
		{
			drop=60,
			lock=120,
			fall=10,
			target=100,
			reach=Event.gameover.win,
			freshLimit=15,
			ospin=false,
			bg="rgb",
			bgm="infinite",
		},
		{
			drop=20,
			lock=60,
			fall=20,
			target=100,
			reach=Event.gameover.win,
			freshLimit=15,
			ospin=false,
			bg="rgb",
			bgm="infinite",
		},
	},
	techmino41={
		{
			fall=20,
			royaleMode=true,
			royalePowerup={2,5,10,20},
			royaleRemain={30,20,15,10,5},
			pushSpeed=2,
			freshLimit=15,
			bg="game3",
			bgm="race",
		},
	},
	techmino99={
		{
			fall=20,
			royaleMode=true,
			royalePowerup={2,6,14,30},
			royaleRemain={75,50,35,20,10},
			pushSpeed=2,
			freshLimit=15,
			bg="game3",
			bgm="race",
		},
	},
	drought={
		{
			drop=20,
			lock=60,
			sequence="drought1",
			target=100,
			reach=Event.gameover.win,
			ospin=false,
			freshLimit=15,
			bg="glow",
			bgm="reason",
		},
		{
			drop=20,
			lock=60,
			sequence="drought2",
			target=100,
			reach=Event.gameover.win,
			ospin=false,
			freshLimit=15,
			bg="glow",
			bgm="reason",
		},
	},
	hotseat={
		{
			freshLimit=15,
			bg="none",
			bgm="way",
		},
	},
	custom={
		{
			bg="none",
			bgm="reason",
			reach=Event.gameover.win,
		},
	},
}