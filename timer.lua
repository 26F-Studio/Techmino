local Timer=love.timer.getTime

Tmr={}
function Tmr.load()
	if loading==1 then
		loadnum=loadnum+1
		loadprogress=loadnum/10
		if loadnum==5 then
			--require("texture")
		elseif loadnum==10 then
			loadnum=1
			loading=2
		end
	elseif loading==2 then
		if loadnum<=#bgm then
			bgm[bgm[loadnum]]=love.audio.newSource("/BGM/"..bgm[loadnum]..".ogg","stream")
			bgm[bgm[loadnum]]:setLooping(true)
			bgm[bgm[loadnum]]:setVolume(0)
			loadprogress=loadnum/#bgm
			loadnum=loadnum+1
		else
			for i=1,#bgm do bgm[i]=nil end
			loading=3
			loadnum=1
		end
	elseif loading==3 then
		if loadnum<=#sfx then
			sfx[sfx[loadnum]]={love.audio.newSource("/SFX/"..sfx[loadnum]..".ogg","static")}
			loadprogress=loadnum/#sfx
			loadnum=loadnum+1
		else
			for i=1,#sfx do sfx[i]=nil end
			loading=4
			loadnum=0
		end
	elseif loading==4 then
		loadnum=loadnum+1
		if loadnum==15 then
			stat.run=stat.run+1
			gotoScene("intro","none")
		end
	end
end
function Tmr.intro()
	count=count+1
	if count==200 then count=80 end
end
function Tmr.play(dt)
	frame=frame+1
	stat.gametime=stat.gametime+dt

	for i=#FX.beam,1,-1 do
		local b=FX.beam[i]
		b.t=b.t+1
		local t0=b.t*.025--t in [0,1]
		local t=(sin(1.5*(2*t0-1))+1)*.5
		PTC.attack[b.lv]:setPosition(b[1]+(b[3]-b[1])*t,b[2]+(b[4]-b[2])*t)
		PTC.attack[b.lv]:emit(1)
		if t0==1 then
			rem(FX.beam,i)
		end
	end
	for i=#FX.badge,1,-1 do
		local b=FX.badge[i]
		b.t=b.t+1
		if b.t==60 then
			rem(FX.badge,i)
		end
	end
	for i=1,#virtualkey do
		if virtualkeyPressTime[i]>0 then
			virtualkeyPressTime[i]=virtualkeyPressTime[i]-1
		end
	end
	PTC.attack[1]:update(dt)
	PTC.attack[2]:update(dt)
	PTC.attack[3]:update(dt)
	if frame<180 then
		if frame==179 then
			gameStart()
		elseif frame%60==0 then
			sysSFX("ready")
		end
		for p=1,#players do
			P=players[p]
			if P.keyPressing[1]or P.keyPressing[2]then
				P.moving=P.moving+(P.moving>0 and 1 or -1)
			else
				P.moving=0
			end
		end
		return
	end--Counting,include pre-das,directy RETURN
	for p=1,#players do
		P=players[p]
		if P.timing then P.time=P.time+dt end
		if P.alive then
			if not P.small then
				local v=0
				for i=2,10 do v=v+i*(i-1)*7.2/(frame-P.keyTime[i])end P.keySpeed=P.keySpeed*.99+v*.1
				v=0
				for i=2,10 do v=v+i*(i-1)*7.2/(frame-P.dropTime[i])end P.dropSpeed=P.dropSpeed*.99+v*.1
				--Update speeds
				if modeEnv.royaleMode then
					if P.keyPressing[9]then
						P.swappingAtkMode=min(P.swappingAtkMode+2,30)
					else
						P.swappingAtkMode=P.swappingAtkMode+((#P.field>15 and P.swappingAtkMode>4 or P.swappingAtkMode>8)and -1 or 1)
					end
				end
			end

			if P.ai and P.waiting==-1 then
				P.ai.controlDelay=P.ai.controlDelay-1
				if P.ai.controlDelay==0 then
					if #P.ai.controls>0 then
						pressKey(P.ai.controls[1],P)
						releaseKey(P.ai.controls[1],P)
						rem(P.ai.controls,1)
						P.ai.controlDelay=P.ai.controlDelay0+1
					else
						AI_getControls(P.ai.controls)
						P.ai.controlDelay=P.ai.controlDelay0+2
						if Timer()-P.cstat.point>P.cstat.event then
							P.cstat.point=Timer()
							P.cstat.event=P.ai.controlDelay0+rnd(2,10)
							changeAtkMode(rnd()<.85 and 1 or #P.atker>3 and 4 or rnd()<.35 and 2 or 3)
						end
					end
				end
			end
			if not P.keepVisible then
				for j=1,#P.field do for i=1,10 do
					if P.visTime[j][i]>0 then P.visTime[j][i]=P.visTime[j][i]-1 end
				end end
			end--Fresh visible time

			if P.keyPressing[1]or P.keyPressing[2]then
				P.moving=P.moving+(P.moving>0 and 1 or -1)
				local d=abs(P.moving)-P.gameEnv.das
				if d>1 then
					if P.gameEnv.arr>0 then
						if d%P.gameEnv.arr==0 then
							act[P.moving>0 and"moveRight"or"moveLeft"](true)
						end
					else
						act[P.moving>0 and"insRight"or"insLeft"]()
					end
				end
			else
				P.moving=0
			end
			if P.keyPressing[7]and not P.keyPressing[9]then
				local d=abs(P.downing)-P.gameEnv.sddas
				P.downing=P.downing+1
				if d>1 then
					if P.gameEnv.sdarr>0 then
						if d%P.gameEnv.sdarr==0 then
							act.down1()
						end
					else
						act.insDown()
					end
				end
			else
				P.downing=0
			end
			if P.falling>=0 then
				P.falling=P.falling-1
				if P.falling>=0 then goto stop end
				if P.gameEnv.fall>0 and #P.field>P.clearing[1]then SFX("fall")end
				for i=1,#P.clearing do
					removeRow(P.field,P.clearing[i])
					removeRow(P.visTime,P.clearing[i])
				end
				::L::
					rem(P.clearing)
				if P.clearing[1]then goto L end
			end
			if P.waiting>=0 then
				P.waiting=P.waiting-1
				if P.waiting==-1 then resetblock()end
				goto stop
			end
			if P.curY~=P.y_img then
				if P.dropDelay>=0 then
					P.dropDelay=P.dropDelay-1
					if P.dropDelay>=0 then goto stop end
				end
				drop()
				P.dropDelay=P.gameEnv.drop
				if P.freshTime<=P.gameEnv.freshLimit then
					P.lockDelay=P.gameEnv.lock
				end
			else
				P.lockDelay=P.lockDelay-1
				if P.lockDelay>=0 then goto stop end
				drop()
			end
			::stop::
			if P.b2b1==P.b2b then
			elseif P.b2b1<P.b2b then
				P.b2b1=min(P.b2b1*.98+P.b2b*.02+.4,P.b2b)
			else
				P.b2b1=max(P.b2b1*.95+P.b2b*.05-.6,P.b2b)
			end
			--Alive
		else
			if not P.small then
				P.keySpeed=P.keySpeed*.96+P.cstat.key/P.time*60*.04
				P.dropSpeed=P.dropSpeed*.96+P.cstat.piece/P.time*60*.04
				--Final average speeds
				if modeEnv.royaleMode then
					P.swappingAtkMode=min(P.swappingAtkMode+2,30)
				end
			end
			if P.falling>=0 then
				P.falling=P.falling-1
				if P.falling>=0 then goto stop end
				if P.gameEnv.fall>0 and #P.field>P.clearing[1]then SFX("fall")end
				for i=1,#P.clearing do
					removeRow(P.field,P.clearing[i])
					removeRow(P.visTime,P.clearing[i])
				end
				::L::
					rem(P.clearing)
				if P.clearing[1]then goto L end
			end::stop::
			if P.endCounter<40 then
				for j=1,#P.field do for i=1,10 do
					if P.visTime[j][i]<20 then P.visTime[j][i]=P.visTime[j][i]+.5 end
				end end--Make field visible
			end
			if P.b2b1>0 then P.b2b1=max(0,P.b2b1*.92-1)end
			--Dead
		end
		for i=#P.shade,1,-1 do
			local S=P.shade[i]
			S[1]=S[1]-1
			if S[1]==0 then
				rem(P.shade,i)
			end
		end
		for i=#P.bonus,1,-1 do
			local b=P.bonus[i]
			if b.inf then
				if b.t<30 then
					b.t=b.t+.5
				end
			else
				b.t=b.t+b.speed
				if b.t>=60 then rem(P.bonus,i)end
			end
		end
		for i=#P.atkBuffer,1,-1 do
			local atk=P.atkBuffer[i]
			atk.time=atk.time+1
			if not atk.sent then
				if atk.countdown>0 then
					atk.countdown=atk.countdown-garbageSpeed
				end
			else
				if atk.time>20 then
					rem(P.atkBuffer,i)
				end
			end
		end
		if P.fieldBeneath>0 then P.fieldBeneath=max(P.fieldBeneath-pushSpeed,0)end
		if not P.small then
			PTC.dust[p]:update(dt)
		end
	end
	if modeEnv.royaleMode and frame%120==0 then freshMostDangerous()end
end