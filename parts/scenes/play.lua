local gc=love.graphics
local tc=love.touch
local Timer=love.timer.getTime

local max,sin=math.max,math.sin
local log=math.log

local SCR=SCR--play/pause

local VK=virtualkey
local function onVirtualkey(x,y)
	local dist,nearest=1e10
	for K=1,#VK do
		local b=VK[K]
		if b.ava then
			local d1=(x-b.x)^2+(y-b.y)^2
			if d1<b.r^2 then
				if d1<dist then
					nearest,dist=K,d1
				end
			end
		end
	end
	return nearest
end

function sceneInit.play()
	love.keyboard.setKeyRepeat(false)
	restartCount=0
	if needResetGameData then
		resetGameData()
		needResetGameData=nil
	end
end

function touchDown.play(_,x,y)
	if not SETTING.VKSwitch or GAME.replaying then return end

	local t=onVirtualkey(x,y)
	if t then
		PLAYERS[1]:pressKey(t)
		if SETTING.VKSFX>0 then
			SFX.play("virtualKey",SETTING.VKSFX)
		end
		VK[t].isDown=true
		VK[t].pressTime=10
		if SETTING.VKTrack then
			local B=VK[t]
			if SETTING.VKDodge then--Button collision (not accurate)
			for i=1,#VK do
					local b=VK[i]
					local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5--Hit depth(Neg means distance)
					if d>0 then
						b.x=b.x+(b.x-B.x)*d*b.r*5e-4
						b.y=b.y+(b.y-B.y)*d*b.r*5e-4
					end
				end
			end
			local O=VK_org[t]
			local _FW,_CW=SETTING.VKTchW*.1,1-SETTING.VKCurW*.1
			local _OW=1-_FW-_CW

			--Auto follow: finger, current, origin (weight from setting)
			B.x,B.y=x*_FW+B.x*_CW+O.x*_OW,y*_FW+B.y*_CW+O.y*_OW
		end
		VIB(SETTING.VKVIB)
	end
end
function touchUp.play(_,x,y)
	if not SETTING.VKSwitch or GAME.replaying then return end

	local t=onVirtualkey(x,y)
	if t then
		PLAYERS[1]:releaseKey(t)
	end
end
function touchMove.play()
	if not SETTING.VKSwitch or GAME.replaying then return end

	local l=tc.getTouches()
	for n=1,#VK do
		local B=VK[n]
		for i=1,#l do
			local x,y=xOy:inverseTransformPoint(tc.getPosition(l[i]))
			if(x-B.x)^2+(y-B.y)^2<=B.r^2 then
				goto next
			end
		end
		PLAYERS[1]:releaseKey(n)
		::next::
	end
end
function keyDown.play(key)
	if GAME.replaying then return end

	local m=keyMap
	for k=1,20 do
		if key==m[1][k]or key==m[2][k]then
			PLAYERS[1]:pressKey(k)
			VK[k].isDown=true
			VK[k].pressTime=10
			return
		end
	end

	if key=="escape"then pauseGame()end
end
function keyUp.play(key)
	if GAME.replaying then return end
	local m=keyMap
	for k=1,20 do
		if key==m[1][k]or key==m[2][k]then
			PLAYERS[1]:releaseKey(k)
			VK[k].isDown=false
			return
		end
	end
end
function gamepadDown.play(key)
	if GAME.replaying then return end

	local m=keyMap
	for k=1,20 do
		if key==m[3][k]or key==m[4][k]then
			PLAYERS[1]:pressKey(k)
			VK[k].isDown=true
			VK[k].pressTime=10
			return
		end
	end

	if key=="back"then pauseGame()end
end
function gamepadUp.play(key)
	if GAME.replaying then return end

	local m=keyMap
	for k=1,20 do
		if key==m[3][k]or key==m[4][k]then
			PLAYERS[1]:releaseKey(k)
			VK[k].isDown=false
			return
		end
	end
end

function Tmr.play(dt)
	local _
	local P1=PLAYERS[1]
	local GAME=GAME
	GAME.frame=GAME.frame+1
	STAT.time=STAT.time+dt

	--Update virtualkey animation
	if SETTING.VKSwitch then
		for i=1,#VK do
			_=VK[i]
			if _.pressTime>0 then
				_.pressTime=_.pressTime-1
			end
		end
	end

	--Replay
	if GAME.replaying then
		_=GAME.replaying
		local L=GAME.rec
		while GAME.frame==L[_]do
			local k=L[_+1]
			if k>0 then
				P1:pressKey(k)
				VK[k].isDown=true
				VK[k].pressTime=10
			else
				VK[-k].isDown=false
				P1:releaseKey(-k)
			end
			_=_+2
		end
		GAME.replaying=_
	end

	--Counting,include pre-das,directy RETURN,or restart counting
	if GAME.frame<180 then
		if GAME.frame==179 then
			gameStart()
		elseif GAME.frame==60 or GAME.frame==120 then
			SFX.play("ready")
		end
		for p=1,#PLAYERS do
			local P=PLAYERS[p]
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
			resetPartGameData()
			return
		end
	elseif restartCount>0 then
		restartCount=restartCount>2 and restartCount-2 or 0
	end

	--Update players
	for p=1,#PLAYERS do
		local P=PLAYERS[p]
		P:update(dt)
	end

	--Fresh royale target
	if modeEnv.royaleMode and GAME.frame%120==0 then
		freshMostDangerous()
	end

	--Warning check
	if P1.alive then
		if GAME.frame%26==0 and SETTING.warn then
			local F=P1.field
			local height=0--Max height of row 4~7
			for x=4,7 do
				for y=#F,1,-1 do
					if F[y][x]>0 then
						if y>height then
							height=y
						end
						break
					end
				end
			end
			GAME.warnLVL0=log(height-15+P1.atkBuffer.sum*.8)
		end
		_=GAME.warnLVL
		if _<GAME.warnLVL0 then
			_=_*.95+GAME.warnLVL0*.05
		elseif _>0 then
			_=max(_-.026,0)
		end
		GAME.warnLVL=_
	elseif GAME.warnLVL>0 then
		GAME.warnLVL=max(GAME.warnLVL-.026,0)
	end
end

local function drawAtkPointer(x,y)
	local t=sin(Timer()*20)
	gc.setColor(.2,.7+t*.2,1,.6+t*.4)
	gc.circle("fill",x,y,25,6)
	local a=Timer()*3%1*.8
	gc.setColor(0,.6,1,.8-a)
	gc.circle("line",x,y,30*(1+a),6)
end
local function drawVirtualkey()
	local a=SETTING.VKAlpha
	local _
	if SETTING.VKIcon then
		local icons=TEXTURE.VKIcon
		for i=1,#VK do
			if VK[i].ava then
				local B=VK[i]
				gc.setColor(1,1,1,a)
				gc.setLineWidth(B.r*.07)
				gc.circle("line",B.x,B.y,B.r,10)--Button outline
				_=VK[i].pressTime
				gc.draw(icons[i],B.x,B.y,nil,B.r*.026+_*.08,nil,18,18)--Icon
				if _>0 then
					gc.setColor(1,1,1,a*_*.08)
					gc.circle("fill",B.x,B.y,B.r*.94,10)--Glow
					gc.circle("line",B.x,B.y,B.r*(1.4-_*.04),10)--Ripple
				end
			end
		end
	else
		for i=1,#VK do
			if VK[i].ava then
				local B=VK[i]
				gc.setColor(1,1,1,a)
				gc.setLineWidth(B.r*.07)
				gc.circle("line",B.x,B.y,B.r,10)
				_=VK[i].pressTime
				if _>0 then
					gc.setColor(1,1,1,a*_*.08)
					gc.circle("fill",B.x,B.y,B.r*.94,10)
					gc.circle("line",B.x,B.y,B.r*(1.4-_*.04),10)
				end
			end
		end
	end
end
function Pnt.play()
	if MARKING then
		setFont(26)
		local t=Timer()
		gc.setColor(1,1,1,.2+.1*(sin(3*t)+sin(2.6*t)))
		mStr(text.marking,190,60+26*sin(t))
	end
	for p=1,#PLAYERS do
		PLAYERS[p]:draw()
	end

	gc.setColor(1,1,1)
	if SETTING.VKSwitch then drawVirtualkey()end

	if modeEnv.royaleMode then
		local P=PLAYERS[1]
		gc.setLineWidth(5)
		gc.setColor(.8,1,0,.2)
		for i=1,#P.atker do
			local p=P.atker[i]
			gc.line(p.centerX,p.centerY,P.x+300*P.size,P.y+670*P.size)
		end
		if P.atkMode~=4 then
			if P.atking then drawAtkPointer(P.atking.centerX,P.atking.centerY)end
		else
			for i=1,#P.atker do
				local p=P.atker[i]
				drawAtkPointer(p.centerX,p.centerY)
			end
		end
	end

	--Mode info
	gc.setColor(1,1,1,.8)
	gc.draw(drawableText.modeName,485,10)
	gc.draw(drawableText.levelName,511+drawableText.modeName:getWidth(),10)

	--Replaying
	if GAME.replaying then
		gc.setColor(1,1,Timer()%1>.5 and 1 or 0)
		mText(drawableText.replaying,410,17)
	end

	--Warning
	gc.push("transform")
	gc.origin()
	if GAME.warnLVL>0 then
		gc.setColor(0,0,0,0)
		SHADER.warning:send("level",GAME.warnLVL)
		gc.setShader(SHADER.warning)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
		gc.setShader()
	end
	if restartCount>0 then
		gc.setColor(0,0,0,restartCount*.05)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
	end
	gc.pop()
end

WIDGET.init("play",{
	WIDGET.newButton({name="pause",	x=1235,	y=45,	w=80,		font=25,code=function()pauseGame()end}),
})