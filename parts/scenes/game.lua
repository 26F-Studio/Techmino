local gc,tc=love.graphics,love.touch
local sin=math.sin
local SCR,VK=SCR,VK
local GAME=GAME

local noTouch,noKey=false,false
local touchMoveLastFrame=false
local floatRepRate,replayRate

local replaying
local repRateStrings={[0]="pause",[.125]="0.125x",[.5]="0.5x",[1]="1x",[2]="2x",[5]="5x"}

local scene={}

local function updateRepButtons()
	local L=scene.widgetList
	if replaying then
		for i=1,6 do L[i].hide=false end L[7].hide=true
		if replayRate==0 then
			L[1].hide=true
			L[7].hide=false
		elseif replayRate==.125 then
			L[2].hide=true
		elseif replayRate==.5 then
			L[3].hide=true
		elseif replayRate==1 then
			L[4].hide=true
		elseif replayRate==2 then
			L[5].hide=true
		elseif replayRate==5 then
			L[6].hide=true
		end
	else
		for i=1,7 do L[i].hide=true end
	end
end
local function _rep0()
	scene.widgetList[1].hide=true
	scene.widgetList[7].hide=false
	replayRate=0
	updateRepButtons()
end
local function _repP8()
	scene.widgetList[2].hide=true
	replayRate=.125
	updateRepButtons()
end
local function _repP2()
	scene.widgetList[3].hide=true
	replayRate=.5
	updateRepButtons()
end
local function _rep1()
	scene.widgetList[4].hide=true
	replayRate=1
	updateRepButtons()
end
local function _rep2()
	scene.widgetList[5].hide=true
	replayRate=2
	updateRepButtons()
end
local function _rep5()
	scene.widgetList[6].hide=true
	replayRate=5
	updateRepButtons()
end
local function _step()floatRepRate=floatRepRate+1 end


function scene.sceneInit(org)
	if GAME.init then
		resetGameData()
		GAME.init=false
	end
	replaying=GAME.replaying

	if org~='depause'and org~='pause'then
		floatRepRate,replayRate=0,1
	end
	updateRepButtons()

	noKey=replaying
	noTouch=not SETTING.VKSwitch or noKey
	WIDGET.active.restart.hide=replaying
end
function scene.sceneBack()
	destroyPlayers()
end

scene.mouseDown=NULL
local function restart()
	resetGameData(PLAYERS[1].frameRun<240 and'q')
	noKey=replaying
	noTouch=replaying
end
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
	if not replaying then
		if isRep then return end
		local k=keyMap.keyboard[key]
		if k then
			if k>0 then
				if noKey then return end
				PLAYERS[1]:pressKey(k)
				VK.press(k)
			elseif not GAME.fromRepMenu then
				restart()
			end
		elseif key=="escape"then
			pauseGame()
		end
	else
		if key=="space"then
			if not isRep then replayRate=replayRate==0 and 1 or 0 end
			updateRepButtons()
		elseif key=="right"then
			if replayRate==0 then
				_step()
			elseif not isRep then
				if replayRate==.125 then replayRate=.5
				elseif replayRate==.5 then replayRate=1
				elseif replayRate==1 then replayRate=2
				elseif replayRate==2 then replayRate=5
				end
				updateRepButtons()
			end
		elseif key=="left"then
			if replayRate~=0 and not isRep then
				if replayRate==.5 then replayRate=.125
				elseif replayRate==1 then replayRate=.5
				elseif replayRate==2 then replayRate=1
				elseif replayRate==5 then replayRate=2
				end
				updateRepButtons()
			end
		elseif key=="escape"then
			pauseGame()
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
	local repPtr=GAME.replaying
	if repPtr then
		floatRepRate=floatRepRate+replayRate
		while floatRepRate>=1 do
			floatRepRate=floatRepRate-1
			if repPtr then
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
			update_common(dt)
		end
	else
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
	--Players
	for p=1,#PLAYERS do
		PLAYERS[p]:draw()
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
	gc.draw(drawableText.modeName,1120-drawableText.modeName:getWidth(),10)

	--Replaying
	if replaying then
		setFont(20)
		gc.setColor(1,1,TIME()%.8>.4 and 1 or 0)
		mStr(text.replaying,770,6)
		gc.setColor(1,1,1,.8)
		mStr(("%s   %sf"):format(repRateStrings[replayRate],PLAYERS[1].frameRun),770,31)
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
	WIDGET.newKey{name="restart",	x=1165,y=45,w=60,code=restart,fText=TEXTURE.game.restart},
	WIDGET.newKey{name="pause",		x=1235,y=45,w=60,code=pauseGame,fText=TEXTURE.game.pause},
}

return scene