local gc=love.graphics
local mt=love.math
local Timer=love.timer.getTime
local int,ceil,rnd=math.floor,math.ceil,math.random
local max,min,abs,sin,cos,log=math.max,math.min,math.abs,math.sin,math.cos,math.log
local ins,rem=table.insert,table.remove
local format=string.format
local scr=scr
local setFont=setFont

--------------------------<Data>--------------------------
local gameEnv0={
	das=10,arr=2,sddas=2,sdarr=2,
	ihs=true,irs=true,ims=true,
	swap=true,

	ghost=.3,center=1,
	smooth=false,grid=false,
	bagLine=false,
	text=true,
	score=true,
	lockFX=2,
	dropFX=2,
	moveFX=2,
	clearFX=2,
	shakeFX=3,

	highCam=false,
	nextPos=false,

	drop=60,lock=60,
	wait=0,fall=0,
	_20G=false,bone=false,
	next=6,
	hold=true,oncehold=true,
	ospin=true,
	sequence="bag",
	freshMethod=NULL,
	bag={1,2,3,4,5,6,7},
	mission=NULL,
	face=NULL,skin=NULL,

	life=0,
	pushSpeed=3,
	block=true,
	noTele=false,
	visible="show",
	freshLimit=1e99,easyFresh=true,

	Fkey=NULL,
	fine=false,fineKill=false,
	missionKill=false,
	target=1e99,dropPiece=NULL,
	mindas=0,minarr=0,minsdarr=0,

	bg="none",bgm="race"
}
local scs=spinCenters
local kickList=require("parts/kickList")
local CCblockID={6,5,4,3,2,1,0}
local freshPrepare={
	none=NULL,
	bag=function(P)
		local bag=P.gameEnv.bag
		local L
		repeat
			L={}for i=1,#bag do L[i]=i end
			repeat P:getNext(bag[rem(L,P:RND(#L))])until not L[1]
		until #P.next>5
	end,
	his4=function(P)
		local bag=P.gameEnv.bag
		local L=#bag
		P.his={bag[P:RND(L)],bag[P:RND(L)],bag[P:RND(L)],bag[P:RND(L)]}
		for _=1,6 do
			local i
			local j=0
			repeat
				i=bag[P:RND(L)]
				j=j+1
			until i~=P.his[1]and i~=P.his[2]and i~=P.his[3]and i~=P.his[4]or j==6
			P:getNext(i)
			rem(P.his,1)P.his[4]=i
		end
	end,
	rnd=function(P)
		local bag=P.gameEnv.bag
		local L=#bag
		P:getNext(bag[P:RND(L)])
		for i=1,5 do
			local count=0
			local i
			repeat
				i=bag[P:RND(L)]
				count=count+1
			until i~=P.next[#P.next].id or count>=L
			P:getNext(i)
		end
	end,
	loop=function(P)
		local bag=P.gameEnv.bag
		repeat
			for i=1,#bag do
				P:getNext(bag[i])
			end
		until #P.next>5
	end,
	fixed=function(P)
		local bag=P.gameEnv.bag
		for i=1,#bag do
			P:getNext(bag[i])
		end
	end,
}
local freshMethod={
	none=NULL,
	bag=function(P)
		if #P.next<6 then
			local bag0,bag=P.gameEnv.bag,{}
			for i=1,#bag0 do bag[i]=bag0[i]end
			repeat P:getNext(rem(bag,P:RND(#bag)))until not bag[1]
		end
	end,
	his4=function(P)
		if #P.next<6 then
			local bag=P.gameEnv.bag
			local L=#bag
			for n=1,4 do
				local j,i=0
				repeat
					i=bag[P:RND(L)]
					j=j+1
				until i~=P.his[1]and i~=P.his[2]and i~=P.his[3]and i~=P.his[4]or j==4
				P:getNext(i)
				P.his[n]=i
			end
		end
	end,
	rnd=function(P)
		if #P.next<6 then
			local bag=P.gameEnv.bag
			local L=#bag
			for i=1,4 do
				local count=0
				local i
				repeat
					i=bag[P:RND(L)]
					count=count+1
				until i~=P.next[#P.next].id or count>=L
				P:getNext(i)
			end
		end
	end,
	loop=function(P)
		local bag=P.gameEnv.bag
		for i=1,#bag do
			P:getNext(bag[i])
		end
	end,
	fixed=function(P)
		if P.cur or P.hd then return end
		P:lose()
	end,
}
--------------------------</Data>--------------------------

--------------------------<LIB>--------------------------
local player={}--Player object
local PLY={}--Lib
--------------------------</LIB>--------------------------

--------------------------<Update>--------------------------
local function updateLine(P,dt)
	local bf=P.atkBuffer
	for i=#bf,1,-1 do
		local A=bf[i]
		A.time=A.time+1
		if not A.sent then
			if A.countdown>0 then
				A.countdown=max(A.countdown-game.garbageSpeed,0)
			end
		else
			if A.time>20 then
				rem(bf,i)
			end
		end
	end

	local y=P.fieldBeneath
	if y>0 then
		P.fieldBeneath=max(y-P.gameEnv.pushSpeed,0)
	end

	if P.gameEnv.highCam then
		local f=P.fieldUp
		if not P.alive then
			y=0
		else
			y=30*max(min(#P.field-19.5-P.fieldBeneath/30,P.imgY-17),0)
		end
		if f~=y then
			P.fieldUp=f>y and max(f*.95+y*.05-2,y)or ceil(f*.97+y*.03+1,y)
		end
	end
end
local function updateFXs(P,dt)
	if P.stat.score>P.score1 then
		if P.stat.score-P.score1<10 then
			P.score1=P.score1+1
		else
			P.score1=int(min(P.score1*.9+P.stat.score*.1+1))
		end
	end

	--LockFX
	for i=#P.lockFX,1,-1 do
		local S=P.lockFX[i]
		S[3]=S[3]+S[4]*dt
		if S[3]>1 then
			rem(P.lockFX,i)
		end
	end

	--DropFX
	for i=#P.dropFX,1,-1 do
		local S=P.dropFX[i]
		S[5]=S[5]+S[6]*dt
		if S[5]>1 then
			rem(P.dropFX,i)
		end
	end

	--MoveFX
	for i=#P.moveFX,1,-1 do
		local S=P.moveFX[i]
		S[4]=S[4]+S[5]*dt
		if S[4]>1 then
			rem(P.moveFX,i)
		end
	end

	--ClearFX
	for i=#P.clearFX,1,-1 do
		local S=P.clearFX[i]
		S[2]=S[2]+S[3]*dt
		if S[2]>1 then
			rem(P.clearFX,i)
		end
	end

	--Field shaking
	if P.gameEnv.shakeFX then
		local O=P.fieldOff
		O.vx,O.vy=O.vx*.8-abs(O.x)^1.2*(O.x>0 and .1 or -.1),O.vy*.8-abs(O.y)^1.2*(O.y>0 and .1 or -.1)
		O.x,O.y=O.x+O.vx,O.y+O.vy
		if abs(O.x)<.3 then O.x=0 end
		if abs(O.y)<.3 then O.y=0 end
	end

	if P.bonus then
		TEXT.update(P.bonus)
	end
end
local function updateTasks(P)
	local L=P.tasks
	for i=#L,1,-1 do
		if L[i].code(P,L[i].data)then rem(L,i)end
	end
end
local function Pupdate_alive(P,dt)
	if P.timing then P.stat.time=P.stat.time+dt end
	if P.keyRec then
		local _=game.frame
		local v=0
		for i=2,10 do v=v+i*(i-1)*7.2/(_-P.keyTime[i])end
		P.keySpeed=P.keySpeed*.99+v*.1
		v=0
		for i=2,10 do v=v+i*(i-1)*7.2/(_-P.dropTime[i])end
		P.dropSpeed=P.dropSpeed*.99+v*.1
		--Update speeds
		if modeEnv.royaleMode then
			if P.keyPressing[9]then
				P.swappingAtkMode=min(P.swappingAtkMode+2,30)
			else
				P.swappingAtkMode=P.swappingAtkMode+((#P.field>15 and P.swappingAtkMode>4 or P.swappingAtkMode>8)and -1 or 1)
			end
		end
	end

	if not P.human and P.control and P.waiting==-1 then
		local C=P.AI_keys
		P.AI_delay=P.AI_delay-1
		if not C[1]then
			P.AI_stage=AIfunc[P.AI_mode][P.AI_stage](P,C)
		elseif P.AI_delay<=0 then
			P:pressKey(C[1])P:releaseKey(C[1])
			rem(C,1)
			P.AI_delay=P.AI_delay0*2
		end
	end

	--Fresh visible time
	if not P.keepVisible then
		for j=1,#P.field do for i=1,10 do
			if P.visTime[j][i]>0 then P.visTime[j][i]=P.visTime[j][i]-1 end
		end end
	end

	--Moving pressed
	if P.movDir~=0 then
		local das,arr=P.gameEnv.das,P.gameEnv.arr
		local mov=P.moving
		if P.waiting==-1 then
			if P.movDir==1 then
				if P.keyPressing[2]then
					if arr>0 then
						if mov==das+arr or mov==das then
							if not P.cur or P:ifoverlap(P.cur.bk,P.curX+1,P.curY)then
								mov=das+arr-1
							else
								P.act.moveRight(P,true)
								mov=das
							end
						end
						mov=mov+1
					else
						if mov==das then
							P.act.insRight(P,true)
						else
							mov=mov+1
						end
					end
					if mov>=das and P.gameEnv.shakeFX and P.cur and P:ifoverlap(P.cur.bk,P.curX+1,P.curY)then
						P.fieldOff.vx=P.gameEnv.shakeFX*.5
					end
				else
					P.movDir=0
				end
			else
				if P.keyPressing[1]then
					if arr>0 then
						if mov==das+arr or mov==das then
							if not P.cur or P:ifoverlap(P.cur.bk,P.curX-1,P.curY)then
								mov=das+arr-1
							else
								P.act.moveLeft(P,true)
								mov=das
							end
						end
						mov=mov+1
					else
						if mov==das then
							P.act.insLeft(P,true)
						else
							mov=mov+1
						end
					end
					if mov>=das and P.gameEnv.shakeFX and P.cur and P:ifoverlap(P.cur.bk,P.curX-1,P.curY)then
						P.fieldOff.vx=-P.gameEnv.shakeFX*.5
					end
				else
					P.movDir=0
				end
			end
		elseif mov<das then
			mov=mov+1
		end
		P.moving=mov
	end

	--Drop pressed
	if P.keyPressing[7]and not P.keyPressing[9]then
		local d=P.downing-P.gameEnv.sddas
		P.downing=P.downing+1
		if d>1 then
			if P.gameEnv.sdarr>0 then
				if d%P.gameEnv.sdarr==0 then
					P.act.down1(P)
				end
			else
				P.act.insDown(P)
			end
			if P.gameEnv.shakeFX then
				P.fieldOff.vy=P.gameEnv.shakeFX*.3
			end
		end
	else
		P.downing=0
	end

	--Falling animation
	if P.falling>=0 then
		P.falling=P.falling-1
		if P.falling>=0 then
			goto stop
		else
			local L=#P.clearingRow
			if P.human and P.gameEnv.fall>0 and #P.field+L>P.clearingRow[L]then SFX.play("fall")end
			P.clearingRow={}
		end
	end

	--Try spawn new block
	if not P.control then goto stop end
	if P.waiting>=0 then
		P.waiting=P.waiting-1
		if P.waiting<0 then P:popNext()end
		goto stop
	end

	--Natural block falling
	if P.cur then
		if P.curY>P.imgY then
			local D=P.dropDelay
			if D>1 then
				P.dropDelay=D-1
				goto stop
			end

			if D==1 then
				if P.gameEnv.moveFX and P.gameEnv.block then
					P:createMoveFX("down")
				end
				P.curY=P.curY-1
			else
				D=1/D--Fall dist
				if D>P.curY-P.imgY then D=P.curY-P.imgY end
				if P.gameEnv.moveFX and P.gameEnv.block then
					for i=1,D do
						P:createMoveFX("down")
						P.curY=P.curY-1
					end
				else
					P.curY=P.curY-D
				end
				-- assert(P.curY==int(P.curY),"y:"..P.curY.." fall:"..D.." D_env:"..P.gameEnv.drop)
			end
			P:freshBlock(true,true)
			P.spinLast=false

			if P.imgY~=P.curY then
				P.dropDelay=P.gameEnv.drop
			elseif P.AI_mode=="CC"then
				CC_updateField(P)
				if not P.AIdata._20G and P.gameEnv.drop<P.AI_delay0*.5 then
					CC_switch20G(P)
				end
			end
		else
			P.lockDelay=P.lockDelay-1
			if P.lockDelay>=0 then goto stop end
			P:drop()
			if P.AI_mode=="CC"then
				CC_updateField(P)
			end
		end
	end
	::stop::
	if P.b2b1==P.b2b then
	elseif P.b2b1<P.b2b then
		P.b2b1=min(P.b2b1*.98+P.b2b*.02+.4,P.b2b)
	else
		P.b2b1=max(P.b2b1*.95+P.b2b*.05-.6,P.b2b)
	end
	updateLine(P,dt)
	updateFXs(P,dt)
	updateTasks(P)
end
local function Pupdate_dead(P,dt)
	if P.timing then P.stat.time=P.stat.time+dt end
	if P.keyRec then
		P.keySpeed=P.keySpeed*.96+P.stat.key/P.stat.time*60*.04
		P.dropSpeed=P.dropSpeed*.96+P.stat.piece/P.stat.time*60*.04
		--Final average speeds
		if modeEnv.royaleMode then
			P.swappingAtkMode=min(P.swappingAtkMode+2,30)
		end
	end
	if P.falling>=0 then
		P.falling=P.falling-1
		if P.falling<0 then
			local L=#P.clearingRow
			if P.human and P.gameEnv.fall>0 and #P.field+L>P.clearingRow[L]then SFX.play("fall")end
			P.clearingRow={}
		end
	end
	if P.b2b1>0 then P.b2b1=max(0,P.b2b1*.92-1)end
	updateLine(P,dt)
	updateFXs(P,dt)
	updateTasks(P)
end
--------------------------</Update>--------------------------

--------------------------<Paint>--------------------------
local frameColor={
	[0]=color.white,
	color.lGreen,
	color.lBlue,
	color.lPurple,
	color.lOrange,
}
local function drawCell(y,x,id)
	gc.draw(blockSkin[id],30*x-30,-30*y)
end
local function drawGrid(P)
	local FBN,FUP=P.fieldBeneath,P.fieldUp
	gc.setLineWidth(1)
	gc.setColor(1,1,1,.2)
	for x=1,9 do
		gc.line(30*x,-10,30*x,600)
	end
	for y=0,19 do
		y=30*(y-int((FBN+FUP)/30))+FBN+FUP
		gc.line(0,y,300,y)
	end
end
local function drawField(P)
	local V,F=P.visTime,P.field
	local start=int((P.fieldBeneath+P.fieldUp)/30+1)
	local rep=game.replaying
	if P.falling==-1 then--Blocks only
		for j=start,min(start+21,#F)do
			for i=1,10 do
				if F[j][i]>0 then
					if V[j][i]>0 then
						gc.setColor(1,1,1,min(V[j][i]*.05,1))
						drawCell(j,i,F[j][i])
					elseif rep then
						gc.setColor(1,1,1,.3+.08*sin(.5*(j-i)+Timer()*4))
						gc.rectangle("fill",30*i-30,-30*j,30,30)
					end
				end
			end
		end
	else--With falling animation
		local ENV=P.gameEnv
		local dy,stepY=0,ENV.smooth and(P.falling/(ENV.fall+1))^2.5*30 or 30
		local A=P.falling/ENV.fall
		local h=1
		for j=start,min(start+21,#F)do
			while j==P.clearingRow[h]do
				h=h+1
				dy=dy+stepY
				gc.translate(0,-stepY)
				gc.setColor(1,1,1,A)
				gc.rectangle("fill",0,30-30*j,300,stepY)
			end
			for i=1,10 do
				if F[j][i]>0 then
					if V[j][i]>0 then
						gc.setColor(1,1,1,min(V[j][i]*.05,1))
						drawCell(j,i,F[j][i])
					elseif rep then
						gc.setColor(1,1,1,.2)
						gc.rectangle("fill",30*i-30,-30*j,30,30)
					end
				end
			end
		end
		gc.translate(0,dy)
	end
end
local function drawFXs(P)
	--LockFX
	for i=1,#P.lockFX do
		local S=P.lockFX[i]
		if S[3]<.5 then
			gc.setColor(1,1,1,2*S[3])
			gc.rectangle("fill",S[1],S[2],60*S[3],30)
		else
			gc.setColor(1,1,1,2-2*S[3])
			gc.rectangle("fill",S[1]+30,S[2],60*S[3]-60,30)
		end
	end

	--DropFX
	for i=1,#P.dropFX do
		local S=P.dropFX[i]
		gc.setColor(1,1,1,.6-S[5]*.6)
		local w=30*S[3]*(1-S[5]*.5)
		gc.rectangle("fill",30*S[1]-30+15*S[3]-w*.5,-30*S[2],w,30*S[4])
	end

	--MoveFX
	for i=1,#P.moveFX do
		local S=P.moveFX[i]
		gc.setColor(1,1,1,.6-S[4]*.6)
		drawCell(S[3],S[2],S[1])
	end

	--ClearFX
	for i=1,#P.clearFX do
		local S=P.clearFX[i]
		local t=S[2]
		local x=t<.3 and 1-(3.3333*t-1)^2 or 1
		local y=t<.2 and 5*t or 1-1.25*(t-.2)
		gc.setColor(1,1,1,y)
		gc.rectangle("fill",150-x*150,15-S[1]*30-y*15,300*x,y*30)
	end
end
local function drawGhost(P,clr)
	gc.setColor(1,1,1,P.gameEnv.ghost)
	for i=1,P.r do for j=1,P.c do
		if P.cur.bk[i][j]then
			drawCell(i+P.imgY-1,j+P.curX-1,clr)
		end
	end end
end
local function drawBlockOutline(P,clr,trans)
	SHADER.alpha:send("a",trans)
	gc.setShader(SHADER.alpha)
	local _=blockSkin[clr]
	for i=1,P.r do for j=1,P.c do
		if P.cur.bk[i][j]then
			local x=30*(j+P.curX)-60-3
			local y=30-30*(i+P.curY)-3
			gc.draw(_,x,y)gc.draw(_,x+6,y+6)
			gc.draw(_,x+6,y)gc.draw(_,x,y+6)
		end
	end end
	gc.setShader()
end
local function drawBlock(P,clr)
	gc.setColor(1,1,1)
	for i=1,P.r do for j=1,P.c do
		if P.cur.bk[i][j]then
			drawCell(i+P.curY-1,j+P.curX-1,clr)
		end
	end end
end
local function drawNextPreview(P,B)
	gc.setColor(1,1,1,.8)
	local x=int(6-#B[1]*.5)
	local y=21+ceil(P.fieldBeneath/30)
	for i=1,#B do for j=1,#B[1]do
		if B[i][j]then
			gc.draw(puzzleMark[-1],30*(x+j-2),30*(1-y-i))
		end
	end end
end
local function drawHold(P,clr)
	if P.holded then gc.setColor(.6,.4,.4)end
	local B=P.hd.bk
	for i=1,#B do for j=1,#B[1]do
		if B[i][j]then
			drawCell(i+1.36-#B*.5,j+2.06-#B[1]*.5,clr)
		end
	end end
end

local Pdraw_norm
do--function Pdraw_norm(P)
	local attackColor={
		{color.dGrey,color.white},
		{color.grey,color.white},
		{color.lPurple,color.white},
		{color.lRed,color.white},
		{color.dGreen,color.cyan},
	}
	local RCPB={10,33,200,33,105,5,105,60}
	local function drawDial(x,y,speed)
		gc.setColor(1,1,1)
		mStr(int(speed),x,y-18)

		gc.setLineWidth(4)
		gc.setColor(1,1,1,.4)
		gc.circle("line",x,y,30,10)

		gc.setLineWidth(2)
		gc.setColor(1,1,1,.6)
		gc.circle("line",x,y,30,10)

		gc.setColor(1,1,1,.8)
		gc.draw(IMG.dialNeedle,x,y,2.094+(speed<=175 and .02094*speed or 4.712-52.36/(speed-125)),nil,nil,5,4)
	end
	function Pdraw_norm(P)
		local _
		local ENV=P.gameEnv
		local FBN,FUP=P.fieldBeneath,P.fieldUp
		gc.push("transform")
			gc.translate(P.x,P.y)gc.scale(P.size)

			--Field-related things
			gc.push("transform")
				gc.translate(150,70)

				--Things shake with field
				gc.push("transform")
					gc.translate(P.fieldOff.x,P.fieldOff.y)

					--Fill field
					gc.setColor(0,0,0,.6)
					gc.rectangle("fill",0,-10,300,610)

					--Draw grid
					if ENV.grid then drawGrid(P)end

					--In-field things
					gc.push("transform")
						gc.translate(0,600+FBN+FUP)
						gc.setScissor(scr.x+(P.absFieldX+P.fieldOff.x)*scr.k,scr.y+(P.absFieldY+P.fieldOff.y)*scr.k,300*P.size*scr.k,610*P.size*scr.k)

						--Draw dangerous area
						gc.setColor(1,0,0,.3)
						gc.rectangle("fill",0,-600,300,-610-FUP-FBN)

						--Draw field
						drawField(P)

						--Draw spawn line
						gc.setColor(1,sin(Timer())*.4+.5,0,.5)
						gc.setLineWidth(4)
						gc.line(0,-600-FBN,300,-600-FBN)

						--Draw FXs
						drawFXs(P)

						--Draw current block
						if P.cur and P.waiting==-1 then
							local curColor=P.cur.color

							--Draw ghost
							if ENV.ghost then drawGhost(P,curColor)end

							local dy=ENV.smooth and P.imgY~=P.curY and(P.dropDelay/ENV.drop-1)*30 or 0
							gc.translate(0,-dy)
							local trans=P.lockDelay/ENV.lock

							--Draw block
							if ENV.block then
								drawBlockOutline(P,curColor,trans)
								drawBlock(P,curColor)
							end

							--Draw rotate center
							local x=30*(P.curX+P.sc[2])-15
							if ENV.center and ENV.block then
								gc.setColor(1,1,1,ENV.center)
								gc.draw(IMG.spinCenter,x,-30*(P.curY+P.sc[1])+15,nil,nil,nil,4,4)
							end
							gc.translate(0,dy)
							if ENV.center and ENV.ghost then
								gc.setColor(1,1,1,trans*ENV.center)
								gc.draw(IMG.spinCenter,x,-30*(P.imgY+P.sc[1])+15,nil,nil,nil,4,4)
							end
						end

						--Draw next preview
						if ENV.nextPos and P.next[1]then
							drawNextPreview(P,P.next[1].bk)
						end

						gc.setScissor()
					gc.pop()

					gc.setLineWidth(2)
					gc.setColor(P.frameColor)
					gc.rectangle("line",-1,-11,302,612)--Boarder
					gc.rectangle("line",301,-3,15,604)--AtkBuffer boarder
					gc.rectangle("line",-16,-3,15,604)--B2b bar boarder

					--Buffer line
					local h=0
					for i=1,#P.atkBuffer do
						local A=P.atkBuffer[i]
						local bar=A.amount*30
						if h+bar>600 then bar=600-h end
						if not A.sent then
							--Appear
							if A.time<20 then
								bar=bar*(20*A.time)^.5*.05
							end
							if A.countdown>0 then
								--Timing
								gc.setColor(attackColor[A.lv][1])
								gc.rectangle("fill",303,599-h,11,-bar)
								gc.setColor(attackColor[A.lv][2])
								gc.rectangle("fill",303,599-h-bar,11,bar*(1-A.countdown/A.cd0))
							else
								--Warning
								local t=math.sin((Timer()-i)*30)*.5+.5
								local c1,c2=attackColor[A.lv][1],attackColor[A.lv][2]
								gc.setColor(c1[1]*t+c2[1]*(1-t),c1[2]*t+c2[2]*(1-t),c1[3]*t+c2[3]*(1-t))
								gc.rectangle("fill",303,599-h,11,-bar)
							end
						else
							gc.setColor(attackColor[A.lv][1])
							bar=bar*(20-A.time)*.05
							gc.rectangle("fill",303,599-h,11,-bar)
							--Disappear
						end
						h=h+bar
					end

					--B2B indictator
					local a,b=P.b2b,P.b2b1 if a>b then a,b=b,a end
					gc.setColor(.8,1,.2)
					gc.rectangle("fill",-14,599,11,-b*.5)
					gc.setColor(P.b2b<40 and color.white or P.b2b<=1e3 and color.lRed or color.lBlue)
					gc.rectangle("fill",-14,599,11,-a*.5)
					gc.setColor(1,1,1)
					if Timer()%.5<.3 then
						gc.rectangle("fill",-15,b<40 and 578.5 or 98.5,13,3)
					end

					--LockDelay indicator
					if ENV.easyFresh then
						gc.setColor(1,1,1)
					else
						gc.setColor(1,.26,.26)
					end
					if P.lockDelay>=0 then
						gc.rectangle("fill",0,602,300*P.lockDelay/ENV.lock,6)--Lock delay indicator
					end
					_=3
					for i=1,min(ENV.freshLimit-P.freshTime,15)do
						gc.rectangle("fill",_,615,14,5)
						_=_+20
					end

					--Draw Hold
					if ENV.hold then
						gc.push("transform")
						gc.translate(-140,116)
							gc.setColor(0,0,0,.4)gc.rectangle("fill",0,-80,124,80)
							gc.setColor(1,1,1)gc.rectangle("line",0,-80,124,80)
							mText(drawableText.hold,62,-131)
							if P.hd then
								drawHold(P,P.hd.color)
							end
						gc.pop()
					end

					--Draw Next(s)
					local N=ENV.next*72
					if ENV.next>0 then
						gc.setColor(0,0,0,.4)gc.rectangle("fill",316,36,124,N)
						gc.setColor(1,1,1)gc.rectangle("line",316,36,124,N)
						mText(drawableText.next,378,-15)
						N=1
						while N<=ENV.next and P.next[N]do
							local b,c=P.next[N].bk,P.next[N].color
							for i=1,#b do for j=1,#b[1] do
								if b[i][j]then
									drawCell(i-2.4*N-#b*.5,j+12.6-#b[1]*.5,c)
								end
							end end
							N=N+1
						end
					end

					--Draw Bagline(s)
					if ENV.bagLine then
						local L=ENV.bagLen
						local C=-P.pieceCount%L--Phase
						gc.setColor(.8,.5,.5)
						for i=C,N-1,L do
							local y=72*i+36
							gc.line(318+P.fieldOff.x,y,438,y)
						end
					end

					--Draw target selecting pad
					if modeEnv.royaleMode then
						if P.atkMode then
							gc.setColor(1,.8,0,P.swappingAtkMode*.02)
							gc.rectangle("fill",RCPB[2*P.atkMode-1],RCPB[2*P.atkMode],90,35,8,4)
						end
						gc.setColor(1,1,1,P.swappingAtkMode*.025)
						setFont(18)
						for i=1,4 do
							gc.rectangle("line",RCPB[2*i-1],RCPB[2*i],90,35,8,4)
							mStr(text.atkModeName[i],RCPB[2*i-1]+45,RCPB[2*i]+3)
						end
					end
				gc.pop()

				--Bonus texts
				TEXT.draw(P.bonus)
			gc.pop()

			--Speed dials
			setFont(25)
			drawDial(510,580,P.dropSpeed)
			drawDial(555,635,P.keySpeed)
			gc.setColor(1,1,1)
			gc.draw(drawableText.bpm,540,550)
			gc.draw(drawableText.kpm,494,643)
			if P.life>0 then
				if P.life<=3 then
					for i=1,P.life do
						gc.draw(IMG.lifeIcon,450+25*i,665,nil,.8)
					end
				else
					gc.draw(IMG.lifeIcon,475,665,nil,.8)
					setFont(20)
					gc.print("x",503,665)
					gc.print(P.life,517,665)
				end
			end
			mStr(format("%.2f",P.stat.time),69,588)--Time
			mStr(P.score1,69,630)--Score

			--Display Ys
			-- gc.setLineWidth(6)
			-- if P.curY then gc.setColor(1,.4,0,.626)gc.line(0,611-P.curY*30,300,611-P.curY*30)end
			-- if P.imgY then gc.setColor(0,1,.4,.626)gc.line(0,615-P.imgY*30,300,615-P.imgY*30)end
			-- if P.minY then gc.setColor(0,.4,1,.626)gc.line(0,619-P.minY*30,300,619-P.minY*30)end

			--Other messages
			gc.setColor(1,1,1)
			if curMode.mesDisp then
				curMode.mesDisp(P)
			end

			--Missions
			if P.curMission then
				local missionEnum=missionEnum
				local L=ENV.mission

				--Draw current mission
				setFont(35)
				if ENV.missionKill then
					gc.setColor(1,.7+.2*sin(Timer()*3),.4)
				else
					gc.setColor(1,1,1)
				end
				gc.print(missionEnum[L[P.curMission]],85,180)

				--Draw next mission
				gc.setColor(1,1,1)
				setFont(17)
				for i=1,3 do
					local t=L[P.curMission+i]
					if t then
						t=missionEnum[t]
						gc.print(t,87-26*i,187)
					else
						break
					end
				end
			end

			--Draw starting counter
			gc.setColor(1,1,1)
			if game.frame<180 then
				local count=179-game.frame
				gc.push("transform")
					gc.translate(305,290)
					setFont(95)
					if count%60>45 then gc.scale(1+(count%60-45)^2*.01,1)end
					mStr(int(count/60+1),0,0)
				gc.pop()
			end
		gc.pop()
	end
end
local function Pdraw_small(P)
	--Draw content
	P.frameWait=P.frameWait-1
	if P.frameWait==0 then
		P.frameWait=10
		gc.setCanvas(P.canvas)
		gc.clear(0,0,0,.4)
		gc.push("transform")
		gc.origin()
		gc.setColor(1,1,1,P.result and max(20-P.endCounter,0)*.05 or 1)

		--Field
		local F=P.field
		for j=1,#F do
			for i=1,10 do if F[j][i]>0 then
				gc.draw(blockSkinMini[F[j][i]],6*i-6,120-6*j)
			end end
		end

		--Draw boarder
		if P.alive then
			gc.setLineWidth(2)
			gc.setColor(P.frameColor)
			gc.rectangle("line",0,0,60,120)
		end

		--Draw badge
		if modeEnv.royaleMode then
			gc.setColor(1,1,1)
			for i=1,P.strength do
				gc.draw(IMG.badgeIcon,12*i-7,4,nil,.5)
			end
		end

		--Draw result
		if P.result then
			gc.setColor(1,1,1,min(P.endCounter,60)*.01)
			setFont(17)mStr(P.result,32,47)
			setFont(15)mStr(P.modeData.event,30,82)
		end
		gc.pop()
		gc.setCanvas()
	end

	--Draw Canvas
	gc.setColor(1,1,1)
	gc.draw(P.canvas,P.x,P.y,nil,P.size*10)
	if P.killMark then
		gc.setLineWidth(3)
		gc.setColor(1,0,0,min(P.endCounter,25)*.04)
		gc.circle("line",P.centerX,P.centerY,(840-20*min(P.endCounter,30))*P.size)
	end
	setFont(30)
end
local function Pdraw_demo(P)
	local _
	local ENV=P.gameEnv
	local curColor=P.cur.color

	--Camera
	gc.push("transform")
	gc.translate(P.x,P.y)gc.scale(P.size)gc.translate(P.fieldOff.x,P.fieldOff.y)

	--Frame
	gc.setColor(.1,.1,.1,.8)
	gc.rectangle("fill",0,0,300,600)

	gc.setLineWidth(2)
	gc.setColor(1,1,1)
	gc.rectangle("line",-1,-1,302,602)

	gc.push("transform")
		gc.translate(0,600)
		if P.falling==-1 then
			--Field block only
			for j=int(P.fieldBeneath/30+1),#P.field do
				for i=1,10 do
					if P.field[j][i]>0 then
						gc.setColor(1,1,1,min(P.visTime[j][i]*.05,1))
						drawCell(j,i,P.field[j][i])
					end
				end
			end
		else
			--Field with falling animation
			local dy,stepY=0,ENV.smooth and(P.falling/(ENV.fall+1))^2.5*30 or 30
			local A=P.falling/ENV.fall
			local h,H=1,#P.field
			for j=int(P.fieldBeneath/30+1),H do
				while j==P.clearingRow[h]do
					h=h+1
					dy=dy+stepY
					gc.translate(0,-stepY)
					gc.setColor(1,1,1,A)
					gc.rectangle("fill",0,630-30*j,300,stepY)
				end
				for i=1,10 do
					if P.field[j][i]>0 then
						gc.setColor(1,1,1,min(P.visTime[j][i]*.05,1))
						drawCell(j,i,P.field[j][i])
					end
				end
			end
			gc.translate(0,dy)
		end

		drawFXs(P)

		if P.cur and P.waiting==-1 then
			--Draw ghost
			if ENV.ghost then
				gc.setColor(1,1,1,ENV.ghost)
				for i=1,P.r do for j=1,P.c do
					if P.cur.bk[i][j]then
						drawCell(i+P.imgY-1,j+P.curX-1,curColor)
					end
				end end
			end

			--Draw block
			gc.setColor(1,1,1)
			for i=1,P.r do for j=1,P.c do
				if P.cur.bk[i][j]then
					drawCell(i+P.curY-1,j+P.curX-1,curColor)
				end
			end end
		end
	gc.pop()

	--Draw hold
	local blockImg=TEXTURE.miniBlock
	if P.hd then
		local id=P.hd.id
		_=P.color[id]
		gc.setColor(_[1],_[2],_[3],.3)
		_=blockImg[id]
		gc.draw(_,15,30,nil,16,nil,0,_:getHeight()*.5)
	end

	--Draw next
	local N=1
	while N<=ENV.next and P.next[N]do
		local id=P.next[N].id
		_=P.color[id]
		gc.setColor(_[1],_[2],_[3],.3)
		_=blockImg[id]
		gc.draw(_,285,40*N-10,nil,16,nil,_:getWidth(),_:getHeight()*.5)
		N=N+1
	end

	gc.setColor(1,1,1)
	gc.translate(-P.fieldOff.x,-P.fieldOff.y)
	TEXT.draw(P.bonus)
	gc.pop()
end
function player.drawTargetLine(P,r)
	if r<21+(P.fieldBeneath+P.fieldUp)/30 and r>0 then
		gc.setLineWidth(4)
		gc.setColor(1,r>10 and 0 or rnd(),.5)
		local dx,dy=150+P.fieldOff.x,70+P.fieldOff.y+P.fieldBeneath+P.fieldUp
		gc.line(dx,600-30*r+dy,300+dx,600-30*r+dy)
	end
end
--------------------------</Paint>--------------------------

--------------------------<Lib Func>--------------------------
local function without(L,e)
	for i=1,#L do
		if L[i]==e then return end
	end
	return true
end
local function getNewStatTable()
	local T={
		time=0,score=0,
		key=0,rotate=0,hold=0,
		extraPiece=0,extraRate=0,
		piece=0,row=0,dig=0,
		atk=0,digatk=0,
		send=0,recv=0,pend=0,off=0,
		clear={},clears={},spin={},spins={},
		pc=0,hpc=0,b2b=0,b3b=0,
	}
	for i=1,25 do
		T.clear[i]={0,0,0,0,0}
		T.spin[i]={0,0,0,0,0,0}
		T.clears[i]=0
		T.spins[i]=0
	end
	return T
end
local function pressKey(P,i)
	if P.keyAvailable[i]then
		P.keyPressing[i]=true
		P.act[i](P)
		if P.control then
			if P.keyRec then
				ins(P.keyTime,1,game.frame)
				P.keyTime[11]=nil
			end
			P.stat.key=P.stat.key+1
		end
	end
end
local function releaseKey(P,i)
	P.keyPressing[i]=false
end
local function pressKey_Rec(P,i)
	if P.keyAvailable[i]then
		if game.recording then
			ins(game.rec,game.frame+1)
			ins(game.rec,i)
		end
		P.keyPressing[i]=true
		P.act[i](P)
		if P.control then
			if P.keyRec then
				ins(P.keyTime,1,game.frame)
				P.keyTime[11]=nil
			end
			P.stat.key=P.stat.key+1
		end
	end
end
local function releaseKey_Rec(P,i)
	if game.recording then
		ins(game.rec,game.frame+1)
		ins(game.rec,-i)
	end
	P.keyPressing[i]=false
end
local function loadGameEnv(P)--Load gameEnv
	P.gameEnv={}--Current game setting environment
	local ENV=P.gameEnv
	local E
	--Load game settings
	for k,v in next,gameEnv0 do
		if modeEnv[k]~=nil then
			v=modeEnv[k]				--Mode setting
			-- DBP("mode-"..k..":"..tostring(v))
		elseif game.setting[k]~=nil then
			v=game.setting[k]			--Game setting
			-- DBP("game-"..k..":"..tostring(v))
		elseif setting[k]~=nil then
			v=setting[k]				--Global setting
			-- DBP("global-"..k..":"..tostring(v))
		-- else
			-- DBP("default-"..k..":"..tostring(v))
		end
		ENV[k]=v						--Default setting
	end
end
local function applyGameEnv(P)--Finish gameEnv processing
	local ENV=P.gameEnv

	P._20G=ENV.drop==0
	P.dropDelay=ENV.drop
	P.lockDelay=ENV.lock

	P.color={}
	for _=1,7 do
		P.color[_]=SKIN.libColor[ENV.skin[_]]
	end

	P.keepVisible=ENV.visible=="show"
	P.showTime=
		ENV.visible=="show"and 1e99 or
		ENV.visible=="time"and 300 or
		ENV.visible=="fast"and 20 or
		ENV.visible=="none"and 0

	P.life=ENV.life

	P.keyAvailable={true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true}
	if ENV.noTele then
		local L={11,12,13,15,16,17,18,19,20}
		for i=1,#L do
			P.keyAvailable[L[i]]=false
			virtualkey[L[i]].ava=false
		end
	end

	if type(ENV.mission)=="table"then
		P.curMission=1
	end

	ENV.das=max(ENV.das,ENV.mindas)
	ENV.arr=max(ENV.arr,ENV.minarr)
	ENV.sdarr=max(ENV.sdarr,ENV.minsdarr)
	ENV.next=min(ENV.next,setting.maxNext)

	if ENV.sequence~="bag"and ENV.sequence~="loop"then
		ENV.bagLine=false
	else
		ENV.bagLen=#ENV.bag
	end

	if ENV.next==0 then ENV.nextPos=false end

	if ENV.lockFX==0 then	ENV.lockFX=nil	end
	if ENV.dropFX==0 then	ENV.dropFX=nil	end
	if ENV.moveFX==0 then	ENV.moveFX=nil	end
	if ENV.clearFX==0 then	ENV.clearFX=nil end
	if ENV.shakeFX==0 then	ENV.shakeFX=nil	end

	if ENV.ghost==0 then	ENV.ghost=nil	end
	if ENV.center==0 then	ENV.center=nil	end
end
local function prepareSequence(P)--Call freshPrepare and set newNext
	local ENV=P.gameEnv
	if type(ENV.sequence)=="string"then
		freshPrepare[ENV.sequence](P)
		P.newNext=freshMethod[ENV.sequence]
	else
		print(type(ENV.sequence))
		print(type(ENV.freshMethod))
		assert(type(ENV.sequence)=="function"and type(ENV.freshMethod)=="function","wrong sequence generator code")
		ENV.sequence(P)
		P.newNext=ENV.freshMethod
	end
end
local function loadAI(P,AIdata)--Load AI params
	local ENV=P.gameEnv
	P.AI_mode=AIdata.type
	P.AI_stage=1
	P.AI_keys={}
	P.AI_delay=AIdata.delay or min(int(ENV.drop*.8),AIdata.delta*rnd()*4)
	P.AI_delay0=AIdata.delta
	P.AIdata={
		type=AIdata.type,
		delay=AIdata.delay,
		delta=AIdata.delta,

		next=AIdata.next,
		hold=AIdata.hold,
		_20G=ENV._20G,
		bag=AIdata.bag,
		node=AIdata.node,
	}
	if not CC then P.AI_mode="9S"end
	if P.AI_mode=="CC"then
		P.RS=kickList.AIRS
		local opt,wei=CC.getConf()
			CC.setHold(opt,P.AIdata.hold)
			CC.set20G(opt,P.AIdata._20G)
			CC.setBag(opt,P.AIdata.bag=="bag")
			CC.setNode(opt,P.AIdata.node)
		P.AI_bot=CC.new(opt,wei)
		CC.free(opt)CC.free(wei)
		for i=1,AIdata.next do
			CC.addNext(P.AI_bot,CCblockID[P.next[i].id])
		end
	elseif P.AI_mode=="9S"then
		P.RS=kickList.TRS
	end
end
local function newEmptyPlayer(id,x,y,size)
	local P={id=id}
	players[id]=P
	players.alive[id]=P

	--Inherit functions of player class
	for k,v in next,player do P[k]=v end
	if P.id==1 and game.recording then
		P.pressKey=pressKey_Rec
		P.releaseKey=releaseKey_Rec
	else
		P.pressKey=pressKey
		P.releaseKey=releaseKey
	end
	P.update=Pupdate_alive

	P.fieldOff={x=0,y=0,vx=0,vy=0}--For shake FX
	P.x,P.y,P.size=x,y,size or 1
	P.frameColor=frameColor[0]

	P.small=P.size<.1--If draw in small mode
	if P.small then
		P.centerX,P.centerY=P.x+300*P.size,P.y+600*P.size
		P.canvas=love.graphics.newCanvas(60,120)
		P.frameWait=rnd(30,120)
		P.draw=Pdraw_small
	else
		P.keyRec=true--If calculate keySpeed
		P.centerX,P.centerY=P.x+300*P.size,P.y+370*P.size
		P.absFieldX=P.x+150*P.size
		P.absFieldY=P.y+60*P.size
		P.draw=Pdraw_norm
		P.bonus={}--Text objects
	end
	P.randGen=mt.newRandomGenerator(game.seed)

	P.small=false
	P.alive=true
	P.control=false
	P.timing=false
	P.stat=getNewStatTable()

	P.modeData={point=0,event=0,counter=0}--Data use by mode
	P.keyTime={}P.keySpeed=0
	P.dropTime={}P.dropSpeed=0
	for i=1,10 do P.keyTime[i]=-1e5 end
	for i=1,10 do P.dropTime[i]=-1e5 end

	P.field,P.visTime={},{}
	P.atkBuffer={sum=0}

	--Royale-related
	P.badge,P.strength=0,0
	P.atkMode,P.swappingAtkMode=1,20
	P.atker,P.atking,P.lastRecv={}

	P.dropDelay,P.lockDelay=0,0
	P.color={}
	P.showTime=nil
	P.keepVisible=true

	--P.cur={bk=matrix[2], id=shapeID, color=colorID, name=nameID}
	--P.sc,P.dir={0,0},0--SpinCenterCoord, direction
	--P.r,P.c=0,0--row, col
	--P.hd={...},same as P.cur
	-- P.curX,P.curY,P.imgY,P.minY=0,0,0,0--x,y,ghostY
	P.holded=false
	P.next={}

	P.freshTime=0
	P.spinLast=false
	P.lastClear={
		id=1,--block id
		name=1,--block name
		row=0,--line cleared
		spin=false,--if spin
		mini=false,--if mini
		pc=false,--if pc
		special=false,--if special clear (spin, >=4, pc)
	}
	P.spinSeq=0--For Ospin, each digit mean a spin
	P.ctrlCount=0--Key press time, for finesse check
	P.pieceCount=0--Count pieces from next, for drawing bagline

	P.human=false
	P.RS=kickList.TRS

	-- P.newNext=nil--Call prepareSequence()to get a function to get new next

	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.movDir,P.moving,P.downing=0,0,0--Last move key,DAS charging,downDAS charging
	P.waiting,P.falling=-1,-1
	P.clearingRow,P.clearedRow={},{}--Clearing animation height,cleared row mark
	P.combo,P.b2b=0,0
	P.garbageBeneath=0
	P.fieldBeneath=0
	P.fieldUp=0

	P.score1,P.b2b1=0,0
	P.dropFX,P.moveFX,P.lockFX,P.clearFX={},{},{},{}
	P.tasks={}--Tasks
	P.bonus={}--Texts

	P.endCounter=0--Used after gameover
	P.result=nil--String:"WIN"/"K.O."

	return P
end
--------------------------</Lib Func>--------------------------

--------------------------<FX>--------------------------
function player.showText(P,text,dx,dy,font,style,spd,stop)
	if P.gameEnv.text then
		ins(P.bonus,TEXT.getText(text,150+dx,300+dy,font*P.size,style,spd,stop))
	end
end
function player.showTextF(P,text,dx,dy,font,style,spd,stop)
	ins(P.bonus,TEXT.getText(text,150+dx,300+dy,font*P.size,style,spd,stop))
end
function player.createLockFX(P)
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
function player.createDropFX(P,x,y,w,h)
	ins(P.dropFX,{x,y,w,h,0,13-2*P.gameEnv.dropFX})
end
function player.createMoveFX(P,dir)
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
function player.createClearingFX(P,y,spd)
	ins(P.clearFX,{y,0,spd})
end
function player.createBeam(P,R,send,time,target,color,clear,combo)
	local x1,y1,x2,y2
	if P.small then x1,y1=P.centerX,P.centerY
	else x1,y1=P.x+(30*(P.curX+P.sc[2])-30+15+150)*P.size,P.y+(600-30*(P.curY+P.sc[1])+15+70)*P.size
	end
	if R.small then x2,y2=R.centerX,R.centerY
	else x2,y2=R.x+308*R.size,R.y+450*R.size
	end

	local radius,corner
	local a,r,g,b=1,unpack(SKIN.libColor[color])
	if clear.special then
		radius=10+3*send+100/(target+4)
		local t=clear.row
		if t==1 then
			corner=3
			r=.3+r*.4
			g=.3+g*.4
			b=.3+b*.4
		elseif t==2 then
			corner=5
			r=.5+r*.5
			g=.5+g*.5
			b=.5+b*.5
		elseif t<6 then
			corner=6
			r=.6+r*.4
			g=.6+g*.4
			b=.6+b*.4
		else
			corner=20
			r=.8+r*.2
			g=.8+g*.2
			b=.8+b*.2
		end
	else
		if combo>3 then
			radius=min(15+combo,30)
			corner=3
		else
			radius=30
			corner=4
		end
		r=1-r*.3
		g=1-g*.3
		b=1-b*.3
	end
	if modeEnv.royaleMode and not(P.human or R.human)then
		radius=radius*.4
		a=.35
	end
	sysFX.newAttack(x1,y1,x2,y2,radius*(setting.atkFX+3)*.12,corner,type==1 and"fill"or"line",r,g,b,a*(setting.atkFX+5)*.1)
end
function player.newTask(P,code,data)
	local L=P.tasks
	ins(L,{
		code=code,
		data=data,
	})
end
--------------------------</FX>--------------------------

--------------------------<Method>--------------------------
function player.RND(P,a,b)
	local R=P.randGen
	return R:random(a,b)
end

function player.solid(P,x,y)
	if x<1 or x>10 or y<1 then return true end
	if y>#P.field then return false end
	return P.field[y][x]>0
end
function player.ifoverlap(P,bk,x,y)
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
function player.ckfull(P,i)
	for j=1,10 do if P.field[i][j]<=0 then return end end
	return true
end
function player.finesseError(P,rate)
	P.stat.extraPiece=P.stat.extraPiece+1
	P.stat.extraRate=P.stat.extraRate+rate
	if P.human then
		if P.gameEnv.fineKill then
			SFX.play("finesseError_long",.6)
			P:lose()
		elseif setting.fine then
			SFX.play("finesseError",.8)
		end
	elseif P.gameEnv.fineKill then
		P:lose()
	end
end
function player.attack(P,R,send,time,...)
	if setting.atkFX>0 then
		P:createBeam(R,send,time,...)
	end
	R.lastRecv=P
	if R.atkBuffer.sum<20 then
		local B=R.atkBuffer
		if send>20-B.sum then send=20-B.sum end--No more then 20
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
		if R.human then
			SFX.play(send<4 and "blip_1"or"blip_2",min(send+1,5)*.1)
		end
	end
end
function player.garbageRelease(P)
	local n,flag=1
	while true do
		local A=P.atkBuffer[n]
		if A and A.countdown<=0 and not A.sent then
			P:garbageRise(12+A.lv,A.amount,A.pos)
			P.atkBuffer.sum=P.atkBuffer.sum-A.amount
			A.sent,A.time=true,0
			P.stat.pend=P.stat.pend+A.amount
			n=n+1
			flag=true
		else
			break
		end
	end
	if flag and P.AI_mode=="CC"then CC_updateField(P)end
end
function player.garbageRise(P,color,amount,pos)
	local _
	local t=P.showTime*2
	for _=1,amount do
		ins(P.field,1,freeRow.get(color))
		ins(P.visTime,1,freeRow.get(t))
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
function player.pushLine(P,L,mir)
	local S=P.gameEnv.skin
	for i=1,#L do
		local r=freeRow.get(0)
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
		ins(P.visTime,1,freeRow.get(20))
	end
	P.fieldBeneath=P.fieldBeneath+120
	P.curY=P.curY+#L
	P.imgY=P.imgY+#L
	P:freshBlock(false,false)
end
function player.pushNext(P,L,mir)
	for i=1,#L do
		P:getNext(mir and invList[L[i]]or L[i])
	end
end

function player.freshTarget(P)
	if P.atkMode==1 then
		if not P.atking or not P.atking.alive or rnd()<.1 then
			P:changeAtk(randomTarget(P))
		end
	elseif P.atkMode==2 then
		P:changeAtk(P~=game.mostBadge and game.mostBadge or game.secBadge or randomTarget(P))
	elseif P.atkMode==3 then
		P:changeAtk(P~=game.mostDangerous and game.mostDangerous or game.secDangerous or randomTarget(P))
	elseif P.atkMode==4 then
		for i=1,#P.atker do
			if not P.atker[i].alive then
				rem(P.atker,i)
				return
			end
		end
	end
end
function player.changeAtkMode(P,m)
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
function player.changeAtk(P,R)
	-- if not P.human then R=players[1]end--1vALL mode?
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
function player.freshBlock(P,keepGhost,control,system)
	local ENV=P.gameEnv
	if not keepGhost and P.cur then
		P.imgY=min(#P.field+1,P.curY)
		if _20G or P.keyPressing[7]and ENV.sdarr==0 then
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
			if P.lockDelay<d0 and P.freshTime<ENV.freshLimit then
				if not system then
					P.freshTime=P.freshTime+1
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
				if P.lockDelay<ENV.lock and P.freshTime<ENV.freshLimit then
					P.freshTime=P.freshTime+1
					P.dropDelay=ENV.drop
					P.lockDelay=ENV.lock
				end
			end
		end
	end
end
function player.lock(P)
	local dest=P.AI_dest
	local has_dest=dest~=nil
	for i=1,P.r do
		local y=P.curY+i-1
		if not P.field[y]then P.field[y],P.visTime[y]=freeRow.get(0),freeRow.get(0)end
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
		CC_updateField(P)
	end
end
function player.spin(P,d,ifpre)
	local iki=P.RS[P.cur.id]
	if type(iki)=="table"then
		local idir=(P.dir+d)%4
		local icb=blocks[P.cur.id][idir]
		local isc=scs[P.cur.id][idir]
		local ir,ic=#icb,#icb[1]
		local ix,iy=P.curX+P.sc[2]-isc[2],P.curY+P.sc[1]-isc[1]
		iki=iki[P.dir*10+idir]
		if not iki then
			if P.gameEnv.easyFresh then
				P:freshBlock(false,true)
			end
			SFX.fieldPlay(ifpre and"prerotate"or "rotate",nil,P)
			return
		end
		for test=1,#iki do
			local x,y=ix+iki[test][1],iy+iki[test][2]
			if not P:ifoverlap(icb,x,y)and(P.freshTime<=P.gameEnv.freshLimit or iki[test][2]<0)then
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
					P.freshTime=P.freshTime+1
				end

				if P.human then
					SFX.fieldPlay(ifpre and"prerotate"or P:ifoverlap(P.cur.bk,P.curX,P.curY+1)and P:ifoverlap(P.cur.bk,P.curX-1,P.curY)and P:ifoverlap(P.cur.bk,P.curX+1,P.curY)and"rotatekick"or"rotate",nil,P)
				end
				P.stat.rotate=P.stat.rotate+1
				return
			end
		end
	else
		iki(P,d)
	end
end
function player.resetBlock(P)
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
	if P.human and id<8 then
		SFX.fplay("spawn_"..id,setting.spawn)
	end
end
function player.hold(P,ifpre)
	if not P.holded and (ifpre or P.waiting==-1) and P.gameEnv.hold then
		local H,C=P.hd,P.cur
		if not(H or C)then return end

		--Finesse check
		if H and C and H.id==C.id and H.name==C.name or P.ctrlCount>1 then
			P:finesseError(1)
		end

		P.holded=P.gameEnv.oncehold
		P.spinLast=false
		P.ctrlCount=0
		P.spinSeq=0

		P.cur,P.hd=H,C--Swap hold

		H,C=P.hd,P.cur
		if H then
			local hid=P.hd.id
			P.hd.bk=blocks[hid][P.gameEnv.face[hid]]
		end
		if not C then
			C=rem(P.next,1)
			P:newNext()
			if C then
				P.cur=C
				P.pieceCount=P.pieceCount+1
				if P.AI_mode=="CC"then
					local next=P.next[P.AIdata.next]
					if next then
						CC.addNext(P.AI_bot,CCblockID[next.id])
					end
				end
			else
				P.holded=false
			end
		end
		if C then
			P:resetBlock()
			P:freshBlock(false,true)
			P.dropDelay=P.gameEnv.drop
			P.lockDelay=P.gameEnv.lock
			P.freshTime=max(P.freshTime-5,0)
			if P:ifoverlap(P.cur.bk,P.curX,P.curY)then P:lock()P:lose()end
		end

		if P.human then
			SFX.play(ifpre and"prehold"or"hold")
		end
		P.stat.hold=P.stat.hold+1
	end
end

function player.getNext(P,n)
	local E=P.gameEnv
	ins(P.next,{bk=blocks[n][E.face[n]],id=n,color=E.bone and 12 or E.skin[n],name=n})
end
function player.popNext(P)--Pop next queue to hand
	P.holded=false
	P.spinLast=false
	P.spinSeq=0
	P.ctrlCount=0

	P.cur=rem(P.next,1)
	P:newNext()
	if P.cur then
		P.pieceCount=P.pieceCount+1
		if P.AI_mode=="CC"then
			local next=P.next[P.AIdata.next]
			if next then
				CC.addNext(P.AI_bot,CCblockID[next.id])
			end
		end

		local _=P.keyPressing
		--IHS
		if _[8]and P.gameEnv.hold and P.gameEnv.ihs then
			P:hold(true)
			_[8]=false
		else
			P:resetBlock()
		end

		P.dropDelay=P.gameEnv.drop
		P.lockDelay=P.gameEnv.lock
		P.freshTime=0

		if P.cur then
			if P:ifoverlap(P.cur.bk,P.curX,P.curY)then
				P:lock()
				P:lose()
			end
			P:freshBlock(false,true,true)
		end

		--IHdS
		if _[6]then
			P.act.hardDrop(P)
			_[6]=false
		end
	end
end

function player.cancel(P,N)--Cancel Garbage
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
do--player.drop(P)--Place piece
	local b2bPoint={50,100,180,1000,1200}
	local b2bATK={3,5,8,12,18}
	local clearSCR={80,200,400}
	local spinSCR={--[blockName][row]
		{200,750,1300},--Z
		{200,750,1300},--S
		{220,700,1300},--L
		{220,700,1300},--J
		{250,800,1400},--T
		{260,900,1700,4000},--O
		{300,1200,1700,4000},--I
		{220,800,2000,3000,8000},--Else
	}
	--B2BMUL:1.2/2.0
	--Techrash:1K;MUL:1.3/1.8
	--Mini*=.6
	local reAtk={0,0,1,1,1,2,2,3,3}
	local reDef={0,1,1,2,3,3,4,4,5}
	local spinName={"zspin","sspin","jspin","lspin","tspin","ospin","ispin","zspin","sspin","pspin","qspin","fspin","espin","tspin","uspin","vspin","wspin","xspin","jspin","lspin","rspin","yspin","hspin","nspin","ispin"}
	local clearName={"single","double","triple","techrash","pentcrash"}
	local spin_n={[0]="spin_0","spin_1","spin_2","spin_3","spin_3","spin_3"}
	local clear_n={"clear_1","clear_2","clear_3","clear_4","clear_4"}
	local ren_n={}for i=1,11 do ren_n[i]="ren_"..i end
	local finesseList={
		[1]={
			{1,2,1,0,1,2,2,1},
			{2,2,2,1,1,2,3,2,2},
		},--Z
		[3]={
			{1,2,1,0,1,2,2,1},
			{2,2,3,2,1,2,3,3,2},
			{3,4,3,2,3,4,4,3},
			{2,3,2,1,2,3,3,2,2},
		},--L
		[6]={
			{1,2,2,1,0,1,2,2,1},
		},--O
		[7]={
			{1,2,1,0,1,2,1},
			{2,2,2,2,1,1,2,2,2,2},
		},--I
	}
	finesseList[1][3],finesseList[1][4],finesseList[7][3],finesseList[7][4]=finesseList[1][1],finesseList[1][2],finesseList[7][1],finesseList[7][2]--"2-phase" SZI
	finesseList[2]=finesseList[1]--S=Z
	finesseList[4],finesseList[5]=finesseList[3],finesseList[3]--J=L=T
	function player.drop(P)--Place piece
		local _
		local CHN=VOC.getFreeChannel()
		P.dropTime[11]=ins(P.dropTime,1,game.frame)--Update speed dial
		local ENV=P.gameEnv
		local STAT=P.stat
		P.waiting=ENV.wait

		local cmb=P.combo
		local CB,CX,CY=P.cur,P.curX,P.curY
		local clear--If (perfect)clear
		local cc,gbcc=0,0--Row/garbage-row cleared,full-part
		local atk,exblock=0,0--Attack & extra defense
		local send,off=0,0--Sending lines remain & offset
		local cscore,sendTime=10,0--Score & send Time
		local dospin=0
		local mini

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

		--Check rows to be cleared
		for i=0,P.r-1 do
			local h=CY+i
			if P:ckfull(h)then
				cc=cc+1
				P.clearingRow[cc]=h-cc+1
				P.clearedRow[cc]=h
			end
		end

		--Create clearing FX
		if cc>0 and ENV.clearFX then
			local t=7-ENV.clearFX*1
			for i=1,cc do
				P:createClearingFX(P.clearedRow[i],t)
			end
		end

		--Create locking FX
		if ENV.lockFX then
			if cc==0 then
				P:createLockFX()
			else
				_=#P.lockFX
				if _>0 then
					for i=1,_ do
						rem(P.lockFX)
					end
				end
			end
		end

		--Final spin check
		if dospin>0 then
			if cc>0 then
				if P.spinLast then
					dospin=dospin+1
				end
				if dospin<3 then
					mini=CB.id<6 and cc<P.r
				end
			end
		else
			dospin=false
		end

		--Finesse: roof check
		local finesse
		if CB.id>7 then
			finesse=true
		elseif CY<=18 then
			local y0=CY
			local x,c=CX,P.c
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
					for y=y0+y,#P.field do
						--Roof=finesse
						if P:solid(x,y)then
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
				freeRow.discard(rem(P.field,_))
				freeRow.discard(rem(P.visTime,_))
				if _<=P.garbageBeneath then
					P.garbageBeneath=P.garbageBeneath-1
					gbcc=gbcc+1
				end
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
		if not finesse then
			if dospin then P.ctrlCount=P.ctrlCount-2 end--Allow 2 more step for roof-less spin
			local id=CB.id
			local d=P.ctrlCount-finesseList[id][P.dir+1][CX]
			if d>=2 then
				P:finesseError(2)
			elseif d>0 then
				P:finesseError(d)
			end
		end

		if cc>0 then--If lines cleared, about 200 lines below
			local C=P.lastClear
			C.id,C.name=CB.id,CB.name
			C.row=cc
			C.spin=dospin
			cmb=cmb+1
			if dospin then
				cscore=(spinSCR[CB.name]or spinSCR[8])[cc]
				if P.b2b>1000 then
					P:showText(text.b3b..text.block[CB.name]..text.spin.." "..text.clear[cc],0,-30,35,"stretch")
					atk=b2bATK[cc]+cc*.5
					exblock=exblock+1
					cscore=cscore*2
					STAT.b3b=STAT.b3b+1
					if P.human then
						VOC.play("b3b",CHN)
					end
				elseif P.b2b>=50 then
					P:showText(text.b2b..text.block[CB.name]..text.spin.." "..text.clear[cc],0,-30,35,"spin")
					atk=b2bATK[cc]
					cscore=cscore*1.2
					STAT.b2b=STAT.b2b+1
					if P.human then
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
					if P.human then
						VOC.play("mini",CHN)
					end
				else
					P.b2b=P.b2b+b2bPoint[cc]
				end
				C.mini=mini
				C.special=true
				if P.human then
					SFX.play(spin_n[cc])
					VOC.play(spinName[CB.name],CHN)
				end
			elseif cc>=4 then
				cscore=cc==4 and 1000 or 1500
				if P.b2b>1000 then
					P:showText(text.b3b..text.clear[cc],0,-30,50,"fly")
					atk=cc*1.5
					sendTime=100
					exblock=exblock+1
					cscore=cscore*1.8
					STAT.b3b=STAT.b3b+1
					if P.human then
						VOC.play("b3b",CHN)
					end
				elseif P.b2b>=50 then
					P:showText(text.b2b..text.clear[cc],0,-30,50,"drive")
					sendTime=80
					atk=cc+1
					cscore=cscore*1.3
					STAT.b2b=STAT.b2b+1
					if P.human then
						VOC.play("b2b",CHN)
					end
				else
					P:showText(text.clear[cc],0,-30,70,"stretch")
					sendTime=60
					atk=cc
				end
				P.b2b=P.b2b+cc*100-300
				C.special=true
			else
				C.special=false
			end
			if P.human then
				VOC.play(clearName[cc],CHN)
			end

			--PC/HPC bonus
			C.pc,C.hpc=false,false
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
				if P.human then
					SFX.play("clear")
					VOC.play("perfect_clear",CHN)
				end
				C.pc=true
				C.special=true
			elseif clear and(cc>1 or #P.field==P.garbageBeneath)then
				P:showText(text.HPC,0,-80,50,"fly")
				atk=atk+2
				exblock=exblock+2
				sendTime=sendTime+60
				cscore=cscore+626
				STAT.hpc=STAT.hpc+1
				if P.human then
					SFX.play("clear")
					VOC.play("half_clear",CHN)
				end
				C.hpc=true
				C.special=true
			end

			--Normal clear, reduce B2B point
			if not C.special then
				P.b2b=max(P.b2b-250,0)
				P:showText(text.clear[cc],0,-30,27+cc*3,"appear",(8-cc)*.3)
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
				P:showText(text.cmb[min(cmb,21)],0,25,15+min(cmb,25)*3,cmb<10 and"appear"or"flicker")
				cscore=cscore+min(50*cmb,500)*(2*cc-1)
			end

			if P.b2b>1200 then P.b2b=1200 end

			--Bonus atk/def when focused
			if modeEnv.royaleMode then
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
						if modeEnv.royaleMode then
							if P.atkMode==4 then
								local M=#P.atker
								if M>0 then
									for i=1,M do
										P:attack(P.atker[i],send,sendTime,M,CB.color,C,cmb)
									end
								else
									T=randomTarget(P)
								end
							else
								P:freshTarget()
								T=P.atking
							end
						elseif #players.alive>1 then
							T=randomTarget(P)
						end
						if T then
							P:attack(T,send,sendTime,1,CB.color,C,cmb)
						end
					end
					if P.human and send>3 then SFX.play("emit",min(send,7)*.1)end
				end
			end

			--Check clearing task
			if P.curMission then
				local t=ENV.mission[P.curMission]
				local success
				if t<5 then
					if C.row==t and not C.special then
						success=true
					end
				elseif t<9 then
					if C.row==t-4 and C.spin then
						success=true
					end
				elseif t==9 then
					if C.pc then
						success=true
					end
				elseif t<90 then
					if C.row==t%10 and C.name==int(t/10)and C.spin then
						success=true
					end
				end
				if success then
					P.curMission=P.curMission+1
					SFX.play("reach")
					if P.curMission>#ENV.mission then
						P.curMission=nil
						P:win()
					end
				elseif ENV.missionKill then
					P:showText(text.missionFailed,0,140,40,"flicker",.5)
					SFX.play("finesseError_long",.6)
					P:lose()
				end
			end

			--SFX & Vibrate
			if P.human then
				SFX.play(clear_n[cc])
				SFX.play(ren_n[min(cmb,11)])
				if cmb>14 then SFX.play("ren_mega",(cmb-10)*.1)end
				VIB(cc+1)
			end
		else--No lines clear
			cmb=0

			--Spin bonus
			if dospin then
				P:showText(text.block[CB.name]..text.spin,0,-30,45,"appear")
				P.b2b=P.b2b+20
				if P.human then
					SFX.play("spin_0")
					VOC.play(spinName[CB.name],CHN)
				end
				cscore=30
			end

			if P.b2b>1000 then
				P.b2b=max(P.b2b-40,1000)
			end
			P:garbageRelease()
		end

		P.combo=cmb

		local mul=1
		--DropSpeed bonus
		if P._20G then
			cscore=cscore*2
		elseif ENV.drop<3 then
			cscore=cscore*1.5
		end

		--Speed bonus
		if P.dropSpeed>60 then
			cscore=cscore*(.9+P.dropSpeed/600)
		end

		cscore=int(cscore)
		if ENV.score then
			P:showText(cscore,(P.curX+P.sc[2]-5.5)*30,(10-P.curY-P.sc[1])*30+P.fieldBeneath+P.fieldUp,int(40-600/(cscore+20)),"score",2)
		end
		STAT.score=STAT.score+cscore
		STAT.piece=STAT.piece+1
		STAT.row=STAT.row+cc
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

		--Update stat
		local n=CB.name
		if dospin then
			_=STAT.spin[n]	_[cc+1]=_[cc+1]+1--Spin[1~25][0~4]
			_=STAT.spins	_[cc+1]=_[cc+1]+1--Spin[0~4]
		elseif cc>0 then
			_=STAT.clear[n]	_[cc]=_[cc]+1--Clear[1~25][1~5]
			_=STAT.clears	_[cc]=_[cc]+1--Clear[1~5]
		end

		--Drop event
		_=ENV.dropPiece
		if _ then _(P)end

		--Stereo SFX
		if P.human then SFX.fieldPlay("lock",nil,P)end
	end
end
--------------------------</Methods>--------------------------

--------------------------<Events>--------------------------
local function gameOver()--Save record
	if game.replaying then return end
	FILE.saveData()
	local M=curMode
	local R=M.getRank
	if R then
		local P=players[1]
		R=R(P)--New rank
		if R then
			if R>0 then LOG.print(text.getRank..text.ranks[R],color.green)end
			local r=modeRanks[M.name]--Old rank
			local _
			if R>r then
				modeRanks[M.name]=R
				_=true
			end
			if M.unlock then
				for i=1,#M.unlock do
					local m=M.unlock[i]
					local n=Modes[m].name
					if not modeRanks[n]then
						modeRanks[n]=Modes[m].score and 0 or 6
						_=true
					end
				end
			end
			if _ then
				FILE.saveUnlock()
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
				FILE.saveRecord(M.name,L)
			end
		end
	end
end

function player.die(P)--Called when win/lose,not really die!
	P.alive=false
	P.timing=false
	P.control=false
	P.update=Pupdate_dead
	P.waiting=1e99
	P.b2b=0
	for i=1,#P.tasks do rem(P.tasks)end
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
function player.win(P,result)
	P:die()
	P.result="WIN"
	if modeEnv.royaleMode then
		P.modeData.event=1
		P:changeAtk()
	end
	if P.human then
		game.result=result or"win"
		SFX.play("win")
		VOC.play("win")
		if modeEnv.royaleMode then
			BGM.play("8-bit happiness")
		end
	end
	if curMode.id=="custom_puzzle"then
		P:showTextF(text.win,0,0,90,"beat",.4)
	else
		P:showTextF(text.win,0,0,90,"beat",.5,.2)
	end
	if P.human then
		gameOver()
		TASK.new(TICK.autoPause,{0})
		if marking then
			P:showTextF(text.marking,0,-226,22,"appear",.4,.0626)
		end
	end
	P:newTask(TICK.finish)
end
function player.lose(P)
	if P.life>0 then
		for _=#P.field,1,-1 do
			freeRow.discard(P.field[_])
			freeRow.discard(P.visTime[_])
			P.field[_],P.visTime[_]=nil
		end

		if P.AI_mode=="CC"then
			CC.destroy(P.AI_bot)
			P.hd=nil
			loadAI(P,P.AIdata)
			P:popNext()
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

		for i=1,21 do
			P:createClearingFX(i,1.5)
		end
		sysFX.newShade(.5,1,1,1,P.x+150*P.size,P.y+60*P.size,300*P.size,610*P.size)
		sysFX.newRectRipple(.3,P.x+150*P.size,P.y+60*P.size,300*P.size,610*P.size)
		sysFX.newRipple(.3,P.x+(475+25*(P.life<3 and P.life or 0)+12)*P.size,P.y+(665+12)*P.size,20)
		--300+25*i,595
		SFX.play("clear_3")
		SFX.play("emit")

		return
	end
	P:die()
	for i=1,#players.alive do
		if players.alive[i]==P then
			rem(players.alive,i)
			break
		end
	end
	P.result="K.O."
	if modeEnv.royaleMode then
		P:changeAtk()
		P.modeData.event=#players.alive+1
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
				for i=A.strength+1,4 do
					if A.badge>=royaleData.powerUp[i]then
						A.strength=i
						A.frameColor=frameColor[A.strength]
					end
				end
				P.lastRecv=A
				if P.id==1 or A.id==1 then
					TASK.new(TICK.throwBadge,{A.ai,P,max(3,P.badge)*4})
				end
			end
		else
			P.badge=-1
		end

		freshMostBadge()
		freshMostDangerous()
		if #players.alive==royaleData.stage[game.stage]then
			royaleLevelup()
		end
		P:showTextF(P.modeData.event,0,120,60,"appear",.26,.9)
	end
	P.gameEnv.keepVisible=P.gameEnv.visible~="show"
	P:showTextF(text.gameover,0,0,60,"appear",.26,.9)
	if P.human then
		game.result="gameover"
		SFX.play("fail")
		VOC.play("lose")
		if modeEnv.royaleMode then
			if P.modeData.event==2 then
				BGM.play("hay what kind of feeling")
			else
				BGM.play("end")
			end
		end
		gameOver()
		P:newTask(#players>1 and TICK.lose or TICK.finish)
		TASK.new(TICK.autoPause,{0})
		if marking then
			P:showTextF(text.marking,0,-226,22,"appear",.4,.0626)
		end
	else
		P:newTask(TICK.lose)
	end
	if #players.alive==1 then
		players.alive[1]:win()
	end
end

function PLY.check_lineReach(P)
	if P.stat.row>=P.gameEnv.target then
		P:win("finish")
	end
end
function PLY.check_attackReach(P)
	if P.stat.atk>=P.gameEnv.target then
		P:win("finish")
	end
end
--------------------------<\Events>--------------------------

--------------------------<Control>--------------------------
player.act={}
function player.act.moveLeft(P,auto)
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
			if P.human and P.curY==P.imgY then SFX.play("move")end
			if not auto then P.moving=0 end
			P.spinLast=false
		else
			P.moving=P.gameEnv.das
		end
	else
		P.moving=0
	end
end
function player.act.moveRight(P,auto)
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
			if P.human and P.curY==P.imgY then SFX.play("move")end
			if not auto then P.moving=0 end
			P.spinLast=false
		else
			P.moving=P.gameEnv.das
		end
	else
		P.moving=0
	end
end
function player.act.rotRight(P)
	if P.control and P.waiting==-1 and P.cur then
		P.ctrlCount=P.ctrlCount+1
		P:spin(1)
		P.keyPressing[3]=false
	end
end
function player.act.rotLeft(P)
	if P.control and P.waiting==-1 and P.cur then
		P.ctrlCount=P.ctrlCount+1
		P:spin(3)
		P.keyPressing[4]=false
	end
end
function player.act.rot180(P)
	if P.control and P.waiting==-1 and P.cur then
		P.ctrlCount=P.ctrlCount+2
		P:spin(2)
		P.keyPressing[5]=false
	end
end
function player.act.hardDrop(P)
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
			if P.human then
				SFX.fieldPlay("drop",nil,P)
				VIB(1)
			end
		end
		P.lockDelay=-1
		P:drop()
		P.keyPressing[6]=false
	end
end
function player.act.softDrop(P)
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
function player.act.hold(P)
	if P.control and P.waiting==-1 then
		P:hold()
	end
end
function player.act.func(P)
	P.gameEnv.Fkey(P)
end
function player.act.restart(P)
	if game.frame<240 or game.result then
		resetPartGameData()
	else
		LOG.print(text.holdR,20,color.orange)
	end
end
function player.act.insLeft(P,auto)
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
function player.act.insRight(P,auto)
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
function player.act.insDown(P)
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
function player.act.down1(P)
	if P.cur and P.curY>P.imgY then
		if P.gameEnv.moveFX and P.gameEnv.block then
			P:createMoveFX("down")
		end
		P.curY=P.curY-1
		P:freshBlock(true,true)
		P.spinLast=false
	end
end
function player.act.down4(P)
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
function player.act.down10(P)
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
function player.act.dropLeft(P)
	if not P.cur then return end
	P.act.insLeft(P)
	P.act.hardDrop(P)
end
function player.act.dropRight(P)
	if not P.cur then return end
	P.act.insRight(P)
	P.act.hardDrop(P)
end
function player.act.zangiLeft(P)
	if not P.cur then return end
	P.act.insLeft(P)
	P.act.insDown(P)
	P.act.insRight(P)
	P.act.hardDrop(P)
end
function player.act.zangiRight(P)
	if not P.cur then return end
	P.act.insRight(P)
	P.act.insDown(P)
	P.act.insLeft(P)
	P.act.hardDrop(P)
end
--Give operations a num name
do
	local A=player.act
	local T={
		A.moveLeft	,A.moveRight,	A.rotRight,	A.rotLeft,
		A.rot180	,A.hardDrop,	A.softDrop,	A.hold,
		A.func		,A.restart,		A.insLeft,	A.insRight,
		A.insDown	,A.down1,		A.down4,	A.down10,
		A.dropLeft	,A.dropRight,	A.zangiLeft,A.zangiRight
	}for i=1,20 do A[i]=T[i]end
end
--------------------------</Control>--------------------------

--------------------------<Generator>--------------------------
function PLY.newDemoPlayer(id,x,y,size)
	local P=newEmptyPlayer(id,x,y,size)

	-- rewrite some args
	P.small=false
	P.centerX,P.centerY=P.x+300*P.size,P.y+600*P.size
	P.absFieldX=P.x+150*P.size
	P.absFieldY=P.y+60*P.size
	P.draw=Pdraw_demo
	P.control=true
	P.gameEnv={
		drop=1e99,lock=1e99,
		wait=10,fall=20,
		next=6,hold=true,
		oncehold=true,

		das=10,arr=2,
		sddas=2,sdarr=2,
		swap=true,

		--Visual
		block=true,
		ghost=setting.ghost,
		center=setting.center,
		bone=false,
		smooth=setting.smooth,
		grid=setting.grid,
		text=setting.text,
		score=setting.score,
		lockFX=setting.lockFX,
		dropFX=setting.dropFX,
		moveFX=setting.moveFX,
		clearFX=setting.clearFX,
		shakeFX=setting.shakeFX,

		mindas=0,minarr=0,minsdarr=0,
		sequence="bag",
		ospin=true,
		noTele=false,

		easyFresh=true,
		visible="show",
		freshLimit=1e99,
		life=1e99,
		pushSpeed=3,

		bag={1,2,3,4,5,6,7},
		face={0,0,0,0,0,0,0},
		skin=setting.skin,
	}
	applyGameEnv(P)
	prepareSequence(P)

	P.human=false
	loadAI(P,{
		type="CC",
		next=5,
		hold=true,
		delay=3,
		delta=3,
		bag="bag",
		node=100000,
	})

	P:popNext()
end
function PLY.newRemotePlayer(id,x,y,size,actions)
	local P=newEmptyPlayer(id,x,y,size)

	P.human=false
	P.remote=true

	-- P.updateAction=buildActionFunctionFromActions(P, actions)

	loadGameEnv(P)
	applyGameEnv(P)
	prepareSequence(P)
end
function PLY.newAIPlayer(id,x,y,size,AIdata)
	local P=newEmptyPlayer(id,x,y,size)

	if P.small then
		ENV.text=false
		ENV.lockFX=nil
		ENV.dropFX=nil
		ENV.moveFX=nil
		ENV.shakeFX=nil
	end

	loadGameEnv(P)
	applyGameEnv(P)

	local ENV=P.gameEnv
	ENV.face={0,0,0,0,0,0,0}
	ENV.skin={1,5,8,2,10,3,7}
	prepareSequence(P)

	P.human=false
	loadAI(P,AIdata)
end
function PLY.newPlayer(id,x,y,size)
	local P=newEmptyPlayer(id,x,y,size)

	loadGameEnv(P)
	applyGameEnv(P)
	prepareSequence(P)

	P.human=true
	P.RS=kickList.TRS
end
--------------------------</Generator>--------------------------
return PLY