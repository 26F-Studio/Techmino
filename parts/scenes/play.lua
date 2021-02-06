local gc=love.graphics
local gc_setColor,gc_circle=gc.setColor,gc.circle
local tc=love.touch

local int=math.floor
local max,sin=math.max,math.sin

local SCR=SCR
local VK=virtualkey
local function onVirtualkey(x,y)
	local dist,nearest=1e10
	for K=1,#VK do
		local B=VK[K]
		if B.ava then
			local d1=(x-B.x)^2+(y-B.y)^2
			if d1<B.r^2 then
				if d1<dist then
					nearest,dist=K,d1
				end
			end
		end
	end
	return nearest
end

local noTouch,noKey=false,false
local touchMoveLastFrame=false

local scene={}

function scene.sceneInit()
	love.keyboard.setKeyRepeat(false)
	if GAME.init then
		resetGameData()
		GAME.init=false
	end
	noKey=GAME.replaying
	noTouch=not SETTING.VKSwitch or noKey
end

scene.mouseDown=NULL
local function restart()
	resetGameData(GAME.frame<240 and"q")
end
function scene.touchDown(_,x,y)
	if noTouch then return end

	local t=onVirtualkey(x,y)
	if t then
		PLAYERS[1]:pressKey(t)
		if SETTING.VKSFX>0 then
			SFX.play("virtualKey",SETTING.VKSFX)
		end
		local B=VK[t]
		B.isDown=true
		B.pressTime=10
		if SETTING.VKTrack then
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
			local _FW,_CW=SETTING.VKTchW,1-SETTING.VKCurW
			local _OW=1-_FW-_CW

			--Auto follow: finger, current, origin (weight from setting)
			B.x,B.y=x*_FW+B.x*_CW+O.x*_OW,y*_FW+B.y*_CW+O.y*_OW
		end
		VIB(SETTING.VKVIB)
	end
end
function scene.touchUp(_,x,y)
	if noTouch then return end

	local t=onVirtualkey(x,y)
	if t then
		PLAYERS[1]:releaseKey(t)
	end
end
function scene.touchMove()
	if noTouch or touchMoveLastFrame then return end
	touchMoveLastFrame=true

	local L=tc.getTouches()
	for i=#L,1,-1 do
		L[2*i-1],L[2*i]=SCR.xOy:inverseTransformPoint(tc.getPosition(L[i]))
	end
	for n=1,#VK do
		local B=VK[n]
		if B.ava then
			for i=1,#L,2 do
				if(L[i]-B.x)^2+(L[i+1]-B.y)^2<=B.r^2 then
					goto continue
				end
			end
			PLAYERS[1]:releaseKey(n)
		end
		::continue::
	end
end
function scene.keyDown(key)
	local k=keyMap.keyboard[key]
	if k then
		if k>0 then
			if noKey then return end
			PLAYERS[1]:pressKey(k)
			VK[k].isDown=true
			VK[k].pressTime=10
		else
			restart()
		end
	elseif key=="escape"then
		pauseGame()
	end
end
function scene.keyUp(key)
	if noKey then return end
	local k=keyMap.keyboard[key]
	if k then
		if k>0 then
			PLAYERS[1]:releaseKey(k)
			VK[k].isDown=false
		end
	elseif key=="back"then
		pauseGame()
	end
end
function scene.gamepadDown(key)
	if noKey then return end
	local k=keyMap.joystick[key]
	if k then
		if k>0 then
			PLAYERS[1]:pressKey(k)
			VK[k].isDown=true
			VK[k].pressTime=10
		else
			restart()
		end
	elseif key=="back"then
		pauseGame()
	end
end
function scene.gamepadUp(key)
	if noKey then return end
	local k=keyMap.joystick[key]
	if k then
		if k>0 then
			PLAYERS[1]:releaseKey(k)
			VK[k].isDown=false
		end
	elseif key=="back"then
		pauseGame()
	end
end

function scene.update(dt)
	local _
	local P1=PLAYERS[1]
	local GAME=GAME
	GAME.frame=GAME.frame+1

	touchMoveLastFrame=false

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
		local L=GAME.rep
		while GAME.frame==L[_]do
			local key=L[_+1]
			if key==0 then--Just wait
			elseif key<=32 then--Press key
				P1:pressKey(key)
				VK[key].isDown=true
				VK[key].pressTime=10
			elseif key<=64 then--Release key
				VK[key-32].isDown=false
				P1:releaseKey(key-32)
			end
			_=_+2
		end
		GAME.replaying=_
	end

	--Counting,include pre-das,directy RETURN,or restart counting
	if GAME.frame<=180 then
		if GAME.frame==180 then
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
		return
	end

	--Update players
	for p=1,#PLAYERS do
		PLAYERS[p]:update(dt)
	end

	--Fresh royale target
	if GAME.modeEnv.royaleMode and GAME.frame%120==0 then
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
			GAME.warnLVL0=math.log(height-15+P1.atkBuffer.sum*.8)
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
	if GAME.warnLVL>1.126 and GAME.frame%30==0 then
		SFX.fplay("warning",SETTING.sfx_warn)
	end
end

local function drawAtkPointer(x,y)
	local t=TIME()
	local a=t*3%1*.8
	t=sin(t*20)

	gc_setColor(.2,.7+t*.2,1,.6+t*.4)
	gc_circle("fill",x,y,25,6)

	gc_setColor(0,.6,1,.8-a)
	gc_circle("line",x,y,30*(1+a),6)
end
function scene.draw()
	local t=TIME()
	if MARKING then
		setFont(25)
		gc_setColor(1,1,1,.2+.1*(sin(3*t)+sin(2.6*t)))
		mStr(text.marking,190,60+26*sin(t))
	end

	--Players
	for p=1,#PLAYERS do
		PLAYERS[p]:draw()
	end

	--Virtual keys
	if SETTING.VKSwitch then
		local a=SETTING.VKAlpha
		local _
		if SETTING.VKIcon then
			local icons=TEXTURE.VKIcon
			for i=1,#VK do
				if VK[i].ava then
					local B=VK[i]
					gc_setColor(1,1,1,a)
					gc.setLineWidth(B.r*.07)
					gc_circle("line",B.x,B.y,B.r,10)--Button outline
					_=VK[i].pressTime
					gc_setColor(B.color[1],B.color[2],B.color[3],a)
					gc.draw(icons[i],B.x,B.y,nil,B.r*.026+_*.08,nil,18,18)--Icon
					if _>0 then
						gc_setColor(1,1,1,a*_*.08)
						gc_circle("fill",B.x,B.y,B.r*.94,10)--Glow when press
						gc_circle("line",B.x,B.y,B.r*(1.4-_*.04),10)--Ripple
					end
				end
			end
		else
			for i=1,#VK do
				if VK[i].ava then
					local B=VK[i]
					gc_setColor(1,1,1,a)
					gc.setLineWidth(B.r*.07)
					gc_circle("line",B.x,B.y,B.r,10)
					_=VK[i].pressTime
					if _>0 then
						gc_setColor(1,1,1,a*_*.08)
						gc_circle("fill",B.x,B.y,B.r*.94,10)
						gc_circle("line",B.x,B.y,B.r*(1.4-_*.04),10)
					end
				end
			end
		end
	end

	--Attacking & Being attacked
	if GAME.modeEnv.royaleMode then
		local P=PLAYERS[1]
		gc.setLineWidth(5)
		gc_setColor(.8,1,0,.2)
		for i=1,#P.atker do
			local p=P.atker[i]
			gc.line(p.centerX,p.centerY,P.x+300*P.size,P.y+670*P.size)
		end
		if P.atkMode~=4 then
			if P.atking then
				drawAtkPointer(P.atking.centerX,P.atking.centerY)
			end
		else
			for i=1,#P.atker do
				local p=P.atker[i]
				drawAtkPointer(p.centerX,p.centerY)
			end
		end
	end

	--Mode info
	gc_setColor(1,1,1,.8)
	gc.draw(drawableText.modeName,485,10)
	gc.draw(drawableText.levelName,511+drawableText.modeName:getWidth(),10)

	--Replaying
	if GAME.replaying then
		gc_setColor(1,1,t%1>.5 and 1 or 0)
		mText(drawableText.replaying,770,17)
	end

	--Warning
	gc.push("transform")
	gc.origin()
	if GAME.warnLVL>0 then
		SHADER.warning:send("level",GAME.warnLVL)
		gc.setShader(SHADER.warning)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
		gc.setShader()
	end
	gc.pop()
end
scene.widgetList={
	WIDGET.newKey{name="restart",fText="R",x=410,y=40,w=60,font=40,code=restart},
	WIDGET.newKey{name="pause",fText="II",x=870,y=40,w=60,font=40,code=function()pauseGame()end},
}

return scene