local wd=love.window
local Timer=love.timer.getTime
local int,abs,rnd,max,min,sin=math.floor,math.abs,math.random,math.max,math.min,math.sin
local ins,rem=table.insert,table.remove

local Tmr={}
function Tmr.load()
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
			SFX("welcome",.2)
		end
	elseif loading==4 then
		loadnum=loadnum+1
		if loadnum==48 then
			stat.run=stat.run+1
			gotoScene("intro","none")
		end
	end
end
function Tmr.intro()
	count=count+1
	if count==200 then count=80 end
end
function Tmr.main(dt)
	players[1]:update(dt)
end
function Tmr.draw()
	if clearSureTime>0 then clearSureTime=clearSureTime-1 end
end
function Tmr.play(dt)
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
			if #L==6*setting.atkFX then
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
			local P=players[p]
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
		local P=players[p]
		P:update(dt)
	end
	if modeEnv.royaleMode and frame%120==0 then freshMostDangerous()end
end
function Tmr.pause(dt)
	if not gamefinished then
		pauseTime=pauseTime+dt
	end
	if pauseTimer<50 and not wd.isMinimized()then
		pauseTimer=pauseTimer+1
	end
end
return Tmr