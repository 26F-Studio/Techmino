local gc,tc=love.graphics,love.touch
local sin=math.sin
local SCR,VK=SCR,VK
local GAME=GAME

local noTouch,noKey=false,false
local touchMoveLastFrame=false
local floatRepRate,replayRate

local repRateStrings={[0]="pause",[.125]="0.125x",[.5]="0.5x",[1]="1x",[2]="2x",[5]="5x"}
local function _rep0()replayRate=0 end
local function _repP8()replayRate=.125 end
local function _repP2()replayRate=.5 end
local function _rep1()replayRate=1 end
local function _rep2()replayRate=2 end
local function _rep5()replayRate=5 end
local function _step()floatRepRate=floatRepRate+1 end

local scene={}

function scene.sceneInit()
	if GAME.init then
		resetGameData()
		GAME.init=false
	end
	floatRepRate,replayRate=0,1
	noKey=GAME.replaying
	noTouch=not SETTING.VKSwitch or noKey
	WIDGET.active.restart.hide=GAME.replaying
end
function scene.sceneBack()
	destroyPlayers()
end

scene.mouseDown=NULL
local function restart()
	resetGameData(PLAYERS[1].frameRun<240 and'q')
	noKey=GAME.replaying
	noTouch=noKey
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
	if not GAME.replaying then
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
		elseif key=="right"then
			if replayRate==0 then
				_step()
			elseif not isRep then
				if replayRate==.125 then replayRate=.5
				elseif replayRate==.5 then replayRate=1
				elseif replayRate==1 then replayRate=2
				elseif replayRate==2 then replayRate=5
				end
			end
		elseif key=="left"then
			if replayRate~=0 and not isRep then
				if replayRate==.5 then replayRate=.125
				elseif replayRate==1 then replayRate=.5
				elseif replayRate==2 then replayRate=1
				elseif replayRate==5 then replayRate=2
				end
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
	drawFWM()

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
	gc.draw(drawableText.modeName,940,0)

	--Replaying
	if GAME.replaying then
		gc.setColor(1,1,TIME()%1>.5 and 1 or 0)
		mText(drawableText.replaying,770,8)
		setFont(20)
		mStr(("%s  <%sf>"):format(repRateStrings[replayRate],PLAYERS[1].frameRun),770,30)
	end

	--Warning
	drawWarning()
end

scene.widgetList={
	WIDGET.newKey{name="rep0",		fText=TEXTURE.rep.rep0,x=40,y=50,w=60,code=_rep0,hideF=function()return not GAME.replay and replayRate==0 end},
	WIDGET.newKey{name="repP8",		fText=TEXTURE.rep.repP8,x=105,y=50,w=60,code=_repP8,hideF=function()return not GAME.replay and replayRate==.125 end},
	WIDGET.newKey{name="repP2",		fText=TEXTURE.rep.repP2,x=170,y=50,w=60,code=_repP2,hideF=function()return not GAME.replay and replayRate==.5 end},
	WIDGET.newKey{name="rep1",		fText=TEXTURE.rep.rep1,x=235,y=50,w=60,code=_rep1,hideF=function()return not GAME.replay and replayRate==1 end},
	WIDGET.newKey{name="rep2",		fText=TEXTURE.rep.rep2,x=300,y=50,w=60,code=_rep2,hideF=function()return not GAME.replay and replayRate==2 end},
	WIDGET.newKey{name="rep5",		fText=TEXTURE.rep.rep5,x=365,y=50,w=60,code=_rep5,hideF=function()return not GAME.replay and replayRate==5 end},
	WIDGET.newKey{name="step",		fText=TEXTURE.rep.step,x=430,y=50,w=60,code=_step,hideF=function()return not GAME.replay and replayRate~=0 end},
	WIDGET.newKey{name="restart",	fText="R",x=380,y=35,w=60,font=40,code=restart},
	WIDGET.newKey{name="pause",		fText="II",x=900,y=35,w=60,font=40,code=function()pauseGame()end},
}

return scene