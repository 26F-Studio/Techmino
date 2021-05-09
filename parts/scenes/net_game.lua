local gc,tc=love.graphics,love.touch
local ins=table.insert
local SCR,VK,NET,netPLY=SCR,VK,NET,netPLY
local PLAYERS,GAME=PLAYERS,GAME

local textBox=WIDGET.newTextBox{name="texts",x=340,y=80,w=600,h=550,hide=false}

local playing
local lastUpstreamTime
local upstreamProgress
local lastBackTime=0
local noTouch,noKey=false,false
local touchMoveLastFrame=false

local scene={}

function scene.sceneBack()
	love.keyboard.setKeyRepeat(true)
end
function scene.sceneInit(org)
	love.keyboard.setKeyRepeat(false)
	textBox.hide=true
	textBox:clear()

	noTouch=not SETTING.VKSwitch
	playing=false
	lastUpstreamTime=0
	upstreamProgress=1

	if org=="setting_game"then
		NET.changeConfig()
	end
end

scene.mouseDown=NULL
function scene.mouseMove(x,y)netPLY.mouseMove(x,y)end
function scene.touchDown(x,y)
	if not playing or noTouch then return end

	local t=VK.on(x,y)
	if t then
		PLAYERS[1]:pressKey(t)
		VK.touch(t,x,y)
	end
end
function scene.touchUp(x,y)
	if not playing or noTouch then return end

	local n=VK.on(x,y)
	if n then
		PLAYERS[1]:releaseKey(n)
		VK.release(n)
	end
end
function scene.touchMove(x,y)
	if not playing then netPLY.mouseMove(x,y)end
	if touchMoveLastFrame or noTouch then return end
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
function scene.keyDown(key)
	if key=="escape"then
		if TIME()-lastBackTime<1 then
			NET.signal_quit()
		else
			lastBackTime=TIME()
			LOG.print(text.sureQuit,COLOR.O)
		end
	elseif key=="\\"then
		textBox.hide=not textBox.hide
	elseif playing then
		if noKey then return end
		local k=keyMap.keyboard[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK.press(k)
		end
	else
		if key=="space"then
			NET.signal_ready(not netPLY.getSelfReady())
		elseif key=="s"then
			if not(netPLY.getSelfReady()or NET.getlock('ready'))then
				SCN.go('setting_game')
			end
		end
	end
end
function scene.keyUp(key)
	if noKey then return end
	local k=keyMap.keyboard[key]
	if k and k>0 then
		PLAYERS[1]:releaseKey(k)
		VK.release(k)
	end
end
function scene.gamepadDown(key)
	if key=="back"then
		if TIME()-lastBackTime<1 then
			NET.signal_quit()
		else
			lastBackTime=TIME()
			LOG.print(text.sureQuit,COLOR.O)
		end
	else
		local k=keyMap.joystick[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK.press(k)
		end
	end
end
function scene.gamepadUp(key)
	local k=keyMap.joystick[key]
	if k and k>0 then
		PLAYERS[1]:releaseKey(k)
		VK.release(k)
	end
end

function scene.socketRead(cmd,d)
	if cmd=='join'then
		textBox:push{
			COLOR.lR,d.username,
			COLOR.dY,"#"..d.uid.." ",
			COLOR.Y,text.joinRoom,
		}
		SFX.play('click')
	elseif cmd=='leave'then
		textBox:push{
			COLOR.lR,d.username,
			COLOR.dY,"#"..d.uid.." ",
			COLOR.Y,text.leaveRoom,
		}
	elseif cmd=='talk'then
		textBox:push{
			COLOR.Z,d.username,
			COLOR.dY,"#"..d.uid.." ",
			COLOR.N,d.message or"[_]",
		}
	elseif cmd=='go'then
		if not playing then
			playing=true
			netPLY.resetReady()
			netPLY.mouseMove(0,0)
			lastUpstreamTime=0
			upstreamProgress=1
			resetGameData('n',d.seed)
		else
			LOG.print("Redundant [Go]",30,COLOR.G)
		end
	elseif cmd=='finish'then
		playing=false
		local winnerUID
		for _,p in next,d.result do
			if p.place==1 then
				winnerUID=p.uid
				break
			end
		end
		if winnerUID then
			TEXT.show(text.champion:gsub("$1",netPLY.getUsername(winnerUID)),640,260,80,'zoomout',.26)
		end
	elseif cmd=='stream'then
		if d.uid~=USER.uid and playing then
			for _,P in next,PLAYERS do
				if P.uid==d.uid then
					local res,stream=pcall(love.data.decode,'string','base64',d.stream)
					if res then
						DATA.pumpRecording(stream,P.stream)
					else
						LOG.print("Bad stream from "..P.username.."#"..P.uid)
					end
				end
			end
		end
	end
end

function scene.update(dt)
	if NET.checkPlayDisconn()then
		NET.wsclose_stream()
		SCN.back()
	end
	if playing then
		local P1=PLAYERS[1]

		touchMoveLastFrame=false
		VK.update()

		--Update players
		for p=1,#PLAYERS do PLAYERS[p]:update(dt)end

		--Warning check
		checkWarning()

		--Upload stream
		if P1.frameRun-lastUpstreamTime>8 then
			local stream
			stream,upstreamProgress=DATA.dumpRecording(GAME.rep,upstreamProgress)
			if #stream>0 then
				NET.uploadRecStream(stream)
			else
				ins(GAME.rep,P1.frameRun)
				ins(GAME.rep,0)
			end
			lastUpstreamTime=PLAYERS[1].alive and P1.frameRun or 1e99
		end
	else
		netPLY.update(dt)
	end
end

function scene.draw()
	if playing then
		drawFWM()

		--Players
		for p=1,#PLAYERS do
			PLAYERS[p]:draw()
		end

		--Virtual keys
		VK.draw()

		--Warning
		drawWarning()
	else
		--Users
		netPLY.draw()

		--Ready & Set mark
		gc.setColor(.1,1,0,.9)
		setFont(60)
		if NET.connectingStream then
			mStr(text.set,640,10)
		elseif NET.allReady then
			mStr(text.ready,640,10)
		end

		--Room info.
		gc.setColor(1,1,1)
		setFont(25)
		gc.printf(NET.roomInfo.name,0,685,1270,'right')
		setFont(40)
		gc.print(netPLY.getCount().."/"..NET.roomInfo.capacity,70,655)
		if NET.roomInfo.private then gc.draw(IMG.lock,30,668)end

		--Profile
		drawSelfProfile()
	end

	--New message
	if textBox.new then
		setFont(40)
		gc.setColor(1,1,0)
		gc.print("M",430,10)
	end
end
scene.widgetList={
	textBox,
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=pressKey"s",hide=function()return playing or netPLY.getSelfReady()or NET.getlock('ready')end},
	WIDGET.newKey{name="ready",x=1060,y=630,w=300,h=80,color='lB',font=40,code=pressKey"space",
		hide=function()
			return
				playing or
				NET.serverGaming or
				netPLY.getSelfReady()or
				NET.getlock('ready')
		end},
	WIDGET.newKey{name="cancel",x=1060,y=630,w=300,h=80,color='H',font=40,code=pressKey"space",
		hide=function()
			return
				playing or
				NET.serverGaming or
				not netPLY.getSelfReady()or
				NET.getlock('ready')
		end},
	WIDGET.newKey{name="hideChat",fText="...",x=380,y=35,w=60,font=35,code=pressKey"\\"},
	WIDGET.newKey{name="quit",fText="X",x=900,y=35,w=60,font=40,code=pressKey"escape"},
}

return scene