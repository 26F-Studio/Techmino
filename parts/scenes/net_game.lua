local gc=love.graphics
local tc=love.touch

local ins=table.insert

local SCR=SCR
local VK=VK

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
function scene.sceneInit()
	love.keyboard.setKeyRepeat(false)
	textBox.hide=true
	textBox:clear()

	noTouch=not SETTING.VKSwitch
	playing=false
	lastUpstreamTime=0
	upstreamProgress=1
end

scene.mouseDown=NULL
function scene.touchDown(x,y)
	if noTouch or not playing then return end

	local t=VK.on(x,y)
	if t then
		PLAYERS[1]:pressKey(t)
		VK.touch(t,x,y)
	end
end
function scene.touchUp(x,y)
	if noTouch or not playing then return end

	local t=VK.on(x,y)
	if t then
		PLAYERS[1]:releaseKey(t)
	end
end
function scene.touchMove()
	if noTouch or touchMoveLastFrame or not playing then return end
	touchMoveLastFrame=true

	local L=tc.getTouches()
	for i=#L,1,-1 do
		L[2*i-1],L[2*i]=SCR.xOy:inverseTransformPoint(tc.getPosition(L[i]))
	end
	local keys=VK.getKeys
	for n=1,#keys do
		local B=keys[n]
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
			local vk=VK.getKeys()[k]
			vk.isDown=true
			vk.pressTime=10
		end
	elseif key=="space"then
		NET.signal_ready(not PLY_NET[1].ready)
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
			SCN.back()
		else
			lastBackTime=TIME()
			LOG.print(text.sureQuit,COLOR.O)
		end
	else
		if noKey then return end
		local k=keyMap.joystick[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK.press(k)
		end
	end
end
function scene.gamepadUp(key)
	if noKey then return end
	local k=keyMap.joystick[key]
	if k and k>0 then
		PLAYERS[1]:releaseKey(k)
		VK.release(k)
		return
	end
end

function scene.socketRead(cmd,d)
	if cmd=="Join"then
		textBox:push{
			COLOR.lR,d.username,
			COLOR.dY,"#"..d.uid.." ",
			COLOR.Y,text.joinRoom,
		}
		SFX.play("click")
	elseif cmd=="Leave"then
		textBox:push{
			COLOR.lR,d.username,
			COLOR.dY,"#"..d.uid.." ",
			COLOR.Y,text.leaveRoom,
		}
	elseif cmd=="Talk"then
		textBox:push{
			COLOR.Z,d.username,
			COLOR.dY,"#"..d.uid.." ",
			COLOR.N,d.message or"[_]",
		}
	elseif cmd=="Go"then
		if not playing then
			playing=true
			for i=1,#PLY_NET do
				PLY_NET[i].ready=false
			end
			lastUpstreamTime=0
			upstreamProgress=1
			resetGameData("n",d.seed)
		else
			LOG.print("Redundant [Go]",30,COLOR.G)
		end
	elseif cmd=="Finish"then
		playing=false
		local winnerUID
		for _,p in next,d.result do
			if p.place==1 then
				winnerUID=p.uid
				break
			end
		end
		if not winnerUID then return end
		for _,p in next,PLY_NET do
			if p.uid==winnerUID then
				TEXT.show(text.champion:gsub("$1",p.username),640,260,80,"zoomout",.26)
				break
			end
		end
	elseif cmd=="Stream"then
		if d.uid~=USER.uid and playing then
			for _,P in next,PLAYERS do
				if P.uid==d.uid then
					local res,stream=pcall(love.data.decode,"string","base64",d.stream)
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
	if NET.checkPlayDisconn()then SCN.back()end
	if not playing then return end

	local P1=PLAYERS[1]
	local GAME=GAME

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
end

function scene.draw()
	if playing then
		drawFWM()

		--Players
		for p=textBox.hide and 1 or 2,#PLAYERS do
			PLAYERS[p]:draw()
		end

		--Virtual keys
		VK.draw()

		--Warning
		drawWarning()
	else
		for i=1,#PLY_NET do
			local p=PLY_NET[i]

			--Rectangle
			gc.setColor(COLOR[p.ready and"G"or"white"])
			gc.setLineWidth(3)
			gc.rectangle("line",40,67+50*i,800,42)

			--Username
			gc.setColor(1,1,1)
			setFont(40)
			gc.print(p.username,200,60+50*i)

			--UID
			gc.setColor(.5,.5,.5)
			gc.print("#"..p.uid,50,60+50*i)
		end

		--Profile
		drawSelfProfile()
	end
	--New message
	if textBox.new and textBox.hide then
		setFont(30)
		gc.setColor(1,TIME()%.4<.2 and 1 or 0,0)
		gc.print("M",460,15)
	end
end
scene.widgetList={
	textBox,
	WIDGET.newKey{name="ready",x=900,y=560,w=400,h=100,color="lB",font=40,code=pressKey"space",
		hide=function()
			return
				playing or
				not textBox.hide or
				PLY_NET[1].ready or
				NET.getlock("ready")
		end},
	WIDGET.newKey{name="cancel",x=900,y=560,w=400,h=100,color="H",font=40,code=pressKey"space",
		hide=function()
			return
				playing or
				not textBox.hide or
				not PLY_NET[1].ready or
				NET.getlock("ready")
		end},
	WIDGET.newKey{name="hideChat",fText="...",x=380,y=35,w=60,font=35,code=pressKey"\\"},
	WIDGET.newKey{name="quit",fText="X",x=900,y=35,w=60,font=40,code=pressKey"escape"},
}

return scene