local data=love.data
local gc=love.graphics
local tc=love.touch

local playerData
local ins,rem=table.insert,table.remove
local sin=math.sin

local SCR=SCR
local VK=virtualkey
local onVirtualkey=onVirtualkey
local pressVirtualkey=pressVirtualkey
local updateVirtualkey=updateVirtualkey

local hideChatBox
local textBox=WIDGET.newTextBox{name="texts",x=340,y=80,w=600,h=550,hide=function()return hideChatBox end}
local function switchChat()
	hideChatBox=not hideChatBox
end


local playerInitialized
local playing
local heartBeatTimer
local lastUpstreamTime
local upstreamProgress
local lastBackTime=0
local noTouch,noKey=false,false
local touchMoveLastFrame=false

local scene={}

function scene.sceneBack()
	wsWrite("Q")
	WSCONN=false
	LOG.print(text.wsDisconnected,"warn")
	love.keyboard.setKeyRepeat(true)
end
function scene.sceneInit()
	love.keyboard.setKeyRepeat(false)
	TASK.new(TICK_wsRead)
	hideChatBox=true
	playerInitialized=false
	textBox:clear()

	playerData={}
	resetGameData("n",playerData)
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
					goto continue
				end
			end
			PLAYERS[1]:releaseKey(n)
		end
		::continue::
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
		switchChat()
	elseif playing then
		if noKey then return end
		local k=keyMap.keyboard[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK[k].isDown=true
			VK[k].pressTime=10
		end
	elseif key=="space"then
		if not PLAYERS[1].ready then
			wsWrite("R")
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
			WSCONN=false
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

function scene.socketRead(mes)
	local cmd=mes:sub(1,1)
	local args=splitStr(mes:sub(2),";")
	if cmd=="J"then
		if playerInitialized then
			local L=splitStr(args[1],",")
			textBox:push{
				COLOR.lR,L[1],
				COLOR.dY,"#"..L[2].." ",
				COLOR.Y,text.joinRoom,
			}
		end
		for i=1,#args do
			local L=splitStr(args[i],",")
			ins(playerData,{name=L[1],id=L[2],sid=L[3],conf=L[4],ready=L[5]=="1"})
		end
		playerInitialized=true
		SFX.play("click")
		if not playing then
			resetGameData("qn",playerData)
		end
	elseif cmd=="L"then
		textBox:push{
			COLOR.lR,args[1],
			COLOR.dY,"#"..args[2].." ",
			COLOR.Y,text.leaveRoom,
		}
		for i=1,#playerData do
			if playerData[i].id==args[2]then
				rem(playerData,i)
				break
			end
		end
		for i=1,#PLAYERS do
			if PLAYERS[i].userID==args[2]then
				rem(PLAYERS,i)
				break
			end
		end
		for i=1,#PLAYERS.alive do
			if PLAYERS.alive[i].userID==args[2]then
				rem(PLAYERS.alive,i)
				break
			end
		end
		initPlayerPosition(true)
	elseif cmd=="T"then
		textBox:push{
			COLOR.W,args[1],
			COLOR.dY,"#"..args[2].." ",
			COLOR.sky,data.decode("string","base64",args[3])
		}
	elseif cmd=="C"then
		if tostring(USER.id)~=args[2]then
			for i=1,#playerData do
				if playerData[i].id==args[2]then
					playerData[i].conf=args[4]
					playerData[i].p:setConf(args[4])
					return
				end
			end
			resetGameData("qn",playerData)
		end
	elseif cmd=="S"then
		if playing and args[1]~=PLAYERS[1].subID then
			for _,P in next,PLAYERS do
				if P.subID==args[1]then
					pumpRecording(data.decode("string","base64",args[2]),P.stream)
				end
			end
		end
	elseif cmd=="R"then
		local L=PLAYERS.alive
		for i=1,#L do
			if L[i].subID==args[1]then
				L[i].ready=true
				SFX.play("reach",.6)
				break
			end
		end
	elseif cmd=="B"then
		if not playing then
			playing=true
			lastUpstreamTime=0
			upstreamProgress=1
			resetGameData("n",playerData,tonumber(args[1]))
		else
			LOG.print("Redundant signal: B(begin)",30,COLOR.green)
		end
	elseif cmd=="F"then
		playing=false
		resetGameData("n",playerData)
		for i=1,#playerData do
			if playerData[i].sid==args[1]then
				TEXT.show(text.champion:gsub("$1",playerData[i].name.."#"..playerData[i].id),640,260,80,"zoomout",.26)
				break
			end
		end
	else
		LOG.print("Illegal message: ["..mes.."]",30,COLOR.green)
	end
end

function scene.update(dt)
	local _
	local GAME=GAME

	if not WSCONN and not SCN.swapping then SCN.back()end
	if not playing then
		heartBeatTimer=heartBeatTimer+dt
		if heartBeatTimer>42 then
			heartBeatTimer=0
			wsWrite("P")
		end
		return
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

	--Upload stream
	if GAME.frame-lastUpstreamTime>8 then
		local stream
		stream,upstreamProgress=dumpRecording(GAME.rep,upstreamProgress)
		if #stream>0 then
			wsWrite("S"..data.encode("string","base64",stream))
		else
			ins(GAME.rep,GAME.frame)
			ins(GAME.rep,0)
		end
		lastUpstreamTime=PLAYERS[1].alive and GAME.frame or 1e99
	end
end

function scene.draw()
	local t=TIME()
	if MARKING then
		setFont(25)
		gc.setColor(1,1,1,.2+.1*(sin(3*t)+sin(2.6*t)))
		mStr(text.marking,190,60+26*sin(t))
	end

	--Players
	for p=hideChatBox and 1 or 2,#PLAYERS do
		PLAYERS[p]:draw()
	end

	--Virtual keys
	drawVirtualkeys()

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

	--New message
	if textBox.new and hideChatBox then
		setFont(30)
		gc.setColor(1,TIME()%.4<.2 and 1 or 0,0)
		gc.print("M",460,15)
	end
end
scene.widgetList={
	textBox,
	WIDGET.newKey{name="ready",x=640,y=440,w=200,h=80,color="yellow",font=40,code=pressKey("space"),hide=function()return playing or not hideChatBox or PLAYERS[1].ready end},
	WIDGET.newKey{name="hideChat",fText="...",x=380,y=35,w=60,font=35,code=switchChat},
	WIDGET.newKey{name="quit",fText="X",x=900,y=35,w=60,font=40,code=pressKey"escape"},
}

return scene