local gc,tc=love.graphics,love.touch
local sin=math.sin
local SCR,VK=SCR,VK
local GAME=GAME

local noTouch,noKey=false,false
local touchMoveLastFrame=false
local floatGameRate,gameRate
local modeTextPos

local tasMode
local replaying
local repRateStrings={[0]="pause",[.125]="0.125x",[.5]="0.5x",[1]="1x",[2]="2x",[5]="5x"}

local scene={}

local function updateMenuButtons()
	WIDGET.active.restart.hide=replaying

	local pos=(tasMode or replaying)and'right'or SETTING.menuPos
	if GAME.replaying or pos=='right'then
		WIDGET.active.restart.x=1125
		WIDGET.active.pause.x=1195
		modeTextPos=1100-drawableText.modeName:getWidth()
	elseif pos=='middle'then
		WIDGET.active.restart.x=360
		WIDGET.active.pause.x=860
		modeTextPos=940
	elseif pos=='left'then
		WIDGET.active.restart.x=120
		WIDGET.active.pause.x=190
		modeTextPos=1200-drawableText.modeName:getWidth()
	end
end
local function updateRepButtons()
	local L=scene.widgetList
	if replaying or tasMode then
		for i=1,6 do L[i].hide=false end L[7].hide=true
		if gameRate==0 then
			L[1].hide=true
			L[7].hide=false
		elseif gameRate==.125 then
			L[2].hide=true
		elseif gameRate==.5 then
			L[3].hide=true
		elseif gameRate==1 then
			L[4].hide=true
		elseif gameRate==2 then
			L[5].hide=true
		elseif gameRate==5 then
			L[6].hide=true
		end
	else
		for i=1,7 do L[i].hide=true end
	end
end
local function speedUp()
	if gameRate==.125 then gameRate=.5
	elseif gameRate==.5 then gameRate=1
	elseif gameRate==1 then gameRate=2
	elseif gameRate==2 then gameRate=5
	end
	updateRepButtons()
end
local function speedDown()
	if gameRate==.5 then gameRate=.125
	elseif gameRate==1 then gameRate=.5
	elseif gameRate==2 then gameRate=1
	elseif gameRate==5 then gameRate=2
	end
	updateRepButtons()
end
local function _rep0()
	scene.widgetList[1].hide=true
	scene.widgetList[7].hide=false
	gameRate=0
	updateRepButtons()
end
local function _repP8()
	scene.widgetList[2].hide=true
	gameRate=.125
	updateRepButtons()
end
local function _repP2()
	scene.widgetList[3].hide=true
	gameRate=.5
	updateRepButtons()
end
local function _rep1()
	scene.widgetList[4].hide=true
	gameRate=1
	updateRepButtons()
end
local function _rep2()
	scene.widgetList[5].hide=true
	gameRate=2
	updateRepButtons()
end
local function _rep5()
	scene.widgetList[6].hide=true
	gameRate=5
	updateRepButtons()
end
local function _step()floatGameRate=floatGameRate+1 end

local function restart()
	resetGameData(PLAYERS[1].frameRun<240 and'q')
	noKey=replaying
	noTouch=replaying
end
local function checkGameKeyDown(key)
	local k=keyMap.keyboard[key]
	if k then
		if k>0 then
			if noKey then return end
			PLAYERS[1]:pressKey(k)
			VK.press(k)
			return
		elseif not GAME.fromRepMenu then
			restart()
			return
		end
	end
	return true--No key pressed
end

function scene.sceneInit(org)
	if GAME.init then
		resetGameData()
		GAME.init=false
	end

	tasMode=GAME.tasUsed
	replaying=GAME.replaying
	noKey=replaying
	noTouch=not SETTING.VKSwitch or replaying

	if tasMode then
		floatGameRate,gameRate=0,0
	elseif org~='depause'and org~='pause'then
		floatGameRate,gameRate=0,1
	end

	updateRepButtons()
	updateMenuButtons()
end
function scene.sceneBack()
	destroyPlayers()
end

scene.mouseDown=NULL
function scene.touchDown(x,y)
	if noTouch then return end

	local t=VK.on(x,y)
	if t then
		PLAYERS[1]:pressKey(t)
		VK.touch(t,x,y)
	end
end
function scene.touchUp(x,y)
	if noTouch then return end

	local n=VK.on(x,y)
	if n then
		PLAYERS[1]:releaseKey(n)
		VK.release(n)
	end
end
function scene.touchMove()
	if noTouch or touchMoveLastFrame then return end
	touchMoveLastFrame=true

	local L=tc.getTouches()
	for i=#L,1,-1 do
		L[2*i-1],L[2*i]=SCR.xOy:inverseTransformPoint(tc.getPosition(L[i]))
	end
	local keys=VK.keys
	for n=1,#keys do
		local B=keys[n]
		if B.ava then
			for i=1,#L,2 do
				if(L[i]-B.x)^2+(L[i+1]-B.y)^2<=B.r^2 then
					goto CONTINUE_nextKey
				end
			end
			PLAYERS[1]:releaseKey(n)
			VK.release(n)
		end
		::CONTINUE_nextKey::
	end
end
function scene.keyDown(key,isRep)
	if replaying then
		if key=="space"then
			if not isRep then gameRate=gameRate==0 and 1 or 0 end
			updateRepButtons()
		elseif key=="left"then
			if not isRep then
				speedDown()
			end
		elseif key=="right"then
			if gameRate==0 then
				_step()
			elseif not isRep then
				speedUp()
			end
		elseif key=="escape"then
			pauseGame()
		end
	else
		if isRep then
			return
		elseif checkGameKeyDown(key)then
			if tasMode then
				if key=="f1"then
					if not isRep then gameRate=gameRate==0 and .125 or 0 end
					updateRepButtons()
				elseif key=='f2'then
					if not isRep then
						speedDown()
					end
				elseif key=='f3'then
					if gameRate==0 then
						_step()
					elseif not isRep then
						speedUp()
					end
				end
			end
			if key=="escape"then
				pauseGame()
			end
		end
	end
end
function scene.keyUp(key)
	if noKey then return end
	local k=keyMap.keyboard[key]
	if k then
		if k>0 then
			PLAYERS[1]:releaseKey(k)
			VK.release(k)
		end
	end
end
function scene.gamepadDown(key)
	if noKey then return end
	local k=keyMap.joystick[key]
	if k then
		if k>0 then
			PLAYERS[1]:pressKey(k)
			VK.press(k)
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
			VK.release(k)
		end
	end
end

local function update_replay(repPtr)
	local P1=PLAYERS[1]
	local L=GAME.rep
	while P1.frameRun==L[repPtr]do
		local key=L[repPtr+1]
		if key==0 then--Just wait
		elseif key<=32 then--Press key
			P1:pressKey(key)
			VK.press(key)
		elseif key<=64 then--Release key
			P1:releaseKey(key-32)
			VK.release(key-32)
		end
		repPtr=repPtr+2
	end
	GAME.replaying=repPtr
end
local function update_common(dt)
	--Update control
	touchMoveLastFrame=false
	VK.update()

	--Update players
	for p=1,#PLAYERS do PLAYERS[p]:update(dt)end

	--Fresh royale target
	if GAME.modeEnv.royaleMode and PLAYERS[1].frameRun%120==0 then
		freshMostDangerous()
	end

	--Warning check
	checkWarning()
end
function scene.update(dt)
	floatGameRate=floatGameRate+gameRate
	while floatGameRate>=1 do
		floatGameRate=floatGameRate-1
		if GAME.replaying then update_replay(GAME.replaying)end
		update_common(dt)
	end
end

local function drawAtkPointer(x,y)
	local t=TIME()
	local a=t*3%1*.8
	t=sin(t*20)

	gc.setColor(.2,.7+t*.2,1,.6+t*.4)
	gc.circle('fill',x,y,25,6)

	gc.setColor(0,.6,1,.8-a)
	gc.circle('line',x,y,30*(1+a),6)
end
function scene.draw()
	local repMode=GAME.replaying

	--Players
	for p=1,#PLAYERS do
		PLAYERS[p]:draw(repMode)
	end

	--Virtual keys
	VK.draw()

	--Attacking & Being attacked
	if GAME.modeEnv.royaleMode then
		local P=PLAYERS[1]
		gc.setLineWidth(5)
		gc.setColor(.8,1,0,.2)
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
	gc.setColor(1,1,1,.8)
	gc.draw(drawableText.modeName,modeTextPos,10)

	--Replaying
	if replaying or tasMode then
		setFont(20)
		gc.setColor(1,1,TIME()%.8>.4 and 1 or 0)
		mStr(text[replaying and'replaying'or'tasUsing'],770,6)
		gc.setColor(1,1,1,.8)
		mStr(("%s   %sf"):format(repRateStrings[gameRate],PLAYERS[1].frameRun),770,31)
	end

	--Warning
	drawWarning()
end

scene.widgetList={
	WIDGET.newKey{name="rep0",		x=40,y=50,w=60,code=_rep0,fText=TEXTURE.rep.rep0},
	WIDGET.newKey{name="repP8",		x=105,y=50,w=60,code=_repP8,fText=TEXTURE.rep.repP8},
	WIDGET.newKey{name="repP2",		x=170,y=50,w=60,code=_repP2,fText=TEXTURE.rep.repP2},
	WIDGET.newKey{name="rep1",		x=235,y=50,w=60,code=_rep1,fText=TEXTURE.rep.rep1},
	WIDGET.newKey{name="rep2",		x=300,y=50,w=60,code=_rep2,fText=TEXTURE.rep.rep2},
	WIDGET.newKey{name="rep5",		x=365,y=50,w=60,code=_rep5,fText=TEXTURE.rep.rep5},
	WIDGET.newKey{name="step",		x=430,y=50,w=60,code=_step,fText=TEXTURE.rep.step},
	WIDGET.newKey{name="restart",	x=0,y=45,w=60,code=restart,fText=TEXTURE.game.restart},
	WIDGET.newKey{name="pause",		x=0,y=45,w=60,code=pauseGame,fText=TEXTURE.game.pause},
}

return scene