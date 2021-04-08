local gc=love.graphics
local tc=love.touch

local ins=table.insert

local SCR=SCR
local VK=virtualkey
local onVirtualkey=onVirtualkey
local pressVirtualkey=pressVirtualkey
local updateVirtualkey=updateVirtualkey

local hideChatBox
local textBox=WIDGET.newTextBox{name="texts",x=340,y=80,w=600,h=550,hide=function()return hideChatBox end}

local playing
local lastUpstreamTime
local upstreamProgress
local lastBackTime=0
local noTouch,noKey=false,false
local touchMoveLastFrame=false

local scene={}

function scene.sceneBack()
	NET.signal_quit()
	NET.wsclose_stream()
	love.keyboard.setKeyRepeat(true)
end
function scene.sceneInit()
	love.keyboard.setKeyRepeat(false)
	hideChatBox=true
	textBox:clear()

	resetGameData("n")
	noTouch=not SETTING.VKSwitch
	playing=false
	lastUpstreamTime=0
	upstreamProgress=1
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
					goto CONTINUE_nextKey
				end
			end
			PLAYERS[1]:releaseKey(n)
		end
		::CONTINUE_nextKey::
	end
end
function scene.keyDown(key)
	if key=="escape"then
		if TIME()-lastBackTime<1 then
			SCN.back()
		else
			lastBackTime=TIME()
			LOG.print(text.sureQuit,COLOR.orange)
		end
	elseif key=="\\"then
		hideChatBox=not hideChatBox
	elseif playing then
		if noKey then return end
		local k=keyMap.keyboard[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK[k].isDown=true
			VK[k].pressTime=10
		end
	elseif key=="space"then
		if not NET.getLock("ready")then
			NET.signal_ready(not PLAYERS[1].ready)
		end
	end
end
function scene.keyUp(key)
	if noKey then return end
	local k=keyMap.keyboard[key]
	if k and k>0 then
		PLAYERS[1]:releaseKey(k)
		VK[k].isDown=false
	end
end
function scene.gamepadDown(key)
	if key=="back"then
		if TIME()-lastBackTime<1 then
			SCN.back()
		else
			lastBackTime=TIME()
			LOG.print(text.sureQuit,COLOR.orange)
		end
	else
		if noKey then return end
		local k=keyMap.joystick[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK[k].isDown=true
			VK[k].pressTime=10
		end
	end
end
function scene.gamepadUp(key)
	if noKey then return end
	local k=keyMap.joystick[key]
	if k and k>0 then
		PLAYERS[1]:releaseKey(k)
		VK[k].isDown=false
		return
	end
end

function scene.socketRead(cmd,data)
	if cmd=="Join"then
		textBox:push{
			COLOR.lR,data.username,
			COLOR.dY,"#"..data.uid.." ",
			COLOR.Y,text.joinRoom,
		}
		SFX.play("click")
		if not playing then
			resetGameData("qn")
		end
	elseif cmd=="Leave"then
		textBox:push{
			COLOR.lR,data.username,
			COLOR.dY,"#"..data.uid.." ",
			COLOR.Y,text.leaveRoom,
		}
		if not playing then
			initPlayerPosition(true)
		end
	elseif cmd=="Talk"then
		textBox:push{
			COLOR.W,data.username,
			COLOR.dY,"#"..data.uid.." ",
			COLOR.sky,data.message or"[_]",
		}
	elseif cmd=="Config"then
		if tostring(USER.uid)~=data.uid then
			for i=1,#PLY_NET do
				if PLY_NET[i].uid==data.uid then
					PLY_NET[i].conf=data.config
					PLY_NET[i].p:setConf(data.config)
					return
				end
			end
			resetGameData("qn")
		end
	elseif cmd=="Ready"then
		if data.uid==USER.uid then
			if PLAYERS[1].ready~=data.ready then
				PLAYERS[1].ready=data.ready
				SFX.play("reach",.6)
			end
		else
			for i=1,#PLAYERS do
				if PLAYERS[i].userID==data.uid then
					if PLAYERS[i].ready~=data.ready then
						PLAYERS[i].ready=data.ready
						SFX.play("reach",.6)
					end
					break
				end
			end
		end
	elseif cmd=="Set"then
		NET.rsid=data.rid
		NET.wsconn_stream()
		TASK.new(NET.updateWS_stream)
	elseif cmd=="Begin"then
		if not playing then
			playing=true
			lastUpstreamTime=0
			upstreamProgress=1
			resetGameData("n",data.seed)
		else
			LOG.print("Redundant signal: Begin",30,COLOR.green)
		end
	elseif cmd=="Finish"then
		playing=false
		resetGameData("n")
		local winnerUID
		for _,p in next,data.result do
			if p.place==1 then
				winnerUID=p.uid
				break
			end
		end
		if not winnerUID then return end
		for _,d in next,PLY_NET do
			if d.uid==winnerUID then
				TEXT.show(text.champion:gsub("$1",d.username),640,260,80,"zoomout",.26)
				break
			end
		end
	elseif cmd=="Stream"then
		if data.uid~=USER.uid and playing then
			for _,P in next,PLAYERS do
				if P.userID==data.uid then
					local res,stream=pcall(love.data.decode,"string","base64",data.stream)
					if res then
						pumpRecording(stream,P.stream)
					else
						LOG.print("Bad stream from "..P.userName.."#"..P.userID)
					end
				end
			end
		end
	end
end

function scene.update(dt)
	if NET.checkPlayDisconn()then SCN.back()end
	if not playing then return end

	local _
	local GAME=GAME

	touchMoveLastFrame=false
	updateVirtualkey()
	GAME.frame=GAME.frame+1

	--Counting, include pre-das
	if checkStart()then return end

	--Update players
	for p=1,#PLAYERS do PLAYERS[p]:update(dt)end

	--Warning check
	checkWarning()

	--Upload stream
	if GAME.frame-lastUpstreamTime>8 then
		local stream
		stream,upstreamProgress=dumpRecording(GAME.rep,upstreamProgress)
		if #stream>0 then
			NET.uploadRecStream(stream)
		else
			ins(GAME.rep,GAME.frame)
			ins(GAME.rep,0)
		end
		lastUpstreamTime=PLAYERS[1].alive and GAME.frame or 1e99
	end
end

function scene.draw()
	drawFWM()

	--Players
	for p=hideChatBox and 1 or 2,#PLAYERS do
		PLAYERS[p]:draw()
	end

	--Virtual keys
	drawVirtualkeys()

	--Warning
	drawWarning()

	--New message
	if textBox.new and hideChatBox then
		setFont(30)
		gc.setColor(1,TIME()%.4<.2 and 1 or 0,0)
		gc.print("M",460,15)
	end
end
scene.widgetList={
	textBox,
	WIDGET.newKey{name="ready",x=640,y=440,w=200,h=80,color="yellow",font=40,code=pressKey"space",hide=function()
		return
			playing or
			not hideChatBox or
			NET.getLock("ready")
		end},
	WIDGET.newKey{name="hideChat",fText="...",x=380,y=35,w=60,font=35,code=pressKey"\\"},
	WIDGET.newKey{name="quit",fText="X",x=900,y=35,w=60,font=40,code=pressKey"escape"},
}

return scene