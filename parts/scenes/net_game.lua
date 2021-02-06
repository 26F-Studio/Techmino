local data=love.data
local gc=love.graphics
local gc_setColor,gc_circle=gc.setColor,gc.circle
local tc=love.touch

local playerData
local ins,rem=table.insert,table.remove
local max,sin=math.max,math.sin

local SCR=SCR
local VK=virtualkey
local function onVirtualkey(x,y)
	local dist,nearest=1e10
	for K=1,#VK do
		local B=VK[K]
		if B.ava then
			local d1=(x-B.x)^2+(y-B.y)^2
			if d1<B.r^2 then
				if d1<dist then
					nearest,dist=K,d1
				end
			end
		end
	end
	return nearest
end

local hideChatBox
local textBox=WIDGET.newTextBox{name="texts",x=340,y=80,w=600,h=550,hide=function()return hideChatBox end}
local function switchChat()
	hideChatBox=not hideChatBox
end


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
	wsWrite("C"..dumpBasicConfig())
	TASK.new(TICK_wsRead)
	hideChatBox=true
	textBox:clear()

	playerData={}
	resetGameData("n",playerData)
	noTouch=not SETTING.VKSwitch
	playing=false
	lastUpstreamTime=0
	upstreamProgress=1
	heartBeatTimer=0
end

function scene.touchDown(_,x,y)
	if noTouch then return end

	local t=onVirtualkey(x,y)
	if t then
		PLAYERS[1]:pressKey(t)
		if SETTING.VKSFX>0 then
			SFX.play("virtualKey",SETTING.VKSFX)
		end
		local B=VK[t]
		B.isDown=true
		B.pressTime=10
		if SETTING.VKTrack then
			if SETTING.VKDodge then--Button collision (not accurate)
			for i=1,#VK do
					local b=VK[i]
					local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5--Hit depth(Neg means distance)
					if d>0 then
						b.x=b.x+(b.x-B.x)*d*b.r*5e-4
						b.y=b.y+(b.y-B.y)*d*b.r*5e-4
					end
				end
			end
			local O=VK_org[t]
			local _FW,_CW=SETTING.VKTchW,1-SETTING.VKCurW
			local _OW=1-_FW-_CW

			--Auto follow: finger, current, origin (weight from setting)
			B.x,B.y=x*_FW+B.x*_CW+O.x*_OW,y*_FW+B.y*_CW+O.y*_OW
		end
		VIB(SETTING.VKVIB)
	end
end
function scene.touchUp(_,x,y)
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
	elseif key=="b"then
		wsWrite("B")
	elseif key=="\\"then
		switchChat()
	else
		if noKey then return end
		local k=keyMap.keyboard[key]
		if k and k>0 then
			PLAYERS[1]:pressKey(k)
			VK[k].isDown=true
			VK[k].pressTime=10
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
	local args=splitStr(mes:sub(2),":")
				print(cmd.." "..table.concat(args, " ; "))-------DEBUG PRINT
	if cmd=="J"or cmd=="L"then
		textBox:push{
			COLOR.lR,args[1],
			COLOR.dY,args[2].." ",
			COLOR.Y,text[cmd=="J"and"joinRoom"or"leaveRoom"]
		}
		if cmd=="J"then
			if tostring(USER.id)~=args[2]then
				wsWrite("C"..dumpBasicConfig())
				ins(playerData,{name=args[1],id=args[2]})
				resetGameData("qn",playerData)
			end
		else
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
					initPlayerPosition(true)
					return
				end
			end
		end
	elseif cmd=="T"then
		textBox:push{
			COLOR.W,args[1],
			COLOR.dY,args[2].." ",
			COLOR.sky,args[3]
		}
	elseif cmd=="C"then
		if tostring(USER.id)~=args[2]then
			local ENV=json.decode(data.decode("string","base64",args[3]))
			for i=1,#playerData do
				if playerData[i].id==args[2]then
					playerData[i].conf=ENV
					playerData[i].p:setConf(ENV)
					return
				end
			end
			ins(playerData,{name=args[1],id=args[2],conf=ENV})
			resetGameData("qn",playerData)
		end
	elseif cmd=="S"then
		if args[1]~=tostring(USER.id)then
			for _,P in next,PLAYERS do
				if P.userID==args[1]then
					pumpRecording(data.decode("string","base64",args[2]),P.stream)
				end
			end
		end
	elseif cmd=="B"then
		if not playing then
			playing=true
			resetGameData("n",playerData,tonumber(args[1]))
		else
			LOG.print("Redundant signal: B(begin)",30,COLOR.green)
		end
	elseif cmd=="F"then
		playing=false
		LOG.print(text.gameover,30,COLOR.green)
	else
		LOG.print("Illegal message: ["..mes.."]",30,COLOR.green)
	end
end

function scene.update(dt)
	local _
	local P1=PLAYERS[1]
	local GAME=GAME

	touchMoveLastFrame=false

	--Update virtualkey animation
	if SETTING.VKSwitch then
		for i=1,#VK do
			_=VK[i]
			if _.pressTime>0 then
				_.pressTime=_.pressTime-1
			end
		end
	end

	if not playing then
		heartBeatTimer=heartBeatTimer+dt
		if heartBeatTimer>42 then
			heartBeatTimer=0
			wsWrite("P")
		end
		return
	end

	GAME.frame=GAME.frame+1

	if GAME.frame-lastUpstreamTime>10 then
		local stream
		stream,upstreamProgress=dumpRecording(GAME.rep,upstreamProgress)
		if #stream>0 then
			wsWrite("S"..data.encode("string","base64",stream))
		end
		lastUpstreamTime=PLAYERS[1].alive and GAME.frame or 1e99
	end

	--Counting,include pre-das,directy RETURN,or restart counting
	if GAME.frame<180 then
		if GAME.frame==179 then
			gameStart()
		elseif GAME.frame==60 or GAME.frame==120 then
			SFX.play("ready")
		end
		for p=1,#PLAYERS do
			local P=PLAYERS[p]
			if P.movDir~=0 then
				if P.moving<P.gameEnv.das then
					P.moving=P.moving+1
				end
			else
				P.moving=0
			end
		end
		return
	end

	--Update players
	for p=1,#PLAYERS do
		PLAYERS[p]:update(dt)
	end

	--Warning check
	if P1.alive then
		if GAME.frame%26==0 and SETTING.warn then
			local F=P1.field
			local height=0--Max height of row 4~7
			for x=4,7 do
				for y=#F,1,-1 do
					if F[y][x]>0 then
						if y>height then
							height=y
						end
						break
					end
				end
			end
			GAME.warnLVL0=math.log(height-15+P1.atkBuffer.sum*.8)
		end
		_=GAME.warnLVL
		if _<GAME.warnLVL0 then
			_=_*.95+GAME.warnLVL0*.05
		elseif _>0 then
			_=max(_-.026,0)
		end
		GAME.warnLVL=_
	elseif GAME.warnLVL>0 then
		GAME.warnLVL=max(GAME.warnLVL-.026,0)
	end
	if GAME.warnLVL>1.126 and GAME.frame%30==0 then
		SFX.fplay("warning",SETTING.sfx_warn)
	end
end

function scene.draw()
	local t=TIME()
	if MARKING then
		setFont(25)
		gc_setColor(1,1,1,.2+.1*(sin(3*t)+sin(2.6*t)))
		mStr(text.marking,190,60+26*sin(t))
	end

	--Players
	for p=hideChatBox and 1 or 2,#PLAYERS do
		PLAYERS[p]:draw()
	end

	--Virtual keys
	if SETTING.VKSwitch then
		local a=SETTING.VKAlpha
		local _
		if SETTING.VKIcon then
			local icons=TEXTURE.VKIcon
			for i=1,#VK do
				if VK[i].ava then
					local B=VK[i]
					gc_setColor(1,1,1,a)
					gc.setLineWidth(B.r*.07)
					gc_circle("line",B.x,B.y,B.r,10)--Button outline
					_=VK[i].pressTime
					gc_setColor(B.color[1],B.color[2],B.color[3],a)
					gc.draw(icons[i],B.x,B.y,nil,B.r*.026+_*.08,nil,18,18)--Icon
					if _>0 then
						gc_setColor(1,1,1,a*_*.08)
						gc_circle("fill",B.x,B.y,B.r*.94,10)--Glow when press
						gc_circle("line",B.x,B.y,B.r*(1.4-_*.04),10)--Ripple
					end
				end
			end
		else
			for i=1,#VK do
				if VK[i].ava then
					local B=VK[i]
					gc_setColor(1,1,1,a)
					gc.setLineWidth(B.r*.07)
					gc_circle("line",B.x,B.y,B.r,10)
					_=VK[i].pressTime
					if _>0 then
						gc_setColor(1,1,1,a*_*.08)
						gc_circle("fill",B.x,B.y,B.r*.94,10)
						gc_circle("line",B.x,B.y,B.r*(1.4-_*.04),10)
					end
				end
			end
		end
	end

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
	WIDGET.newKey{name="hideChat",fText="...",x=410,y=40,w=60,font=35,code=switchChat},
	WIDGET.newKey{name="quit",fText="X",x=870,y=40,w=60,font=40,code=pressKey"escape"},
}

return scene