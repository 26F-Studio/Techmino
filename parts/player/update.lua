local max,min=math.max,math.min
local int,abs,rnd=math.floor,math.abs,math.random
local rem=table.remove
local assert,resume,status=assert,coroutine.resume,coroutine.status

local function updateLine(P)--Attacks, line pushing, cam moving
	local bf=P.atkBuffer
	for i=#bf,1,-1 do
		local A=bf[i]
		A.time=A.time+1
		if not A.sent then
			if A.countdown>0 then
				A.countdown=max(A.countdown-P.gameEnv.garbageSpeed,0)
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
			y=30*max(min(#P.field-18.5-P.fieldBeneath/30,P.ghoY-17),0)
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
		O.vx=O.vx*.8-abs(O.x)^1.3*(O.x>0 and .1 or -.1)
		O.x=O.x+O.vx

		O.vy=O.vy*.8-abs(O.y)^1.2*(O.y>0 and .1 or -.1)
		O.y=O.y+O.vy

		O.va=O.va*.8-abs(O.a)^1.4*(O.a>0 and .08 or -.08)
		O.a=O.a+O.va
		-- if abs(O.a)<.3 then O.a,O.va=0,0 end
	end

	if P.bonus then
		TEXT.update(P.bonus)
	end
end
local function updateTasks(P)
	local L=P.tasks
	for i=#L,1,-1 do
		local tr=L[i].thread
		assert(resume(tr))
		if status(tr)=="dead"then
			rem(L,i)
		end
	end
end

local update={
}
function update.alive(P,dt)
	local ENV=P.gameEnv
	if P.timing then
		local S=P.stat
		S.time=S.time+dt
		S.frame=S.frame+1
	end

	--Calculate key speed
	do
		local v=0
		for i=2,10 do v=v+i*(i-1)*72/(GAME.frame-P.keyTime[i]+1)end
		P.keySpeed=P.keySpeed*.99+v*.01
		v=0
		for i=2,10 do v=v+i*(i-1)*72/(GAME.frame-P.dropTime[i])end
		P.dropSpeed=P.dropSpeed*.99+v*.01
	end

	if GAME.modeEnv.royaleMode then
		v=P.swappingAtkMode
		if P.keyPressing[9]then
			P.swappingAtkMode=min(v+2,30)
		else
			local tar=#P.field>15 and 4 or 8
			if v~=tar then
				P.swappingAtkMode=v+(v<tar and 1 or -1)
			end
		end
	end

	if P.type=="computer"and P.control and P.waiting==-1 then
		local C=P.AI_keys
		P.AI_delay=P.AI_delay-1
		if not C[1]then
			if P.AI_thread and not pcall(P.AI_thread)then
				P.AI_thread=false
			end
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
		local das,arr=ENV.das,ENV.arr
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
					if mov>=das and ENV.shakeFX and P.cur and P:ifoverlap(P.cur.bk,P.curX+1,P.curY)then
						P.fieldOff.vx=ENV.shakeFX*.5
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
					if mov>=das and ENV.shakeFX and P.cur and P:ifoverlap(P.cur.bk,P.curX-1,P.curY)then
						P.fieldOff.vx=-ENV.shakeFX*.5
					end
				else
					P.movDir=0
				end
			end
		elseif mov<das then
			mov=mov+1
		end
		P.moving=mov
	elseif P.keyPressing[1]then
		P.movDir=-1
		P.moving=0
	elseif P.keyPressing[2]then
		P.movDir=1
		P.moving=0
	end

	--Drop pressed
	if P.keyPressing[7]and not P.keyPressing[9]then
		local d=P.downing-ENV.sddas
		P.downing=P.downing+1
		if d>1 then
			if ENV.sdarr>0 then
				if d%ENV.sdarr==0 then
					P:act_down1()
				end
			else
				P:act_insDown()
			end
			if ENV.shakeFX then
				P.fieldOff.vy=ENV.shakeFX*.2
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
			if P.sound and ENV.fall>0 and #P.field+L>P.clearingRow[L]then SFX.play("fall")end
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
		if P.curY>P.ghoY then
			local D=P.dropDelay
			if D>1 then
				P.dropDelay=D-1
				goto stop
			end

			if D==1 then
				if ENV.moveFX and ENV.block then
					P:createMoveFX("down")
				end
				P.curY=P.curY-1
			else
				D=1/D--Fall dist
				if D>P.curY-P.ghoY then D=P.curY-P.ghoY end
				if ENV.moveFX and ENV.block then
					for _=1,D do
						P:createMoveFX("down")
						P.curY=P.curY-1
					end
				else
					P.curY=P.curY-D
				end
			end
			P:freshBlock("fresh")
			P.spinLast=false

			if P.ghoY~=P.curY then
				P.dropDelay=ENV.drop
			elseif P.AI_mode=="CC"and P.AI_bot then
				CC.updateField(P)
				if not P.AIdata._20G and ENV.drop<P.AI_delay0*.5 then
					CC.switch20G(P)
				end
			end
		else
			P.lockDelay=P.lockDelay-1
			if P.lockDelay>=0 then goto stop end
			P:drop()
			if P.AI_mode=="CC"and P.AI_bot then
				CC.updateField(P)
			end
		end
	end
	::stop::

	--B2B bar animation
	if P.b2b1==P.b2b then
	elseif P.b2b1<P.b2b then
		P.b2b1=min(P.b2b1*.98+P.b2b*.02+.4,P.b2b)
	else
		P.b2b1=max(P.b2b1*.95+P.b2b*.05-.6,P.b2b)
	end

	--Finesse combo animation
	if P.finesseComboTime>0 then
		P.finesseComboTime=P.finesseComboTime-1
	end

	--Update FXs
	updateLine(P)
	updateFXs(P,dt)
	updateTasks(P)
	-- P:setPosition(640-150-(30*(P.curX+P.cur.sc[2])-15),30*(P.curY+P.cur.sc[1])+15-300+(ENV.smooth and P.ghoY~=P.curY and(P.dropDelay/ENV.drop-1)*30 or 0))
end
function update.dead(P,dt)
	local S=P.stat

	--Final average key speed
	P.keySpeed=P.keySpeed*.96+S.key/S.frame*144
	P.dropSpeed=P.dropSpeed*.96+S.piece/S.frame*144

	if GAME.modeEnv.royaleMode then
		P.swappingAtkMode=min(P.swappingAtkMode+2,30)
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
function update.remote_alive(P,dt)
	local frmStep=GAME.frame-P.stat.frame
	frmStep=
		frmStep<60 and 1 or
		frmStep<120 and rnd(2)or
		frmStep<240 and 2 or
		frmStep<480 and rnd(2,3) or
		3
	repeat
		local eventTime=P.stream[P.streamProgress]
		if eventTime then--Normal state, event forward
			if P.stat.frame==eventTime then--Event time, execute action, read next so don't update immediately
				local event=P.stream[P.streamProgress+1]
				if event==0 then--Just wait
				elseif event<=32 then--Press key
					P:pressKey(event)
				elseif event<=64 then--Release key
					P:releaseKey(event-32)
				elseif event>0x2000000000000 then--Sending lines
					local sid=tostring(event%0x100)
					local amount=int(event/0x100)%0x100
					local time=int(event/0x10000)%0x10000
					local line=int(event/0x100000000)%0x10000
					local L=PLY_ALIVE
					for i=1,#L do
						if L[i].subID==sid then
							P:attack(L[i],amount,time,line,true)
							if SETTING.atkFX>0 then
								P:createBeam(L[i],amount,P.cur.color)
							end
							break
						end
					end
				elseif event>0x1000000000000 then--Receiving lines
					local L=PLY_ALIVE
					local sid=tostring(event%0x100)
					for i=1,#L do
						if L[i].subID==sid then
							P:receive(
								L[i],
								int(event/0x100)%0x100,--amount
								int(event/0x10000)%0x10000,--time
								int(event/0x100000000)%0x10000--line
							)
							break
						end
					end
				end
				P.streamProgress=P.streamProgress+2
			else--No event now, run one frame
				update.alive(P,dt)
				frmStep=frmStep-1
			end
		else--Pause state, no actions, quit loop
			break
		end
	until frmStep<=0
end
return update