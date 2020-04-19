local gc=love.graphics
local kb=love.keyboard
local Timer=love.timer.getTime
local int,abs,rnd,max,min,sin=math.floor,math.abs,math.random,math.max,math.min,math.sin
local ins,rem=table.insert,table.remove

local Tmr={}
function Tmr.load()
	local t=Timer()
	local S=sceneTemp
	::R::
	--L={stage,curPos,curLen}
	if S.phase==1 then
		local N=voiceName[S.cur]
		for i=1,#voiceList[N]do
			local V=voiceList[N][i]
			voiceBank[V]={love.audio.newSource("VOICE/"..V..".ogg","static")}
		end
	elseif S.phase==2 then
		BGM.loadOne(S.cur)
	elseif S.phase==3 then
		SFX.loadOne(S.cur)
	elseif S.phase==4 then
		IMG.loadOne(S.cur)
	elseif S.phase==5 then
		local m=modes[S.cur]
		modes[S.cur]=require("modes/"..m[1])
		local M=modes[S.cur]
		M.saveFileName,M.id=m[1],m.id
		M.x,M.y,M.size,M.shape=m.x,m.y,m.size,m.shape
		M.unlock=m.unlock
		M.records=FILE.loadRecord(m[1])or M.score and{}
		-- M.icon=gc.newImage("image/modeIcon/"..m.icon..".png")
		-- M.icon=gc.newImage("image/modeIcon/custom.png")
	elseif S.phase==6 then
		--------------------------Loading some other things here?
		skin.load()
		stat.run=stat.run+1
		--------------------------
		SFX.play("welcome",.2)
	else
		S.cur=S.cur+1
		S.tar=S.cur
		if S.cur>62.6 then
			SCN.swapTo("intro","none")
		end
		return
	end
	S.cur=S.cur+1
	if S.cur>S.tar then
		S.phase=S.phase+1
		S.cur=1
		S.tar=S.list[S.phase]
		if not S.tar then
			S.phase=0
			S.tar=1
		end
	end
	if S.skip and not SCN.swapping then goto R end
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
	if not SCN.swapping then
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
	local _=SCN.swap.tar
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
	local _
	for i=1,#virtualkey do
		_=virtualkey[i]
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
			if P.movDir~=0 then
				if P.moving<P.gameEnv.das then
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
			TASK.clear("play")
			mergeStat(stat,players[1].stat)
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
	if frame%120==0 then
		if modeEnv.royaleMode then freshMostDangerous()end
		if marking and rnd()<.2 then
			TEXT.show("游戏作者:MrZ_26\n出现此水印则为非法录屏上传",rnd(162,scr.w-162),rnd(126,scr.h-200),40,"mark",.626)
		end--mark 2s each 10s
	end
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