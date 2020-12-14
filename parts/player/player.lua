------------------------------------------------------
--Notice: anything in this file or in any other file,
--var P stands for Player object. Don't forget that.
------------------------------------------------------
local Player={}--Player class

local int,ceil,rnd=math.floor,math.ceil,math.random
local max,min=math.max,math.min
local ins,rem=table.insert,table.remove
local ct=coroutine

local kickList=require"parts/kickList"
local scs=spinCenters

local function without(L,e)
	for i=1,#L do
		if L[i]==e then return end
	end
	return true
end

--------------------------<FX>--------------------------
function Player.showText(P,text,dx,dy,font,style,spd,stop)
	if P.gameEnv.text then
		ins(P.bonus,TEXT.getText(text,150+dx,300+dy,font*P.size,style,spd,stop))
	end
end
function Player.showTextF(P,text,dx,dy,font,style,spd,stop)
	ins(P.bonus,TEXT.getText(text,150+dx,300+dy,font*P.size,style,spd,stop))
end
function Player.createLockFX(P)
	local BK=P.cur.bk
	local t=12-P.gameEnv.lockFX*2

	for i=1,P.r do
		local y=P.curY+i-1
		if without(P.clearedRow,y)then
			y=-30*y
			for j=1,P.c do
				if BK[i][j]then
					ins(P.lockFX,{30*(P.curX+j-2),y,0,t})
				end
			end
		end
	end
end
function Player.createDropFX(P,x,y,w,h)
	ins(P.dropFX,{x,y,w,h,0,13-2*P.gameEnv.dropFX})
end
function Player.createMoveFX(P,dir)
	local T=10-1.5*P.gameEnv.moveFX
	local C=P.cur.color
	local x=P.curX-1
	local y=P.gameEnv.smooth and P.curY+P.dropDelay/P.gameEnv.drop-2 or P.curY-1
	if dir=="left"then
		for i=1,P.r do for j=P.c,1,-1 do
			if P.cur.bk[i][j]then
				ins(P.moveFX,{C,x+j,y+i,0,T})
				break
			end
		end end
	elseif dir=="right"then
		for i=1,P.r do for j=1,P.c do
			if P.cur.bk[i][j]then
				ins(P.moveFX,{C,x+j,y+i,0,T})
				break
			end
		end end
	elseif dir=="down"then
		for j=1,P.c do for i=P.r,1,-1 do
			if P.cur.bk[i][j]then
				ins(P.moveFX,{C,x+j,y+i,0,T})
				break
			end
		end end
	else
		for i=1,P.r do for j=1,P.c do
			if P.cur.bk[i][j]then
				ins(P.moveFX,{C,x+j,y+i,0,T})
			end
		end end
	end
end
function Player.createSplashFX(P,h)
	local L=P.field[h]
	local size=P.size
	local y=P.fieldY+size*(P.fieldOff.y+P.fieldBeneath+P.fieldUp+615)
	for x=1,10 do
		local c=L[x]
		if c>0 then
			SYSFX.newCell(
				2.5-P.gameEnv.splashFX*.4,
				SKIN.curText[c],
				size,
				P.fieldX+(30*x-15)*size,y-30*h*size,
				rnd()*5-2.5,rnd()*-1,
				0,.6
			)
		end
	end
end
function Player.createClearingFX(P,y,spd)
	ins(P.clearFX,{y,0,spd})
end
function Player.createBeam(P,R,send,color)
	local x1,y1,x2,y2
	if P.small then x1,y1=P.centerX,P.centerY
	else x1,y1=P.x+(30*(P.curX+P.sc[2])-30+15+150)*P.size,P.y+(600-30*(P.curY+P.sc[1])+15+70)*P.size
	end
	if R.small then x2,y2=R.centerX,R.centerY
	else x2,y2=R.x+308*R.size,R.y+450*R.size
	end

	wid=int(send^.7*(4+SETTING.atkFX))
	local r,g,b=unpack(SKIN.libColor[color])
	r,g,b=r*2,g*2,b*2

	local a=GAME.modeEnv.royaleMode and not(P.human or R.human)and .2 or 1
	SYSFX.newAttack(1-SETTING.atkFX*.1,x1,y1,x2,y2,wid,r,g,b,a*(SETTING.atkFX+2)*.0626)
end
--------------------------</FX>--------------------------

--------------------------<Method>--------------------------
function Player.RND(P,a,b)
	local R=P.randGen
	return R:random(a,b)
end
function Player.newTask(P,code)
	local L=P.tasks
	local thread=ct.create(code)
	ct.resume(thread,P)
	L[#L+1]=thread
end

function Player.set20G(P,if20g,init)--Only set init=true when initialize CC, do not use it
	P._20G=if20g
	P.keyAvailable[7]=not if20g
	if P.human then
		virtualkey[7].ava=not if20g
	end
	if init and if20g and P.AI_mode=="CC"then CC.switch20G(P)end
end
function Player.setHold(P,count)--Set hold count (false/true as 0/1)
	if not count then
		count=0
	elseif count==true then
		count=1
	end
	P.gameEnv.holdCount=count
	P.holdTime=count
	if P.human then
		virtualkey[8].ava=count>0
	end
	if count==0 then
		P.drawHold=NULL
		while P.holdQueue[1]do rem(P.holdQueue)end
	elseif count==1 then
		P.drawHold=PLY.draw.drawHold_norm
	else
		P.drawHold=PLY.draw.drawHold_multi
	end
end
function Player.setNext(P,next,hidden)--Set next count　(use hidden=true if set env.nextStartPos>1)
	P.gameEnv.nextCount=next
	if next==0 then
		P.drawNext=NULL
	elseif not hidden then
		P.drawNext=PLY.draw.drawNext_norm
	else
		P.drawNext=PLY.draw.drawNext_hidden
	end
end
function Player.setInvisible(P,time)--Time in frames
	if time<0 then
		P.keepVisible=true
		P.showTime=1e99
	else
		P.keepVisible=false
		P.showTime=time
	end
end
function Player.setRS(P,RSname)
	P.RS=kickList[RSname]
end

function Player.getHolePos(P)--Get a good garbage-line hole position
	if P.garbageBeneath==0 then
		return P:RND(10)
	else
		local p=P:RND(10)
		if P.field[1][p]<=0 then
			return P:RND(10)
		end
		return p
	end
end
function Player.garbageRelease(P)--Check garbage buffer and try to release them
	local n,flag=1
	while true do
		local A=P.atkBuffer[n]
		if A and A.countdown<=0 and not A.sent then
			P:garbageRise(19+A.lv,A.amount,A.pos)
			P.atkBuffer.sum=P.atkBuffer.sum-A.amount
			A.sent,A.time=true,0
			P.stat.pend=P.stat.pend+A.amount
			n=n+1
			flag=true
		else
			break
		end
	end
	if flag and P.AI_mode=="CC"then CC.updateField(P)end
end
function Player.garbageRise(P,color,amount,pos)--Release n-lines garbage to field
	local _
	local t=P.showTime*2
	for _=1,amount do
		ins(P.field,1,FREEROW.get(color,true))
		ins(P.visTime,1,FREEROW.get(t))
		P.field[1][pos]=0
	end
	P.fieldBeneath=P.fieldBeneath+amount*30
	if P.cur then
		P.curY=P.curY+amount
		P.imgY=P.imgY+amount
	end
	P.garbageBeneath=P.garbageBeneath+amount
	for i=1,#P.clearingRow do
		P.clearingRow[i]=P.clearingRow[i]+amount
	end
	P:freshBlock(false,false)
	for i=1,#P.lockFX do
		_=P.lockFX[i]
		_[2]=_[2]-30*amount--Shift 30px per line cleared
	end
	for i=1,#P.dropFX do
		_=P.dropFX[i]
		_[3],_[5]=_[3]+amount,_[5]+amount
	end
	if #P.field>42 then P:lose()end
end

local invList={2,1,4,3,5,6,7}
function Player.pushLineList(P,L,mir)--Push some lines to field
	local l=#L
	local S=P.gameEnv.skin
	for i=1,l do
		local r=FREEROW.get(0)
		if not mir then
			for j=1,10 do
				r[j]=S[L[i][j]]or 0
			end
		else
			for j=1,10 do
				r[j]=S[invList[L[i][11-j]]]or 0
			end
		end
		ins(P.field,1,r)
		ins(P.visTime,1,FREEROW.get(20))
	end
	P.fieldBeneath=P.fieldBeneath+30*l
	P.curY=P.curY+l
	P.imgY=P.imgY+l
	P:freshBlock(false,false)
end
function Player.pushNextList(P,L,mir)--Push some nexts to nextQueue
	for i=1,#L do
		P:getNext(mir and invList[L[i]]or L[i])
	end
end

function Player.solid(P,x,y)
	if x<1 or x>10 or y<1 then return true end
	if y>#P.field then return false end
	return P.field[y]
	[x]>0--to catch bug (nil[*])
end
function Player.ifoverlap(P,bk,x,y)
	local C=#bk[1]
	if x<1 or x+C>11 or y<1 then return true end
	if y>#P.field then return end
	for i=1,#bk do
		if P.field[y+i-1]then
			for j=1,C do
				if bk[i][j]and P.field[y+i-1][x+j-1]>0 then return true end
			end
		end
	end
end
function Player.attack(P,R,send,time,...)
	if SETTING.atkFX>0 then
		P:createBeam(R,send,time,...)
	end
	R.lastRecv=P
	if R.atkBuffer.sum<26 then
		local B=R.atkBuffer
		if send>26-B.sum then send=26-B.sum end
		local m,k=#B,1
		while k<=m and time>B[k].countdown do k=k+1 end
		for i=m,k,-1 do
			B[i+1]=B[i]
		end
		B[k]={
			pos=P:RND(10),
			amount=send,
			countdown=time,
			cd0=time,
			time=0,
			sent=false,
			lv=min(int(send^.69),5),
		}--Sorted insert(by time)
		B.sum=B.sum+send
		R.stat.recv=R.stat.recv+send
		if R.sound then
			SFX.play(send<4 and"blip_1"or"blip_2",min(send+1,5)*.1)
		end
	end
end
function Player.freshTarget(P)
	if P.atkMode==1 then
		if not P.atking or not P.atking.alive or rnd()<.1 then
			P:changeAtk(randomTarget(P))
		end
	elseif P.atkMode==2 then
		P:changeAtk(P~=GAME.mostBadge and GAME.mostBadge or GAME.secBadge or randomTarget(P))
	elseif P.atkMode==3 then
		P:changeAtk(P~=GAME.mostDangerous and GAME.mostDangerous or GAME.secDangerous or randomTarget(P))
	elseif P.atkMode==4 then
		for i=1,#P.atker do
			if not P.atker[i].alive then
				rem(P.atker,i)
				return
			end
		end
	end
end
function Player.changeAtkMode(P,m)
	if P.atkMode==m then return end
	P.atkMode=m
	if m==1 then
		P:changeAtk(randomTarget(P))
	elseif m==2 or m==3 then
		P:freshTarget()
	elseif m==4 then
		P:changeAtk()
	end
end
function Player.changeAtk(P,R)
	-- if not P.human then R=PLAYERS[1]end--1vALL mode?
	if P.atking then
		local K=P.atking.atker
		for i=1,#K do
			if K[i]==P then
				rem(K,i)
				break
			end
		end
	end
	if R then
		P.atking=R
		ins(R.atker,P)
	else
		P.atking=nil
	end
end
function Player.freshBlock(P,keepGhost,control,system)
	local ENV=P.gameEnv
	if not keepGhost and P.cur then
		P.imgY=min(#P.field+1,P.curY)
		if P._20G or P.keyPressing[7]and ENV.sdarr==0 then
			local _=P.imgY

			--Move ghost to bottom
			while not P:ifoverlap(P.cur.bk,P.curX,P.imgY-1)do
				P.imgY=P.imgY-1
			end

			--Cancel spinLast
			if _~=P.imgY then
				P.spinLast=false
			end

			--Create FX if dropped
			if P.curY>P.imgY then
				if ENV.dropFX and ENV.block and P.curY-P.imgY-P.r>-1 then
					P:createDropFX(P.curX,P.curY-1,P.c,P.curY-P.imgY-P.r+1)
				end
				if ENV.shakeFX then
					P.fieldOff.vy=ENV.shakeFX*.5
				end
				P.curY=P.imgY
			end
		else
			while not P:ifoverlap(P.cur.bk,P.curX,P.imgY-1)do
				P.imgY=P.imgY-1
			end
		end
	end

	if control then
		if ENV.easyFresh then
			local d0=ENV.lock
			if P.lockDelay<d0 and P.freshTime>0 then
				if not system then
					P.freshTime=P.freshTime-1
				end
				P.lockDelay=d0
				P.dropDelay=ENV.drop
			end
			if P.curY<P.minY then
				P.minY=P.curY
				P.dropDelay=ENV.drop
				P.lockDelay=ENV.lock
			end
		else
			if P.curY<P.minY then
				P.minY=P.curY
				if P.lockDelay<ENV.lock and P.freshTime>0 then
					P.freshTime=P.freshTime-1
					P.dropDelay=ENV.drop
					P.lockDelay=ENV.lock
				end
			end
		end
	end
end
function Player.lock(P)
	local dest=P.AI_dest
	local has_dest=dest~=nil
	for i=1,P.r do
		local y=P.curY+i-1
		if not P.field[y]then P.field[y],P.visTime[y]=FREEROW.get(0),FREEROW.get(0)end
		for j=1,P.c do
			if P.cur.bk[i][j]then
				P.field[y][P.curX+j-1]=P.cur.color
				P.visTime[y][P.curX+j-1]=P.showTime
				local x=P.curX+j-1
				if dest then
					local original_length=#dest
					for k=1,original_length do
						if x==dest[k][1]and y==dest[k][2]then
							rem(dest, k)
							break
						end
					end
					if #dest~=original_length-1 then
						dest=nil
					end
				end
			end
		end
	end
	if has_dest and not dest then
		CC.updateField(P)
	end
end

local spawnSFX_name={}for i=1,7 do spawnSFX_name[i]="spawn_"..i end
function Player.resetBlock(P)
	local C=P.cur
	local id=C.id
	local face=P.gameEnv.face[id]
	local sc=scs[id][face]
	P.sc=sc					--Spin center
	P.dir=face				--Block direction
	P.r,P.c=#C.bk,#C.bk[1]	--Row/column
	P.curX=int(6-P.c*.5)
	local y=21+ceil(P.fieldBeneath/30)
	P.curY=y
	P.minY=y+sc[2]

	local _=P.keyPressing
	--IMS
	if P.gameEnv.ims and(_[1]and P.movDir==-1 or _[2]and P.movDir==1)and P.moving>=P.gameEnv.das then
		local x=P.curX+P.movDir
		if not P:ifoverlap(C.bk,x,y)then
			P.curX=x
		end
	end

	--IRS
	if P.gameEnv.irs then
		if _[5]then
			P:spin(2,true)
		else
			if _[3]then
				if _[4]then
					P:spin(2,true)
				else
					P:spin(1,true)
				end
			elseif _[4]then
				P:spin(3,true)
			end
		end
	end

	--Spawn SFX
	if P.sound and id<8 then
		SFX.fplay(spawnSFX_name[id],SETTING.spawn)
	end
end

function Player.spin(P,d,ifpre)
	local iki=P.RS[P.cur.id]
	if type(iki)=="table"then
		local idir=(P.dir+d)%4
		local icb=BLOCKS[P.cur.id][idir]
		local isc=scs[P.cur.id][idir]
		local ir,ic=#icb,#icb[1]
		local ix,iy=P.curX+P.sc[2]-isc[2],P.curY+P.sc[1]-isc[1]
		iki=iki[P.dir*10+idir]
		if not iki then
			if P.gameEnv.easyFresh then
				P:freshBlock(false,true)
			end
			SFX.fieldPlay(ifpre and"prerotate"or"rotate",nil,P)
			return
		end
		for test=1,#iki do
			local x,y=ix+iki[test][1],iy+iki[test][2]
			if not P:ifoverlap(icb,x,y)and(P.freshTime>=0 or iki[test][2]<0)then
				ix,iy=x,y
				if P.gameEnv.moveFX and P.gameEnv.block then
					P:createMoveFX()
				end
				P.curX,P.curY,P.dir=ix,iy,idir
				P.sc,P.cur.bk=scs[P.cur.id][idir],icb
				P.r,P.c=ir,ic
				P.spinLast=test==2 and 0 or 1
				if not ifpre then
					P:freshBlock(false,true)
				end
				if iki[test][2]>0 and not P.gameEnv.easyFresh then
					P.freshTime=P.freshTime-1
				end

				if P.sound then
					SFX.fieldPlay(ifpre and"prerotate"or P:ifoverlap(P.cur.bk,P.curX,P.curY+1)and P:ifoverlap(P.cur.bk,P.curX-1,P.curY)and P:ifoverlap(P.cur.bk,P.curX+1,P.curY)and"rotatekick"or"rotate",nil,P)
				end
				P.stat.rotate=P.stat.rotate+1
				return
			end
		end
	elseif iki then
		iki(P,d)
	end
end
function Player.hold(P,ifpre)
	if P.holdTime>0 and(ifpre or P.waiting==-1)then
		if #P.holdQueue<P.gameEnv.holdCount and P.nextQueue[1]then--Skip
			local C=P.cur
			C.bk=BLOCKS[C.id][P.gameEnv.face[C.id]]
			ins(P.holdQueue,C)

			local t=P.holdTime
			P:popNext(true)
			P.holdTime=t
		else--Hold
			local C,H=P.cur,P.holdQueue[1]

			--Finesse check
			if H and C and H.id==C.id and H.name==C.name then
				P.ctrlCount=P.ctrlCount+1
			elseif P.ctrlCount<=1 then
				P.ctrlCount=0
			end

			P.spinLast=false
			P.spinSeq=0

			if C then
				C.bk=BLOCKS[C.id][P.gameEnv.face[C.id]]
				ins(P.holdQueue,C)
			end
			P.cur=rem(P.holdQueue,1)

			P:resetBlock()
			P:freshBlock(false,true)
			P.dropDelay=P.gameEnv.drop
			P.lockDelay=P.gameEnv.lock
			if P:ifoverlap(P.cur.bk,P.curX,P.curY)then P:lock()P:lose()end
		end

		P.freshTime=int(min(P.freshTime+P.gameEnv.freshLimit*.25,P.gameEnv.freshLimit*((P.holdTime+1)/P.gameEnv.holdCount)))
		if not P.gameEnv.infHold then
			P.holdTime=P.holdTime-1
		end

		if P.sound then
			SFX.play(ifpre and"prehold"or"hold")
		end

		if P.AI_mode=="CC"then
			local next=P.nextQueue[P.AIdata.nextCount]
			if next then
				CC.addNext(P.AI_bot,next.id)
			end
		end

		P.stat.hold=P.stat.hold+1
	end
end

function Player.getNext(P,n)--Push a block(id=n) to nextQueue
	local E=P.gameEnv
	ins(P.nextQueue,{bk=BLOCKS[n][E.face[n]],id=n,color=E.bone and 17 or E.skin[n],name=n})
end
function Player.popNext(P,ifhold)--Pop nextQueue to hand
	if not ifhold then
		P.holdTime=min(P.holdTime+1,P.gameEnv.holdCount)
	end
	P.spinLast=false
	P.spinSeq=0
	P.ctrlCount=0

	P.cur=rem(P.nextQueue,1)
	P:newNext()
	if P.cur then
		P.pieceCount=P.pieceCount+1
		if P.AI_mode=="CC"then
			local next=P.nextQueue[P.AIdata.next]
			if next then
				CC.addNext(P.AI_bot,next.id)
			end
		end

		local _=P.keyPressing

		--IHS
		if not ifhold and _[8]and P.gameEnv.ihs then
			P:hold(true)
			_[8]=false
		else
			P:resetBlock()
		end

		P.dropDelay=P.gameEnv.drop
		P.lockDelay=P.gameEnv.lock
		P.freshTime=P.gameEnv.freshLimit

		if P.cur then
			if P:ifoverlap(P.cur.bk,P.curX,P.curY)then
				P:lock()
				P:lose()
			end
			P:freshBlock(false,true,true)
		end

		--IHdS
		if _[6]then
			P.act_hardDrop(P)
			_[6]=false
		end
	else
		P:hold()
	end
end

function Player.cancel(P,N)--Cancel Garbage
	local k=0	--Pointer, attack bar selected
	local off=0	--Lines offseted
	local bf=P.atkBuffer
	::R::
	if bf.sum>0 then
		local A
		repeat
			k=k+1
			A=bf[k]
			if not A then return off end
		until not A.sent
		if N>=A.amount then
			local O=A.amount--Cur Offset
			N=N-O
			off=off+O
			bf.sum=bf.sum-O
			A.sent,A.time=true,0
			if N>0 then goto R end
		else
			off=off+N
			A.amount=A.amount-N
			bf.sum=bf.sum-N
		end
	end
	return off
end
do--Player.drop(P)--Place piece
	local clearSCR={80,200,400}--Techrash:1K; B2Bmul:1.3/1.8
	local spinSCR={
		{200,750,1300,2000},--Z
		{200,750,1300,2000},--S
		{220,700,1300,2000},--L
		{220,700,1300,2000},--J
		{250,800,1400,2000},--T
		{260,900,1600,4500,7000},--O
		{300,1200,1700,4000,6000},--I
		{220,800,2000,3000,8000,26000},--Else
	}--B2Bmul:1.2/2.0; Mini*=.6
	local b2bPoint={50,100,180,1000,1200,9999}

	local b2bATK={3,5,8,12,18}
	local reAtk={0,0,1,1,1,2,2,3,3}
	local reDef={0,1,1,2,3,3,4,4,5}

	local spinVoice={"zspin","sspin","jspin","lspin","tspin","ospin","ispin","zspin","sspin","pspin","qspin","fspin","espin","tspin","uspin","vspin","wspin","xspin","jspin","lspin","rspin","yspin","hspin","nspin","ispin"}
	local clearVoice={"single","double","triple","techrash","pentcrash","hexcrash"}
	local spinSFX={[0]="spin_0","spin_1","spin_2"}
	local clearSFX={"clear_1","clear_2","clear_3"}
	local renSFX={}for i=1,11 do renSFX[i]="ren_"..i end
	local finesseList={
		{
			{1,2,1,0,1,2,2,1},
			{2,2,2,1,1,2,3,2,2},
			1,2
		},--Z
		1,--S
		{
			{1,2,1,0,1,2,2,1},
			{2,2,3,2,1,2,3,3,2},
			{3,4,3,2,3,4,4,3},
			{2,3,2,1,2,3,3,2,2},
		},--J
		3,--L
		3,--T
		{
			{1,2,2,1,0,1,2,2,1},
			1,1,1
		},--O
		{
			{1,2,1,0,1,2,1},
			{2,2,2,2,1,1,2,2,2,2},
			1,2
		},--I
		{
			{1,2,1,0,1,2,2,1},
			{2,3,2,1,2,3,3,2},
			1,2
		},--Z5
		8,--S5
		3,--P
		3,--Q
		{
			{1,2,1,0,1,2,2,1},
			{2,3,2,1,2,3,3,2},
			{3,4,3,2,3,4,4,3},
			2
		},--F
		12,--E
		12,--T5
		3,--U
		{
			{1,2,1,0,1,2,2,1},
			{2,3,3,2,1,2,3,2},
			{3,4,4,3,2,3,4,3},
			{2,3,2,1,2,3,3,2},
		},--V
		12,--W
		{
			{1,2,1,0,1,2,2,1},
			1,1,1
		},--X
		{
			{1,2,1,0,1,2,1},
			{2,2,3,2,1,2,3,2,2},
			{3,4,3,2,3,4,3},
			2,
		},--J5
		19,--L5
		19,--R
		19,--Y
		19,--N
		19,--H
		{
			{1,1,0,1,2,1},
			{2,3,2,2,1,2,3,2,3,2},
			1,2
		},--I5
	}
	for k,v in next,finesseList do
		if type(v)=="table"then
			for d,l in next,v do
				if type(l)=="number"then
					v[d]=v[l]
				end
			end
		else
			finesseList[k]=finesseList[v]
		end
	end

	function Player.drop(P)
		local _
		local CHN=VOC.getFreeChannel()
		P.dropTime[11]=ins(P.dropTime,1,GAME.frame)--Update speed dial
		local ENV=P.gameEnv
		local STAT=P.stat
		local piece=P.lastPiece

		local finish
		local cmb=P.combo
		local CB,CX,CY=P.cur,P.curX,P.curY
		local clear--If clear with no line fall
		local cc,gbcc=0,0--Row/garbage-row cleared,full-part
		local atk,exblock=0,0--Attack & extra defense
		local send,off=0,0--Sending lines remain & offset
		local cscore,sendTime=10,0--Score & send Time
		local dospin,mini=0

		piece.id,piece.name=CB.id,CB.name
		P.waiting=ENV.wait

		--Tri-corner spin check
		if P.spinLast then
			if CB.id<6 then
				local x,y=CX+P.sc[2],CY+P.sc[1]
				local c=0
				if P:solid(x-1,y+1)then c=c+1 end
				if P:solid(x+1,y+1)then c=c+1 end
				if c==0 then goto NTC end
				if P:solid(x-1,y-1)then c=c+1 end
				if P:solid(x+1,y-1)then c=c+1 end
				if c>2 then dospin=dospin+2 end
			end
			::NTC::
		end
		--Immovable spin check
		if P:ifoverlap(CB.bk,CX,CY+1)and P:ifoverlap(CB.bk,CX-1,CY)and P:ifoverlap(CB.bk,CX+1,CY)then
			dospin=dospin+2
		end

		--Lock block to field
		P:lock()

		--Clear list of cleared-rows
		if P.clearedRow[1]then P.clearedRow={}end

		--Check line clear
		for i=1,P.r do
			local h=CY+i-2

			--Bomb trigger
			if h>0 and P.field[h]and P.clearedRow[cc]~=h then
				for x=1,P.c do
					if CB.bk[i][x]and P.field[h][CX+x-1]==19 then
						cc=cc+1
						P.clearingRow[cc]=h-cc+1
						P.clearedRow[cc]=h
						break
					end
				end
			end

			h=h+1
			--Row filled
			for x=1,10 do
				if P.field[h][x]<=0 then
					goto notFull
				end
			end
				cc=cc+1
				P.clearingRow[cc]=h-cc+1
				P.clearedRow[cc]=h
			::notFull::
		end

		--Create clearing FX
		if cc>0 and ENV.clearFX then
			local t=7-ENV.clearFX*1
			for i=1,cc do
				local y=P.clearedRow[i]
				P:createClearingFX(y,t)
				if ENV.splashFX then
					P:createSplashFX(y)
				end
			end
		end

		--Create locking FX
		if ENV.lockFX then
			if cc==0 then
				P:createLockFX()
			else
				_=#P.lockFX
				if _>0 then
					for _=1,_ do
						rem(P.lockFX)
					end
				end
			end
		end

		--Final spin check
		if dospin>0 then
			if cc>0 then
				dospin=dospin+(P.spinLast or 0)
				if dospin<3 then
					mini=CB.id<6 and cc<P.r
				end
			end
		else
			dospin=false
		end

		--Finesse: roof check
		local finesse
		if CY<=18 then
			local y0=CY
			local c=P.c
			local B=CB.bk
			for x=1,c do
				local y
				for i=#B,1,-1 do
					if B[i][x]then
						y=i
						goto L1
					end
				end
				goto L2
				::L1::
				if y then
					x=CX+x-1
					for y1=y0+y,#P.field do
						--Roof=finesse
						if P:solid(x,y1)then
							finesse=true
							goto L2
						end
					end
				end
			end
		else
			finesse=true
		end
		::L2::

		--Remove rows need to be cleared
		if cc>0 then
			for i=cc,1,-1 do
				_=P.clearedRow[i]
				if P.field[_][11]then
					P.garbageBeneath=P.garbageBeneath-1
					gbcc=gbcc+1
				end
				FREEROW.discard(rem(P.field,_))
				FREEROW.discard(rem(P.visTime,_))
			end
		end

		--Cancel no-sense clearing FX
		_=#P.clearingRow
		while _>0 and P.clearingRow[_]>#P.field do
			P.clearingRow[_]=nil
			_=_-1
		end
		if P.clearingRow[1]then
			P.falling=ENV.fall
		elseif cc==P.r then
			clear=true
		end

		--Finesse check (control)
		local finePts
		if not finesse then
			if dospin then P.ctrlCount=P.ctrlCount-2 end--Allow 2 more step for roof-less spin
			local id=CB.id
			local d=P.ctrlCount-finesseList[id][P.dir+1][CX]
			finePts=d<=0 and 5 or max(3-d,0)
		else
			finePts=5
		end
		piece.finePts=finePts

		STAT.finesseRate=STAT.finesseRate+finePts
		if finePts<5 then
			STAT.extraPiece=STAT.extraPiece+1
			if ENV.fineKill then
				finish=true
			end
			if P.sound then
				if ENV.fineKill then
					SFX.play("finesseError_long",.6)
				elseif ENV.fine then
					SFX.play("finesseError",.8)
				end
			end
		end
		if finePts<=1 then
			P.finesseCombo=0
		else
			P.finesseCombo=P.finesseCombo+1
			if P.finesseCombo>2 then
				P.finesseComboTime=12
			end
			if P.sound then SFX.fieldPlay("lock",nil,P)end
		end

		piece.spin,piece.mini=dospin,false
		piece.pc,piece.hpc=false,false
		piece.special=false
		if cc>0 then--If lines cleared, about 200 lines below
			cmb=cmb+1
			if dospin then
				cscore=(spinSCR[CB.name]or spinSCR[8])[cc]
				if P.b2b>1000 then
					P:showText(text.b3b..text.block[CB.name]..text.spin.." "..text.clear[cc],0,-30,35,"stretch")
					atk=b2bATK[cc]+cc*.5
					exblock=exblock+1
					cscore=cscore*2
					STAT.b3b=STAT.b3b+1
					if P.sound then
						VOC.play("b3b",CHN)
					end
				elseif P.b2b>=50 then
					P:showText(text.b2b..text.block[CB.name]..text.spin.." "..text.clear[cc],0,-30,35,"spin")
					atk=b2bATK[cc]
					cscore=cscore*1.2
					STAT.b2b=STAT.b2b+1
					if P.sound then
						VOC.play("b2b",CHN)
					end
				else
					P:showText(text.block[CB.name]..text.spin.." "..text.clear[cc],0,-30,45,"spin")
					atk=2*cc
				end
				sendTime=20+atk*20
				if mini then
					P:showText(text.mini,0,-80,35,"appear")
					atk=atk*.25
					sendTime=sendTime+60
					cscore=cscore*.5
					P.b2b=P.b2b+b2bPoint[cc]*.5
					if P.sound then
						VOC.play("mini",CHN)
					end
				else
					P.b2b=P.b2b+b2bPoint[cc]
				end
				piece.mini=mini
				piece.special=true
				if P.sound then
					SFX.play(spinSFX[cc]or"spin_3")
					VOC.play(spinVoice[CB.name],CHN)
				end
			elseif cc>=4 then
				cscore=cc==4 and 1000 or cc==5 and 1500 or 2000
				if P.b2b>1000 then
					P:showText(text.b3b..text.clear[cc],0,-30,50,"fly")
					atk=4*cc-10
					sendTime=100
					exblock=exblock+1
					cscore=cscore*1.8
					STAT.b3b=STAT.b3b+1
					if P.sound then
						VOC.play("b3b",CHN)
					end
				elseif P.b2b>=50 then
					P:showText(text.b2b..text.clear[cc],0,-30,50,"drive")
					sendTime=80
					atk=3*cc-7
					cscore=cscore*1.3
					STAT.b2b=STAT.b2b+1
					if P.sound then
						VOC.play("b2b",CHN)
					end
				else
					P:showText(text.clear[cc],0,-30,70,"stretch")
					sendTime=60
					atk=2*cc-4
				end
				P.b2b=P.b2b+cc*100-300
				piece.special=true
			else
				piece.special=false
			end
			if P.sound then
				VOC.play(clearVoice[cc],CHN)
			end

			--PC/HPC bonus
			if clear and #P.field==0 then
				P:showText(text.PC,0,-80,50,"flicker")
				atk=atk*.5+min(8+STAT.pc*2,20)
				exblock=exblock+2
				sendTime=sendTime+120
				if STAT.row+cc>4 then
					P.b2b=1200
					cscore=cscore+300*min(6+STAT.pc,10)
				else
					cscore=cscore+626
				end
				STAT.pc=STAT.pc+1
				if P.sound then
					SFX.play("clear")
					VOC.play("perfect_clear",CHN)
				end
				piece.pc=true
				piece.special=true
			elseif clear and(cc>1 or #P.field==P.garbageBeneath)then
				P:showText(text.HPC,0,-80,50,"fly")
				atk=atk+2
				exblock=exblock+2
				sendTime=sendTime+60
				cscore=cscore+626
				STAT.hpc=STAT.hpc+1
				if P.sound then
					SFX.play("clear")
					VOC.play("half_clear",CHN)
				end
				piece.hpc=true
				piece.special=true
			end

			--Normal clear, reduce B2B point
			if not piece.special then
				P.b2b=max(P.b2b-250,0)
				if P.b2b<50 and ENV.b2bKill then
					finish=true
				end
				P:showText(text.clear[cc],0,-30,35,"appear",(8-cc)*.3)
				atk=cc-.5
				sendTime=20+atk*20
				cscore=cscore+clearSCR[cc]
			end

			--Combo bonus
			sendTime=sendTime+25*cmb
			if cmb>1 then
				atk=atk*(1+(cc==1 and .15 or .25)*min(cmb-1,12))
				if cmb>=3 then
					atk=atk+1
				end
				P:showText(text.cmb[min(cmb,21)],0,25,15+min(cmb,15)*5,cmb<10 and"appear"or"flicker")
				cscore=cscore+min(50*cmb,500)*(2*cc-1)
			end

			if P.b2b>1200 then P.b2b=1200 end

			--Bonus atk/def when focused
			if GAME.modeEnv.royaleMode then
				local i=min(#P.atker,9)
				if i>1 then
					atk=atk+reAtk[i]
					exblock=exblock+reDef[i]
				end
			end

			--Send Lines
			send=atk
			if send>0 then
				if exblock>0 then
					exblock=int(exblock*(1+P.strength*.25))--Badge Buff
					P:showText("+"..exblock,0,53,20,"fly")
					off=off+P:cancel(exblock)
				end

				send=int(send*(1+P.strength*.25))--Badge Buff
				if send>0 then
					P:showText(send,0,80,35,"zoomout")
					_=P:cancel(send)
					send=send-_
					off=off+_
					if send>0 then
						local T
						if GAME.modeEnv.royaleMode then
							if P.atkMode==4 then
								local M=#P.atker
								if M>0 then
									for i=1,M do
										P:attack(P.atker[i],send,CB.color)
									end
								else
									T=randomTarget(P)
								end
							else
								P:freshTarget()
								T=P.atking
							end
						elseif #PLAYERS.alive>1 then
							T=randomTarget(P)
						end
						if T then
							P:attack(T,send,CB.color)
						end
					end
					if P.sound and send>3 then SFX.play("emit",min(send,7)*.1)end
				end
			end

			--SFX & Vibrate
			if P.sound then
				SFX.play(clearSFX[cc]or"clear_4")
				SFX.play(renSFX[min(cmb,11)])
				if cmb>14 then SFX.play("ren_mega",(cmb-10)*.1)end
				VIB(cc+1)
			end
		else--No lines clear
			cmb=0

			--Spin bonus
			if dospin then
				P:showText(text.block[CB.name]..text.spin,0,-30,45,"appear")
				P.b2b=P.b2b+20
				if P.sound then
					SFX.play("spin_0")
					VOC.play(spinVoice[CB.name],CHN)
				end
				cscore=30
			end

			if P.b2b>1000 then
				P.b2b=max(P.b2b-40,1000)
			end
			P:garbageRelease()
		end

		P.combo=cmb

		--DropSpeed bonus
		if P._20G then
			cscore=cscore*2
		elseif ENV.drop<1 then
			cscore=cscore*1.5
		elseif ENV.drop<3 then
			cscore=cscore*1.2
		end

		--Speed bonus
		if P.dropSpeed>60 then
			cscore=cscore*(.9+P.dropSpeed/600)
		end

		cscore=int(cscore)
		if ENV.score then
			P:showText(cscore,(P.curX+P.sc[2]-5.5)*30,(10-P.curY-P.sc[1])*30+P.fieldBeneath+P.fieldUp,int(8-120/(cscore+20))*5,"score",2)
		end

		piece.row,piece.dig=cc,gbcc
		piece.score=cscore
		piece.atk,piece.exblock=atk,exblock
		piece.off,piece.send=off,send

		--Check clearing task
		if cc>0 and P.curMission then
			local t=ENV.mission[P.curMission]
			local success
			if t<5 then
				if piece.row==t and not piece.spin then
					success=true
				end
			elseif t<9 then
				if piece.row==t-4 and piece.spin then
					success=true
				end
			elseif t==9 then
				if piece.pc then
					success=true
				end
			elseif t<90 then
				if piece.row==t%10 and piece.name==int(t/10)and piece.spin then
					success=true
				end
			end
			if success then
				P.curMission=P.curMission+1
				SFX.play("reach")
				if P.curMission>#ENV.mission then
					P.curMission=nil
					if not finish then finish="finish"end
				end
			elseif ENV.missionKill then
				P:showText(text.missionFailed,0,140,40,"flicker",.5)
				SFX.play("finesseError_long",.6)
				finish=true
			end
		end

		--Update stat
		STAT.score=STAT.score+cscore
		STAT.piece=STAT.piece+1
		STAT.row=STAT.row+cc
		STAT.maxFinesseCombo=max(STAT.maxFinesseCombo,P.finesseCombo)
		STAT.maxCombo=max(STAT.maxCombo,P.combo)
		if atk>0 then
			STAT.atk=STAT.atk+atk
			if send>0 then
				STAT.send=STAT.send+int(send)
			end
			if off>0 then
				STAT.off=STAT.off+off
			end
		end
		if gbcc>0 then
			STAT.dig=STAT.dig+gbcc
			STAT.digatk=STAT.digatk+atk*gbcc/cc
		end
		local n=CB.name
		if dospin then
			_=STAT.spin[n]	_[cc+1]=_[cc+1]+1--Spin[1~25][0~4]
			_=STAT.spins	_[cc+1]=_[cc+1]+1--Spin[0~4]
		elseif cc>0 then
			_=STAT.clear[n]	_[cc]=_[cc]+1--Clear[1~25][1~5]
			_=STAT.clears	_[cc]=_[cc]+1--Clear[1~5]
		end

		if finish then
			if finish==true then P:lose()end
			_=ENV.dropPiece if _ then _(P)end
			if finish then P:win(finish)end
		else
			_=ENV.dropPiece if _ then _(P)end
		end
	end
end
function Player.loadAI(P,data)--Load AI params
	P.AI_mode=data.type
	P.AI_stage=1
	P.AI_keys={}
	P.AI_delay=min(int(P.gameEnv.drop*.8),data.delta*rnd()*4)
	P.AI_delay0=data.delta
	P.AIdata={
		type=data.type,
		delay=data.delay,
		delta=data.delta,

		next=data.next,
		hold=data.hold,
		_20G=P._20G,
		bag=data.bag,
		node=data.node,
	}
	if not CC then
		P.AI_mode="9S"
		P.AI_delay0=int(P.AI_delay0*.3)
	end
	if P.AI_mode=="CC"then
		P:setRS("SRS")
		local opt,wei=CC.getConf()
			CC.fastWeights(wei)
			CC.setHold(opt,P.AIdata.hold)
			CC.set20G(opt,P.AIdata._20G)
			CC.setBag(opt,P.AIdata.bag=="bag")
			CC.setNode(opt,P.AIdata.node)
		P.AI_bot=CC.new(opt,wei)
		CC.free(opt)CC.free(wei)
		for i=1,P.AIdata.next do
			CC.addNext(P.AI_bot,P.nextQueue[i].id)
		end
		if P.gameEnv.holdCount and P.gameEnv.holdCount>1 then
			P:setHold(1)
		end
	else
		P:setRS("TRS")
	end
end
--------------------------</Methods>--------------------------

--------------------------<Events>--------------------------
local function gameOver()--Save record
	if GAME.replaying then return end
	FILE.save(STAT,"data")
	local M=GAME.curMode
	local R=M.getRank
	if R then
		local P=PLAYERS[1]
		R=R(P)--New rank
		if R then
			if R>0 then
				GAME.rank=R
			end
			if scoreValid()and M.score then
				local r=RANKS[M.name]--Old rank
				local needSave
				if R>r then
					RANKS[M.name]=R
					needSave=true
				end
				if R>0 then
					if M.unlock then
						for i=1,#M.unlock do
							local m=M.unlock[i]
							local n=MODES[m].name
							if not RANKS[n]then
								RANKS[n]=MODES[m].getRank and 0 or 6
								needSave=true
							end
						end
					end
				end
				if needSave then
					FILE.save(RANKS,"unlock")
				end
				local D=M.score(P)
				local L=M.records
				local p=#L--Rank-1
				if p>0 then
					while M.comp(D,L[p])do--If higher rank
						p=p-1
						if p==0 then break end
					end
				end
				if p<10 then
					if p==0 then
						P:showTextF(text.newRecord,0,-100,100,"beat",.5)
					end
					D.date=os.date("%Y/%m/%d %H:%M")
					ins(L,p+1,D)
					if L[11]then L[11]=nil end
					FILE.save(L,M.name,"",true)
				end
			end
		end
	end
end

function Player.die(P)--Called both when win/lose!
	P.alive=false
	P.timing=false
	P.control=false
	P.update=PLY.update.dead
	P.waiting=1e99
	P.b2b=0
	P.tasks={}
	for i=1,#P.atkBuffer do
		P.atkBuffer[i].sent=true
		P.atkBuffer[i].time=0
	end
	for i=1,#P.field do
		for j=1,10 do
			P.visTime[i][j]=min(P.visTime[i][j],20)
		end
	end
end
function Player.win(P,result)
	if P.result then return end
	P:die()
	P.result="WIN"
	if GAME.modeEnv.royaleMode then
		P.modeData.event=1
		P:changeAtk()
	end
	if P.human then
		GAME.result=result or"win"
		SFX.play("win")
		VOC.play("win")
		if GAME.modeEnv.royaleMode then
			BGM.play("8-bit happiness")
		end
	end
	if GAME.curMode.id=="custom_puzzle"then
		P:showTextF(text.win,0,0,90,"beat",.4)
	else
		P:showTextF(text.win,0,0,90,"beat",.5,.2)
	end
	if P.human then
		gameOver()
		TASK.new(TICK.autoPause)
		if MARKING then
			P:showTextF(text.marking,0,-226,25,"appear",.4,.0626)
		end
	end
	P:newTask(TICK.finish)
end
function Player.lose(P,force)
	if P.result then return end
	if P.life>0 and not force then
		P.waiting=62
		local h=#P.field
		for _=h,1,-1 do
			FREEROW.discard(P.field[_])
			FREEROW.discard(P.visTime[_])
			P.field[_],P.visTime[_]=nil
		end
		P.garbageBeneath=0

		if P.AI_mode=="CC"then
			CC.destroy(P.AI_bot)
			while P.holdQueue[1]do rem(P.holdQueue)end
			P:loadAI(P.AIdata)
		end

		P.life=P.life-1
		P.fieldBeneath=0
		P.b2b=0
		for i=1,#P.atkBuffer do
			local A=P.atkBuffer[i]
			if not A.sent then
				A.sent=true
				A.time=0
			end
		end
		P.atkBuffer.sum=0

		for i=1,h do
			P:createClearingFX(i,1.5)
		end
		SYSFX.newShade(1.4,1,1,1,P.fieldX,P.fieldY,300*P.size,610*P.size)
		SYSFX.newRectRipple(2,P.fieldX,P.fieldY,300*P.size,610*P.size)
		SYSFX.newRipple(2,P.x+(475+25*(P.life<3 and P.life or 0)+12)*P.size,P.y+(665+12)*P.size,20)
		--300+25*i,595
		SFX.play("clear_3")
		SFX.play("emit")

		return
	end
	P:die()
	for i=1,#PLAYERS.alive do
		if PLAYERS.alive[i]==P then
			rem(PLAYERS.alive,i)
			break
		end
	end
	P.result="K.O."
	if GAME.modeEnv.royaleMode then
		P:changeAtk()
		P.modeData.event=#PLAYERS.alive+1
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
				A.modeData.point,A.badge=A.modeData.point+1,A.badge+P.badge+1
				for j=A.strength+1,4 do
					if A.badge>=royaleData.powerUp[j]then
						A.strength=j
						A.frameColor=A.strength
					end
				end
				P.lastRecv=A
				if P.id==1 or A.id==1 then
					TASK.new(TICK.throwBadge,A.ai,P,max(3,P.badge)*4)
				end
			end
		else
			P.badge=-1
		end

		freshMostBadge()
		freshMostDangerous()
		if #PLAYERS.alive==royaleData.stage[GAME.stage]then
			royaleLevelup()
		end
		P:showTextF(P.modeData.event,0,120,60,"appear",.26,.9)
	end
	P.gameEnv.keepVisible=P.gameEnv.visible~="show"
	P:showTextF(text.gameover,0,0,60,"appear",.26,.9)
	if P.human then
		GAME.result="gameover"
		SFX.play("fail")
		VOC.play("lose")
		if GAME.modeEnv.royaleMode then
			if P.modeData.event==2 then
				BGM.play("hay what kind of feeling")
			else
				BGM.play("end")
			end
		end
		gameOver()
		P:newTask(#PLAYERS>1 and TICK.lose or TICK.finish)
		TASK.new(TICK.autoPause)
		if MARKING then
			P:showTextF(text.marking,0,-226,25,"appear",.4,.0626)
		end
	else
		P:newTask(TICK.lose)
	end
	if #PLAYERS.alive==1 then
		PLAYERS.alive[1]:win()
	end
end
--------------------------<\Events>--------------------------

--------------------------<Actions>--------------------------
function Player.act_moveLeft(P,auto)
	if not auto then
		P.ctrlCount=P.ctrlCount+1
	end
	P.movDir=-1
	if P.keyPressing[9]then
		if P.gameEnv.swap then
			P:changeAtkMode(1)
			P.keyPressing[1]=false
		end
	elseif P.control and P.waiting==-1 then
		if P.cur and not P:ifoverlap(P.cur.bk,P.curX-1,P.curY)then
			if P.gameEnv.moveFX and P.gameEnv.block then
				P:createMoveFX("left")
			end
			P.curX=P.curX-1
			P:freshBlock(false,true)
			if P.sound and P.curY==P.imgY then SFX.play("move")end
			if not auto then P.moving=0 end
			P.spinLast=false
		else
			P.moving=P.gameEnv.das
		end
	else
		P.moving=0
	end
end
function Player.act_moveRight(P,auto)
	if not auto then
		P.ctrlCount=P.ctrlCount+1
	end
	P.movDir=1
	if P.keyPressing[9]then
		if P.gameEnv.swap then
			P:changeAtkMode(2)
			P.keyPressing[2]=false
		end
	elseif P.control and P.waiting==-1 then
		if P.cur and not P:ifoverlap(P.cur.bk,P.curX+1,P.curY)then
			if P.gameEnv.moveFX and P.gameEnv.block then
				P:createMoveFX("right")
			end
			P.curX=P.curX+1
			P:freshBlock(false,true)
			if P.sound and P.curY==P.imgY then SFX.play("move")end
			if not auto then P.moving=0 end
			P.spinLast=false
		else
			P.moving=P.gameEnv.das
		end
	else
		P.moving=0
	end
end
function Player.act_rotRight(P)
	if P.control and P.waiting==-1 and P.cur then
		P.ctrlCount=P.ctrlCount+1
		P:spin(1)
		P.keyPressing[3]=false
	end
end
function Player.act_rotLeft(P)
	if P.control and P.waiting==-1 and P.cur then
		P.ctrlCount=P.ctrlCount+1
		P:spin(3)
		P.keyPressing[4]=false
	end
end
function Player.act_rot180(P)
	if P.control and P.waiting==-1 and P.cur then
		P.ctrlCount=P.ctrlCount+2
		P:spin(2)
		P.keyPressing[5]=false
	end
end
function Player.act_hardDrop(P)
	if P.keyPressing[9]then
		if P.gameEnv.swap then
			P:changeAtkMode(3)
		end
		P.keyPressing[6]=false
	elseif P.control and P.waiting==-1 and P.cur then
		if P.curY>P.imgY then
			if P.gameEnv.dropFX and P.gameEnv.block and P.curY-P.imgY-P.r>-1 then
				P:createDropFX(P.curX,P.curY-1,P.c,P.curY-P.imgY-P.r+1)
			end
			P.curY=P.imgY
			P.spinLast=false
			if P.gameEnv.shakeFX then
				P.fieldOff.vy=P.gameEnv.shakeFX*.6
			end
			if P.sound then
				SFX.fieldPlay("drop",nil,P)
				VIB(1)
			end
		end
		P.lockDelay=-1
		P:drop()
		P.keyPressing[6]=false
	end
end
function Player.act_softDrop(P)
	if P.keyPressing[9]then
		if P.gameEnv.swap then
			P:changeAtkMode(4)
		end
	else
		P.downing=1
		if P.control and P.waiting==-1 and P.cur then
			if P.curY>P.imgY then
				P.curY=P.curY-1
				P:freshBlock(true,true)
				P.spinLast=false
			end
		end
	end
end
function Player.act_hold(P)
	if P.control and P.waiting==-1 then
		P:hold()
	end
end
function Player.act_func(P)
	P.gameEnv.Fkey(P)
end
function Player.act_restart()
	if GAME.frame<240 or GAME.result then
		resetGameData()
	else
		LOG.print(text.holdR,20,COLOR.orange)
	end
end

function Player.act_insLeft(P,auto)
	if not P.cur then return end
	local x0=P.curX
	while not P:ifoverlap(P.cur.bk,P.curX-1,P.curY)do
		if P.gameEnv.moveFX and P.gameEnv.block then
			P:createMoveFX("left")
		end
		P.curX=P.curX-1
		P:freshBlock(false,true)
	end
	if P.curX~=x0 then
		P.spinLast=false
	end
	if P.gameEnv.shakeFX then
		P.fieldOff.vx=-P.gameEnv.shakeFX*.5
	end
	if auto then
		if P.ctrlCount==0 then P.ctrlCount=1 end
	else
		P.ctrlCount=P.ctrlCount+1
	end
end
function Player.act_insRight(P,auto)
	if not P.cur then return end
	local x0=P.curX
	while not P:ifoverlap(P.cur.bk,P.curX+1,P.curY)do
		if P.gameEnv.moveFX and P.gameEnv.block then
			P:createMoveFX("right")
		end
		P.curX=P.curX+1
		P:freshBlock(false,true)
	end
	if P.curX~=x0 then
		P.spinLast=false
	end
	if P.gameEnv.shakeFX then
		P.fieldOff.vx=P.gameEnv.shakeFX*.5
	end
	if auto then
		if P.ctrlCount==0 then P.ctrlCount=1 end
	else
		P.ctrlCount=P.ctrlCount+1
	end
end
function Player.act_insDown(P)
	if P.cur and P.curY>P.imgY then
		if P.gameEnv.dropFX and P.gameEnv.block and P.curY-P.imgY-P.r>-1 then
			P:createDropFX(P.curX,P.curY-1,P.c,P.curY-P.imgY-P.r+1)
		end
		if P.gameEnv.shakeFX then
			P.fieldOff.vy=P.gameEnv.shakeFX*.5
		end
		P.curY=P.imgY
		P.lockDelay=P.gameEnv.lock
		P.spinLast=false
		P:freshBlock(true,true)
	end
end
function Player.act_down1(P)
	if P.cur and P.curY>P.imgY then
		if P.gameEnv.moveFX and P.gameEnv.block then
			P:createMoveFX("down")
		end
		P.curY=P.curY-1
		P:freshBlock(true,true)
		P.spinLast=false
	end
end
function Player.act_down4(P)
	if P.cur and P.curY>P.imgY then
		local y=max(P.curY-4,P.imgY)
		if P.gameEnv.dropFX and P.gameEnv.block and P.curY-y-P.r>-1 then
			P:createDropFX(P.curX,P.curY-1,P.c,P.curY-y-P.r+1)
		end
		P.curY=y
		P:freshBlock(true,true)
		P.spinLast=false
	end
end
function Player.act_down10(P)
	if P.cur and P.curY>P.imgY then
		local y=max(P.curY-10,P.imgY)
		if P.gameEnv.dropFX and P.gameEnv.block and P.curY-y-P.r>-1 then
			P:createDropFX(P.curX,P.curY-1,P.c,P.curY-y-P.r+1)
		end
		P.curY=y
		P:freshBlock(true,true)
		P.spinLast=false
	end
end
function Player.act_dropLeft(P)
	if not P.cur then return end
	P:act_insLeft()
	P:act_hardDrop()
end
function Player.act_dropRight(P)
	if not P.cur then return end
	P:act_insRight()
	P:act_hardDrop()
end
function Player.act_zangiLeft(P)
	if not P.cur then return end
	P:act_insLeft()
	P:act_insDown()
	P:act_insRight()
	P:act_hardDrop()
end
function Player.act_zangiRight(P)
	if not P.cur then return end
	P:act_insRight()
	P:act_insDown()
	P:act_insLeft()
	P:act_hardDrop()
end
Player.actList={
	Player.act_moveLeft,	--1
	Player.act_moveRight,	--2
	Player.act_rotRight,	--3
	Player.act_rotLeft,		--4
	Player.act_rot180,		--5
	Player.act_hardDrop,	--6
	Player.act_softDrop,	--7
	Player.act_hold,		--8
	Player.act_func,		--9
	Player.act_restart,		--10
	Player.act_insLeft,		--11
	Player.act_insRight,	--12
	Player.act_insDown,		--13
	Player.act_down1,		--14
	Player.act_down4,		--15
	Player.act_down10,		--16
	Player.act_dropLeft,	--17
	Player.act_dropRight,	--18
	Player.act_zangiLeft,	--19
	Player.act_zangiRight,	--20
}
--------------------------</Actions>--------------------------
return Player