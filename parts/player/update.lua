local int,max,min,abs=math.floor,math.max,math.min,math.abs
local rem=table.remove

local function updateLine(P)--Attacks, line pushing, cam moving
	local bf=P.atkBuffer
	for i=#bf,1,-1 do
		local A=bf[i]
		A.time=A.time+1
		if not A.sent then
			if A.countdown>0 then
				A.countdown=max(A.countdown-GAME.garbageSpeed,0)
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
			P.fieldUp=f>y and max(f*.95+y*.05-2,y)or min(f*.97+y*.03+1,y)
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

local update={}
function update.alive(P,dt)
	if P.timing then P.stat.time=P.stat.time+dt end
	if P.keyRec then--Update speeds
		local _=GAME.frame

		local v=0
		for i=2,10 do v=v+i*(i-1)*7.2/(_-P.keyTime[i]+1)end
		P.keySpeed=P.keySpeed*.99+v*.1

		v=0
		for i=2,10 do v=v+i*(i-1)*7.2/(_-P.dropTime[i])end
		P.dropSpeed=P.dropSpeed*.99+v*.1

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
			P.AI_stage=AIFUNC[P.AI_mode][P.AI_stage](P,C)
		elseif P.AI_delay<=0 then
			P:pressKey(C[1])P:releaseKey(C[1])
			if P.AI_mode~="CC"or C[1]>3 then
				P.AI_delay=P.AI_delay0*2
			else
				P.AI_delay=P.AI_delay0*.5
			end
			rem(C,1)
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
								P:act_moveRight(true)
								mov=das
							end
						end
						mov=mov+1
					else
						if mov==das then
							P:act_insRight(true)
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
								P:act_moveLeft(true)
								mov=das
							end
						end
						mov=mov+1
					else
						if mov==das then
							P:act_insLeft(true)
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
					P:act_down1()
				end
			else
				P:act_insDown()
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
			if P.sound and P.gameEnv.fall>0 and #P.field+L>P.clearingRow[L]then SFX.play("fall")end
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
					for _=1,D do
						P:createMoveFX("down")
						P.curY=P.curY-1
					end
				else
					P.curY=P.curY-D
				end
			end
			P:freshBlock(true,true)
			P.spinLast=false

			if P.imgY~=P.curY then
				P.dropDelay=P.gameEnv.drop
			elseif P.AI_mode=="CC"then
				CC.updateField(P)
				if not P.AIdata._20G and P.gameEnv.drop<P.AI_delay0*.5 then
					CC.switch20G(P)
				end
			end
		else
			P.lockDelay=P.lockDelay-1
			if P.lockDelay>=0 then goto stop end
			P:drop()
			if P.AI_mode=="CC"then
				CC.updateField(P)
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
	if P.finesseComboTime>0 then
		P.finesseComboTime=P.finesseComboTime-1
	end
	updateLine(P)
	updateFXs(P,dt)
	updateTasks(P)
end
function update.dead(P,dt)
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
			if P.sound and P.gameEnv.fall>0 and #P.field+L>P.clearingRow[L]then SFX.play("fall")end
			P.clearingRow={}
		end
	end
	if P.b2b1>0 then
		P.b2b1=max(0,P.b2b1*.92-1)
	end
	if P.finesseComboTime>0 then
		P.finesseComboTime=P.finesseComboTime-1
	end
	updateLine(P)
	updateFXs(P,dt)
	updateTasks(P)
end
return update