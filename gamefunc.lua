function resetGameData()
	players={alive={}}
	royaleMode=false
	loadmode[gamemode]()

	frame=0
	count=179
	FX.beam={}
	for i=1,#PTC.dust do PTC.dust[i]:release()end
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
function createPlayer(id,x,y,size,AIspeed,data)
	players[id]={id=id}
	ins(players.alive,id)
	local P=players[id]
	P.index={__index=P}
	P.x,P.y,P.size=x,y,size or 1
	P.small=P.size<.3

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
	P.cstat={key=0,piece=0,row=0,atk=0,techrash=0}--Current gamestat
	P.keyTime={}for i=1,10 do P.keyTime[i]=-1e5 end P.keySpeed=0
	P.dropTime={}for i=1,10 do P.dropTime[i]=-1e5 end P.dropSpeed=0

	P.field,P.visTime,P.atkBuffer={},{},{}
	P.badge,P.strength,P.lastRecv=0,0,nil
	
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

	P.freshNext=randomMethod[P.gameEnv.sequence]
	if P.gameEnv.sequence==1 then P.bag={}--Bag7
	elseif P.gameEnv.sequence==2 then P.his={}for i=1,4 do P.his[i]=P.nxt[i+3]end--History4
	elseif P.gameEnv.sequence==3 then--Pure random
	end

	P.showTime=P.gameEnv.visible==1 and 1e99 or P.gameEnv.visible==2 and 300 or 20
	P.cb,P.sc,P.bn,P.r,P.c,P.cx,P.cy,P.dir,P.y_img={{}},{0,0},1,0,0,0,0,0,0
	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.moving,P.downing=0,0
	P.waiting,P.falling=0,0
	P.clearing={}
	P.fieldBeneath=0

	P.combo=0
	P.b2b=0
	P.b2b1=0

	P.counter=0
	P.result=nil--string,"win"/"lose"
	P.task={}
	P.bonus={}
end
function showText(text,type,font,dy,inf)
	if not P.small then
		ins(P.bonus,{t=0,text=text,draw=FX[type],font=font,dy=dy or 0,inf=inf,solid=inf})
	end
end
function createBeam(s,r,lv)--Player id
	S,R=players[s],players[r]
	local x1,y1,x2,y2
	if S.small then
		x1,y1=S.x+(30*(cx+sc[2]-1)+15)*S.size,S.y+(600-30*(cy+sc[1]-1)+15)*S.size
	else
		x1,y1=S.x+(30*(cx+sc[2]-1)-30+15+150)*S.size,S.y+(600-30*(cy+sc[1]-1)+15+70)*S.size
	end
	if R.small then
		x2,y2=R.x+150*R.size,R.y+300*R.size
	else
		x2,y2=R.x+308*R.size,R.y+450*R.size
	end
	ins(FX.beam,{x1,y1,x2,y2,t=0,lv=lv})
end
function throwBadge(s,r,amount)--Player id
	s,r=players[s],players[r]
	local x1,y1,x2,y2
	if s.small then
		x1,y1=s.x+150*s.size,s.y+300*s.size
	else
		x1,y1=s.x+308*s.size,s.y+450*s.size
	end
	if r.small then
		x2,y2=r.x+150*r.size,r.y+300*r.size
	else
		x2,y2=r.x+308*r.size,r.y+450*r.size
	end
	ins(FX.badge,{x1,y1,x2,y2,t=0,size=(10+min(amount,10))*.1})
end
function freshgho()
	if P.gameEnv._20G or keyPressing[7]and gameEnv.sdarr==0 then
		while not ifoverlap(cb,cx,cy-1)do
			P.cy=P.cy-1
			P.spinLast=false
		end
		P.y_img=P.cy
	else
		P.y_img=P.cy>#field+1 and #field+1 or P.cy
		while not ifoverlap(cb,cx,y_img-1)do
			P.y_img=P.y_img-1
		end
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
	if abs(moving)-gameEnv.das>1 then
		if not ifoverlap(cb,cx+sgn(moving),cy)then
			P.cx=cx+sgn(moving)
		end
	end
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
		if P.id==1 then stat.key=stat.key+1 end
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
    if bn==6 then
		freshgho()--May cancel spinLast
		freshLockDelay()
		SFX(ifpre and"prerotate"or ifoverlap(cb,cx,cy+1)and ifoverlap(cb,cx-1,cy)and ifoverlap(cb,cx+1,cy)and"rotatekick"or"rotate")
		if id==1 then
			stat.rotate=stat.rotate+1
		end
        return nil
    end
	local icb=blocks[bn][(dir+d)%4]
	local isc=d==1 and{c-sc[2]+1,sc[1]}or d==-1 and{sc[2],r-sc[1]+1}or{r-sc[1]+1,c-sc[2]+1}
	local ir,ic=#icb,#icb[1]
	local ix,iy=cx+sc[2]-isc[2],cy+sc[1]-isc[1]
	local t--succssful num
	local iki=TRS[bn][dir*10+(dir+d)%4]
	for i=1,#iki do
		if not ifoverlap(icb,ix+iki[i][1],iy+iki[i][2])then
			ix,iy=ix+iki[i][1],iy+iki[i][2]
			t=i
			break
		end
	end
	if t then
		P.cx,P.cy=ix,iy
		P.sc,P.cb=isc,icb
		P.r,P.c=ir,ic
		P.dir=(dir+d)%4
		P.spinLast=t
		freshgho()--May cancel spinLast
		freshLockDelay()
		SFX(ifpre and"prerotate"or ifoverlap(cb,cx,cy+1)and ifoverlap(cb,cx-1,cy)and ifoverlap(cb,cx+1,cy)and"rotatekick"or"rotate")
		if id==1 then
			stat.rotate=stat.rotate+1
		end
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

		if abs(moving)-gameEnv.das>1 then
			if not ifoverlap(cb,cx+sgn(moving),cy)then
				P.cx=cx+sgn(moving)
			end
		end

		freshgho()
		P.dropDelay,P.lockDelay,P.freshTime=gameEnv.drop,gameEnv.lock,0
		if ifoverlap(cb,cx,cy) then lock()Event.gameover.lose()end
		P.holded=true
		SFX(ifpre and"prehold"or"hold")
		if id==1 then
			stat.hold=stat.hold+1
		end
	end
end
function drop()
	if cy==y_img then
		ins(dropTime,1,frame)rem(dropTime,11)--update speed dial
		P.waiting=gameEnv.wait

		local dospin=bn~=6 and ifoverlap(cb,cx-1,cy)and ifoverlap(cb,cx+1,cy)and ifoverlap(cb,cx,cy+1)and 1 or 0
		if bn<6 and spinLast then
			local x,y=cx+sc[2]-1,cy+sc[1]-1
			local c=0
			if solid(x-1,y+1)then c=c+1 end
			if solid(x+1,y+1)then c=c+1 end
			if c>0 then
				if solid(x-1,y-1)then c=c+1 end
				if solid(x+1,y-1)then c=c+1 end
				if c>2 then
					dospin=dospin+(spinLast==2 and 1 or 2)
				end
			end
		end--Three point
		if dospin==0 then dospin=false end
		lock()
		local cc,csend,exblock,sendTime=checkrow(cy,r),0,0,0--Currect clear&send&sendTime
		local mini=bn~=7 and dospin==1 and cc<3 and cc<r

		P.combo=P.combo+1--combo=0 is under
		if cc==4 then
			if b2b>500 then
				showText("Techrash B2B2B","fly",70)
				csend=6
				sendTime=80
				exblock=exblock+1
			elseif b2b>=100 then
				showText("Techrash B2B","drive",70)
				sendTime=70
				csend=5
			else
				showText("Techrash","stretch",80)
				sendTime=60
				csend=4
			end
			P.b2b=P.b2b+100
			P.cstat.techrash=P.cstat.techrash+1
		elseif cc>0 then
			if dospin then
				if b2b>500 then
					showText(spinName[cc][bn].." B2B2B","spin",40)
					csend=b2bATK[cc]+1
					exblock=exblock+1
				elseif b2b>=100 then
					showText(spinName[cc][bn].." B2B","spin",40)
					csend=b2bATK[cc]
				else
					showText(spinName[cc][bn],"spin",50)
					csend=2*cc
				end
				sendTime=20+csend*20
				if mini then
					showText("Mini","drive",40,10)
					sendTime=sendTime+60
					P.b2b=P.b2b+90+10*cc
				else
					P.b2b=P.b2b+70+30*cc
				end
				SFX(spin_n[cc])
				if id==1 then
					stat.spin=stat.spin+1
				end
			elseif #clearing<#field then
				P.b2b=P.b2b-300
				showText(clearName[cc],"appear",50)
				csend=cc-1
				sendTime=20+csend*20
			end
		else
			P.combo=0
			if dospin then
				showText(spinName[0][bn],"appear",50)
				SFX("spin_0")
				P.b2b=b2b+30
			end
		end

		if cc>0 and #clearing==#field then
			showText("Perfect Clear","flicker",70,-80)
			csend=csend+5
			exblock=exblock+2
			sendTime=sendTime+30
			SFX("perfectclear")
			if cstat.piece>10 then
				P.b2b=600
			end
		end

		csend=csend+(renATK[combo]or 4)
		if combo>2 then
			showText(renName[min(combo,20)],combo<10 and"appear"or"flicker",20+combo*3,60)
		end
		sendTime=sendTime+20*combo
		if cc>0 then
			SFX(clear_n[cc])
			SFX(ren_n[min(combo,11)])
		end
		P.b2b=max(min(b2b,600),0)

		if csend>0 then
			if exblock then exblock=int(exblock*(1+P.strength*.25))end
			csend=csend*(1+P.strength*.25)
			if mini then csend=csend end
			csend=int(csend)
			--Buffs

			P.cstat.atk=P.cstat.atk+csend
			if P.id==1 then stat.atk=stat.atk+csend end
			--ATK statistics

			while csend>0 and P.atkBuffer[1]do
				if exblock>0 then
					exblock=exblock-1
				else
					csend=csend-1
				end
				P.atkBuffer[1].amount=P.atkBuffer[1].amount-1
				if P.atkBuffer[1].amount==0 then
					rem(P.atkBuffer,1)
				end
				if P.atkBuffer[1]and csend==0 then
					local s=P.atkBuffer[1].amount
					P.atkBuffer[1].lv=s<4 and 1 or s<7 and 2 or 3
				end
			end
			if csend>0 then
				showText(csend,"zoomout",25,70)
				if #players.alive>1 then
					garbageSend(P.id,csend,sendTime)
				end
			end
		elseif cc==0 then
			if P.b2b>450 then
				P.b2b=b2b-10
			elseif P.b2b>100 then
				P.b2b=max(b2b-6,100)
			end
			garbageRelease()
		end
		if id==1 then
			stat.piece,stat.row=stat.piece+1,stat.row+cc
		end
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
	players[r].lastRecv=sender
	sort(players[r].atkBuffer,timeSort)
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