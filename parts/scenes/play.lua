local gc=love.graphics
local gc_setColor=gc.setColor
local tc=love.touch

local sin=math.sin

local SCR=SCR
local VK=virtualkey
local onVirtualkey=onVirtualkey
local pressVirtualkey=pressVirtualkey
local updateVirtualkey=updateVirtualkey

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
	noKey=GAME.replaying
	noTouch=noKey
end
function scene.touchDown(x,y)
	if noTouch then return end

	local t=onVirtualkey(x,y)
	if t then
		PLAYERS[1]:pressKey(t)
		pressVirtualkey(t,x,y)
	end
end
function scene.touchUp(x,y)
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
	local GAME=GAME

	--Replay
	if GAME.replaying then
		_=GAME.replaying
		local P1=PLAYERS[1]
		local L=GAME.rep
		while GAME.frame==L[_]do
			local key=L[_+1]
			if key==0 then--Just wait
			elseif key<=32 then--Press key
				P1:pressKey(key)
				pressVirtualkey(key)
			elseif key<=64 then--Release key
				P1:releaseKey(key-32)
				VK[key-32].isDown=false
			end
			_=_+2
		end
		GAME.replaying=_
	end

	touchMoveLastFrame=false
	updateVirtualkey()
	GAME.frame=GAME.frame+1

	--Counting, include pre-das
	if checkStart()then return end

	--Update players
	for p=1,#PLAYERS do PLAYERS[p]:update(dt)end

	--Warning check
	checkWarning()

	--Fresh royale target
	if GAME.modeEnv.royaleMode and GAME.frame%120==0 then
		freshMostDangerous()
	end
end

local function drawAtkPointer(x,y)
	local t=TIME()
	local a=t*3%1*.8
	t=sin(t*20)

	gc_setColor(.2,.7+t*.2,1,.6+t*.4)
	gc.circle("fill",x,y,25,6)

	gc_setColor(0,.6,1,.8-a)
	gc.circle("line",x,y,30*(1+a),6)
end
function scene.draw()
	drawFWM()

	--Players
	for p=1,#PLAYERS do
		PLAYERS[p]:draw()
	end

	--Virtual keys
	drawVirtualkeys()

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
		gc_setColor(1,1,TIME()%1>.5 and 1 or 0)
		mText(drawableText.replaying,770,17)
	end

	--Warning
	drawWarning()
end
scene.widgetList={
	WIDGET.newKey{name="restart",fText="R",x=380,y=35,w=60,font=40,code=restart},
	WIDGET.newKey{name="pause",fText="II",x=900,y=35,w=60,font=40,code=function()pauseGame()end},
}

return scene