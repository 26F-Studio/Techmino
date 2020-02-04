local int,rnd,max,min=math.floor,math.random,math.max,math.min
local format=string.format
local ins,rem=table.insert,table.remove
local PCbase={
	{3,3,3,0,0,0,0,0,2,2},
	{3,6,6,0,0,0,0,2,2,5},
	{4,6,6,0,0,0,1,1,5,5},
	{4,4,4,0,0,0,0,1,1,5},
	{1,1,0,0,0,0,0,4,4,4},
	{5,1,1,0,0,0,0,6,6,4},
	{5,5,2,2,0,0,0,6,6,3},
	{5,2,2,0,0,0,0,3,3,3},
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
local rush_lock={20,18,16,15,14}
local rush_wait={12,10,9,8,7}
local rush_fall={18,16,14,13,12}
local death_lock={12,11,10,9,8}
local death_wait={10,9,8,7,6}
local death_fall={10,9,8,7,6}
local pc_drop={50,45,40,35,30,26,22,18,15,12}
local pc_lock={55,50,45,40,36,32,30}
local pc_fall={18,16,14,12,10,9,8,7,6}
local function throwBadge(S,R)--Sender/Receiver
	local x1,y1,x2,y2
	if S.small then
		x1,y1=S.centerX,S.centerY
	else
		x1,y1=S.x+308*S.size,S.y+450*S.size
	end
	if R.small then
		x2,y2=R.centerX,R.centerY
	else
		x2,y2=R.x+66*R.size,R.y+344*R.size
	end
	FX_badge[#FX_badge+1]={x1,y1,x2,y2,t=0}
end
local AISpeed={60,50,45,35,25,15,9,6,4,2}
local function AITemplate(type,speedLV,next,hold,node)
	if type=="CC"then
		return{
			type="CC",
			next=next,
			hold=hold,--hold,-------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			delta=AISpeed[speedLV],
			node=node,
		}
	elseif type=="9S"then
		return{
			type="9S",
			delta=int(AISpeed[speedLV]*.5),
		}
	end
end
loadmode={}
function loadmode.sprint()
	newPlayer(1,340,15)
end
function loadmode.marathon()
	newPlayer(1,340,15)
end
function loadmode.master()
	newPlayer(1,340,15)
end
function loadmode.classic()
	newPlayer(1,340,15)
end
function loadmode.zen()
	newPlayer(1,340,15)
end
function loadmode.infinite()
	newPlayer(1,340,15)
	if curMode.lv==2 then
		pushSpeed=1
		for _=1,5 do
			players[1]:garbageRise(10,1,rnd(10))
		end
	end
end
function loadmode.solo()
	newPlayer(1,340,15)
	if curMode.lv==1 then
		newPlayer(2,965,360,.5,AITemplate("9S",3))
	elseif curMode.lv==2 then
		newPlayer(2,965,360,.5,AITemplate("CC",3,2,false,10000))
	elseif curMode.lv==3 then
		newPlayer(2,965,360,.5,AITemplate("9S",5))
	elseif curMode.lv==4 then
		newPlayer(2,965,360,.5,AITemplate("CC",5,2,true,20000))
	elseif curMode.lv==5 then
		newPlayer(2,965,360,.5,AITemplate("9S",7))
	elseif curMode.lv==6 then
		newPlayer(2,965,360,.5,AITemplate("CC",8,3,true,30000))
	elseif curMode.lv==7 then
		newPlayer(2,965,360,.5,AITemplate("9S",8))
	elseif curMode.lv==8 then
		newPlayer(2,965,360,.5,AITemplate("CC",9,3,true,40000))
	elseif curMode.lv==9 then
		newPlayer(2,965,360,.5,AITemplate("9S",9))
	elseif curMode.lv==10 then
		newPlayer(2,965,360,.5,AITemplate("CC",10,4,true,80000))
	end
end
function loadmode.round()
	newPlayer(1,340,15)
	if curMode.lv==1 then
		newPlayer(2,965,360,.5,AITemplate("9S",10))
	elseif curMode.lv==2 then
		newPlayer(2,965,360,.5,AITemplate("CC",10,2,false,10000))
	elseif curMode.lv==3 then
		newPlayer(2,965,360,.5,AITemplate("CC",10,3,true,30000))
	elseif curMode.lv==4 then
		newPlayer(2,965,360,.5,AITemplate("CC",10,4,true,60000))
	elseif curMode.lv==5 then
		newPlayer(2,965,360,.5,AITemplate("CC",10,6,true,100000))
	end
	garbageSpeed=1e4
end
function loadmode.tsd()
	newPlayer(1,340,15)
end
function loadmode.blind()
	newPlayer(1,340,15)
end
function loadmode.dig()
	newPlayer(1,340,15)
	pushSpeed=1
end
function loadmode.survivor()
	newPlayer(1,340,15)
	pushSpeed=curMode.lv>2 and 2 or 1
end
function loadmode.defender()
	newPlayer(1,340,15)
	if curMode.lv==1 then
		pushSpeed=1
	elseif curMode.lv==2 then
		pushSpeed=2
	end
end
function loadmode.attacker()
	newPlayer(1,340,15)
	if curMode.lv==1 then
		pushSpeed=2
	end
end
function loadmode.tech()
	newPlayer(1,340,15)
end
function loadmode.c4wtrain()
	newPlayer(1,340,15)
	local P=players[1]
	local F=P.field
	for i=1,24 do
		F[i]=getNewRow(10)
		P.visTime[i]=getNewRow(20)
		for x=4,7 do F[i][x]=0 end
	end
	local r=rnd(6)
	if r==1 then	 F[1][5],F[1][4],F[2][4]=10,10,10
	elseif r==2 then F[1][6],F[1][7],F[2][7]=10,10,10
	elseif r==3 then F[1][4],F[2][4],F[2][5]=10,10,10
	elseif r==4 then F[1][7],F[2][7],F[2][6]=10,10,10
	elseif r==5 then F[1][4],F[1][5],F[1][6]=10,10,10
	elseif r==6 then F[1][7],F[1][6],F[1][5]=10,10,10
	end
end
function loadmode.pctrain()
	newPlayer(1,340,15)
	Event.newPC(players[1])
end
function loadmode.pcchallenge()
	newPlayer(1,340,15)
end
function loadmode.techmino49()
	newPlayer(1,340,15)
	local LV=curMode.lv
	if LV==3 then players[1].gameEnv.drop=15 end
	local L={}for i=1,49 do L[i]=true end
	local t=system~="Windows"and 0 or 2*LV
	while t>0 do
		local r=rnd(2,49)
		if L[r]then L[r],t=false,t-1 end
	end
	local min,max
	if LV==1 then		min,max=4,6
	elseif LV==2 then	min,max=4,8
	elseif LV==3 then	min,max=8,10
	end
	local n=2
	for i=1,4 do for j=1,6 do
		if L[n]then
			newPlayer(n,78*i-54,115*j-98,.09,AITemplate("9S",rnd(min,max)))
		else
			newPlayer(n,78*i-54,115*j-98,.09,AITemplate("CC",rnd(min,max)-1,LV+1,true,LV*10000))
		end
		n=n+1
	end end
	for i=9,12 do for j=1,6 do
		if L[n]then
			newPlayer(n,78*i+267,115*j-98,.09,AITemplate("9S",rnd(min,max)))
		else
			newPlayer(n,78*i+267,115*j-98,.09,AITemplate("CC",rnd(min,max)-1,LV+1,true,LV*10000))
		end
		n=n+1
	end end
end
function loadmode.techmino99()
	newPlayer(1,340,15)
	local LV=curMode.lv
	if LV==3 then players[1].gameEnv.drop=15 end
	local L={}for i=1,100 do L[i]=true end
	local t=system~="Windows"and 0 or 1+3*LV
	while t>0 do
		local r=rnd(2,99)
		if L[r]then L[r],t=false,t-1 end
	end
	local min,max
	if LV==1 then		min,max=4,6
	elseif LV==2 then	min,max=4,8
	elseif LV==3 then	min,max=8,10
	end
	local n=2
	for i=1,7 do for j=1,7 do
		if L[n]then
			newPlayer(n,46*i-36,97*j-72,.068,AITemplate("9S",rnd(min,max)))
		else
			newPlayer(n,46*i-36,97*j-72,.068,AITemplate("CC",rnd(min,max)-1,LV+1,true,LV*10000))
		end
		n=n+1
	end end
	for i=15,21 do for j=1,7 do
		if L[n]then
			newPlayer(n,46*i+264,97*j-72,.068,AITemplate("9S",rnd(min,max)))
		else
			newPlayer(n,46*i+264,97*j-72,.068,AITemplate("CC",rnd(min,max)-1,LV+1,true,LV*10000))
		end
		n=n+1
	end end
end
function loadmode.drought()
	newPlayer(1,340,15)
end
function loadmode.hotseat()
	if curMode.lv==1 then
		newPlayer(1,20,15)
		newPlayer(2,650,15)
	elseif curMode.lv==2 then
		newPlayer(1,20,100,.65)
		newPlayer(2,435,100,.65)
		newPlayer(3,850,100,.65)
	elseif curMode.lv==3 then
		newPlayer(1,25,160,.5)
		newPlayer(2,335,160,.5)
		newPlayer(3,645,160,.5)
		newPlayer(4,955,160,.5)
	end
end
function loadmode.custom()
	for i=1,#customID do
		local k=customID[i]
		modeEnv[k]=customRange[k][customSel[i]]
	end
	modeEnv._20G=modeEnv.drop==0
	modeEnv.oncehold=customSel[6]==1
	if curMode.lv==2 then
		modeEnv.target=0
	end
	newPlayer(1,340,15)
	local L=modeEnv.opponent
	if L~=0 then
		modeEnv.target=nil
		if L<10 then
			newPlayer(2,965,360,.5,AITemplate("9S",2*L))
		else
			newPlayer(2,965,360,.5,AITemplate("CC",L-6,2+int((L-11)*.5),modeEnv.hold,15000+5000*(L-10)))
		end
	end
	preField.h=20
	repeat
		for i=1,10 do
			if preField[preField.h][i]>0 or curMode.lv==2 and preField[preField.h][i]==-1 then
				goto L
			end
		end
		preField.h=preField.h-1
	until preField.h==0
	::L::
	if curMode.lv==1 then
		for _,P in next,players.alive do
			local t=P.showTime*3
			for y=1,preField.h do
				P.field[y]=getNewRow(0)
				P.visTime[y]=getNewRow(t)
				for x=1,10 do P.field[y][x]=preField[y][x]end
			end
		end
	end
	modeEnv.bg=customRange.bg[customSel[12]]
	modeEnv.bgm=customRange.bgm[customSel[13]]
end
-------------------------<Events>-------------------------
Event={null=NULL}
function Event.reach_winCheck(P)
	if P.stat.row>=P.gameEnv.target then
		Event.win(P)
	end
end
function Event.win(P)
	P.alive=false
	P.control=false
	P.timing=false
	P.waiting=1e99
	P.b2b=0
	clearTask(P)
	if modeEnv.royaleMode then
		P.rank=1
		P.result="WIN"
		P:changeAtk()
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
	if P.human then
		gamefinished=true
		SFX("win")
		VOICE("win")
		if modeEnv.royaleMode then
			BGM("8-bit happiness")
		end
	end
	newTask(Event_task.finish,P)
	P:showText(text.win,"beat",90,nil,.4,curMode.id~="custom")
end
function Event.lose(P)
	if P.invincible then
		while P.field[1]do
			removeRow(P.field)
			removeRow(P.visTime)
		end
		if P.AI_mode=="CC"then
			P.AI_needFresh=true
		end
		return
	end
	P.alive=false
	P.control=false
	P.timing=false
	P.waiting=1e99
	P.b2b=0
	clearTask(P)
	for i=1,#players.alive do
		if players.alive[i]==P then
			for k=i,#players.alive do
				players.alive[k]=players.alive[k+1]
			end
			break
		end
	end
	if modeEnv.royaleMode then
		P:changeAtk()
		P.result="K.O."
		P.rank=#players.alive+1
		P:showText(P.rank,"appear",60,120,nil,true)
		P.strength=0
		if P.lastRecv then
			local A,i=P,0
			repeat
				A,i=A.lastRecv,i+1
			until not A or A.alive or A==P or i==3
			if A and A.alive then
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
					newTask(Event_task.throwBadge,A,{P,max(3,P.badge)*4})
				end
				freshMostBadge()
			end
		else
			P.badge=-1
		end
		freshMostDangerous()
		for i=1,#players.alive do
			if players.alive[i].atking==P then
				players.alive[i]:freshTarget()
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
	P.gameEnv.keepVisible=P.gameEnv.visible~="show"
	P:showText(text.lose,"appear",90,nil,nil,true)
	if P.human then
		gamefinished=true
		SFX("fail")
		VOICE("lose")
		if modeEnv.royaleMode then BGM("end")end
	end
	if #players.alive==1 then
		Event.win(players.alive[1])
	end
	if #players>1 then
		newTask(Event_task.lose,P)
	else
		newTask(Event_task.finish,P)
	end
end
function Event.marathon_update(P)
	if P.stat.row>=P.gameEnv.target then
		local s=int(P.stat.row*.1)
		if s>=20 then
			P.stat.row=200
			Event.win(P)
		else
			P.gameEnv.drop=marathon_drop[s]
			if s==18 then P.gameEnv._20G=true end
			P.gameEnv.target=s*10+10
			SFX("reach")
		end
	end
end
function Event.master_score(P)
	local c=#P.cleared
	if c==0 and P.modeData.point%100==99 then return end
	local s=c<3 and c+1 or c==3 and 5 or 7
	if P.combo>7 then s=s+2
	elseif P.combo>3 then s=s+1
	end
	P.modeData.point=P.modeData.point+s
	if P.modeData.point%100==99 then
		SFX("blip_1")
	elseif P.modeData.point>=100*(P.modeData.event+1)then
		local s=P.modeData.event+1;P.modeData.event=s--level up!
		local E=P.gameEnv
		local mode=curMode.lv
		if mode==1 then
			curBG=s==1 and"game1"or s==2 and"game2"or s==3 and"game3"or s==4 and"game4"
			E.lock=rush_lock[s]
			E.wait=rush_wait[s]
			E.fall=rush_fall[s]
			E.das=10-s
			if s==2 then P.gameEnv.arr=2 end
			if s==4 then P.gameEnv.bone=true end
		elseif mode==2 then
			curBG=s==1 and"game3"or s==2 and"game4"or s==3 and"game5"or s==4 and"game6"
			E.lock=death_lock[s]
			E.wait=death_wait[s]
			E.fall=death_fall[s]
			E.das=int(6.9-s*.4)
			if s==3 then P.gameEnv.bone=true end
		end
		if s==5 then
			P.modeData.point,P.modeData.event=500,4
			Event.win(P)
		else
			P:showText(text.stage(s),"fly",80,-120)
		end
		SFX("reach")
	end
end
function Event.master_score_hard(P)
	local c=#P.cleared
	if c==0 then return end
	local s
	if P.lastClear<10 then
		s=c
	else
		s=c<3 and c+1 or c<5 and 6 or 10
	end
	if P.combo>9 then s=s+2
	elseif P.combo>4 then s=s+1
	end
	P.modeData.point=P.modeData.point+s
	if P.modeData.point%100==99 then SFX("blip_1")end
	if int(P.modeData.point*.01)>P.modeData.event then
		local s=P.modeData.event+1;P.modeData.event=s--level up!
		P:showText(text.stage(s),"fly",80,-120)
		if s<4 then--first 300
			if s~=1 then P.gameEnv.lock=P.gameEnv.lock-1 end
			if s~=2 then P.gameEnv.wait=P.gameEnv.wait-1 end
			if s~=3 then P.gameEnv.fall=P.gameEnv.fall-1 end
		elseif s<10 then
			if s==4 or s==7 then P.gameEnv.das=P.gameEnv.das-1 end
			s=s%3
			if s==0 then
				P.gameEnv.lock=P.gameEnv.lock-1
			elseif s==1 then
				P.gameEnv.wait=P.gameEnv.wait-1
			elseif s==2 then
				P.gameEnv.fall=P.gameEnv.fall-1
			end
		else
			P.modeData.point,P.modeData.event=1000,9
			Event.win(P)
		end
		SFX("reach")
	end
end
function Event.classic_reach(P)
	if P.stat.row>=P.gameEnv.target then
		P.gameEnv.target=P.gameEnv.target+10
		if P.gameEnv.target==110 then
			P.gameEnv.drop,P.gameEnv.lock=2,2
		elseif P.gameEnv.target==200 then
			P.gameEnv.drop,P.gameEnv.lock=1,1
		end
		if P.gameEnv.target>100 then
			SFX("reach")
		end
	end
end
function Event.infinite_check(P)
	for i=1,#P.cleared do
		if P.cleared[i]<6 then
			P:garbageRise(10,1,rnd(10))
		end
	end
end
function Event.round_check(P)
	if #players.alive>1 then
		P.control=false
		local ID=P.id
		repeat
			ID=ID+1
			if not players[ID]then ID=1 end
		until players[ID].alive or ID==P.id
		players[ID].control=true
	end
end
function Event.GM_score(P)
	local F=false
	if P.modeData.point<70 then--if Less then MM
		local R=#P.cleared
		if R==4 then R=10 end
		P.modeData.point=P.modeData.point+R
		F=true
	end
	if P.stat.time>=53.5 then
		P.modeData.point=min(P.modeData.point+15,80)
		F=true
		Event.win(P)
	end
	if F then
		P.modeData.event=sectionName[int(P.modeData.point*.1)+1]
	end
end
function Event.tsd_reach(P)
	if #P.cleared>0 then
		if P.lastClear~=52 then
			Event.lose(P)
		elseif #P.cleared>0 then
			P.modeData.event=P.modeData.event+1
		end
	end
end
function Event.tech_reach_easy(P)
	if #P.cleared>0 and P.b2b<40 then
		Event.lose(P)
	end
end
function Event.tech_reach_hard(P)
	if #P.cleared>0 and P.lastClear<10 then
		Event.lose(P)
	end
end
function Event.tech_reach_ultimate(P)
	if #P.cleared>0 and P.lastClear<10 or P.lastClear==74 then
		Event.lose(P)
	end
end
function Event.c4w_reach(P)
	for i=1,#P.cleared do
		P.field[#P.field+1]=getNewRow(10)
		P.visTime[#P.visTime+1]=getNewRow(20)
		for i=4,7 do P.field[#P.field][i]=0 end
	end
	if #P.cleared==0 then
		if curMode.lv==2 then
			Event.lose(P)
		end
	else
		if P.combo>P.modeData.point then
			P.modeData.point=P.combo
		end
		if P.stat.row>=100 then
			Event.win(P)
		end
	end
end
function Event.newPC(P)
	local r=P.field;r=r[#r]
	if r then
		local c=0
		for i=1,10 do if r[i]>0 then c=c+1 end end
		if c<5 then
			Event.lose(P)
		end
	end
	if P.stat.piece%4==0 and #P.field==0 then
		P.modeData.event=P.modeData.event==0 and 1 or 0
		local r=rnd(#PClist)
		local f=P.modeData.event==0
		for i=1,4 do
			local b=PClist[r][i]
			if f then
				if b<3 then b=3-b
				elseif b<5 then b=7-b
				end
			end
			P.next[#P.next+1]={bk=blocks[b][0],id=b,color=b,name=b}--P:newNext(b)'s simple version!
		end
		P.counter=P.stat.piece==0 and 20 or 0
		newTask(Event_task.PC,P)
		if curMode.lv==2 then
			local s=P.stat.pc*.5
			if int(s)==s and s>0 then
				P.gameEnv.drop=pc_drop[s]or 10
				P.gameEnv.lock=pc_lock[s]or 20
				P.gameEnv.fall=pc_fall[s]or 5
				if s==10 then
					P:showText(text.maxspeed,"appear",100,-140,.6)
				else
					P:showText(text.speedup,"appear",40,-140)
				end
			end
		end
	end
end
function Event.puzzleCheck(P)
	for y=1,20 do
		local L=P.field[y]
		for x=1,10 do
			local a,b=preField[y][x],L and L[x]or 0
			if a~=0 then
				if a==-1 then
					if b>0 then return end
				elseif a<8 then
					if a~=b then return end
				elseif a>7 then
					if b==0 then return end
				end
			end
		end
	end
	P.modeData.event=1
	Event.win(P)
end
-------------------------</Events>-------------------------

-------------------------<Tasks>-------------------------
Event_task={}
function Event_task.finish(P)
	P.endCounter=P.endCounter+1
	if P.endCounter>120 then
		pauseGame()
		return true
	end
end
function Event_task.lose(P)
	P.endCounter=P.endCounter+1
	if P.endCounter>80 then
		for i=1,#P.field do
			for j=1,10 do
				if P.visTime[i][j]>0 then
					P.visTime[i][j]=P.visTime[i][j]-1
				end
			end
		end
		if P.endCounter==100 then
			while P.field[1]do
				removeRow(P.field)
				removeRow(P.visTime)
			end
			if #players==1 then
				pauseGame()
			end
			return true
		end
	end
end
function Event_task.throwBadge(A,data)
	data[2]=data[2]-1
	if data[2]%4==0 then
		throwBadge(data[1],data[1].lastRecv)
		if not A.ai and data[2]%8==0 then
			SFX("collect")
		end
	end
	if data[2]<=0 then return true end
end
function Event_task.dig_normal(P)
	if not P.control then return end
	P.counter=P.counter+1
	if P.counter>=max(90,180-P.modeData.event)then
		P.counter=0
		P:garbageRise(10,1,rnd(10))
		P.modeData.event=P.modeData.event+1
	end
end
function Event_task.dig_lunatic(P)
	if not P.control then return end
	P.counter=P.counter+1
	if P.counter>=max(45,80-.3*P.modeData.event)then
		P.counter=0
		P:garbageRise(11+P.modeData.event%3,1,rnd(10))
		P.modeData.event=P.modeData.event+1
	end
end
function Event_task.survivor_easy(P)
	if not P.control then return end
	P.counter=P.counter+1
	if P.counter>=max(60,150-2*P.modeData.event)and P.atkBuffer.sum<4 then
		P.atkBuffer[#P.atkBuffer+1]={pos=rnd(10),amount=1,countdown=30,cd0=30,time=0,sent=false,lv=1}
		P.atkBuffer.sum=P.atkBuffer.sum+1
		P.stat.recv=P.stat.recv+1
		if P.modeData.event==45 then P:showText(text.maxspeed,"appear",100,-140,.6)end
		P.counter=0
		P.modeData.event=P.modeData.event+1
	end
end
function Event_task.survivor_normal(P)
	if not P.control then return end
	P.counter=P.counter+1
	if P.counter>=max(90,180-2*P.modeData.event)and P.atkBuffer.sum<8 then
		local d=P.modeData.event+1
		P.atkBuffer[#P.atkBuffer+1]=
			d%4==0 and{pos=rnd(10),amount=1,countdown=60,cd0=60,time=0,sent=false,lv=1}or
			d%4==1 and{pos=rnd(10),amount=2,countdown=70,cd0=70,time=0,sent=false,lv=1}or
			d%4==2 and{pos=rnd(10),amount=3,countdown=80,cd0=80,time=0,sent=false,lv=2}or
			d%4==3 and{pos=rnd(10),amount=4,countdown=90,cd0=90,time=0,sent=false,lv=3}
		P.atkBuffer.sum=P.atkBuffer.sum+d%4+1
		P.stat.recv=P.stat.recv+d%4+1
		if P.modeData.event==45 then P:showText(text.maxspeed,"appear",100,-140,.6)end
		P.counter=0
		P.modeData.event=d
	end
end
function Event_task.survivor_hard(P)
	if not P.control then return end
	P.counter=P.counter+1
	if P.counter>=max(60,180-2*P.modeData.event)and P.atkBuffer.sum<15 then
		P.atkBuffer[#P.atkBuffer+1]=
			P.modeData.event%3<2 and
				{pos=rnd(10),amount=1,countdown=0,cd0=0,time=0,sent=false,lv=1}
			or
				{pos=rnd(10),amount=3,countdown=60,cd0=60,time=0,sent=false,lv=2}
		local R=(P.modeData.event%3<2 and 1 or 3)
		P.atkBuffer.sum=P.atkBuffer.sum+R
		P.stat.recv=P.stat.recv+R
		if P.modeData.event==60 then P:showText(text.maxspeed,"appear",100,-140,.6)end
		P.counter=0
		P.modeData.event=P.modeData.event+1
	end
end
function Event_task.survivor_lunatic(P)
	if not P.control then return end
	P.counter=P.counter+1
	if P.counter>=max(60,150-P.modeData.event)and P.atkBuffer.sum<20 then
		local t=max(60,90-P.modeData.event)
		P.atkBuffer[#P.atkBuffer+1]={pos=rnd(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3}
		P.atkBuffer.sum=P.atkBuffer.sum+4
		P.stat.recv=P.stat.recv+4
		if P.modeData.event==60 then P:showText(text.maxspeed,"appear",100,-140,.6)end
		P.counter=0
		P.modeData.event=P.modeData.event+1
	end
end
function Event_task.survivor_ultimate(P)
	if not P.control then return end
	P.counter=P.counter+1
	if P.counter>=max(300,600-10*P.modeData.event)and P.atkBuffer.sum<20 then
		local t=max(300,480-12*P.modeData.event)
		local p=#P.atkBuffer+1
			P.atkBuffer[p]	={pos=rnd(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=2}
			P.atkBuffer[p+1]={pos=rnd(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3}
			P.atkBuffer[p+2]={pos=rnd(10),amount=6,countdown=1.2*t,cd0=1.2*t,time=0,sent=false,lv=4}
			P.atkBuffer[p+3]={pos=rnd(10),amount=6,countdown=1.5*t,cd0=1.5*t,time=0,sent=false,lv=5}
		P.atkBuffer.sum=P.atkBuffer.sum+20
		P.stat.recv=P.stat.recv+20
		P.counter=0
		if P.modeData.event==31 then P:showText(text.maxspeed,"appear",100,-140,.6)end
		P.modeData.event=P.modeData.event+1
	end
end
function Event_task.defender_normal(P)
	if not P.control then return end
	P.counter=P.counter+1
	local t=360-P.modeData.event*2
	if P.counter>=t then
		P.counter=0
		for _=1,3 do
			P.atkBuffer[#P.atkBuffer+1]={pos=rnd(2,9),amount=1,countdown=2*t,cd0=2*t,time=0,sent=false,lv=1}
		end
		P.atkBuffer.sum=P.atkBuffer.sum+3
		P.stat.recv=P.stat.recv+3
		local D=P.modeData
		if D.event<90 then
			D.event=D.event+1
			D.point=int(108e3/(360-D.event*2))*.1
			if D.event==25 then
				P:showText(text.great,"appear",100,-140,.6)
				pushSpeed=2
				P.dropDelay,P.gameEnv.drop=20,20
			elseif D.event==50 then
				P:showText(text.awesome,"appear",100,-140,.6)
				pushSpeed=3
				P.dropDelay,P.gameEnv.drop=10,10
			elseif D.event==90 then
				P.dropDelay,P.gameEnv.drop=5,5
				P:showText(text.maxspeed,"appear",100,-140,.6)
			end
		end
	end
end
function Event_task.defender_lunatic(P)
	if not P.control then return end
	P.counter=P.counter+1
	local t=240-2*P.modeData.event
	if P.counter>=t then
		P.counter=0
		for _=1,4 do
			P.atkBuffer[#P.atkBuffer+1]={pos=rnd(10),amount=1,countdown=5*t,cd0=5*t,time=0,sent=false,lv=2}
		end
		P.atkBuffer.sum=P.atkBuffer.sum+4
		P.stat.recv=P.stat.recv+4
		local D=P.modeData
		if D.event<75 then
			D.event=D.event+1
			D.point=int(144e3/(240-2*D.event))*.1
			if D.event==25 then
				P:showText(text.great,"appear",100,-140,.6)
				pushSpeed=3
				P.dropDelay,P.gameEnv.drop=4,4
			elseif D.event==50 then
				P:showText(text.awesome,"appear",100,-140,.6)
				pushSpeed=4
				P.dropDelay,P.gameEnv.drop=3,3
			elseif D.event==75 then
				P:showText(text.maxspeed,"appear",100,-140,.6)
				P.dropDelay,P.gameEnv.drop=2,2
			end
		end
	end
end
function Event_task.attacker_hard(P)
	if not P.control then return end
	if P.atkBuffer.sum==0 then
		local p=#P.atkBuffer+1
		local B,D=P.atkBuffer,P.modeData
		local t
		if D.event<20 then
			t=1500-30*D.event--1500~900
			B[p]=	{pos=rnd(4,7),amount=12,countdown=t,cd0=t,time=0,sent=false,lv=3}
			B[p+1]=	{pos=rnd(3,8),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=4}
		else
			t=900-10*(D.event-20)--900~600
			B[p]=	{pos=rnd(10),amount=6,countdown=t,cd0=t,time=0,sent=false,lv=4}
			B[p+1]=	{pos=rnd(4,7),amount=16,countdown=t,cd0=t,time=0,sent=false,lv=5}
		end
		B.sum=B.sum+22
		P.stat.recv=P.stat.recv+22
		if D.event<50 then
			D.event=D.event+1
			D.point=int(72e4/t)*.1
			if D.event==20 then
				P:showText(text.great,"appear",100,-140,.6)
				pushSpeed=3
			elseif D.event==50 then
				P:showText(text.maxspeed,"appear",100,-140,.6)
			end
		end
	end
end
function Event_task.attacker_ultimate(P)
	if not P.control then return end
	if P.atkBuffer.sum<2 then
		local p=#P.atkBuffer+1
		local B,D=P.atkBuffer,P.modeData
		local s,t
		if D.event<10 then
			t=1000-20*D.event--1000~800
			B[p]=	{pos=rnd(5,6),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=3}
			B[p+1]=	{pos=rnd(4,7),amount=12,countdown=t,cd0=t,time=0,sent=false,lv=4}
			s=22
		elseif D.event<20 then
			t=800-20*(D.event-15)--800~600
			B[p]=	{pos=rnd(3,8),amount=11,countdown=t,cd0=t,time=0,sent=false,lv=4}
			B[p+1]=	{pos=rnd(4,7),amount=14,countdown=t,cd0=t,time=0,sent=false,lv=5}
			s=25
		else
			t=600-15*(D.event-30)--600~450
			B[p]=	{pos=rnd(2)*9-8,amount=12,countdown=t,cd0=t,time=0,sent=false,lv=5}
			B[p+1]=	{pos=rnd(3,8),amount=16,countdown=t,cd0=t,time=0,sent=false,lv=5}
			s=28
		end
		B.sum=B.sum+s
		P.stat.recv=P.stat.recv+s
		if D.event<45 then
			D.event=D.event+1
			D.point=int(s*36e3/t)*.1
			if D.event==10 then
				P:showText(text.great,"appear",100,-140,.6)
				pushSpeed=4
			elseif D.event==20 then
				P:showText(text.awesome,"appear",100,-140,.6)
				pushSpeed=5
			elseif D.event==30 then
				P:showText(text.maxspeed,"appear",100,-140,.6)
			end
		end
	end
end
function Event_task.PC(P)
	P.counter=P.counter+1
	if P.counter==21 then
		local t=P.stat.pc%2
		for i=1,4 do
			local r=getNewRow(0)
			for j=1,10 do
				r[j]=PCbase[4*t+i][j]
			end
			ins(P.field,1,r)
			ins(P.visTime,1,getNewRow(20))
		end
		P.fieldBeneath=P.fieldBeneath+120
		P.curY=P.curY+4
		P:freshgho()
		return true
	end
end
function Event_task.bgmFadeOut(_,id)
	local v=bgm[id]:getVolume()-.025*setting.bgm*.1
	bgm[id]:setVolume(v>0 and v or 0)
	if v<=0 then
		bgm[id]:stop()
		return true
	end
end
function Event_task.bgmFadeIn(_,id)
	local v=min(bgm[id]:getVolume()+.025*setting.bgm*.1,setting.bgm*.1)
	bgm[id]:setVolume(v)
	if v>=setting.bgm*.1 then return true end
end
-------------------------</Tasks>-------------------------

local Fkey_func={
	royale=function(P)
		if setting.swap then
			for i=1,#P.keyPressing do
				if P.keyPressing[i]then
					P.keyPressing[i]=false
				end
			end
			P.keyPressing[9]=true
		else
			P:changeAtkMode(P.atkMode<3 and P.atkMode+2 or 5-P.atkMode)
			P.swappingAtkMode=30
		end
	end,
	puzzle=function(P)
		P.modeData.event=1-P.modeData.event
	end,
}
defModeEnv={}
defModeEnv.sprint={
	{
		drop=60,lock=60,
		target=10,dropPiece="reach_winCheck",
		bg="strap",bgm="race",
	},
	{
		drop=60,lock=60,
		target=20,dropPiece="reach_winCheck",
		bg="strap",bgm="race",
	},
	{
		drop=60,lock=60,
		target=40,dropPiece="reach_winCheck",
		bg="strap",bgm="race",
	},
	{
		drop=60,lock=60,
		target=100,dropPiece="reach_winCheck",
		bg="strap",bgm="race",
	},
	{
		drop=60,lock=60,
		target=400,dropPiece="reach_winCheck",
		bg="strap",bgm="push",
	},
	{
		drop=60,lock=60,
		target=1000,dropPiece="reach_winCheck",
		bg="strap",bgm="push",
	},
}
defModeEnv.marathon={
	{
		drop=60,lock=60,fall=30,
		target=200,dropPiece="reach_winCheck",
		bg="strap",bgm="way",
	},
	{
		drop=60,fall=20,
		target=10,dropPiece="marathon_update",
		bg="strap",bgm="way",
	},
	{
		_20G=true,fall=15,
		target=200,dropPiece="reach_winCheck",
		bg="strap",bgm="race",
	},
}
defModeEnv.master={
	{
		_20G=true,lock=rush_lock[1],
		wait=rush_wait[1],
		fall=rush_fall[1],
		dropPiece="master_score",
		das=9,arr=3,
		freshLimit=15,
		bg="strap",bgm="secret8th",
	},
	{
		_20G=true,lock=death_lock[1],
		wait=death_wait[1],
		fall=death_fall[1],
		dropPiece="master_score",
		das=6,arr=1,
		freshLimit=15,
		bg="game2",bgm="secret7th",
	},
	{
		_20G=true,lock=12,
		wait=10,fall=10,
		dropPiece="master_score_hard",
		das=5,arr=1,
		freshLimit=15,
		easyFresh=false,bone=true,
		bg="none",bgm="shining terminal",
	},
}
defModeEnv.classic={
	{
		das=16,arr=6,sddas=2,sdarr=2,
		ghost=false,center=false,
		drop=3,lock=3,wait=10,fall=25,
		next=1,hold=false,
		sequence="rnd",
		freshLimit=0,
		target=10,dropPiece="classic_reach",
		bg="rgb",bgm="rockblock",
	},
}
defModeEnv.zen={
	{
		drop=1e99,lock=1e99,
		oncehold=false,
		dropPiece="reach_winCheck",
		bg="strap",bgm="infinite",
	},
}
defModeEnv.infinite={
	{
		drop=1e99,lock=1e99,
		oncehold=false,
		bg="glow",bgm="infinite",
	},
	{
		drop=1e99,lock=1e99,
		oncehold=false,
		dropPiece="infinite_check",
		bg="glow",bgm="infinite",
	},
}
defModeEnv.solo={
	{
		drop=60,lock=60,
		freshLimit=15,
		bg="game2",bgm="race",
	},
}
defModeEnv.round={
	{
		drop=1e99,lock=1e99,
		oncehold=false,
		dropPiece="round_check",
		bg="game2",bgm="push",
	},
}
defModeEnv.tsd={
	{
		oncehold=false,
		drop=1e99,lock=1e99,
		dropPiece="tsd_reach",
		ospin=false,
		bg="matrix",bgm="reason",
	},
	{
		drop=60,lock=60,
		freshLimit=15,
		dropPiece="tsd_reach",
		ospin=false,
		bg="matrix",bgm="reason",
	},
}
defModeEnv.blind={
	{
		drop=30,lock=45,
		freshLimit=10,
		visible="time",
		bg="glow",bgm="newera",
	},
	{
		drop=15,lock=45,
		freshLimit=10,
		visible="fast",
		freshLimit=10,
		bg="glow",bgm="reason",
	},
	{
		drop=15,lock=45,
		fall=10,lock=60,
		center=false,
		visible="none",
		freshLimit=15,
		bg="rgb",bgm="secret7th",
	},
	{
		drop=10,lock=45,
		fall=5,lock=60,
		center=false,ghost=false,
		visible="none",
		freshLimit=15,
		bg="rgb",bgm="secret8th",
	},
	{
		drop=30,lock=60,
		fall=5,
		block=false,
		center=false,ghost=false,
		visible="none",
		freshLimit=15,
		bg="rgb",bgm="secret7th",
	},
	{
		_20G=true,
		drop=0,lock=15,
		wait=10,fall=15,
		visible="fast",
		freshLimit=15,
		dropPiece="GM_score",
		arr=1,
		bg="game3",bgm="shining terminal",
	},
}
defModeEnv.dig={
	{
		drop=60,lock=120,
		fall=20,
		freshLimit=15,
		task="dig_normal",
		bg="game2",bgm="push",
	},
	{
		drop=10,lock=30,
		freshLimit=15,
		task="dig_lunatic",
		bg="game2",bgm="secret7th",
	},
}
defModeEnv.survivor={
	{
		drop=60,lock=120,
		fall=30,
		freshLimit=15,
		task="survivor_easy",
		bg="game2",bgm="push",
	},
	{
		drop=30,lock=60,
		fall=20,
		freshLimit=15,
		task="survivor_normal",
		bg="game2",bgm="newera",
	},
	{
		drop=10,lock=60,
		fall=15,
		freshLimit=15,
		task="survivor_hard",
		bg="game2",bgm="secret8th",
	},
	{
		drop=6,lock=60,
		fall=10,
		freshLimit=15,
		task="survivor_lunatic",
		bg="game3",bgm="secret7th",
	},
	{
		drop=5,lock=60,
		fall=10,
		freshLimit=15,
		task="survivor_ultimate",
		bg="rgb",bgm="secret7th",
	},
}
defModeEnv.defender={
	{
		drop=30,lock=60,
		fall=10,
		freshLimit=15,
		task="defender_normal",
		bg="game3",bgm="way",
	},
	{
		drop=5,lock=60,
		fall=6,
		freshLimit=15,
		task="defender_lunatic",
		bg="game4",bgm="way",
	},
}
defModeEnv.attacker={
	{
		drop=30,lock=60,
		fall=12,
		freshLimit=15,
		task="attacker_hard",
		bg="game3",bgm="push",
	},
	{
		drop=5,lock=60,
		fall=8,
		freshLimit=15,
		task="attacker_ultimate",
		bg="game4",bgm="shining terminal",
	},
}
defModeEnv.tech={
	{
		oncehold=false,
		drop=1e99,lock=1e99,
		dropPiece="tech_reach_easy",
		bg="matrix",bgm="newera",
	},
	{
		oncehold=false,
		drop=1e99,lock=1e99,
		dropPiece="tech_reach_ultimate",
		bg="matrix",bgm="newera",
	},
	{
		drop=10,lock=60,
		freshLimit=15,
		dropPiece="tech_reach_easy",
		bg="matrix",bgm="secret8th",
	},
	{
		drop=30,lock=60,
		freshLimit=15,
		dropPiece="tech_reach_ultimate",
		bg="matrix",bgm="secret8th",
	},
	{
		_20G=true,lock=60,
		freshLimit=15,
		dropPiece="tech_reach_hard",
		bg="matrix",bgm="secret7th",
	},
	{
		_20G=true,lock=60,
		freshLimit=15,
		dropPiece="tech_reach_ultimate",
		bg="matrix",bgm="secret7th",
	},
	{
		drop=1e99,lock=60,
		freshLimit=15,
		fine=true,fineKill=true,
		dropPiece="tech_reach_hard",
		bg="flink",bgm="infinite",
	},
	{
		drop=1e99,lock=60,
		freshLimit=15,
		fine=true,fineKill=true,
		dropPiece="tech_reach_ultimate",
		bg="flink",bgm="infinite",
	},
}
defModeEnv.c4wtrain={
	{
		drop=30,lock=60,
		oncehold=false,
		freshLimit=15,
		dropPiece="c4w_reach",
		ospin=false,
		bg="rgb",bgm="newera",
	},
	{
		drop=5,lock=30,
		freshLimit=15,
		dropPiece="c4w_reach",
		ospin=false,
		bg="rgb",bgm="newera",
	},
}
defModeEnv.pctrain={
	{
		next=4,
		hold=false,
		drop=150,lock=150,
		fall=20,
		sequence="none",
		dropPiece="newPC",
		ospin=false,
		bg="rgb",bgm="newera",
	},
	{
		next=4,
		hold=false,
		drop=60,lock=60,
		fall=20,
		sequence="none",
		freshLimit=15,
		dropPiece="newPC",
		ospin=false,
		bg="rgb",bgm="newera",
	},
}
defModeEnv.pcchallenge={
	{
		oncehold=false,
		drop=300,lock=1e99,
		target=100,dropPiece="reach_winCheck",
		ospin=false,
		bg="rgb",bgm="newera",
	},
	{
		drop=60,lock=120,
		fall=10,
		target=100,dropPiece="reach_winCheck",
		freshLimit=15,
		ospin=false,
		bg="rgb",bgm="infinite",
	},
	{
		drop=20,lock=60,
		fall=20,
		target=100,dropPiece="reach_winCheck",
		freshLimit=15,
		ospin=false,
		bg="rgb",bgm="infinite",
	},
}
defModeEnv.techmino49={
	{
		drop=60,lock=60,
		fall=20,
		royaleMode=true,
		Fkey=Fkey_func.royale,
		royalePowerup={2,5,10,20},
		royaleRemain={30,20,15,10,5},
		pushSpeed=2,
		freshLimit=15,
		bg="game3",bgm="rockblock",
	},
}
defModeEnv.techmino99={
	{
		drop=60,lock=60,
		fall=20,
		royaleMode=true,
		Fkey=Fkey_func.royale,
		royalePowerup={2,6,14,30},
		royaleRemain={75,50,35,20,10},
		pushSpeed=2,
		freshLimit=15,
		bg="game3",bgm="rockblock",
	},
}
defModeEnv.drought={
	{
		drop=20,lock=60,
		sequence="drought1",
		target=100,dropPiece="reach_winCheck",
		ospin=false,
		freshLimit=15,
		bg="glow",bgm="reason",
	},
	{
		drop=20,lock=60,
		sequence="drought2",
		target=100,dropPiece="reach_winCheck",
		ospin=false,
		freshLimit=15,
		bg="glow",bgm="reason",
	},
}
defModeEnv.hotseat={
	{
		drop=60,lock=60,
		freshLimit=15,
		bg="none",bgm="way",
	},
}
defModeEnv.custom={
	{
		dropPiece="reach_winCheck",
	},
	{
		Fkey=Fkey_func.puzzle,puzzle=true,
		dropPiece="puzzleCheck",
	},
}