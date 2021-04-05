local gc=love.graphics
local tc=love.touch

local ins,rem=table.insert,table.remove

local SCR=SCR
local VK=virtualkey
local onVirtualkey=onVirtualkey
local pressVirtualkey=pressVirtualkey
local updateVirtualkey=updateVirtualkey

local PLY_NET=PLY_NET

local hideChatBox
local textBox=WIDGET.newTextBox{name="texts",x=340,y=80,w=600,h=550,hide=function()return hideChatBox end}

local playerInitialized
local playing
local lastUpstreamTime
local upstreamProgress
local lastBackTime=0
local noTouch,noKey=false,false
local touchMoveLastFrame=false

local scene={}

function scene.sceneBack()
	NET.signal_quit()
	love.keyboard.setKeyRepeat(true)
end
function scene.sceneInit()
	love.keyboard.setKeyRepeat(false)
	hideChatBox=true
	playerInitialized=false
	textBox:clear()

	while #PLY_NET>0 do rem(PLY_NET)end
	resetGameData("n")
	noTouch=not SETTING.VKSwitch
	playing=false
	lastUpstreamTime=0
	upstreamProgress=1
	heartBeatTimer=0
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
			NET.signal_ready()
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
		if playerInitialized then
			textBox:push{
				COLOR.lR,data.username,
				COLOR.dY,"#"..data.uid.." ",
				COLOR.Y,text.joinRoom,
			}
		end
		local L=data.players
		for i=1,#L do
			ins(PLY_NET,{
				sid=L[i].sid,
				uid=L[i].uid,
				username=L[i].username,
				conf=L[i].config,
				ready=L[i].ready,
			})
		end
		playerInitialized=true
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
		for i=1,#PLY_NET do
			if PLY_NET[i].id==data.uid then
				rem(PLY_NET,i)
				break
			end
		end
		for i=1,#PLAYERS do
			if PLAYERS[i].userID==data.uid then
				rem(PLAYERS,i)
				break
			end
		end
		for i=1,#PLY_ALIVE do
			if PLY_ALIVE[i].userID==data.uid then
				rem(PLY_ALIVE,i)
				break
			end
		end
		initPlayerPosition(true)
	elseif cmd=="Talk"then
		textBox:push{
			COLOR.W,data.username,
			COLOR.dY,"#"..data.uid.." ",
			COLOR.sky,data.message or"[_]",
		}
	elseif cmd=="Config"then
		if tostring(USER.id)~=data.uid then
			for i=1,#PLY_NET do
				if PLY_NET[i].id==data.uid then
					PLY_NET[i].conf=data.config
					PLY_NET[i].p:setConf(data.config)
					return
				end
			end
			resetGameData("qn")
		end
	elseif cmd=="Ready"then
		local L=PLY_ALIVE
		for i=1,#L do
			if L[i].subID==data.uid then
				L[i].ready=true
				SFX.play("reach",.6)
				break
			end
		end
	elseif cmd=="Set"then
		NET.rsid=data.rid
		NET.wsConnectStream()
	elseif cmd=="Begin"then
		if not playing then
			playing=true
			lastUpstreamTime=0
			upstreamProgress=1
			resetGameData("n",data.seed)
		else
			LOG.print("Redundant signal: B(begin)",30,COLOR.green)
		end
	elseif cmd=="Finish"then
		playing=false
		resetGameData("n")
		TEXT.show(text.champion:gsub("$1","SOMEBODY"),640,260,80,"zoomout",.26)
	elseif cmd=="Die"then
		LOG.print("One player failed",COLOR.sky)
	elseif cmd=="Stream"then
		if playing and data.uid~=PLAYERS[1].subID then
			for _,P in next,PLAYERS do
				if P.subID==data.uid then
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
	local _
	local GAME=GAME

	if WS.status("play")~="running"then SCN.back()end
	if not playing then return end

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
	WIDGET.newKey{name="ready",x=640,y=440,w=200,h=80,color="yellow",font=40,code=pressKey"space",hide=function()return playing or not hideChatBox or PLAYERS[1].ready end},
	WIDGET.newKey{name="hideChat",fText="...",x=380,y=35,w=60,font=35,code=pressKey"\\"},
	WIDGET.newKey{name="quit",fText="X",x=900,y=35,w=60,font=40,code=pressKey"escape"},
}

return scene