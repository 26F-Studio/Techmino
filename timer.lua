local wd=love.window
local Timer=love.timer.getTime
local int,abs,rnd,max,min,sin=math.floor,math.abs,math.random,math.max,math.min,math.sin
local ins,rem=table.insert,table.remove

local Tmr={}
function Tmr.load()
	local t=Timer()
	local L=loading
	::R::
	if L[1]==1 then
		local N=voiceName[L[2]]
		for i=1,#voiceList[N]do
			local V=voiceList[N][i]
			voiceBank[V]={love.audio.newSource("VOICE/"..V..".ogg","static")}
		end
		L[2]=L[2]+1
		if L[2]>L[3]then
			L[1],L[2],L[3]=2,1,#bgm
		end
	elseif L[1]==2 then
		local N=bgm[L[2]]
		bgm[N]=love.audio.newSource("/BGM/"..N..".ogg","stream")
		bgm[N]:setLooping(true)
		bgm[N]:setVolume(0)
		L[2]=L[2]+1
		if L[2]>L[3]then
			for i=1,#bgm do bgm[i]=nil end
			L[1],L[2],L[3]=3,1,#sfx
		end
	elseif L[1]==3 then
		local S=sfx[L[2]]
		sfx[S]={love.audio.newSource("/SFX/"..S..".ogg","static")}
		L[2]=L[2]+1
		if L[2]>L[3]then
			for i=1,L[2]do sfx[i]=nil end
			L[1],L[2],L[3]=4,1,1
			SFX("welcome",.2)
		end
	else
		L[2]=L[2]+1
		L[3]=L[2]
		if L[2]>50 then
			stat.run=stat.run+1
			scene.swapTo("intro","none")
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
			b.rad=b.rad*1.05+.1
			b.x,b.y=b.x2,b.y2
		elseif b.t>10 then
			local t=((b.t-10)*.025)t=(3-2*t)*t*t
			b.x,b.y=b.x1*(1-t)+b.x2*t,b.y1*(1-t)+b.y2*t
		end
		if b.t<60 then
			local L=FX_attack[i].drag
			if #L==4*setting.atkFX then
				rem(L,1)rem(L,1)
			end
			ins(L,b.x)ins(L,b.y)
		else
			for i=i,#FX_attack do
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
		restartCount=restartCount>2 and restartCount-2 or 0
	end--Counting,include pre-das,directy RETURN,or restart counting
	for p=1,#players do
		local P=players[p]
		P:update(dt)
	end
	if modeEnv.royaleMode and frame%120==0 then freshMostDangerous()end
end
function Tmr.pause(dt)
	if not gameResult then
		pauseTime=pauseTime+dt
	end
	if pauseTimer<50 and not wd.isMinimized()then
		pauseTimer=pauseTimer+1
	end
end
return Tmr