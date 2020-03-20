local gc=love.graphics
local kb=love.keyboard
local Timer=love.timer.getTime
local int,abs,rnd,max,min,sin=math.floor,math.abs,math.random,math.max,math.min,math.sin
local ins,rem=table.insert,table.remove

local Tmr={}
function Tmr.load()
	local t=Timer()
	local L=sceneTemp
	::R::
	--L={stage,curPos,curLen}
	if L[1]==1 then
		local N=voiceName[L[2]]
		for i=1,#voiceList[N]do
			local V=voiceList[N][i]
			voiceBank[V]={love.audio.newSource("VOICE/"..V..".ogg","static")}
		end
		L[2]=L[2]+1
		if L[2]>L[3]then
			L[1],L[2],L[3]=2,1,#BGM.list
		end
	elseif L[1]==2 then
		BGM.loadOne(L[2])
		L[2]=L[2]+1
		if L[2]>L[3]then
			L[1],L[2],L[3]=3,1,#SFX.list
		end
	elseif L[1]==3 then
		SFX.loadOne(L[2])
		L[2]=L[2]+1
		if L[2]>L[3]then
			L[1],L[2],L[3]=4,1,#modes
		end
	elseif L[1]==4 then
		local m=modes[L[2]]
		modes[L[2]]=require("modes/"..m[1])
		local M=modes[L[2]]
		M.saveFileName,M.id=m[1],m.id
		M.x,M.y,M.size,M.shape=m.x,m.y,m.size,m.shape
		M.unlock=m.unlock
		M.records=loadRecord(m[1])or M.score and{}
		-- M.icon=gc.newImage("image/modeIcon/"..m.icon..".png")
		-- M.icon=gc.newImage("image/modeIcon/custom.png")
		L[2]=L[2]+1
		if L[2]>L[3]then
			L[1],L[2],L[3]=5,1,1
		end
	elseif L[1]==5 then
		--------------------------Loading some other things here?
		local N=gc.newImage
		titleImage=N("/image/mess/title.png")
		coloredTitleImage=N("/image/mess/title_colored.png")
		dialCircle=N("/image/mess/dialCircle.png")
		dialNeedle=N("/image/mess/dialNeedle.png")
		badgeIcon=N("/image/mess/badge.png")
		spinCenter=N("/image/mess/spinCenter.png")
		ctrlSpeedLimit=N("/image/mess/ctrlSpeedLimit.png")
		speedLimit=N("/image/mess/speedLimit.png")

		background1=N("/image/BG/bg1.png")
		background2=N("/image/BG/bg2.png")
		groupCode=N("/image/mess/groupCode.png")
		payCode=N("/image/mess/payCode.png")

		miya={
			ch=N("/image/miya/ch.png"),
			f1=N("/image/miya/f1.png"),
			f2=N("/image/miya/f2.png"),
			f3=N("/image/miya/f3.png"),
			f4=N("/image/miya/f4.png"),
		}
		skin.load()
		--------------------------
		L[1],L[2],L[3]=0,1,1
		SFX.play("welcome",.2)
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
	sceneTemp=sceneTemp+1
	if sceneTemp==200 then sceneTemp=80 end
end
function Tmr.main(dt)
	players[1]:update(dt)
end
local function dumpTable(L)
	local s="{\n"
	for k,v in next,L do
		local T
		T=type(k)
			if T=="number"then k="["..k.."]="
			elseif T=="string"then k=k.."="
			else error("Error data type!")
			end
		T=type(v)
			if T=="number"then v=tostring(v)
			elseif T=="string"then v="\""..v.."\""
			elseif T=="table"then v=dumpTable(v)
			else error("Error data type!")
			end
		s=s..k..v..",\n"
	end
	return s.."}"
end
function Tmr.mode(dt)
	local cam=mapCam
	local x,y,k=cam.x,cam.y,cam.k
	local F
	if not scene.swapping then
		if kb.isDown("up",	"w")then y=y-10*k;F=true end
		if kb.isDown("down","s")then y=y+10*k;F=true end
		if kb.isDown("left","a")then x=x-10*k;F=true end
		if kb.isDown("right","d")then x=x+10*k;F=true end
		local js1=joysticks[1]
		if js1 then
			local k=js1:getAxis(1)
			if k~="c"then
				if k=="u"or k=="ul"or k=="ur"then y=y-10*k;F=true end
				if k=="d"or k=="dl"or k=="dl"then y=y+10*k;F=true end
				if k=="l"or k=="ul"or k=="dl"then x=x-10*k;F=true end
				if k=="r"or k=="ur"or k=="dr"then x=x+10*k;F=true end
			end
		end
	end
	if F or cam.keyCtrl and(x-cam.x1)^2+(y-cam.y1)^2>2.6 then
		if F then
			cam.keyCtrl=true
		end
		local x,y=(cam.x1-180)/cam.k1,cam.y1/cam.k1
		local MM,R=modes,modeRanks
		for _=1,#MM do
			if R[_]then
				local __
				local M=MM[_]
				local s=M.size
				if M.shape==1 then
					if x>M.x-s and x<M.x+s and y>M.y-s and y<M.y+s then __=_ end
				elseif M.shape==2 then
					if abs(x-M.x)+abs(y-M.y)<s then __=_ end
				elseif M.shape==3 then
					if(x-M.x)^2+(y-M.y)^2<s^2 then __=_ end
				end
				if __ and cam.sel~=__ then
					cam.sel=__
					SFX.play("click")
				end
			end
		end
	end

	if x>1850*k then x=1850*k
	elseif x<-1000*k then x=-1000*k
	end
	if y>500*k then y=500*k
	elseif y<-1900*k then y=-1900*k
	end
	cam.x,cam.y=x,y
	--keyboard controlling
	
	cam.x1=cam.x1*.85+x*.15
	cam.y1=cam.y1*.85+y*.15
	cam.k1=cam.k1*.85+k*.15
	local _=scene.swap.tar
	cam.zoomMethod=_=="play"and 1 or _=="mode"and 2
	if cam.zoomMethod==1 then
		if cam.sel then
			local M=modes[cam.sel]
			cam.x=cam.x*.8+M.x*cam.k*.2
			cam.y=cam.y*.8+M.y*cam.k*.2
		end
		_=cam.zoomK
		if _<.8 then _=_*1.05 end
		if _<1.1 then _=_*1.05 end
		cam.zoomK=_*1.05
	elseif cam.zoomMethod==2 then
		cam.zoomK=cam.zoomK^.9
	end
end
function Tmr.draw()
	if sceneTemp.sure>0 then sceneTemp.sure=sceneTemp.sure-1 end
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
		local _=virtualkey[i]
		if _.pressTime>0 then
			_.pressTime=_.pressTime-1
		end
	end

	if frame<180 then
		if frame==179 then
			gameStart()
		elseif frame==60 or frame==120 then
			SFX.play("ready")
		end
		for p=1,#players do
			local P=players[p]
			if P.keyPressing[1]then
				if P.moving>0 then P.moving=0 end
				if -P.moving<=P.gameEnv.das then
					P.moving=P.moving-1
				end
			elseif P.keyPressing[2]then
				if P.moving<0 then P.moving=0 end
				if P.moving<=P.gameEnv.das then
					P.moving=P.moving+1
				end
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
	if sceneTemp.timer<50 then
		sceneTemp.timer=sceneTemp.timer+1
	end
end
function Tmr.setting_sound()
	local t=sceneTemp.jump
	if t>0 then
		sceneTemp.jump=t-1
	end
end
function Tmr.setting_control()
	local T=sceneTemp
	if T.wait>0 then
		T.wait=T.wait-1
		if T.wait==0 then
			T.pos=T.pos+T.dir
		else
			return
		end
	end
	if T.das>0 then
		T.das=T.das-1
	else
		T.arr=T.arr-1
		if T.arr==0 then
			T.pos=T.pos+T.dir
			T.arr=setting.arr
		elseif T.arr==-1 then
			T.pos=T.dir>0 and 8 or 0
			T.arr=setting.arr
		end
		if T.pos%8==0 then
			T.dir=-T.dir
			T.wait=20
			T.das=setting.das
		end
	end
end
return Tmr