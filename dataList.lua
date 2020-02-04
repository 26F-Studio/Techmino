local gc=love.graphics
local setFont=setFont

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
		newTask(Event_task[curMode.lv==1 and"survivor_easy"or curMode.lv==2 and"survivor_normal"or curMode.lv==3 and"survivor_hard"or curMode.lv==4 and"survivor_lunatic"or curMode.lv==5 and"survivor_ultimate"],P)
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
	techmino49=function()
		createPlayer(1,340,15)
		if curMode.lv==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2,curMode.lv,35-6*curMode.lv
		for i=1,4 do for j=1,6 do
			createPlayer(n,78*i-54,115*j-98,.18,rnd(min,max))
			n=n+1
		end end
		for i=9,12 do for j=1,6 do
			createPlayer(n,78*i+267,115*j-98,.18,rnd(min,max))
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
		modeEnv.oncehold=customSel.hold==1
		createPlayer(1,340,15)
		if modeEnv.opponent==0 then
		else
			modeEnv.target=nil
			createPlayer(2,965,360,.5,modeEnv.opponent)
		end
		preField.h=20
		::R::
			for i=1,10 do
				if preField[preField.h][i]>0 then
					if curMode.lv==1 then
						goto L
					elseif curMode.lv==2 then
						return
					end
				end
			end
			preField.h=preField.h-1
		if preField.h>0 then goto R end
		::L::
		for _,P in next,players.alive do
			local t=P.showTime*3
			for y=1,preField.h do
				P.field[y]=getNewRow(0)
				P.visTime[y]=getNewRow(t)
				for x=1,10 do P.field[y][x]=preField[y][x]end
			end
		end
	end,
}
mesDisp={
	--Default:font=35,white
	sprint=function()
		setFont(70)
		local r=max(P.gameEnv.target-P.stat.row,0)
		mStr(r,-82,260)
		if r<21 and r>0 then
			gc.setLineWidth(3)
			gc.setColor(1,.5,.5)
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
		mStr(format("%.2f",2.5*P.stat.atk/P.stat.piece),-82,420)
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
		mStr(format("%.2f",2.5*P.stat.atk/P.stat.piece),-82,420)
		setFont(20)
		mStr("Attack",-82,363)
		mStr("Efficiency",-82,475)
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
		if P.gameEnv.target<1e4 then
			setFont(75)
			mStr(max(P.gameEnv.target-P.stat.row,0),-82,280)
		end
		if curMode.lv==2 and P.modeData.event==0 then
			gc.setColor(1,1,1,.6)
			gc.setLineWidth(3)
			for y=1,preField.h do for x=1,10 do
				if preField[y][x]>0 then
					gc.setColor(blockColor[preField[y][x]])
					gc.rectangle("line",30*x-25,605-30*y,20,20)
				end
			end end
		end
	end
}
Event={
	marathon_reach=function()
		local s=int(P.stat.row*.1)
		if s>=20 then
			P.stat.row=200
			Event_gameover.win()
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
		if t%100==99 and c==0 then goto L end
		t=t+(c<3 and c+1 or c==3 and 5 or 7)
		if int(t*.01)>P.modeData.event then
			P.modeData.event=P.modeData.event+1
			if P.modeData.event==5 then
				P.modeData.event=4
				P.modeData.point=500
				Event_gameover.win()
				goto L
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
		::L::
	end,
	master_reach_ultimate=function()
		local t=P.modeData.point
		local c=#P.clearing
		if t%100==99 and c==0 then goto L end
		t=t+(c<3 and c+1 or c==3 and 5 or 7)
		if int(t*.01)>P.modeData.event then
			P.modeData.event=P.modeData.event+1
			if P.modeData.event==5 then
				curBG="game5"
				P.modeData.event=4
				P.modeData.point=500
				Event_gameover.win()
				goto L
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
		::L::
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
			Event_gameover.lose()
		elseif #P.clearing>0 then
			P.modeData.event=P.modeData.event+1
		end
	end,
	tech_reach_easy=function()
		if P.b2b<40 then
			Event_gameover.lose()
		end
	end,
	tech_reach_hard=function()
		if #P.clearing>0 and P.lastClear<10 then
			Event_gameover.lose()
		end
	end,
	tech_reach_ultimate=function()
		if #P.clearing>0 and P.lastClear<10 or P.lastClear==74 then
			Event_gameover.lose()
		end
	end,
	newPC=function()
		local P=players[1]
		if P.stat.piece%4==0 then
			if #P.field==#P.clearing then
				P.counter=P.stat.piece==0 and 20 or 0
				newTask(Event_task.PC,P)
				if curMode.lv==2 then
					local s=P.stat.pc*.5
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
				Event_gameover.lose()
			end
		end
	end,
}
Event_gameover={
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
			BGM("end")
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
		if P.id==1 then
			gamefinished=true
			newTask(Event_task.finish,P)
		end
		showText(P,text.win,"beat",90,nil,.4,curMode.id~="custom")
		SFX("win")
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
			if P.lastRecv then
				local A,i=P,0
				::L::
					A,i=A.lastRecv,i+1
				if A and not A.alive and A~=P and i<3 then goto L end
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
						newTask(Event_task.throwBadge,nil,{P,max(3,P.badge)*4})
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
		if P.id==1 then
			gamefinished=true
			SFX("fail")
			if modeEnv.royaleMode then
				BGM("end")
			end
		end
		if #players.alive==1 then
			local t=P
			P=players.alive[1]
			Event_gameover.win()
			P=t
		end
		if #players>1 then
			newTask(Event_task.lose,P)
		else
			newTask(Event_task.finish,P)
		end
	end,
}
Event_task={
	finish=function(P)
		P.endCounter=P.endCounter+1
		if P.endCounter>120 then
			pauseGame()
			return true
		end
	end,
	lose=function(P)
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
				if P.id==1 then
					pauseGame()
				end
				return true
			end
		end
	end,
	throwBadge=function(P,data)
		data[2]=data[2]-1
		if data[2]%4==0 then
			throwBadge(data[1],data[1].lastRecv)
			if data[2]%8==0 then
				sysSFX("collect")
			end
		end
		if data[2]<=0 then return true end
	end,
	dig_normal=function(P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(90,180-P.modeData.event)then
			garbageRise(10,1,rnd(10))
			P.counter=0
			P.modeData.event=P.modeData.event+1
		end
	end,
	dig_lunatic=function(P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(45,80-.3*P.modeData.event)then
			garbageRise(11+P.modeData.event%3,1,rnd(10))
			P.counter=0
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_easy=function(P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(60,150-2*P.modeData.event)then
			ins(P.atkBuffer,{pos=rnd(10),amount=1,countdown=30,cd0=30,time=0,sent=false,lv=1})
			P.counter=0
			if P.modeData.event==45 then showText(P,text.maxspeed,"appear",80,-140)end
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_normal=function(P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(90,180-2*P.modeData.event)then
			local d=P.modeData.event+1
			if d%4==0 then		ins(P.atkBuffer,{pos=rnd(10),amount=1,countdown=60,cd0=60,time=0,sent=false,lv=1})
			elseif d%4==1 then	ins(P.atkBuffer,{pos=rnd(10),amount=2,countdown=70,cd0=70,time=0,sent=false,lv=1})
			elseif d%4==2 then	ins(P.atkBuffer,{pos=rnd(10),amount=3,countdown=80,cd0=80,time=0,sent=false,lv=2})
			elseif d%4==3 then	ins(P.atkBuffer,{pos=rnd(10),amount=4,countdown=90,cd0=90,time=0,sent=false,lv=3})
			end
			P.atkBuffer.sum=P.atkBuffer.sum+d%4+1
			P.stat.recv=P.stat.recv+d%4+1
			if P.atkBuffer.sum>20 then garbageRelease()end
			P.counter=0
			if P.modeData.event==45 then showText(P,text.maxspeed,"appear",80,-140)end
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_hard=function(P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(60,180-2*P.modeData.event)then
			if P.modeData.event%3<2 then
				ins(P.atkBuffer,{pos=rnd(10),amount=1,countdown=0,cd0=0,time=0,sent=false,lv=1})
			else
				ins(P.atkBuffer,{pos=rnd(10),amount=3,countdown=60,cd0=60,time=0,sent=false,lv=2})
			end
			P.atkBuffer.sum=P.atkBuffer.sum+(P.modeData.event%3<2 and 1 or 3)
			if P.atkBuffer.sum>20 then garbageRelease()end
			P.counter=0
			if P.modeData.event==45 then showText(P,text.maxspeed,"appear",80,-140)end
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_lunatic=function(P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(60,150-P.modeData.event)then
			local t=max(60,90-P.modeData.event)
			ins(P.atkBuffer,{pos=rnd(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3})
			P.atkBuffer.sum=P.atkBuffer.sum+4
			if P.atkBuffer.sum>15 then garbageRelease()end
			P.counter=0
			if P.modeData.event==60 then showText(P,text.maxspeed,"appear",80,-140)end
			P.modeData.event=P.modeData.event+1
		end
	end,
	survivor_ultimate=function(P)
		if not P.control then return end
		P.counter=P.counter+1
		if P.counter>=max(300,600-10*P.modeData.event)then
			local t=max(300,480-12*P.modeData.event)
			ins(P.atkBuffer,{pos=rnd(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=2})
			ins(P.atkBuffer,{pos=rnd(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3})
			ins(P.atkBuffer,{pos=rnd(10),amount=6,countdown=1.2*t,cd0=1.2*t,time=0,sent=false,lv=4})
			ins(P.atkBuffer,{pos=rnd(10),amount=6,countdown=1.5*t,cd0=1.5*t,time=0,sent=false,lv=5})
			P.atkBuffer.sum=P.atkBuffer.sum+20
			if P.atkBuffer.sum>32 then garbageRelease()end
			P.counter=0
			if P.modeData.event==31 then showText(P,text.maxspeed,"appear",80,-140)end
			P.modeData.event=P.modeData.event+1
		end
	end,
	PC=function(P)
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

	bgmFadeOut=function(_,id)
		bgm[id]:setVolume(max(bgm[id]:getVolume()-.03,0))
		if bgm[id]:getVolume()==0 then
			bgm[id]:stop()
			return true
		end
	end,
	bgmFadeIn=function(_,id)
		bgm[id]:setVolume(min(bgm[id]:getVolume()+.03,1))
		if bgm[id]:getVolume()==1 then return true end
	end,
}
defaultModeEnv={
	sprint={
		{
			drop=60,target=10,
			reach=Event_gameover.win,
			bg="strap",bgm="race",
		},
		{
			drop=60,target=20,
			reach=Event_gameover.win,
			bg="strap",bgm="race",
		},
		{
			drop=60,target=40,
			reach=Event_gameover.win,
			bg="strap",bgm="race",
		},
		{
			drop=60,target=100,
			reach=Event_gameover.win,
			bg="strap",bgm="race",
		},
		{
			drop=60,target=400,
			reach=Event_gameover.win,
			bg="strap",bgm="push",
		},
		{
			drop=60,target=1000,
			reach=Event_gameover.win,
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
			target=200,reach=Event_gameover.win,
			bg="strap",bgm="infinite",
		},
	},
	infinite={
		{
			drop=1e99,lock=1e99,
			oncehold=false,
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
			ghost=false,
			visible="none",
			freshLimit=15,
			bg="rgb",bgm="secret7th",
		},
		{
			fall=5,lock=60,
			center=false,
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
			wait=10,
			fall=15,
			visible="fast",
			freshLimit=15,
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
			drop=5,lock=60,
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
	},
	tech={
		{
			oncehold=false,
			drop=1e99,lock=1e99,
			target=1,reach=Event.tech_reach_easy,
			bg="matrix",bgm="way",
		},
		{
			oncehold=false,
			drop=30,lock=60,
			target=1,reach=Event.tech_reach_easy,
			bg="matrix",bgm="way",
		},
		{
			drop=8,lock=60,
			freshLimit=15,
			target=1,reach=Event.tech_reach_hard,
			bg="matrix",bgm="secret8th",
		},
		{
			drop=4,lock=40,
			target=1,
			freshLimit=15,
			reach=Event.tech_reach_hard,
			bg="matrix",bgm="secret8th",
		},
		{
			drop=1,lock=40,
			freshLimit=15,
			target=1,reach=Event.tech_reach_ultimate,
			bg="matrix",bgm="secret7th",
		},
	},
	pctrain={
		{
			next=4,
			hold=false,
			drop=150,lock=150,
			fall=20,
			sequence="pc",
			target=0,reach=Event.newPC,
			ospin=false,
			bg="rgb",bgm="newera",
		},
		{
			next=4,
			hold=false,
			drop=60,lock=60,
			fall=20,
			sequence="pc",
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
			target=100,reach=Event_gameover.win,
			ospin=false,
			bg="rgb",bgm="newera",
		},
		{
			drop=60,lock=120,fall=10,
			target=100,reach=Event_gameover.win,
			freshLimit=15,
			ospin=false,
			bg="rgb",bgm="infinite",
		},
		{
			drop=20,lock=60,fall=20,
			target=100,reach=Event_gameover.win,
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
			reach=Event_gameover.win,
			ospin=false,
			freshLimit=15,
			bg="glow",bgm="reason",
		},
		{
			drop=20,lock=60,
			sequence="drought2",
			target=100,
			reach=Event_gameover.win,
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
			reach=Event_gameover.win,
			bg="none",bgm="reason",
		},
		{
			Fkey=true,
			reach=Event_gameover.win,
			bg="none",bgm="reason",
		},
	},
}