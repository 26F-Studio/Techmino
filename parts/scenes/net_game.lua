local gc,kb,tc=love.graphics,love.keyboard,love.touch

local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_print,gc_printf=gc.print,gc.printf
local gc_draw,gc_rectangle=gc.draw,gc.rectangle
local setFont,mStr=setFont,mStr

local ins=table.insert

local SCR,VK,NET,netPLY=SCR,VK,NET,netPLY
local PLAYERS,GAME=PLAYERS,GAME

local textBox=WIDGET.newTextBox{name="texts",x=340,y=80,w=600,h=560}
local inputBox=WIDGET.newInputBox{name="input",x=340,y=660,w=600,h=50}

local playing,stat
local lastUpstreamTime
local upstreamProgress
local lastBackTime=0
local noTouch,noKey=false,false
local touchMoveLastFrame=false
local newMessageTimer

local function _playerSort(a,b)return a.place<b.place end
local function _setReady()NET.signal_setMode(1)end
local function _setSpectate()NET.signal_setMode(2)end
local function _setCancel()NET.signal_setMode(0)end
local function _gotoSetting()
	if not(netPLY.getSelfReady()or NET.getlock('ready'))then
		SCN.go('setting_game')
	end
end
local function _quit()
	if TIME()-lastBackTime<1 then
		NET.signal_quit()
	else
		lastBackTime=TIME()
		LOG.print(text.sureQuit,'warn')
	end
end
local function _switchStat()
	if not playing and #NET.resultList>0 then
		stat=not stat
	end
end
local function _switchChat()
	if inputBox.hide then
		textBox.hide=false
		inputBox.hide=false
		WIDGET.focus(inputBox)
	else
		textBox.hide=true
		inputBox.hide=true
		WIDGET.unFocus(true)
	end
end

local scene={}

function scene.sceneInit(org)
	textBox.hide=true
	textBox:clear()
	inputBox.hide=true

	noTouch=not SETTING.VKSwitch
	playing=false
	stat=false
	lastUpstreamTime=0
	upstreamProgress=1
	newMessageTimer=0

	if org=='setting_game'then NET.changeConfig()end
	if NET.specSRID then
		NET.wsconn_stream(NET.specSRID)
		NET.specSRID=false
	end
end
function scene.sceneBack()
	NET.resultList={}
	love.keyboard.setKeyRepeat(true)
end

scene.mouseDown=NULL
function scene.mouseMove(x,y)netPLY.mouseMove(x,y)end
function scene.touchDown(x,y)
	if not playing then netPLY.mouseMove(x,y)return end
	if noTouch then return end

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
function scene.touchMove()
	if touchMoveLastFrame or not playing or noTouch then return end
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
		if not inputBox.hide then
			scene.keyDown("switchChat")
		else
			_quit()
		end
	elseif key=="return"then
		local mes=STRING.trim(inputBox:getText())
		if not inputBox.hide then
			if #mes>0 then
				NET.sendMessage(mes)
				inputBox:clear()
			elseif #EDITING==0 then
				_switchChat()
			end
		else
			_switchChat()
		end
	elseif not inputBox.hide then
		WIDGET.focus(inputBox)
		inputBox:keypress(key)
	elseif playing then
		if noKey then return end
		local k=keyMap.keyboard[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK.press(k)
		end
	else
		if key=="space"then
			if netPLY.getSelfJoinMode()==0 then
				(kb.isDown("lctrl","rctrl","lalt","ralt")and _setSpectate or _setReady)()
			else
				_setCancel()
			end
		elseif key=="tab"then
			_switchStat()
		elseif key=="s"then
			_gotoSetting()
		end
	end
end
function scene.keyUp(key)
	if not playing or noKey then return end
	local k=keyMap.keyboard[key]
	if k and k>0 then
		PLAYERS[1]:releaseKey(k)
		VK.release(k)
	end
end
function scene.gamepadDown(key)
	if key=="back"then
		scene.keyDown("escape")
	else
		if not playing then return end
		local k=keyMap.joystick[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK.press(k)
		end
	end
end
function scene.gamepadUp(key)
	if not playing then return end
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
		newMessageTimer=60
		textBox:push{
			COLOR.Z,d.username,
			COLOR.dY,"#"..d.uid.." ",
			COLOR.N,d.message or"[_]",
		}
	elseif cmd=='go'then
		if not playing then
			playing=true
			love.keyboard.setKeyRepeat(false)
			lastUpstreamTime=0
			upstreamProgress=1
			resetGameData('n',NET.seed)
			netPLY.mouseMove(0,0)
		else
			LOG.print("Redundant [Go]",'warn')
		end
	elseif cmd=='finish'then
		playing=false
		love.keyboard.setKeyRepeat(true)
		table.sort(d.result,_playerSort)
		NET.resultList=d.result
		for _,p in next,NET.resultList do
			p.username=USERS.getUsername(p.uid)
			for _,P in next,PLAYERS do
				if P.uid==p.uid then
					netPLY.setStat(p.uid,P.stat)
					netPLY.setPlace(p.uid,p.place)
					break
				end
			end
		end
		netPLY.resetState()
	elseif cmd=='stream'then
		if d.uid~=USER.uid then
			for _,P in next,PLAYERS do
				if P.uid==d.uid then
					local res,stream=pcall(love.data.decode,'string','base64',d.stream)
					if res then
						DATA.pumpRecording(stream,P.stream)
					else
						LOG.print("Bad stream from "..P.username.."#"..P.uid,10)
					end
					break
				end
			end
		end
	end
end

function scene.update(dt)
	if NET.checkPlayDisconn()then
		NET.wsclose_stream()
		SCN.back()
		return
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
		if not NET.spectate and P1.frameRun-lastUpstreamTime>8 then
			local stream
			if not GAME.rep[upstreamProgress]then
				ins(GAME.rep,P1.frameRun)
				ins(GAME.rep,0)
			end
			stream,upstreamProgress=DATA.dumpRecording(GAME.rep,upstreamProgress)
			if #stream%3==1 then
				stream=stream.."\0\0"
			elseif #stream%3==2 then
				stream=stream.."\0\0\0\0"
			end
			NET.uploadRecStream(stream)
			lastUpstreamTime=PLAYERS[1].alive and P1.frameRun or 1e99
		end
	elseif not stat then
		netPLY.update()
	end
	if newMessageTimer>0 then
		newMessageTimer=newMessageTimer-1
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

		if NET.spectate then
			setFont(30)
			gc_setColor(.2,1,0,.8)
			gc_print(text.spectating,940,0)
		end
	else
		if stat then
			gc_setColor(1,1,1)
			gc_setLineWidth(4)
			gc_rectangle('line',75,90,730,555)
			local L=NET.resultList
			for i=1,#L do
				local p=L[i]
				setFont(30)gc_print("-"..p.place.."-",100,58+40*i)
				setFont(25)gc_print(p.username,160,60+40*i)
			end
		else
			--Users
			netPLY.draw()

			--Ready & Set mark
			setFont(50)
			if NET.allReady then
				gc_setColor(0,1,.5,.9)
				mStr(text.ready,640,15)
			elseif NET.connectingStream then
				gc_setColor(.1,1,.8,.9)
				mStr(text.connStream,640,15)
			elseif NET.waitingStream then
				gc_setColor(0,.8,1,.9)
				mStr(text.waitStream,640,15)
			end
		end

		--Room info.
		gc_setColor(1,1,1)
		setFont(25)
		gc_printf(NET.roomState.roomInfo.name,0,685,1270,'right')
		setFont(40)
		gc_print(netPLY.getCount().."/"..NET.roomState.capacity,70,655)
		if NET.roomState.private then gc_draw(IMG.lock,30,668)end
		if NET.roomState.start then gc_setColor(0,1,0)gc_print(text.started,230,655)end

		--Profile
		drawSelfProfile()

		--Player count
		drawOnlinePlayerCount()
	end

	--New message
	if newMessageTimer>0 then
		setFont(40)
		gc_setColor(.3,.7,1,(newMessageTimer/60)^2)
		gc_print("M",430,10)
	end
end
scene.widgetList={
	textBox,
	inputBox,
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=_gotoSetting,hideF=function()return playing or netPLY.getSelfReady()or NET.getlock('ready')end},
	WIDGET.newKey{name="ready",x=1060,y=510,w=370,h=90,color='lG',font=35,code=_setReady,
		hideF=function()
			return
				playing or
				NET.roomState.start or
				netPLY.getSelfReady() or
				NET.getlock('ready')
		end},
	WIDGET.newKey{name="spectate",x=1060,y=610,w=370,h=90,color='lO',font=35,code=_setSpectate,
		hideF=function()
			return
				playing or
				NET.roomState.start or
				netPLY.getSelfReady() or
				NET.getlock('ready')
		end},
	WIDGET.newKey{name="cancel",x=1060,y=560,w=370,h=120,color='lH',font=40,code=_setCancel,
		hideF=function()
			return
				playing or
				NET.roomState.start or
				not netPLY.getSelfReady() or
				NET.getlock('ready')
		end},
	WIDGET.newKey{name="showResult",x=310,y=35,w=60,font=35,code=_switchStat,
		hideF=function()
			return
				playing or
				#NET.resultList==0
		end,
		fText=DOGC{50,40,
			{'setLW',4},
			{'dRect',2,38,15,-15},
			{'dRect',17,38,15,-24},
			{'dRect',32,38,16,-10},
		},
	},
	WIDGET.newKey{name="hideChat",fText="...",x=380,y=35,w=60,font=35,code=_switchChat},
	WIDGET.newKey{name="quit",fText="X",x=900,y=35,w=60,font=40,code=_quit},
}

return scene