local gc=love.graphics
local setFont=setFont
local int,rnd,max,min=math.floor,math.random,math.max,math.min
local format=string.format
local ins,rem=table.insert,table.remove
local function newNext(n)
	P.next[#P.next+1]={bk=blocks[n][0],id=n,color=P.gameEnv.bone and 8 or n,name=n}
end
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
PClist={
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
local blockColor=blockColor
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
	FX.badge[#FX.badge+1]={x1,y1,x2,y2,t=0}
end
loadmode={
	sprint=function()
		createPlayer(1,340,15)
	end,
	marathon=function()
		createPlayer(1,340,15)
	end,
	master=function()
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
		if curMode.lv==2 then
			pushSpeed=1
			for i=1,5 do
				garbageRise(10,1,rnd(10))
			end
		end
	end,
	solo=function()
		createPlayer(1,340,15)
		createPlayer(2,965,360,.5,customRange.opponent[3*curMode.lv])
	end,
	tsd=function()
		createPlayer(1,340,15)
	end,
	blind=function()
		createPlayer(1,340,15)
	end,
	dig=function()
		createPlayer(1,340,15)
		newTask(Event_task[curMode.lv==1 and"dig_normal"or curMode.lv==2 and"dig_lunatic"],P)
		pushSpeed=1
	end,
	survivor=function()
		createPlayer(1,340,15)
		newTask(Event_task[curMode.lv==1 and"survivor_easy"or curMode.lv==2 and"survivor_normal"or curMode.lv==3 and"survivor_hard"or curMode.lv==4 and"survivor_lunatic"or curMode.lv==5 and"survivor_ultimate"or curMode.lv==6 and"survivor_extra"],P)
		pushSpeed=curMode.lv>2 and 2 or 1
	end,
	tech=function()
		createPlayer(1,340,15)
	end,
	c4wtrain=function()
		createPlayer(1,340,15)
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
	end,
	pctrain=function()
		createPlayer(1,340,15)
		P=players[1]
		Event.newPC()
	end,
	pcchallenge=function()
		createPlayer(1,340,15)
	end,
	techmino49=function()
		createPlayer(1,340,15)
		if curMode.lv==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2,curMode.lv,35-6*curMode.lv
		for i=1,4 do for j=1,6 do
			createPlayer(n,78*i-54,115*j-98,.09,rnd(min,max))
			n=n+1
		end end
		for i=9,12 do for j=1,6 do
			createPlayer(n,78*i+267,115*j-98,.09,rnd(min,max))
			n=n+1
		end end
	end,
	techmino99=function()
		createPlayer(1,340,15)
		if curMode.lv==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2
		if curMode.lv==1 then min,max=5,32
		elseif curMode.lv==2 then min,max=3,25
		elseif curMode.lv==3 then min,max=2,18
		elseif curMode.lv==4 then min,max=2,12
		elseif curMode.lv==5 then min,max=1,12
		end
		for i=1,7 do for j=1,7 do
			createPlayer(n,46*i-36,97*j-72,.068,rnd(min,max))
			n=n+1
		end end
		for i=15,21 do for j=1,7 do
			createPlayer(n,46*i+264,97*j-72,.068,rnd(min,max))
			n=n+1
		end end
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
			modeEnv[k]=customRange[k][customSel[i]]
		end
		modeEnv._20G=modeEnv.drop==-1
		modeEnv.oncehold=customSel[6]==1
		createPlayer(1,340,15)
		if modeEnv.opponent==0 then
		else
			modeEnv.target=nil
			createPlayer(2,965,360,.5,modeEnv.opponent)
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
	end,
}
mesDisp={
	--Default:font=35,white
	sprint=function()
		setFont(65)
		local r=max(P.gameEnv.target-P.stat.row,0)
		mStr(r,-82,265)
		if r<21 and r>0 then
			gc.setLineWidth(4)
			gc.setColor(1,r>10 and 0 or rnd(),.5)
			gc.line(0,600-30*r,300,600-30*r)
		end
	end,
	marathon=function()
		setFont(50)
		mStr(P.stat.row,-82,320)
		mStr(P.gameEnv.target,-82,370)
		gc.rectangle("fill",-128,376,90,4)
	end,
	master=function()
		setFont(50)
		mStr(P.modeData.point,-82,320)
		mStr((P.modeData.event+1)*100,-82,370)
		gc.rectangle("fill",-128,376,90,4)
	end,
	classic=function()
		setFont(80)
		local r=P.gameEnv.target*.1
		mStr(r<11 and 19+r or r==11 and"00"or r==12 and"0a"or format("%x",r*10-110),-82,210)
		setFont(20)
		mStr("speed level",-82,290)
		setFont(50)
		mStr(P.stat.row,-82,320)
		mStr(P.gameEnv.target,-82,370)
		gc.rectangle("fill",-128,376,90,4)
	end,
	zen=function()
		setFont(75)
		mStr(max(200-P.stat.row,0),-82,280)
	end,
	infinite=function()
		setFont(50)
		mStr(P.stat.atk,-82,310)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-82,420)
		setFont(20)
		mStr("Attack",-82,363)
		mStr("Efficiency",-82,475)
	end,
	tsd=function()
		setFont(35)
		mStr("TSD",-82,407)
		setFont(80)
		mStr(P.modeData.event,-82,330)
	end,
	blind=function()
		setFont(25)
		mStr("Rows",-82,300)
		mStr("Techrash",-82,420)
		if curMode.lv==6 then
			mStr("Point",-82,180)
			setFont(60)
			mStr(P.modeData.point*.1,-82,110)
		end
		setFont(80)
		mStr(P.stat.row,-82,220)
		mStr(P.stat.clear_4,-82,340)
	end,
	dig=function()
		setFont(70)
		mStr(P.modeData.event-20,-82,310)
		setFont(30)
		mStr("Wave",-82,375)
	end,
	survivor=function()
		setFont(70)
		mStr(P.modeData.event,-82,310)
		setFont(30)
		mStr("Wave",-82,375)
	end,
	tech=function()
		setFont(50)
		mStr(P.stat.atk,-82,310)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-82,420)
		setFont(20)
		mStr("Attack",-82,363)
		mStr("Efficiency",-82,475)
	end,
	c4wtrain=function()
		setFont(50)
		mStr(max(200-P.stat.row,0),-82,220)
		mStr(P.combo,-82,310)
		mStr(P.modeData.point,-82,400)
		setFont(20)
		mStr("combo",-82,358)
		mStr("max combo",-82,450)
	end,
	pctrain=function()
		setFont(22)
		mStr("Perfect Clear",-82,412)
		setFont(80)
		mStr(P.stat.pc,-82,330)
	end,
	pcchallenge=function()
		setFont(22)
		mStr("Perfect Clear",-82,432)
		setFont(80)
		mStr(P.stat.pc,-82,350)
		setFont(50)
		mStr(max(100-P.stat.row,0),-82,250)
		gc.setColor(.5,.5,.5)
		local y=72*(7-(P.stat.piece+1)%7)-36
		gc.line(320,y,442,y)
	end,
	techmino49=function()
		setFont(40)
		mStr(#players.alive.."/49",-82,175)
		mStr(P.ko,-70,215)
		setFont(25)
		gc.print("KO",-127,225)
		gc.setColor(1,.5,0,.6)
		gc.print(P.badge,-47,227)
		gc.setColor(1,1,1)
		setFont(30)
		gc.print(up0to4[P.strength],-132,290)
		for i=1,P.strength do
			gc.draw(badgeIcon,16*i-138,260)
		end
	end,
	techmino99=function()
		setFont(40)
		mStr(#players.alive.."/99",-82,175)
		mStr(P.ko,-70,215)
		setFont(25)
		gc.print("KO",-127,225)
		gc.setColor(1,.5,0,.6)
		gc.print(P.badge,-47,227)
		gc.setColor(1,1,1)
		setFont(30)
		gc.print(up0to4[P.strength],-132,290)
		for i=1,P.strength do
			gc.draw(badgeIcon,16*i-138,260)
		end
	end,
	drought=function()
		setFont(75)
		mStr(max(100-P.stat.row,0),-82,280)
	end,
	custom=function()
		setFont(25)
		mStr("Rows",-82,300)
		setFont(65)
		mStr(P.stat.row,-82,225)
		if P.gameEnv.target<1e4 then
			setFont(75)
			mStr(max(P.gameEnv.target-P.stat.row,0),-82,280)
		end
		if P.gameEnv.puzzle and P.modeData.event==0 then
			gc.setLineWidth(3)
			for y=1,preField.h do for x=1,10 do
				local B=preField[y][x]
				if B>7 then
					gc.setColor(blockColor[B])
					gc.rectangle("line",30*x-23,607-30*y,16,16)
				elseif B>0 then
					local c=blockColor[B]
					gc.setColor(c[1],c[2],c[3],.6)
					gc.rectangle("line",30*x-25,605-30*y,20,20)
					gc.rectangle("line",30*x-20,610-30*y,10,10)
				elseif B==0 then
					gc.setColor(1,1,1,.4)
					gc.line(30*x-25,605-30*y,30*x-5,625-30*y)
					gc.line(30*x-25,625-30*y,30*x-5,605-30*y)
				end
			end end
		end
	end
}
Event={
	win=function()
		P.alive=false
		P.control=false
		P.timing=false
		P.waiting=1e99
		P.b2b=0
		clearTask(P)
		if modeEnv.royaleMode then
			P.rank=1
			P.result="WIN"
			changeAtk(P)
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
		showText(P,text.win,"beat",90,nil,.4,curMode.id~="custom")
	end,
	lose=function()
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
			changeAtk(P)
			P.result="K.O."
			P.rank=#players.alive+1
			showText(P,P.rank,"appear",60,120,nil,true)
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
		P.gameEnv.keepVisible=P.gameEnv.visible~="show"
		showText(P,text.lose,"appear",90,nil,nil,true)
		if P.human then
			gamefinished=true
			SFX("fail")
			VOICE("lose")
			if modeEnv.royaleMode then BGM("end")end
		end
		if #players.alive==1 then
			local t=P
			P=players.alive[1]
			Event.win()
			P=t
		end
		if #players>1 then
			newTask(Event_task.lose,P)
		else
			newTask(Event_task.finish,P)
		end
	end,
	marathon_reach=function()
		local s=int(P.stat.row*.1)
		if s>=20 then
			P.stat.row=200
			Event.win()
		else
			P.gameEnv.drop=marathon_drop[s]
			if s==18 then P.gameEnv._20G=true end
			P.gameEnv.target=s*10+10
			SFX("reach")
		end
	end,
	master_reach_lunatic=function()
		local t=P.modeData.point
		local c=#P.clearing
		if t%100==99 and c==0 then return end
		t=t+(c<3 and c+1 or c==3 and 5 or 7)
		if int(t*.01)>P.modeData.event then
			P.modeData.event=P.modeData.event+1
			if P.modeData.event==5 then
				P.modeData.event=4
				P.modeData.point=500
				Event.win()
				return
			else
				local s=P.modeData.event+1
				curBG=s==2 and"game1"or s==3 and"game2"or s==4 and"game3"or s==5 and"game4"
				P.gameEnv.lock=rush_lock[s]
				P.gameEnv.wait=rush_wait[s]
				P.gameEnv.fall=rush_fall[s]
				P.gameEnv.das=10-s
				if s==3 then P.gameEnv.arr=2 end
				if s==5 then P.gameEnv.bone=true end
				showText(P,text.stage[s],"fly",80,-120)
				SFX("reach")
			end
		end
		P.modeData.point=t
		if t%100==99 then SFX("blip_1")end
	end,
	master_reach_ultimate=function()
		local t=P.modeData.point
		local c=#P.clearing
		if t%100==99 and c==0 then return end
		t=t+(c<3 and c+1 or c==3 and 5 or 7)
		if int(t*.01)>P.modeData.event then
			P.modeData.event=P.modeData.event+1
			if P.modeData.event==5 then
				curBG="game5"
				P.modeData.event=4
				P.modeData.point=500
				Event.win()
				return
			else
				local s=P.modeData.event+1
				curBG=s==2 and"game3"or s==3 and"game4"or s==4 and"game5"or s==5 and"game6"
				P.gameEnv.lock=death_lock[s]
				P.gameEnv.wait=death_wait[s]
				P.gameEnv.fall=death_fall[s]
				P.gameEnv.das=int(7.3-s*.4)
				if s==4 then P.gameEnv.bone=true end
				showText(P,text.stage[s],"fly",80,-120)
				SFX("reach")
			end
		end
		P.modeData.point=t
		if t%100==99 then SFX("blip_1")end
	end,
	classic_reach=function()
		P.gameEnv.target=P.gameEnv.target+10
		if P.gameEnv.target==100 then
			P.gameEnv.drop,P.gameEnv.lock=0,0
		end
		SFX("reach")
	end,
	infinite_check=function()
		for i=1,#P.clearing do
			if P.clearing[i]<6 then
				garbageRise(10,1,rnd(10))
			end
		end
	end,
	GM_reach=function()
		local R=#P.clearing
		if R==4 then R=10 end
		P.modeData.point=P.modeData.point+R
		if P.stat.time>=53.5 then
			Event.win()
		end
	end,
	tsd_reach=function()
		if P.lastClear~=52 then
			Event.lose()
		elseif #P.clearing>0 then
			P.modeData.event=P.modeData.event+1
		end
	end,
	tech_reach_easy=function()
		if P.b2b<40 then
			Event.lose()
		elseif P.stat.row==3 then
			Event.win()
		end
	end,
	tech_reach_hard=function()
		if #P.clearing>0 and P.lastClear<10 then
			Event.lose()
		end
	end,
	tech_reach_ultimate=function()
		if #P.clearing>0 and P.lastClear<10 or P.lastClear==74 then
			Event.lose()
		end
	end,
	c4w_reach=function()
		for i=1,#P.clearing do
			P.field[#P.field+1]=getNewRow(10)
			P.visTime[#P.visTime+1]=getNewRow(20)
			for i=4,7 do P.field[#P.field][i]=0 end
		end
		if #P.clearing==0 then
			if curMode.lv==2 then
				Event.lose()
			end
		else
			if P.combo>P.modeData.point then
				P.modeData.point=P.combo
			end
			if P.stat.row>=200 then
				Event.win()
			end
		end
	end,
	newPC=function()
		if P.stat.piece%4==0 then
			if #P.field==#P.clearing then
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
					newNext(b)
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
							showText(P,text.maxspeed,"appear",100,-140,.6)
						else
							showText(P,text.speedup,"appear",40,-140)
						end
					end
				end
			else
				Event.lose()
			end
		elseif P.curY+P.r>5-P.stat.row%4+#P.clearing then
			Event.lose()
		end
	end,
	puzzleCheck=function()
		for y=1,20 do
			local L=P.field[y]
			for x=1,10 do
				local a,b=preField[y][x],L and L[x]or 0
				if a~=-1 and(a==0 and b>0 or a<8 and a~=b or a>7 and b==0)then return end
			end
		end
		P.modeData.event=1
		Event.win()
	end
}
Event_task={
	finish=function(self,P)
		P.endCounter=P.endCounter+1
		if P.endCounter>120 then
			pauseGame()
			return true
		end
	end,
	lose=function(self,P)
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
	end,
	throwBadge=function(self,A,data)
		data[2]=data[2]-1
		if data[2]%4==0 then
			throwBadge(data[1],data[1].lastRecv)
			if not A.ai and data[2]%8==0 then
				SFX("collect")
			end
		end
		if data[2]<=0 then return true end
	end,
	dig_normal=function(self,P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(90,180-P.modeData.event)then
			P.counter=0
			garbageRise(10,1,rnd(10))
			P.modeData.event=P.modeData.event+1
		end
	end,
	dig_lunatic=function(self,P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(45,80-.3*P.modeData.event)then
			P.counter=0
			garbageRise(11+P.modeData.event%3,1,rnd(10))
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_easy=function(self,P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(60,150-2*P.modeData.event)and P.atkBuffer.sum<4 then
			P.atkBuffer[#P.atkBuffer+1]={pos=rnd(10),amount=1,countdown=30,cd0=30,time=0,sent=false,lv=1}
			P.atkBuffer.sum=P.atkBuffer.sum+1
			P.stat.recv=P.stat.recv+1
			if P.modeData.event==45 then showText(P,text.maxspeed,"appear",100,-140,.6)end
			P.counter=0
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_normal=function(self,P)
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
			if P.modeData.event==45 then showText(P,text.maxspeed,"appear",100,-140,.6)end
			P.counter=0
			P.modeData.event=d
		end
	end,
	survivor_hard=function(self,P)
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
			if P.modeData.event==45 then showText(P,text.maxspeed,"appear",100,-140,.6)end
			P.counter=0
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_lunatic=function(self,P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(60,150-P.modeData.event)and P.atkBuffer.sum<20 then
			local t=max(60,90-P.modeData.event)
			P.atkBuffer[#P.atkBuffer+1]={pos=rnd(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3}
			P.atkBuffer.sum=P.atkBuffer.sum+4
			P.stat.recv=P.stat.recv+4
			if P.modeData.event==60 then showText(P,text.maxspeed,"appear",100,-140,.6)end
			P.counter=0
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_ultimate=function(self,P)
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
			if P.modeData.event==31 then showText(P,text.maxspeed,"appear",100,-140,.6)end
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_extra=function(self,P)
		if not P.control then return end
		if P.atkBuffer.sum<3 then
			local p=#P.atkBuffer+1
			local T=P.modeData.event
			if T<15 then
				local t=1200-20*T--1200~900
				P.atkBuffer[p]	={pos=rnd(5,6),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=3}
				P.atkBuffer[p+1]={pos=rnd(4,7),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=4}
			elseif T<30 then
				local t=900-20*(T-15)--900~600
				P.atkBuffer[p]	={pos=rnd(3,8),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=4}
				P.atkBuffer[p+1]={pos=rnd(4,7),amount=12,countdown=t,cd0=t,time=0,sent=false,lv=5}
			else
				local t=max(480,720-16*(T-30))--720~480
				P.atkBuffer[p]	={pos=rnd(2)*9-8,amount=12,countdown=t,cd0=t,time=0,sent=false,lv=5}
				P.atkBuffer[p+1]={pos=rnd(3,8),amount=12,countdown=t,cd0=t,time=0,sent=false,lv=5}
			end
			P.atkBuffer.sum=P.atkBuffer.sum+20
			P.stat.recv=P.stat.recv+20
			P.modeData.event=P.modeData.event+1
			if P.modeData.event==15 then
				showText(P,text.awesome,"appear",100,-140,.6)
			elseif P.modeData.event==16 then
				pushSpeed=4
			elseif P.modeData.event==30 then
				showText(P,text.continue,"appear",100,-140,.6)
			elseif P.modeData.event==31 then
				pushSpeed=6
			elseif P.modeData.event==45 then
				showText(P,text.maxspeed,"appear",100,-140,.6)
			end
		end
	end,
	PC=function(self,P)
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
			for i=1,#P.clearing do
				P.clearing[i]=P.clearing[i]+4
			end
			freshgho()
			return true
		end
	end,

	bgmFadeOut=function(self,_,id)
		bgm[id]:setVolume(max(bgm[id]:getVolume()-.03,0))
		if bgm[id]:getVolume()==0 then
			bgm[id]:stop()
			return true
		end
	end,
	bgmFadeIn=function(self,_,id)
		bgm[id]:setVolume(min(bgm[id]:getVolume()+.03,1))
		if bgm[id]:getVolume()==1 then return true end
	end,
	bgmWarp=function(self)
		if bgmPlaying then
			self.data=self.data-1
			if self.data==0 then
				self.data=rnd(120,180)
				bgm[bgmPlaying]:seek(max(bgm[bgmPlaying]:tell()-1,0))
			end
		else
			return true
		end
	end
}
defaultModeEnv={
	sprint={
		{
			drop=60,lock=60,
			target=10,reach=Event.win,
			bg="strap",bgm="race",
		},
		{
			drop=60,lock=60,
			target=20,reach=Event.win,
			bg="strap",bgm="race",
		},
		{
			drop=60,lock=60,
			target=40,reach=Event.win,
			bg="strap",bgm="race",
		},
		{
			drop=60,lock=60,
			target=100,reach=Event.win,
			bg="strap",bgm="race",
		},
		{
			drop=60,lock=60,
			target=400,reach=Event.win,
			bg="strap",bgm="push",
		},
		{
			drop=60,lock=60,
			target=1000,reach=Event.win,
			bg="strap",bgm="push",
		},
	},
	marathon={
		{
			drop=60,lock=60,fall=30,
			target=200,reach=Event.marathon_reach,
			bg="strap",bgm="way",
		},
		{
			drop=60,fall=20,
			target=10,reach=Event.marathon_reach,
			bg="strap",bgm="way",
		},
		{
			_20G=true,fall=15,
			target=200,reach=Event.marathon_reach,
			bg="strap",bgm="race",
		},
	},
	master={
		{
			_20G=true,drop=0,lock=rush_lock[1],
			wait=rush_wait[1],
			fall=rush_fall[1],
			target=0,reach=Event.master_reach_lunatic,
			das=9,arr=3,
			freshLimit=15,
			bg="strap",bgm="secret8th",
		},
		{
			_20G=true,drop=0,lock=death_lock[1],
			wait=death_wait[1],
			fall=death_fall[1],
			target=0,reach=Event.master_reach_ultimate,
			das=6,arr=1,
			freshLimit=15,
			bg="game2",bgm="secret7th",
		},
	},
	classic={
		{
			das=15,arr=3,sddas=2,sdarr=2,
			ghost=false,center=false,
			drop=1,lock=1,wait=10,fall=25,
			next=1,hold=false,
			sequence="rnd",
			freshLimit=0,
			target=10,reach=Event.classic_reach,
			bg="rgb",bgm="rockblock",
		},
	},
	zen={
		{
			drop=1e99,lock=1e99,
			oncehold=false,
			target=200,reach=Event.win,
			bg="strap",bgm="infinite",
		},
	},
	infinite={
		{
			drop=1e99,lock=1e99,
			oncehold=false,
			bg="glow",bgm="infinite",
		},
		{
			drop=1e99,lock=1e99,
			oncehold=false,
			target=1,reach=Event.infinite_check,
			bg="glow",bgm="infinite",
		},
	},
	solo={
		{
			freshLimit=15,
			bg="game2",bgm="race",
		},
	},
	tsd={
		{
			oncehold=false,
			drop=1e99,lock=1e99,
			freshLimit=15,
			target=1,reach=Event.tsd_reach,
			ospin=false,
			bg="matrix",bgm="reason",
		},
		{
			drop=60,lock=60,
			freshLimit=15,
			target=1,reach=Event.tsd_reach,
			ospin=false,
			bg="matrix",bgm="reason",
		},
	},
	blind={
		{
			drop=30,lock=60,
			freshLimit=15,
			visible="time",
			bg="glow",bgm="newera",
		},
		{
			drop=15,lock=60,
			freshLimit=15,
			visible="fast",
			freshLimit=10,
			bg="glow",bgm="reason",
		},
		{
			fall=10,lock=60,
			center=false,
			visible="none",
			freshLimit=15,
			bg="rgb",bgm="secret7th",
		},
		{
			fall=5,lock=60,
			center=false,
			ghost=false,
			visible="none",
			freshLimit=15,
			bg="rgb",bgm="secret8th",
		},
		{
			fall=5,lock=60,
			block=false,
			center=false,
			ghost=false,
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
			target=1,reach=Event.GM_reach,
			arr=1,
			bg="game3",bgm="secret8th",
		},
	},
	dig={
		{
			drop=60,lock=120,
			fall=20,
			freshLimit=15,
			bg="game2",bgm="push",
		},
		{
			drop=10,lock=30,
			freshLimit=15,
			bg="game2",bgm="secret7th",
		},
	},
	survivor={
		{
			drop=60,lock=120,
			fall=30,
			freshLimit=15,
			bg="game2",bgm="push",
		},
		{
			drop=30,lock=60,
			fall=20,
			freshLimit=15,
			bg="game2",bgm="newera",
		},
		{
			drop=10,lock=60,
			fall=15,
			freshLimit=15,
			bg="game2",bgm="secret8th",
		},
		{
			drop=6,lock=60,
			fall=10,
			freshLimit=15,
			bg="game3",bgm="secret7th",
		},
		{
			drop=5,lock=60,
			fall=10,
			freshLimit=15,
			bg="rgb",bgm="secret7th",
		},
		{
			drop=3,lock=60,
			fall=8,
			freshLimit=15,
			bg="game4",bgm="push",
		},
	},
	tech={
		{
			oncehold=false,
			drop=1e99,lock=1e99,
			target=1,reach=Event.tech_reach_easy,
			bg="matrix",bgm="newera",
		},
		{
			oncehold=false,
			drop=1e99,lock=1e99,
			target=1,reach=Event.tech_reach_ultimate,
			bg="matrix",bgm="newera",
		},
		{
			drop=10,lock=60,
			freshLimit=15,
			target=1,reach=Event.tech_reach_easy,
			bg="matrix",bgm="secret8th",
		},
		{
			drop=30,lock=60,
			freshLimit=15,
			target=1,reach=Event.tech_reach_ultimate,
			bg="matrix",bgm="secret8th",
		},
		{
			_20G=true,lock=60,
			freshLimit=15,
			target=1,reach=Event.tech_reach_hard,
			bg="matrix",bgm="secret7th",
		},
		{
			_20G=true,lock=60,
			freshLimit=15,
			target=1,reach=Event.tech_reach_ultimate,
			bg="matrix",bgm="secret7th",
		},
	},
	c4wtrain={
		{
			freshLimit=15,
			target=0,reach=Event.c4w_reach,
			bg="rgb",bgm="newera",
		},
		{
			drop=5,lock=30,
			freshLimit=15,
			target=0,reach=Event.c4w_reach,
			bg="rgb",bgm="newera",
		},
	},
	pctrain={
		{
			next=4,
			hold=false,
			drop=150,lock=150,
			fall=20,
			sequence="none",
			target=0,reach=Event.newPC,
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
			target=0,reach=Event.newPC,
			ospin=false,
			bg="rgb",bgm="newera",
		},
	},
	pcchallenge={
		{
			oncehold=false,
			drop=300,lock=1e99,
			target=100,reach=Event.win,
			ospin=false,
			bg="rgb",bgm="newera",
		},
		{
			drop=60,lock=120,fall=10,
			target=100,reach=Event.win,
			freshLimit=15,
			ospin=false,
			bg="rgb",bgm="infinite",
		},
		{
			drop=20,lock=60,fall=20,
			target=100,reach=Event.win,
			freshLimit=15,
			ospin=false,
			bg="rgb",bgm="infinite",
		},
	},
	techmino49={
		{
			fall=20,
			royaleMode=true,
			Fkey=true,
			royalePowerup={2,5,10,20},
			royaleRemain={30,20,15,10,5},
			pushSpeed=2,
			freshLimit=15,
			bg="game3",bgm="rockblock",
		},
	},
	techmino99={
		{
			fall=20,
			royaleMode=true,
			Fkey=true,
			royalePowerup={2,6,14,30},
			royaleRemain={75,50,35,20,10},
			pushSpeed=2,
			freshLimit=15,
			bg="game3",bgm="rockblock",
		},
	},
	drought={
		{
			drop=20,lock=60,
			sequence="drought1",
			target=100,
			reach=Event.win,
			ospin=false,
			freshLimit=15,
			bg="glow",bgm="reason",
		},
		{
			drop=20,lock=60,
			sequence="drought2",
			target=100,
			reach=Event.win,
			ospin=false,
			freshLimit=15,
			bg="glow",bgm="reason",
		},
	},
	hotseat={
		{
			freshLimit=15,
			bg="none",bgm="way",
		},
	},
	custom={
		{
			reach=Event.win,
		},
		{
			Fkey=true,puzzle=true,
			target=0,reach=Event.puzzleCheck,
		},
	},
}