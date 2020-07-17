local gc=love.graphics
local kb=love.keyboard
local Timer=love.timer.getTime
local int,abs,rnd,max,min,sin,ln=math.floor,math.abs,math.random,math.max,math.min,math.sin,math.log
local ins,rem=table.insert,table.remove

local Tmr={}
function Tmr.load()
	local t=Timer()
	local S=sceneTemp
	repeat
		if S.phase==1 then
			VOC.loadOne(S.cur)
		elseif S.phase==2 then
			BGM.loadOne(S.cur)
		elseif S.phase==3 then
			SFX.loadOne(S.cur)
		elseif S.phase==4 then
			IMG.loadOne(S.cur)
		elseif S.phase==5 then
			local m=Modes[S.cur]--mode template
			local M=require("modes/"..m.name)--mode file
			Modes[m.name],Modes[S.cur]=M
			for k,v in next,m do
				M[k]=v
			end
			M.records=FILE.loadRecord(m.name)or M.score and{}
			-- M.icon=gc.newImage("image/modeIcon/"..m.icon..".png")
			-- M.icon=gc.newImage("image/modeIcon/custom.png")
		elseif S.phase==6 then
			--------------------------Loading other little things here
			SKIN.load()
			stat.run=stat.run+1
			--------------------------
			SFX.play("welcome_sfx")
			VOC.play("welcome")
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
	until not S.skip and Timer()-t>.01
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
			else assert(false,"Error data type!")
			end
		T=type(v)
			if T=="number"then v=tostring(v)
			elseif T=="string"then v="\""..v.."\""
			elseif T=="table"then v=dumpTable(v)
			else assert(false,"Error data type!")
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
		for name,M in next,Modes do
			if modeRanks[name]then
				local SEL
				local s=M.size
				if M.shape==1 then
					if x>M.x-s and x<M.x+s and y>M.y-s and y<M.y+s then SEL=name end
				elseif M.shape==2 then
					if abs(x-M.x)+abs(y-M.y)<s then SEL=name end
				elseif M.shape==3 then
					if(x-M.x)^2+(y-M.y)^2<s^2 then SEL=name end
				end
				if SEL and cam.sel~=SEL then
					cam.sel=SEL
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
			local M=Modes[cam.sel]
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
function Tmr.sequence()
	if sceneTemp.sure>0 then sceneTemp.sure=sceneTemp.sure-1 end
end
function Tmr.draw()
	if sceneTemp.sure>0 then sceneTemp.sure=sceneTemp.sure-1 end
end
function Tmr.play(dt)
	game.frame=game.frame+1
	stat.time=stat.time+dt
	local P1=players[1]
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

	if game.frame<180 then
		if game.frame==179 then
			gameStart()
		elseif game.frame==60 or game.frame==120 then
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
	elseif P1.keyPressing[10]then
		restartCount=restartCount+1
		if restartCount>20 then
			TASK.clear("play")
			mergeStat(stat,P1.stat)
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
	if game.frame%120==0 then
		if modeEnv.royaleMode then freshMostDangerous()end
	end
	if P1.alive then
		if game.frame%26==0 and setting.warn then
			local F=P1.field
			local M=#F
			local height=0--max height of row 4~7
			for x=4,7 do
				for y=M,1,-1 do
					if F[y][x]>0 then
						if y>height then
							height=y
						end
						break
					end
				end
			end
			game.warnLVL0=ln(height-15+P1.atkBuffer.sum*.8)
		end
		local M=game.warnLVL
		if M<game.warnLVL0 then
			M=M*.95+game.warnLVL0*.05
		elseif M>0 then
			M=max(M-.026,0)
		end
		game.warnLVL=M
	elseif game.warnLVL>0 then
		game.warnLVL=max(game.warnLVL-.026,0)
	end
end
function Tmr.pause(dt)
	if not game.result then
		game.pauseTime=game.pauseTime+dt
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
		if T.das==0 then
			T.pos=T.pos+T.dir
		end
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
			T.wait=26
			T.das=setting.das
		end
	end
end
function Tmr.staff(dt)
	local S=sceneTemp
	if kb.isDown("space","return")and S.v<6.26 then
		S.v=S.v+.26
	elseif S.v>1 then
		S.v=S.v-.26
	end
	S.time=S.time+S.v*dt
	if S.time>45 then
		S.time=45
	elseif S.time<-10 then
		S.time=-10
	end
end
return Tmr