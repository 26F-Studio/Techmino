local wd=love.window
local Timer=love.timer.getTime
local int,abs,rnd,max,min,sin=math.floor,math.abs,math.random,math.max,math.min,math.sin
local ins,rem=table.insert,table.remove

return{
load=function()
	local t=Timer()
	::R::
	if loading==1 then
		if loadnum<=#voiceName then
			local N=voiceName[loadnum]
			for i=1,#voiceList[N]do
				voiceBank[voiceList[N][i]]={love.audio.newSource("VOICE/"..voiceList[N][i]..".ogg","static")}
			end
			loadprogress=loadnum/#voiceName
			loadnum=loadnum+1
		else
			loading=2
			loadnum=1
		end
	elseif loading==2 then
		if loadnum<=#bgm then
			local N=bgm[loadnum]
			bgm[N]=love.audio.newSource("/BGM/"..N..".ogg","stream")
			bgm[N]:setLooping(true)
			bgm[N]:setVolume(0)
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
			loadnum=1
		end
	elseif loading==4 then
		loadnum=loadnum+1
		if loadnum==15 then
			stat.run=stat.run+1
			gotoScene("intro","none")
		end
	end
end,
intro=function()
	count=count+1
	if count==200 then count=80 end
end,
draw=function()
	if clearSureTime>0 then clearSureTime=clearSureTime-1 end
end,
play=function(dt)
	frame=frame+1
	stat.time=stat.time+dt
	for i=#FX_attack,1,-1 do
		local b=FX_attack[i]
		b.t=b.t+1
		if b.t>50 then
			b.rad=b.rad*1.08+.2
			b.x,b.y=b.x2,b.y2
		elseif b.t>10 then
			local t=((b.t-10)*.025)t=(3-2*t)*t*t
			b.x,b.y=b.x1*(1-t)+b.x2*t,b.y1*(1-t)+b.y2*t
		end
		if b.t<60 then
			local L=FX_attack[i].drag
			if #L==10 then
				rem(L,1)rem(L,1)
			end
			ins(L,b.x)ins(L,b.y)
		else
			for i=1,#FX_attack do
				FX_attack[i]=FX_attack[i+1]
			end
		end
	end

	for i=#FX_badge,1,-1 do
		local b=FX_badge[i]
		b.t=b.t+1
		if b.t==60 then
			rem(FX_badge,i)
		end
	end
	for i=1,#virtualkey do
		if virtualkeyPressTime[i]>0 then
			virtualkeyPressTime[i]=virtualkeyPressTime[i]-1
		end
	end

	if frame<180 then
		if frame==179 then
			gameStart()
		elseif frame==60 or frame==120 then
			SFX("ready")
		end
		for p=1,#players do
			P=players[p]
			if P.keyPressing[1]then
				if P.moving>0 then P.moving=0 end
				P.moving=P.moving-1
			elseif P.keyPressing[2]then
				if P.moving<0 then P.moving=0 end
				P.moving=P.moving+1
			else
				P.moving=0
			end
		end
		if restartCount>0 then restartCount=restartCount-1 end
		return
	elseif players[1].keyPressing[10]then
		restartCount=restartCount+1
		if restartCount>20 then
			clearTask("play")
			updateStat()
			resetGameData()
			return
		end
	elseif restartCount>0 then
		restartCount=max(restartCount-2,0)
	end--Counting,include pre-das,directy RETURN,or restart counting
	for p=1,#players do
		P=players[p]
		if P.timing then P.stat.time=P.stat.time+dt end
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

			if not P.human and P.control and P.waiting==-1 then
				local C=P.AI_keys
				P.AI_delay=P.AI_delay-1
				if not C[1]then
					P.AI_stage=AI_think[P.AI_mode][P.AI_stage](C)
				elseif P.AI_delay<=0 then
					pressKey(C[1],P)releaseKey(C[1],P)
					local k=#C for i=1,k do C[i]=C[i+1]end--table.remove(C,1)
					P.AI_delay=P.AI_delay0*2
				end
			end
			if not P.keepVisible then
				for j=1,#P.field do for i=1,10 do
					if P.visTime[j][i]>0 then P.visTime[j][i]=P.visTime[j][i]-1 end
				end end
			end--Fresh visible time
			if P.moving<0 then
				if P.keyPressing[1]then
					if -P.moving<=P.gameEnv.das then
						P.moving=P.moving-1
					elseif P.waiting==-1 then
						local x=P.curX
						if P.gameEnv.arr>0 then
							act.moveLeft(true)
						else
							act.insLeft()
						end
						if x~=P.curX then P.moving=P.moving+P.gameEnv.arr-1 end
					end
				else
					P.moving=0
				end
			elseif P.moving>0 then
				if P.keyPressing[2]then
					if P.moving<=P.gameEnv.das then
						P.moving=P.moving+1
					elseif P.waiting==-1 then
						local x=P.curX
						if P.gameEnv.arr>0 then
							act.moveRight(true)
						else
							act.insRight()
						end
						if x~=P.curX then P.moving=P.moving-P.gameEnv.arr+1 end
					end
				else
					P.moving=0
				end
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
				if P.falling>=0 then
					goto stop
				else
					local L=#P.clearing
					if P.human and P.gameEnv.fall>0 and #P.field+L>P.clearing[L]then SFX("fall")end
					for i=1,L do
						P.clearing[i]=nil
					end
				end
			end
			if not P.control then goto stop end
			if P.waiting>=0 then
				P.waiting=P.waiting-1
				if P.waiting==-1 then resetblock()end
				goto stop
			end
			if P.curY~=P.y_img then
				if P.dropDelay>=0 then
					P.dropDelay=P.dropDelay-1
					if P.dropDelay>0 then goto stop end
				end
				P.curY=P.curY-1
				P.spinLast=false
				if P.y_img~=P.curY then
					P.dropDelay=P.gameEnv.drop
				elseif P.AI_mode=="CC"then
					P.AI_needFresh=true
					if not P.AIdata._20G and P.gameEnv.drop<P.AI_delay0*.5 then
						CC_switch20G(P)
					end
				end
				if P.freshTime<=P.gameEnv.freshLimit then
					P.lockDelay=P.gameEnv.lock
				end
			else
				P.lockDelay=P.lockDelay-1
				if P.lockDelay>=0 then goto stop end
				drop()
				if P.AI_mode=="CC"then
					P.AI_needFresh=true
				end
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
				P.keySpeed=P.keySpeed*.96+P.stat.key/P.stat.time*60*.04
				P.dropSpeed=P.dropSpeed*.96+P.stat.piece/P.stat.time*60*.04
				--Final average speeds
				if modeEnv.royaleMode then
					P.swappingAtkMode=min(P.swappingAtkMode+2,30)
				end
			end
			if P.falling>=0 then
				P.falling=P.falling-1
				if P.falling>=0 then
					goto stop
				else
					local L=#P.clearing
					if P.human and P.gameEnv.fall>0 and #P.field+L>P.clearing[L]then SFX("fall")end
					for i=1,L do
						P.clearing[i]=nil
					end
				end
			end::stop::
			if P.endCounter<40 then
				for j=1,#P.field do for i=1,10 do
					if P.visTime[j][i]<20 then P.visTime[j][i]=P.visTime[j][i]+.5 end
				end end--Make field visible
			end
			if P.b2b1>0 then P.b2b1=max(0,P.b2b1*.92-1)end
			--Dead
		end
		if P.stat.score>P.score1 then
			if P.stat.score-P.score1<10 then
				P.score1=P.score1+1
			else
				P.score1=int(min(P.score1*.9+P.stat.score*.1+1))
			end
		end
		for i=#P.shade,1,-1 do
			local S=P.shade[i]
			S[1]=S[1]-1+setting.dropFX*.25
			if S[1]<=0 then
				rem(P.shade,i)
			end
		end
		if P.fieldOffY>0 then
			P.fieldOffY=P.fieldOffY-(P.fieldOffY>3 and 2 or 1)
		end
		if P.fieldOffX~=0 then
			P.fieldOffX=P.fieldOffX-(P.fieldOffX>0 and 1 or -1)
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
			local A=P.atkBuffer[i]
			A.time=A.time+1
			if not A.sent then
				if A.countdown>0 then
					A.countdown=max(A.countdown-garbageSpeed,0)
				end
			else
				if A.time>20 then
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
end,
pause=function(dt)
	if not gamefinished then
		pauseTime=pauseTime+dt
	end
	if pauseTimer<50 and not wd.isMinimized()then
		pauseTimer=pauseTimer+1
	end
end,
}