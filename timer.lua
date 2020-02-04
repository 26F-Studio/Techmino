Tmr={}
function Tmr.load()
	if loading==1 then
		loadnum=loadnum+1
		loadprogress=loadnum/10
		if loadnum==5 then
			--require("load_texture")
		elseif loadnum==10 then
			loadnum=1
			loading=2
		end
	elseif loading==2 then
		if loadnum<=#bgm then
			bgm[bgm[loadnum]]=love.audio.newSource("/BGM/"..bgm[loadnum]..".ogg","stream")
			bgm[bgm[loadnum]]:setLooping(true)
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
	for i=1,3 do
		PTC.attack[i]:update(dt)
	end
	-- Update attack beam

	if frame<180 then
		if frame==179 then
			gameStart()
		elseif frame%60==0 then
			sysSFX("ready")
		end
		for p=1,#players do
			P=players[p]
			if P.keyPressing[1]or P.keyPressing[2]then
				P.moving=P.moving+sgn(P.moving)
			else
				P.moving=0
			end
		end
		return nil
	end--Counting,include pre-das
	for p=1,#players do
		P=players[p]
		if P.timing then P.time=P.time+dt end
		if P.alive then
			local v=0
			for i=2,10 do v=v+i*(i-1)*7.2/(frame-P.keyTime[i])end P.keySpeed=P.keySpeed*.99+v*.1
			v=0
			for i=2,10 do v=v+i*(i-1)*7.2/(frame-P.dropTime[i])end P.dropSpeed=P.dropSpeed*.99+v*.1
			--Update speeds

			if P.ai and P.waiting<=0 then
				P.ai.controlDelay=P.ai.controlDelay-1
				if P.ai.controlDelay==0 then
					if #P.ai.controls>0 then
						pressKey(P.ai.controls[1],P)
						releaseKey(P.ai.controls[1],P)
						rem(P.ai.controls,1)
						P.ai.controlDelay=P.ai.controlDelay0+2
					else
						AI_getControls(P.ai.controls)
						P.ai.controlDelay=2*P.ai.controlDelay0
					end
				end
			end

			for j=1,#P.field do for i=1,10 do
				if P.visTime[j][i]>0 then P.visTime[j][i]=P.visTime[j][i]-1 end
			end end
			--Fresh visible time
			if P.keyPressing[1]or P.keyPressing[2]then
				P.moving=P.moving+sgn(P.moving)
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
				P.downing=P.downing+1
				local d=abs(P.downing)-P.gameEnv.sddas
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
			if modeEnv.royaleMode then
				if P.keyPressing[9]then
					P.swappingAtkMode=min(P.swappingAtkMode+2,30)
				else
					P.swappingAtkMode=P.swappingAtkMode+((#P.field>15 and P.swappingAtkMode>4 or P.swappingAtkMode>8)and -1 or 1)
				end
			end
			if P.falling>0 then
				P.falling=P.falling-1
				if P.falling<=0 then
					if #P.field>P.clearing[1]then SFX("fall")end
					for i=1,#P.clearing do
						removeRow(P.field,P.clearing[i])
						removeRow(P.visTime,P.clearing[i])
					end
					while #P.clearing>0 do
						rem(P.clearing)
					end
				end
				--Rows cleared drop
			elseif P.waiting>0 then
				P.waiting=P.waiting-1
				if P.waiting<=0 then
					resetblock()
				end
			else
				if P.cy~=P.y_img then
					if P.dropDelay>0 then
						P.dropDelay=P.dropDelay-1
					else
						drop()
						P.dropDelay=P.gameEnv.drop
						if P.freshTime<=P.gameEnv.freshLimit then
							P.lockDelay=P.gameEnv.lock
						end
					end
				else
					if P.lockDelay>0 then P.lockDelay=P.lockDelay-1
					else drop()
					end
				end
			end
			P.b2b1=P.b2b1*.92+P.b2b*.08
			--Alive
		else
			P.keySpeed=P.keySpeed*.96+P.cstat.key/P.time*60*.04
			P.dropSpeed=P.dropSpeed*.96+P.cstat.piece/P.time*60*.04
			--Final average speeds
			if P.falling>0 then
				P.falling=P.falling-1
				if P.falling<=0 then
					if #P.field>P.clearing[1]then SFX("fall")end
					for i=1,#P.clearing do
						removeRow(P.field,P.clearing[i])
						removeRow(P.visTime,P.clearing[i])
					end
					P.clearing={}
				end
			end--Rows cleared drop
			if P.counter<40 then
				for j=1,#P.field do for i=1,10 do
					if P.visTime[j][i]<20 then P.visTime[j][i]=P.visTime[j][i]+.5 end
				end end--Make field visible
			end
			if P.b2b1>0 then P.b2b1=max(P.b2b1-3,0)end
			--Dead
		end
		for i=#P.bonus,1,-1 do
			local b=P.bonus[i]
			if b.inf then
				if b.t<30 then
					b.t=b.t+1
				end
			else
				b.t=b.t+1
				if b.t==60 then rem(P.bonus,i)end
			end
		end
		for i=#P.task,1,-1 do
			if P.task[i]()then rem(P.task,i)end
		end
		for i=#P.atkBuffer,1,-1 do
			local atk=P.atkBuffer[i]
			atk.time=atk.time+1
			if not atk.sent then
				if atk.countdown>0 then
					atk.countdown=atk.countdown-1
				end
			else
				if atk.time>20 then
					rem(P.atkBuffer,i)
				end
			end
		end
		if P.fieldBeneath>0 then P.fieldBeneath=P.fieldBeneath-3 end
		if not P.small then
			PTC.dust[p]:update(dt)
		end
	end
	if modeEnv.royale and frame%120==0 then
		freshRoyaleTarget()
	end
	setmetatable(_G,nil)
end