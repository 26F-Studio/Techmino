function loadGame(mode,level)
	--rec={}
	curMode={id=modeID[mode],lv=level,modeName=text.modeName[mode],levelName=modeLevel[modeID[mode]][level]}
	gotoScene("play")
end
function resetGameData()
	frame=0
	garbageSpeed=1
	pushSpeed=3

	players={alive={}}human=0
	modeEnv=defaultModeEnv[curMode.id][curMode.lv]or defaultModeEnv[curMode.id][1]
	loadmode[curMode.id]()
	curBG=modeEnv.bg
	BGM(modeEnv.bgm)

	FX.beam={}
	for k,v in pairs(PTC.dust)do
		v:release()
	end
	for i=1,#players do
		if not players[i].small then
			PTC.dust[i]=PTC.dust0:clone()
			PTC.dust[i]:start()
		end
	end
	if modeEnv.royaleMode then
		for i=1,#players do
			changeAtk(players[i],randomTarget(players[i]))
		end
		mostBadge,mostDangerous,secBadge,secDangerous=nil
		gameStage=1
		garbageSpeed=.3
		pushSpeed=2
	end
	for i=1,#virtualkey do
		virtualkey[i].press=false
	end
	stat.game=stat.game+1

	freeRow={}
	collectgarbage()
	for i=1,30*#players do
		freeRow[i]={0,0,0,0,0,0,0,0,0,0}
	end
end
function gameStart()
	sysSFX("start")
	for P=1,#players do
		P=players[P]
		_G.P=P
		P.control=true
		P.timing=true
		resetblock()
	end
	setmetatable(_G,nil)
end
function createPlayer(id,x,y,size,AIspeed,data)
	players[id]={id=id}
	P=players[id]
	local P=P
	ins(players.alive,P)
	P.index={__index=P}
	P.x,P.y,P.size=x,y,size or 1
	P.small=P.size<.3
	if P.small then
		P.centerX,P.centerY=P.x+150*P.size,P.y+300*P.size
		P.size=P.size*5
	else
		P.centerX,P.centerY=P.x+300*P.size,P.y+670*P.size
	end

	if AIspeed then
		P.ai={
			controls={},
			controlDelay=30,
			controlDelay0=AIspeed,
		}
	else
		human=human+1
	end

	P.alive=true
	P.control=false
	P.timing=false
	P.time=0
	P.cstat={
		key=0,piece=0,row=0,atk=0,
		techrash=0,pc=0,
		point=0,event=0
	}--Current gamestat
	P.keyTime={}for i=1,10 do P.keyTime[i]=-1e5 end P.keySpeed=0
	P.dropTime={}for i=1,10 do P.dropTime[i]=-1e5 end P.dropSpeed=0

	P.field,P.visTime={},{}
	P.atkBuffer={sum=0}

	P.ko,P.badge,P.strength=0,0,0
	P.atkMode,P.swappingAtkMode=1,20
	P.atker,P.atking,P.lastRecv={}
	--Royale-related

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

	P.curBlock,P.curID,P.curColor,P.curName={{}},1,0,0
		P.sc,P.dir,P.r,P.c={0,0},0,0,0
		P.curX,P.curY,P.y_img=0,0,0
	P.holdBlock,P.holdID,P.holdColor,P.holdName={{}},0,0,0
		P.holded=false
	P.nextID,P.nextBlock,P.nextColor,P.nextName={},{},{},{}

	P.dropDelay,P.lockDelay=P.gameEnv.drop,P.gameEnv.lock
	P.freshTime=0
	P.spinLast,P.lastClear=false,nil
	local s=P.gameEnv.sequence
	if s=="bag7"or s=="his4"then
		local bag1={1,2,3,4,5,6,7}
		for i=1,7 do
			newNext(rem(bag1,rnd(#bag1)))
		end
	elseif s=="rnd"then
		for i=1,6 do
			local r=rnd(7)
			newNext(r)
		end
	elseif s=="drought1"then
		local bag1={1,2,3,4,5,6}
		for i=1,6 do
			newNext(rem(bag1,rnd(#bag1)))
		end
	elseif s=="drought2"then
		local bag1={1,2,3,4,6,7}
		for i=1,6 do
			newNext(rem(bag1,rnd(#bag1)))
		end
	end

	P.freshNext=freshMethod[P.gameEnv.sequence]
	if P.gameEnv.sequence==1 then P.bag={}--Bag7
	elseif P.gameEnv.sequence==2 then P.his={}for i=1,4 do P.his[i]=P.nextID[i+3]end--History4
	elseif P.gameEnv.sequence==3 then--Pure random
	end

	P.showTime=visible_opt[P.gameEnv.visible]
	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.moving,P.downing=0,0
	P.waiting,P.falling=0,0
	P.clearing={}
	P.fieldBeneath=0

	P.combo=0
	P.b2b=0

	P.endCounter=0
	P.counter=0
	P.result=nil--string:win/lose
	P.bonus={}
end
function showText(P,text,type,font,dy,spd,inf)
	if not P.small then
		ins(P.bonus,{t=0,text=text,draw=FX[type],font=font,dy=dy or 0,speed=spd or 1,inf=inf})
	end
end
function garbageSend(S,R,send,time)
	local pos=rnd(10)
	createBeam(S,R,send<4 and 1 or send<7 and 2 or 3)
	R.lastRecv=S
	if R.atkBuffer.sum<20 then
		send=min(send,20-R.atkBuffer.sum)
		R.atkBuffer.sum=R.atkBuffer.sum+send
		ins(R.atkBuffer,{pos,amount=send,countdown=time,cd0=time,time=0,sent=false,lv=min(int(send^.69),5)})
		if R.id==1 then sysSFX(send<4 and "blip_1"or"blip_2",min(send+1,5)*.1)end
	end
end
function garbageRelease()
	local t=P.showTime*2
	for i=1,#P.atkBuffer do
		local atk=P.atkBuffer[i]
		if not atk.sent and atk.countdown<=0 then
			for j=1,atk.amount do
				ins(P.field,1,getNewRow(8+atk.lv))
				ins(P.visTime,1,getNewRow(t))
				for k=1,#atk do
					P.field[1][atk[k]]=0
				end
			end
			P.atkBuffer.sum=P.atkBuffer.sum-atk.amount
			atk.sent=true
			atk.time=0
			P.fieldBeneath=P.fieldBeneath+atk.amount*30
		end
	end
end
function createBeam(S,R,lv)--Player id
	local x1,y1,x2,y2
	if S.small then
		x1,y1=S.centerX,S.centerY
	else
		x1,y1=S.x+(30*(P.curX+P.sc[2]-1)-30+15+150)*S.size,S.y+(600-30*(P.curY+P.sc[1]-1)+15+70)*S.size
	end
	if R.small then
		x2,y2=R.x+150*R.size*.2,R.y+300*R.size*.2
	else
		x2,y2=R.x+308*R.size,R.y+450*R.size
	end
	ins(FX.beam,{x1,y1,x2,y2,t=0,lv=lv})
end
function throwBadge(S,R)--Player id
	local x1,y1,x2,y2
	if S.small then
		x1,y1=S.x+30*S.size,S.y+60*S.size
	else
		x1,y1=S.x+308*S.size,S.y+450*S.size
	end
	if R.small then
		x2,y2=R.x+30*R.size,R.y+60*R.size
	else
		x2,y2=R.x+73*R.size,R.y+345*R.size
	end
	ins(FX.badge,{x1,y1,x2,y2,t=0})
end
function randomTarget(p)
	if #players.alive>1 then
		local r
		::L::
			r=players.alive[rnd(#players.alive)]
		if r==p then goto L end
		return r
	end
end
function freshTarget(P)
	if P.atkMode==1 then
		if not P.atking.alive or rnd()<.1 then
			changeAtk(P,randomTarget(P))
		end
	elseif P.atkMode==2 then
		changeAtk(P,P~=mostBadge and mostBadge or secBadge or randomTarget(P))
	elseif P.atkMode==3 then
		changeAtk(P,P~=mostDangerous and mostDangerous or secDangerous or randomTarget(P))
	elseif P.atkMode==4 then
		for i=1,#P.atker do
			if not P.atker[i].alive then
				rem(P.atker,i)
				return
			end
		end
	end
end
function changeAtkMode(m)
	if P.atkMode==m then goto L end
	P.atkMode=m
	if m==1 then
		changeAtk(P,randomTarget(P))
	elseif m==2 then
		freshTarget(P)
	elseif m==3 then
		freshTarget(P)
	elseif m==4 then
		changeAtk(P)
	end
	::L::
end
function changeAtk(P,R)
	if P.atking then
		local K=P.atking.atker
		for i=1,#K do
			if K[i]==P then
				rem(K,i)
				goto L
			end
		end
	end
	::L::
	if R then
		P.atking=R
		ins(R.atker,P)
	else
		P.atking=nil
	end
end
function freshMostDangerous()
	mostDangerous,secDangerous=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local h=#players.alive[i].field
		if h>=m then
			mostDangerous,secDangerous=players.alive[i],mostDangerous
			m,m2=h,m
		elseif h>=m2 then
			secDangerous=players.alive[i]
			m2=h
		end
	end
end
function freshMostBadge()
	mostBadge,secBadge=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local h=players.alive[i].badge
		if h>=m then
			mostBadge,secBadge=players.alive[i],mostBadge
			m,m2=h,m
		elseif h>=m2 then
			secBadge=players.alive[i]
			m2=h
		end
	end
end
function royaleLevelup()
	gameStage=gameStage+1
	local spd
	if(gameStage==3 or gameStage>4)and players[1].alive then
		showText(players[1],text.royale_remain(#players.alive),"beat",50,-100,.3)
	end
	if gameStage==2 then
		spd=30
	elseif gameStage==3 then
		spd=15
		garbageSpeed=.6
		if players[1].alive then BGM("cruelty")end
	elseif gameStage==4 then
		spd=10
		pushSpeed=3
	elseif gameStage==5 then
		spd=5
		garbageSpeed=1
	elseif gameStage==6 then
		spd=3
		if players[1].alive then BGM("final")end
	end
	for i=1,#players.alive do
		local P=players.alive[i]
		P.gameEnv.drop=spd
	end
	if curMode.lv==5 and players[1].alive then
		local P=players[1]
		P.gameEnv.drop=int(P.gameEnv.drop*.3)
		if P.gameEnv.drop==0 then
			P.gameEnv._20G=true
		end
	end
end
function freshgho()
	if P.gameEnv._20G or P.keyPressing[7]and P.gameEnv.sdarr==0 then
		::L::if not ifoverlap(P.curBlock,P.curX,P.curY-1)then
			P.curY=P.curY-1
			P.spinLast=false
			goto L
		end
		P.y_img=P.curY
	else
		P.y_img=P.curY>#P.field+1 and #P.field+1 or P.curY
		::L::if not ifoverlap(P.curBlock,P.curX,P.y_img-1)then
			P.y_img=P.y_img-1
			goto L
		end
	end
end
function freshLockDelay()
	if P.lockDelay<P.gameEnv.lock or P.curY==P.y_img then
		if P.freshTime<=P.gameEnv.freshLimit then
			P.lockDelay=P.gameEnv.lock
		end
		P.freshTime=P.freshTime+1
	end
end
function ifoverlap(bk,x,y)
	if x<1 or x+#bk[1]>11 or y<1 then return true end
	if y>#P.field then return end
	for i=1,#bk do for j=1,#bk[1]do
		if P.field[y+i-1]and bk[i][j]>0 and P.field[y+i-1][x+j-1]>0 then return true end
	end end
end
function ckfull(i)
	for j=1,10 do if P.field[i][j]==0 then return end end
	return true
end
function checkrow(start,height)--(cy,r)
	local c=0
	for i=start,start+height-1 do
		if ckfull(i)then
			ins(P.clearing,1,i)
			c=c+1
			if not P.small then
				local S=PTC.dust[P.id]
				for k=1,100 do
					S:setPosition(rnd(300),600-30*i+rnd(30))
					S:emit(3)
				end
			end
		end
	end
	if c>0 then P.falling=P.gameEnv.fall end
	return c
end
function solid(x,y)
	if x<1 or x>10 or y<1 then return true end
	if y>#P.field then return false end
	return P.field[y][x]>0
end
function newNext(n)
	ins(P.nextBlock,blocks[n][0])
	ins(P.nextID,n)
	ins(P.nextColor,P.gameEnv.bone and 8 or n)
	ins(P.nextName,n)
end
function resetblock()
	P.spinLast=false
	P.curID,P.curBlock,P.curColor,P.curName=rem(P.nextID,1),rem(P.nextBlock,1),rem(P.nextColor,1),rem(P.nextName,1)--id/block/color/name
	P.freshNext()
	P.holded=false
	P.sc,P.dir=scs[P.curID][0],0--spin center/direction
	P.r,P.c=#P.curBlock,#P.curBlock[1]--row/column
	P.curX,P.curY=blockPos[P.curID],21+ceil(P.fieldBeneath/30)-P.r+min(int(#P.field*.2),2)
	P.dropDelay,P.lockDelay,P.freshTime=P.gameEnv.drop,P.gameEnv.lock,0
	if P.keyPressing[8]then hold(true)end
	if P.keyPressing[3]then spin(1,true)end
	if P.keyPressing[4]then spin(-1,true)end
	if P.keyPressing[5]then spin(2,true)end
	if abs(P.moving)-P.gameEnv.das>1 and not ifoverlap(P.curBlock,P.curX+sgn(P.moving),P.curY)then
		P.curX=P.curX+sgn(P.moving)
	end

	if ifoverlap(P.curBlock,P.curX,P.curY)then lock()Event_gameover.lose()end
	freshgho()	
	if P.keyPressing[6]then act.hardDrop()P.keyPressing[6]=false end
end
function pressKey(i,p)
	P=p
	P.keyPressing[i]=true
	if P.id==1 then
		virtualkeyDown[i]=true
		virtualkeyPressTime[i]=10
	end
	if i==10 then
		act.restart()
	elseif P.alive then
		if P.control and P.waiting<=0 then
			act[actName[i]]()
			if i>2 and i<7 then P.keyPressing[i]=false end
		elseif i==9 and not setting.swap then
			P.atkMode=P.atkMode<3 and P.atkMode+2 or 5-P.atkMode
		elseif P.keyPressing[9]and setting.swap then
			if i==1 then
				P.atkMode=1
				changeAtk(P,randomTarget(P))
			elseif i==2 then
				P.atkMode=2
			elseif i==6 then
				P.atkMode=3
			elseif i==7 then
				P.atkMode=4
			end
		else
			if i==1 then
				P.moving=-1
			elseif i==2 then
				P.moving=1
			end
		end
		ins(P.keyTime,1,frame)rem(P.keyTime,11)
		P.cstat.key=P.cstat.key+1
		if P.id==1 then stat.key=stat.key+1 end
	end
	--ins(rec,{i,frame})
end
function releaseKey(i,p)
	p.keyPressing[i]=false
	if p.id==1 then virtualkeyDown[i]=false end
	-- if recording then ins(rec,{-i,frame})end
end
function spin(d,ifpre)
	local idir=(P.dir+d)%4
	if P.curID==6 then
		freshLockDelay()
		SFX(ifpre and"prerotate"or"rotate")
		if P.gameEnv.ospin and P.freshTime>10 then
			if d==1 then
				if P.curY==P.y_img and solid(P.curX+2,P.curY+1)and solid(P.curX+2,P.curY)and solid(P.curX-1,P.curY+1)and not solid(P.curX-1,P.curY)then
					if solid(P.curX-2,P.curY)then
						P.curX=P.curX-1
						goto T
					else
						P.curX=P.curX-2
						goto I
					end
				end
			elseif d==-1 then
				if P.curY==P.y_img and solid(P.curX-1,P.curY+1)and solid(P.curX-1,P.curY)and solid(P.curX+2,P.curY+1)and not solid(P.curX+2,P.curY)then
					if solid(P.curX+3,P.curY)then
						goto T
					else
						goto I
					end
				end
			elseif d==2 and P.curY==P.y_img and solid(P.curX-1,P.curY+1)and solid(P.curX+2,P.curY+1)and not solid(P.curX-1,P.curY)and not solid(P.curX+2,P.curY)then
				P.curX=P.curX-1
				goto I
			end
			goto E
			::T::
				P.curID=5
				P.curBlock=blocks[5][0]
				P.sc=scs[5][0]
				P.r,P.c,P.dir=2,3,0
				P.spinLast=3
				if P.id==1 then stat.rotate=stat.rotate+1 end
				goto E
			::I::
				P.curID=7
				P.curBlock=blocks[7][2]
				P.sc=scs[7][2]
				P.r,P.c,P.dir=1,4,2
				P.spinLast=3
				if P.id==1 then stat.rotate=stat.rotate+1 end
		end
		::E::return
	end
	local icb=blocks[P.curID][idir]
	local isc=scs[P.curID][idir]
	local ir,ic=#icb,#icb[1]
	local ix,iy=P.curX+P.sc[2]-isc[2],P.curY+P.sc[1]-isc[1]
	local t--succssful test id
	local iki=TRS[P.curID][P.dir*10+idir]
	for i=1,P.freshTime<=1.2*P.gameEnv.freshLimit and #iki or 1 do
		if not ifoverlap(icb,ix+iki[i][1],iy+iki[i][2])then
			ix,iy=ix+iki[i][1],iy+iki[i][2]
			t=i
			goto spin
		end
	end
	goto fail
	::spin::
	P.curX,P.curY,P.dir=ix,iy,idir
	P.sc,P.curBlock=scs[P.curID][idir],icb
	P.r,P.c=ir,ic
	P.spinLast=t==2 and testScore[-d]or 2
	freshgho()
	freshLockDelay()
	SFX(ifpre and"prerotate"or ifoverlap(P.curBlock,P.curX,P.curY+1)and ifoverlap(P.curBlock,P.curX-1,P.curY)and ifoverlap(P.curBlock,P.curX+1,P.curY)and"rotatekick"or"rotate")
	if id==1 then
		stat.rotate=stat.rotate+1
	end
	::fail::
end
function hold(ifpre)
	if not P.holded and P.waiting<=0 and P.gameEnv.hold then
		P.holded=P.gameEnv.oncehold
		P.holdID,P.curID=P.curID,P.holdID
		P.holdBlock,P.curBlock=blocks[P.holdID][0],P.holdBlock
		P.holdColor,P.curColor=P.curColor,P.holdColor
		P.holdName,P.curName=P.curName,P.holdName
		if P.curID==0 then
			P.curID,P.curBlock,P.curColor,P.curName=rem(P.nextID,1),rem(P.nextBlock,1),rem(P.nextColor,1),rem(P.nextName,1)--id/block/color/name
			P.freshNext()
		end
		P.sc,P.dir=scs[P.curID][0],0
		P.r,P.c=#P.curBlock,#P.curBlock[1]
		P.curX,P.curY=blockPos[P.curID],21+ceil(P.fieldBeneath/30)-P.r+min(int(#P.field*.2),2)

		if abs(P.moving)-P.gameEnv.das>1 and not ifoverlap(P.curBlock,P.curX+sgn(P.moving),P.curY)then
			P.curX=P.curX+sgn(P.moving)
		end
	
		freshgho()
		P.dropDelay,P.lockDelay,P.freshTime=P.gameEnv.drop,P.gameEnv.lock,0
		if ifoverlap(P.curBlock,P.curX,P.curY)then lock()Event_gameover.lose()end

		SFX(ifpre and"prehold"or"hold")
		if P.id==1 then
			stat.hold=stat.hold+1
		end
	end
end
function drop()
	if P.curY==P.y_img then
		ins(P.dropTime,1,frame)rem(P.dropTime,11)--update speed dial
		P.waiting=P.gameEnv.wait
		local dospin=0
		if P.spinLast then
			if P.curID<6 then
				local x,y=P.curX+P.sc[2]-1,P.curY+P.sc[1]-1
				local c=0
				if solid(x-1,y+1)then c=c+1 end
				if solid(x+1,y+1)then c=c+1 end
				if c==0 then goto NTC end
				if solid(x-1,y-1)then c=c+1 end
				if solid(x+1,y-1)then c=c+1 end
				if c>2 then
					dospin=dospin+1
				end
			end--Three point
			::NTC::
			if P.curID~=6 and ifoverlap(P.curBlock,P.curX-1,P.curY)and ifoverlap(P.curBlock,P.curX+1,P.curY)and ifoverlap(P.curBlock,P.curX,P.curY+1)then
				dospin=dospin+2
			end--Immobile
		end
		lock()
		local cc,csend,exblock,sendTime=checkrow(P.curY,P.r),0,0,0--Currect clear&send&sendTime
		local mini
		if P.spinLast and cc>0 and dospin>0 then
			dospin=dospin+P.spinLast
		end
		if not P.spinLast then
			dospin=false
		elseif cc==0 then
			if dospin==0 then
				dospin=false
			end
		elseif dospin<2 then
			dospin=false
		elseif dospin==2 then
			mini=P.curID<6 and cc<3 and cc<P.r
		end
		
		P.combo=P.combo+1--combo=0 is under
		if cc==4 then
			if P.b2b>1000 then
				showText(P,text.techrashB3B,"fly",80,-30)
				csend=6
				sendTime=100
				exblock=exblock+1
			elseif P.b2b>=40 then
				showText(P,text.techrashB2B,"drive",80,-30)
				sendTime=80
				csend=5
			else
				showText(P,text.techrash,"stretch",80,-30)
				sendTime=60
				csend=4
			end
			P.b2b=P.b2b+120
			P.lastClear=74
			P.cstat.techrash=P.cstat.techrash+1
		elseif cc>0 then
			if dospin then
				if P.b2b>1000 then
					showText(P,text.b3b..text.spin[P.curName]..text.clear[cc],"spin",40,-30)
					csend=b2bATK[cc]+1
					exblock=exblock+1
				elseif P.b2b>=40 then
					showText(P,text.b2b..text.spin[P.curName]..text.clear[cc],"spin",40,-30)
					csend=b2bATK[cc]
				else
					showText(P,text.spin[P.curName]..text.clear[cc],"spin",50,-30)
					csend=2*cc
				end
				sendTime=20+csend*20
				if mini then
					showText(P,text.mini,"appear",40,-80)
					csend=ceil(csend*.5)
					sendTime=sendTime+60
					P.b2b=P.b2b+b2bPoint[cc]*.8
				else
					P.b2b=P.b2b+b2bPoint[cc]
				end
				P.lastClear=P.curID*10+cc
				if P.id==1 then
					stat.spin=stat.spin+1
				end
				SFX(spin_n[cc])
			elseif #P.clearing<#P.field then
				P.b2b=max(P.b2b-250,0)
				showText(P,text.clear[cc],"appear",32+cc*3,-30,(8-cc)*.3)
				csend=cc-1
				sendTime=20+csend*20
				P.lastClear=cc
			end
		else
			P.combo=0
			if dospin then
				showText(P,text.spin[P.curName],"appear",50,-30)
				SFX("spin_0")
				P.b2b=P.b2b+20
			end
		end
		if #P.clearing==#P.field then
			showText(P,text.PC,"flicker",70,-80)
			csend=csend+min(6+P.cstat.pc,10)
			exblock=exblock+2
			sendTime=sendTime+30
			if P.cstat.row>4 then P.b2b=1200 end
			P.cstat.pc=P.cstat.pc+1
			P.lastClear=P.curID*10+5
			SFX("perfectclear")
		end

		csend=csend+(renATK[P.combo]or 4)
		if P.combo>2 then
			showText(P,text.cmb[min(P.combo,20)],P.combo<10 and"appear"or"flicker",20+P.combo*3,60)
		end
		sendTime=sendTime+20*P.combo
		if cc>0 then
			SFX(clear_n[cc])
			SFX(ren_n[min(P.combo,11)])
			if P.id==1 then VIB(cc<3 and 1 or cc-1)end
		end
		if P.b2b>1200 then P.b2b=1200 end

		if cc>0 and modeEnv.royaleMode then
			local i=min(#P.atker,9)
			if i>1 then
				csend=csend+reAtk[i]
				exblock=exblock+reDef[i]
			end
		end

		if csend>0 then
			if exblock then exblock=int(exblock*(1+P.strength*.25))end
			csend=csend*(1+P.strength*.25)
			if mini then csend=csend end
			csend=int(csend)
			--Badge Buff

			P.cstat.atk=P.cstat.atk+csend
			if P.id==1 then stat.atk=stat.atk+csend end
			--ATK statistics

			if csend==0 then goto L end
				showText(P,csend,"zoomout",40,70)
			if exblock==0 then goto L end
				showText(P,exblock,"zoomout",20,115)
			::L::
			if csend>0 and P.atkBuffer[1]then
				if exblock>0 then
					exblock=exblock-1
				else
					csend=csend-1
				end
				P.atkBuffer[1].amount=P.atkBuffer[1].amount-1
				P.atkBuffer.sum=P.atkBuffer.sum-1
				if P.atkBuffer[1].amount==0 then
					rem(P.atkBuffer,1)
				end
				goto L
			end
			if csend>0 then
				if modeEnv.royaleMode then
					if P.atkMode==4 then
						if #P.atker>0 then
							for i=1,#P.atker do
								garbageSend(P,P.atker[i],csend,sendTime)
							end
						else
							garbageSend(P,randomTarget(P),csend,sendTime)
						end
					else
						freshTarget(P)
						garbageSend(P,P.atking,csend,sendTime)
					end
				elseif #players.alive>1 then
					garbageSend(P,randomTarget(P),csend,sendTime)
				end
				if P.id==1 and csend>3 then sysSFX("emit",min(csend,8)*.125)end
			end
		elseif cc==0 then
			if P.b2b>1000 then
				P.b2b=max(P.b2b-40,1000)
			end
			garbageRelease()
		end
		if P.id==1 then
			stat.piece,stat.row=stat.piece+1,stat.row+cc
		end
		P.cstat.piece,P.cstat.row=P.cstat.piece+1,P.cstat.row+cc
		if P.cstat.row>=P.gameEnv.target then
			P.gameEnv.reach()
		end
		P.spinLast=dospin and cc>0
		SFX("lock")
	else
		P.curY=P.curY-1
		P.spinLast=false
	end
end
function lock()
	for i=1,P.r do
		local y=P.curY+i-1
		if not P.field[y]then P.field[y],P.visTime[y]=getNewRow(),getNewRow()end
		for j=1,P.c do
			if P.curBlock[i][j]~=0 then
				P.field[y][P.curX+j-1]=P.curColor
				P.visTime[y][P.curX+j-1]=P.showTime
			end
		end
	end
end
act={
	moveLeft=function(auto)
		if P.keyPressing[9]and setting.swap then
			changeAtkMode(1)
		else
			if not auto then
				P.moving=-1
			end
			if not ifoverlap(P.curBlock,P.curX-1,P.curY)then
				P.curX=P.curX-1
				freshgho()
				freshLockDelay()
				if P.curY==P.y_img then SFX("move")end
				P.spinLast=false
			end
		end
	end,
	moveRight=function(auto)
		if P.keyPressing[9]and setting.swap then
			changeAtkMode(2)
		else
			if not auto then
				P.moving=1
			end
			if not ifoverlap(P.curBlock,P.curX+1,P.curY)then
				P.curX=P.curX+1
				freshgho()
				freshLockDelay()
				if P.curY==P.y_img then SFX("move")end
				P.spinLast=false
			end
		end
	end,
	rotRight=function()spin(1)end,
	rotLeft=function()spin(3)end,
	rotFlip=function()spin(2)end,
	hardDrop=function()
		if P.keyPressing[9]and setting.swap then
			changeAtkMode(3)
		else
			if P.waiting<=0 then
				if P.curY~=P.y_img then
					P.curY=P.y_img
					P.spinLast=false
					SFX("drop")
					if P.id==1 then VIB(1)end
				end
				drop()
			end
		end
	end,
	softDrop=function()
		if P.keyPressing[9]and setting.swap then
			changeAtkMode(4)
		else
			if P.curY~=P.y_img then
				P.curY=P.curY-1
				P.spinLast=false
			end
			P.downing=1
		end
	end,
	hold=function()hold()end,
	swap=function()
		if modeEnv.royaleMode then
			for i=1,#P.keyPressing do
				if P.keyPressing[i]then
					P.keyPressing[i]=false
				end
			end
			if setting.swap then
				P.keyPressing[9]=true
			else
				changeAtkMode(P.atkMode<3 and P.atkMode+2 or 5-P.atkMode)
				P.swappingAtkMode=30
			end
		else
			P.keyPressing[9]=false
		end
	end,
	restart=function()
		resetGameData()
		frame=30
	end,
	insDown=function()if P.curY~=P.y_img then P.curY,P.lockDelay,P.spinLast=P.y_img,P.gameEnv.lock,false end end,
	insLeft=function()
		local x0=cx
		::L::if not ifoverlap(P.curBlock,P.curX-1,P.curY)then
			P.curX=P.curX-1
			freshgho()
			goto L
		end
		if x0~=cx then freshLockDelay()end
	end,
	insRight=function()
		local x0=cx
		::L::if not ifoverlap(P.curBlock,P.curX+1,P.curY)then
			P.curX=P.curX+1
			freshgho()
			goto L
		end
		if x0~=cx then freshLockDelay()end
	end,
	down1=function()
		if P.curY~=P.y_img then
			P.curY=P.curY-1
			P.spinLast=false
		end
	end,
	down4=function()
		for i=1,4 do
			if P.curY~=P.y_img then
				P.curY=P.curY-1
				P.spinLast=false
			else
				break
			end
		end
	end,
	quit=function()Event_gameover.lose()end,
	--System movements
}