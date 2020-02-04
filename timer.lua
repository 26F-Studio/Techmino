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
			gotoScene("main")
		end
	end
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

	if count then
		count=count-1
		if count==0 then
			count=nil
			sysSFX("start")
			for P=1,#players do
				P=players[P]
				_G.P=P
				setmetatable(_G,P.index)
				P.control=true
				P.timing=true
				resetblock()
			end
			setmetatable(_G,nil)
		elseif count%60==0 then
			sysSFX("ready")
		end

		if count then
			for p=1,#players do
				P=players[p]
				setmetatable(_G,P.index)
				if keyPressing[1]or keyPressing[2]then
					P.moving=moving+sgn(moving)
				else
					P.moving=0
				end
			end
			return nil
		end
	end--Start counting,include pre-das
	for p=1,#players do
		P=players[p]
		setmetatable(_G,P.index)
		if timing then P.time=time+dt end
		if alive then
			local v=0
			for i=2,10 do v=v+i*(i-1)*7.2/(frame-keyTime[i])end P.keySpeed=keySpeed*.99+v*.1
			v=0 for i=2,10 do v=v+i*(i-1)*7.2/(frame-dropTime[i])end P.dropSpeed=dropSpeed*.99+v*.1
			--Update speeds

			if P.ai and waiting<=0 then
				P.ai.controlDelay=P.ai.controlDelay-1
				if P.ai.controlDelay==0 then
					if #P.ai.controls>0 then
						pressKey(P.ai.controls[1],P)
						releaseKey(P.ai.controls[1],P)
						rem(P.ai.controls,1)
						P.ai.controlDelay=P.ai.controlDelay0+rnd(3)
					else
						AI_getControls(P.ai.controls)
						P.ai.controlDelay=2*P.ai.controlDelay0
					end
				end
			end

			for j=1,#field do for i=1,10 do
				if visTime[j][i]>0 then P.visTime[j][i]=visTime[j][i]-1 end
			end end
			--Fresh visible time
			if keyPressing[1]or keyPressing[2]then
				P.moving=moving+sgn(moving)
				local d=abs(moving)-gameEnv.das
				if d>1 then
					if gameEnv.arr>0 then
						if d%gameEnv.arr==0 then
							act[moving>0 and"moveRight"or"moveLeft"](true)
						end
					else
						act[moving>0 and"insRight"or"insLeft"]()
					end
				end
			else
				P.moving=0
			end
			if keyPressing[7]then
				P.downing=downing+1
				local d=abs(downing)-gameEnv.sddas
				if d>1 then
					if gameEnv.sdarr>0 then
						if d%gameEnv.sdarr==0 then
							act.down1()
						end
					else
						act.insDown()
					end
				end
			else
				P.downing=0
			end
			if falling>0 then
				P.falling=falling-1
				if falling<=0 then
					if #field>clearing[1]then SFX("fall")end
					for i=1,#clearing do
						removeRow(field,clearing[i])
						removeRow(visTime,clearing[i])
					end
					while #clearing>0 do
						rem(clearing)
					end
				end
				--Rows cleared drop
			elseif waiting>0 then
				P.waiting=waiting-1
				if waiting<=0 then
					resetblock()
				end
			else
				if cy~=y_img then
					if dropDelay>0 then
						P.dropDelay=dropDelay-1
					else
						drop()
						P.dropDelay=gameEnv.drop
						if P.freshTime<=gameEnv.freshLimit then
							P.lockDelay=gameEnv.lock
						end
					end
				else
					if lockDelay>0 then P.lockDelay=lockDelay-1
					else drop()
					end
				end
			end
			P.b2b1=P.b2b1*.93+P.b2b*.07
			if P.b2b>500 then
				P.b2b=P.b2b-.06
			end
			--Alive
		else
			P.keySpeed=keySpeed*.96+cstat.key/time*60*.04
			P.dropSpeed=dropSpeed*.96+cstat.piece/time*60*.04
			--Final average speeds
			if falling>0 then
				P.falling=falling-1
				if falling<=0 then
					if #field>clearing[1]then SFX("fall")end
					for i=1,#clearing do
						removeRow(field,clearing[i])
						removeRow(visTime,clearing[i])
					end
					P.clearing={}
				end
			end--Rows cleared drop
			if P.counter<40 then
				for j=1,#field do for i=1,10 do
					if visTime[j][i]<20 then P.visTime[j][i]=visTime[j][i]+.5 end
				end end--Make field visible
			end
			if P.b2b1>0 then P.b2b1=max(P.b2b1-3,0)end
			--Dead
		end
		for i=#bonus,1,-1 do
			if bonus[i].inf then
				if bonus[i].t<30 then
					bonus[i].t=bonus[i].t+1
				end
			else
				bonus[i].t=bonus[i].t+1
				if bonus[i].t==60 then rem(bonus,i)end
			end
		end
		for i=#task,1,-1 do
			if task[i]()then rem(task,i)end
		end
		for i=#atkBuffer,1,-1 do
			local atk=atkBuffer[i]
			atk.time=atk.time+1
			if not atk.sent then
				if atk.countdown>0 then
					atk.countdown=atk.countdown-1
				end
			else
				if atk.time>20 then
					rem(atkBuffer,i)
				end
			end
		end
		if fieldBeneath>0 then P.fieldBeneath=fieldBeneath-3 end
		PTC.dust[p]:update(dt)
	end
	setmetatable(_G,nil)
end