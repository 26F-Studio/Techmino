COLOR=	require("Zframework/color")
SCN=	require("Zframework/scene")
LOG=	require("Zframework/log")
require("Zframework/toolfunc")

VIB=	require("Zframework/vib")
SFX=	require("Zframework/sfx")

LIGHT=	require("Zframework/light")
SHADER=	require("Zframework/shader")
BG=		require("Zframework/bg")
WIDGET=	require("Zframework/widget")
TEXT=	require("Zframework/text")
sysFX=	require("Zframework/sysFX")

IMG=	require("Zframework/img")
BGM=	require("Zframework/bgm")
VOC=	require("Zframework/voice")

LANG=	require("Zframework/languages")
TASK=	require("Zframework/task")
FILE=	require("Zframework/file")
PROFILE=require("Zframework/profile")

local ms,kb=love.mouse,love.keyboard
local gc=love.graphics
local int,rnd,abs=math.floor,math.random,math.abs
local min=math.min
local ins,rem=table.insert,table.remove
local SCR=SCR
local setFont=setFont

local mx,my,mouseShow=-20,-20,false
local touching=nil--First touching ID(userdata)
xOy=love.math.newTransform()
joysticks={}

local devMode

local infoCanvas=gc.newCanvas(108,27)
local function updatePowerInfo()
	local state,pow=love.system.getPowerInfo()
	gc.setCanvas(infoCanvas)gc.push("transform")gc.origin()
	gc.clear(0,0,0,.25)
	if state~="unknown"then
		gc.setLineWidth(4)
		local charging=state=="charging"
		if state=="nobattery"then
			gc.setColor(1,1,1)
			gc.setLineWidth(2)
			gc.line(74,5,100,22)
		elseif pow then
			if charging then	gc.setColor(0,1,0)
			elseif pow>50 then	gc.setColor(1,1,1)
			elseif pow>26 then	gc.setColor(1,1,0)
			elseif pow<26 then	gc.setColor(1,0,0)
			else				gc.setColor(.5,0,1)
			end
			gc.rectangle("fill",76,6,pow*.22,14)
			if pow<100 then
				setFont(14)
				gc.setColor(0,0,0)
				gc.print(pow,77,2)
				gc.print(pow,77,4)
				gc.print(pow,79,2)
				gc.print(pow,79,4)
				gc.setColor(1,1,1)
				gc.print(pow,78,3)
			end
		end
		gc.draw(IMG.batteryImage,73,3)
	end
	setFont(25)
	gc.print(os.date("%H:%M",os.time()),3,-5)
	gc.pop()gc.setCanvas()
end
-------------------------------------------------------------
Tmr,Pnt={},{}
mouseClick,touchClick={},{}
mouseDown,mouseMove,mouseUp,wheelMoved={},{},{},{}
touchDown,touchUp,touchMove={},{},{}
keyDown,keyUp={},{}
gamepadDown,gamepadUp={},{}

local Tmr,Pnt=Tmr,Pnt
local mouseClick,touchClick=mouseClick,touchClick
local mouseDown,mouseMove,mouseUp,wheelMoved=mouseDown,mouseMove,mouseUp,wheelMoved
local touchDown,touchUp,touchMove=touchDown,touchUp,touchMove
local keyDown,keyUp=keyDown,keyUp
local gamepadDown,gamepadUp=gamepadDown,gamepadUp
-------------------------------------------------------------
local lastX,lastY=0,0--Last clickDown pos
function love.mousepressed(x,y,k,touch)
	if touch then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	if devMode==1 then DBP(mx,my)end
	if SCN.swapping then return end
	if mouseDown[SCN.cur]then
		mouseDown[SCN.cur](mx,my,k)
	elseif k==2 then
		SCN.back()
	end
	if k==1 then
		WIDGET.press(mx,my)
	end
	lastX,lastY=mx,my
	sysFX.newRipple(.3,mx,my,30)
end
function love.mousemoved(x,y,dx,dy,t)
	if t then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	if SCN.swapping then return end
	dx,dy=dx/SCR.k,dy/SCR.k
	if mouseMove[SCN.cur]then
		mouseMove[SCN.cur](mx,my,dx,dy)
	end
	if ms.isDown(1) then
		WIDGET.drag(mx,my)
	else
		WIDGET.moveCursor(mx,my)
	end
end
function love.mousereleased(x,y,k,touch)
	if touch or SCN.swapping then return end
	mx,my=xOy:inverseTransformPoint(x,y)
	WIDGET.release(mx,my)
	WIDGET.moveCursor(mx,my)
	if mouseUp[SCN.cur]then
		mouseUp[SCN.cur](mx,my,k)
	end
	if lastX and(mx-lastX)^2+(my-lastY)^2<26 and mouseClick[SCN.cur]then
		mouseClick[SCN.cur](mx,my,k)
	end
end
function love.wheelmoved(x,y)
	if SCN.swapping then return end
	if wheelMoved[SCN.cur]then wheelMoved[SCN.cur](x,y)end
end

function love.touchpressed(id,x,y)
	mouseShow=false
	if SCN.swapping then return end
	if not touching then
		touching=id
		love.touchmoved(id,x,y,0,0)
	end
	x,y=xOy:inverseTransformPoint(x,y)
	lastX,lastY=x,y
	if touchDown[SCN.cur]then
		touchDown[SCN.cur](id,x,y)
	end
	if kb.hasTextInput()then kb.setTextInput(false)end
end
function love.touchmoved(id,x,y,dx,dy)
	if SCN.swapping then return end
	x,y=xOy:inverseTransformPoint(x,y)
	if touchMove[SCN.cur]then
		touchMove[SCN.cur](id,x,y,dx/SCR.k,dy/SCR.k)
	end
	if WIDGET.sel then
		if touching then
			WIDGET.drag(x,y)
		end
	else
		WIDGET.moveCursor(x,y)
		if not WIDGET.sel then
			touching=nil
		end
	end
end
function love.touchreleased(id,x,y)
	if SCN.swapping then return end
	x,y=xOy:inverseTransformPoint(x,y)
	if id==touching then
		WIDGET.press(x,y)
		WIDGET.release(x,y)
		touching=nil
		if WIDGET.sel and not WIDGET.sel.keepFocus then
			WIDGET.sel=nil
		end
	end
	if touchUp[SCN.cur]then
		touchUp[SCN.cur](id,x,y)
	end
	if(x-lastX)^2+(y-lastY)^2<26 then
		if touchClick[SCN.cur]then
			touchClick[SCN.cur](x,y)
		end
		sysFX.newRipple(.3,x,y,30)
	end
end

function love.keypressed(i)
	mouseShow=false
	if devMode then
		if i=="f1"then
			PROFILE.switch()
		elseif i=="f2"then
			LOG.print("System:"..SYSTEM.."["..jit.arch.."]")
			LOG.print("luaVer:".._VERSION)
			LOG.print("jitVer:"..jit.version)
			LOG.print("jitVerNum:"..jit.version_num)
			local r=rnd()<.5
			love._setGammaCorrect(r)
			LOG.print("GammaCorrect: "..(r and"on"or"off"),"warn")
		elseif i=="f3"then
			for _=1,8 do
				local P=PLAYERS.alive[rnd(#PLAYERS.alive)]
				if P~=PLAYERS[1]then
					P.lastRecv=PLAYERS[1]
					P:lose()
				end
			end
		elseif i=="f4"then	if not kb.isDown("lalt","ralt")then LOG.copy()end
		elseif i=="f5"then	if love._openConsole then love._openConsole()end
		elseif i=="f6"then	if WIDGET.sel then DBP(WIDGET.sel)end
		elseif i=="f7"then	for k,v in next,_G do DBP(k,v)end
		elseif i=="f8"then	devMode=nil	LOG.print("DEBUG OFF",COLOR.yellow)
		elseif i=="f9"then	devMode=1	LOG.print("DEBUG 1",COLOR.yellow)
		elseif i=="f10"then	devMode=2	LOG.print("DEBUG 2",COLOR.yellow)
		elseif i=="f11"then	devMode=3	LOG.print("DEBUG 3",COLOR.yellow)
		elseif i=="f12"then	devMode=4	LOG.print("DEBUG 4",COLOR.yellow)
		elseif devMode==2 then
			if WIDGET.sel then
				local W=WIDGET.sel
				if i=="left"then W.x=W.x-10
				elseif i=="right"then W.x=W.x+10
				elseif i=="up"then W.y=W.y-10
				elseif i=="down"then W.y=W.y+10
				elseif i==","then W.w=W.w-10
				elseif i=="."then W.w=W.w+10
				elseif i=="/"then W.h=W.h-10
				elseif i=="'"then W.h=W.h+10
				elseif i=="["then W.font=W.font-1
				elseif i=="]"then W.font=W.font+1
				else goto NORMAL
				end
			else
				goto NORMAL
			end
		else
			goto NORMAL
		end
		return
	end
	::NORMAL::
	if i~="f8"then
		if SCN.swapping then return end

		if keyDown[SCN.cur]then keyDown[SCN.cur](i)
		elseif i=="escape"then SCN.back()
		else WIDGET.keyPressed(i)
		end
	else
		devMode=1
		LOG.print("DEBUG ON",COLOR.yellow)
	end
end
function love.keyreleased(i)
	if SCN.swapping then return end
	if keyUp[SCN.cur]then keyUp[SCN.cur](i)end
end
function love.textedited(text)
	EDITING=text
end
function love.textinput(text)
	local W=WIDGET.sel
	if W and W.type=="textBox"then
		if not W.regex or text:match(W.regex)then
			WIDGET.sel.value=WIDGET.sel.value..text
			SFX.play("move")
		else
			SFX.play("finesseError",.3)
		end
	end
end

function love.joystickadded(JS)
	joysticks[#joysticks+1]=JS
end
function love.joystickremoved(JS)
	for i=1,#joysticks do
		if joysticks[i]==JS then
			rem(joysticks,i)
			LOG.print("Joystick removed",COLOR.yellow)
			return
		end
	end
end
local keyMirror={
	dpup="up",
	dpdown="down",
	dpleft="left",
	dpright="right",
	start="return",
	back="escape",
}
function love.gamepadpressed(_,i)
	mouseShow=false
	if SCN.swapping then return end
	if gamepadDown[SCN.cur]then gamepadDown[SCN.cur](i)
	elseif keyDown[SCN.cur]then keyDown[SCN.cur](keyMirror[i]or i)
	elseif i=="back"then SCN.back()
	else WIDGET.gamepadPressed(i)
	end
end
function love.gamepadreleased(_,i)
	if SCN.swapping then return end
	if gamepadUp[SCN.cur]then gamepadUp[SCN.cur](i)
	end
end
--[[
function love.joystickpressed(JS,k)
	mouseShow=false
	if SCN.swapping then return end
	if gamepadDown[SCN.cur]then gamepadDown[SCN.cur](i)
	elseif keyDown[SCN.cur]then keyDown[SCN.cur](keyMirror[i]or i)
	elseif i=="back"then SCN.back()
	else WIDGET.gamepadPressed(i)
	end
end
function love.joystickreleased(JS,k)
	if SCN.swapping then return end
	if gamepadUp[SCN.cur]then gamepadUp[SCN.cur](i)
	end
end
function love.joystickaxis(JS,axis,val)

end
function love.joystickhat(JS,hat,dir)

end
function love.sendData(data)end
function love.receiveData(id,data)end
]]
function love.lowmemory()
	collectgarbage()
end
function love.resize(w,h)
	SCR.w,SCR.h,SCR.dpi=w,h,gc.getDPIScale()
	SCR.W,SCR.H=SCR.w*SCR.dpi,SCR.h*SCR.dpi
	SCR.r=h/w
	SCR.rad=(w^2+h^2)^.5

	if SCR.r>=SCR.h0/SCR.w0 then
		SCR.k=w/SCR.w0
		SCR.x,SCR.y=0,(h-w*SCR.h0/SCR.w0)/2
	else
		SCR.k=h/SCR.h0
		SCR.x,SCR.y=(w-h*SCR.w0/SCR.h0)/2,0
	end
	xOy=xOy:setTransformation(w/2,h/2,nil,SCR.k,nil,SCR.w0/2,SCR.h0/2)
	if BG.resize then BG.resize(w,h)end

	SHADER.warning:send("w",w*SCR.dpi)
	SHADER.warning:send("h",h*SCR.dpi)
end
function love.focus(f)
	if f then
		love.timer.step()
	elseif SCN.cur=="play"and SETTING.autoPause then
		pauseGame()
	end
end
function love.errorhandler(msg)
	ms.setVisible(true)
	love.audio.stop()

	local err={"Error:"..msg}
	local trace=debug.traceback("",2)
	local c=2
	for l in string.gmatch(trace,"(.-)\n")do
		if c>2 then
			if not string.find(l,"boot")then
				err[c]=string.gsub(l,"^\t*","")
				c=c+1
			end
		else
			err[2]="Traceback"
			c=3
		end
	end
	DBP(table.concat(err,"\n"),1,c-2)
	gc.reset()

	local errScrShot
	gc.captureScreenshot(function (_)errScrShot=gc.newImage(_)end)
	gc.present()

	SFX.fplay("error",SETTING.voc*.8)

	local BGcolor=rnd()>.026 and{.3,.5,.9}or{.62,.3,.926}
	local needDraw=true
	local count=0
	return function()
		love.event.pump()
		for E,a,b in love.event.poll()do
			if E=="quit"or a=="escape"then
				destroyPlayers()
				return 1
			elseif E=="resize"then
				love.resize(a,b)
				needDraw=true
			elseif E=="focus"then
				needDraw=true
			elseif E=="touchpressed"or E=="mousepressed"or E=="keypressed"and a=="space"then
				if count<3 then
					count=count+1
					SFX.play("ready")
				else
					local code=loadstring(love.system.getClipboardText())
					if code then
						code()
						SFX.play("reach")
					else
						SFX.play("finesseError")
					end
					count=0
				end
			end
		end
		if needDraw then
			gc.discard()
			gc.clear(BGcolor)
			gc.setColor(1,1,1)
			gc.push("transform")
			gc.replaceTransform(xOy)
			gc.draw(errScrShot,100,365,nil,512/errScrShot:getWidth(),288/errScrShot:getHeight())
			setFont(120)gc.print(":(",100,40)
			setFont(38)gc.printf(text.errorMsg,100,200,SCR.w0-100)
			setFont(20)
			gc.print(SYSTEM.."-"..gameVersion,100,660)
			gc.print("scene:"..SCN.cur,400,660)
			gc.printf(err[1],626,360,1260-626)
			gc.print("TRACEBACK",626,426)
			for i=4,#err-2 do
				gc.print(err[i],626,370+20*i)
			end
			gc.pop()
			gc.present()
			needDraw=false
		end
		love.timer.sleep(.26)
	end
end
local devColor={
	COLOR.white,
	COLOR.lMagenta,
	COLOR.lGreen,
	COLOR.lBlue,
}
local FPS=love.timer.getFPS
love.draw,love.update=nil--remove default draw/update
function love.run()
	local SETTING=SETTING
	local DISCARD=gc.discard
	local PRESENT=gc.present

	local T=love.timer
	local Timer=T.getTime
	local STEP,GETDelta,WAIT=T.step,T.getDelta,T.sleep
	local mini=love.window.isMinimized
	local PUMP,POLL=love.event.pump,love.event.poll

	local frameTimeList={}

	local lastFrame=Timer()
	local lastFreshPow=lastFrame
	local FCT=0--Framedraw counter

	love.resize(gc.getWidth(),gc.getHeight())

	--Scene Launch
	if SETTING.appLock then
		SCN.init("calculator")
	else
		SCN.init("load")
	end
	BG.set("none")

	return function()
		local _

		lastFrame=Timer()

		--EVENT
		PUMP()
		for N,a,b,c,d,e in POLL()do
			if love[N]then
				love[N](a,b,c,d,e)
			elseif N=="quit"then
				destroyPlayers()
				return true
			end
		end

		--UPDATE
		STEP()
		local dt=GETDelta()
		TASK.update()
		VOC.update()
		BG.update(dt)
		sysFX.update(dt)
		TEXT.update()
		_=Tmr[SCN.cur]if _ then _(dt)end--Scene Updater
		if SCN.swapping then SCN.swapUpdate()end--Scene swapping animation
		WIDGET.update()--Widgets animation
		LOG.update()

		--DRAW
		if not mini()then
			FCT=FCT+SETTING.frameMul
			if FCT>=100 then
				FCT=FCT-100
				DISCARD()--SPEED UPUPUP!

				BG.draw()
				gc.push("transform")
					gc.replaceTransform(xOy)

					--Draw scene contents
					if Pnt[SCN.cur]then Pnt[SCN.cur]()end

					--Draw widgets
					WIDGET.draw()

					--Draw cursor
					if mouseShow then
						local r=Timer()*.5
						local R=int(r)%7+1
						_=SKIN.libColor[SETTING.skin[R]]
						gc.setColor(_[1],_[2],_[3],min(1-abs(1-r%1*2),.3))
						gc.draw(TEXTURE.miniBlock[R],mx,my,Timer()%3.1416*4,20,20,spinCenters[R][0][2]+.5,#BLOCKS[R][0]-spinCenters[R][0][1]-.5)
						gc.setColor(1,1,1,.5)gc.circle("fill",mx,my,5)
						gc.setColor(1,1,1)gc.circle("fill",mx,my,3)
					end
					sysFX.draw()
					TEXT.draw()
				gc.pop()

				--Draw power info.
				gc.setColor(1,1,1)
				if SETTING.powerInfo then
					gc.draw(infoCanvas,0,0,0,SCR.k)
				end

				--Draw scene swapping animation
				if SCN.swapping then
					_=SCN.stat
					_.draw(_.time)
				end

				--Draw network working
				if TASK.netTaskCount>0 then
					setFont(30)
					gc.setColor(COLOR.rainbow(Timer()*5))
					gc.print("E",1250,0,.26+.355*math.sin(Timer()*6.26))
				end

				--Draw FPS
				gc.setColor(1,1,1)
				setFont(15)
				_=SCR.h
				gc.print(FPS(),5,_-20)

				--Debug info.
				if devMode then
					gc.setColor(devColor[devMode])
					gc.print("Memory:"..gcinfo(),5,_-40)
					gc.print("Lines:"..FREEROW.getCount(),5,_-60)
					gc.print("Cursor:"..int(mx+.5).." "..int(my+.5),5,_-80)
					gc.print("Voices:"..VOC.getCount(),5,_-100)
					gc.print("Tasks:"..TASK.getCount(),5,_-120)
					ins(frameTimeList,1,dt)rem(frameTimeList,126)
					gc.setColor(1,1,1,.3)
					for i=1,#frameTimeList do
						gc.rectangle("fill",150+2*i,_-20,2,-frameTimeList[i]*4000)
					end
					if devMode==3 then WAIT(.1)
					elseif devMode==4 then WAIT(.5)
					end
				end
				LOG.draw()

				PRESENT()
			end
		end

		--Fresh power info.
		if Timer()-lastFreshPow>2.6 then
			if SETTING.powerInfo and LOADED then
				updatePowerInfo()
				lastFreshPow=Timer()
			end
			if gc.getWidth()~=SCR.w then
				love.resize(gc.getWidth(),gc.getHeight())
				LOG.print("Screen Resized",COLOR.yellow)
			end
		end

		--Keep 60fps
		_=Timer()-lastFrame
		if _<.016 then WAIT(.016-_)end
		while Timer()-lastFrame<1/60-5e-6 do WAIT(0)end
	end
end