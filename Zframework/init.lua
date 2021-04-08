SCR=	require"Zframework.screen"
COLOR=	require"Zframework.color"
SCN=	require"Zframework.scene"
LOG=	require"Zframework.log"
WS=		require"Zframework.websocket"

LOADLIB=require"Zframework.loadLib"
WHEELMOV=require"Zframework.wheelScroll"

require"Zframework.setFont"
MDRAW=require"Zframework.mDraw"
	mStr=MDRAW.str
	mText=MDRAW.simpX
	mDraw=MDRAW.draw

-- UPPERCHAR=require"Zframework.upperChar"
JSON=require"Zframework.json"
DUMPTABLE=require"Zframework.dumpTable"
URLENCODE=require"Zframework.urlEncode"

TABLE=require"Zframework.tableExtend"
SPLITSTR=require"Zframework.splitStr"
TIMESTR=require"Zframework.timeStr"

VIB=	require"Zframework.vibrate"
SFX=	require"Zframework.sfx"

LIGHT=	require"Zframework.light"
DOGC=	require"Zframework.doGC"
BG=		require"Zframework.background"
WIDGET=	require"Zframework.widget"
TEXT=	require"Zframework.text"
SYSFX=	require"Zframework.sysFX"

IMG=	require"Zframework.image"
BGM=	require"Zframework.bgm"
VOC=	require"Zframework.voice"

LANG=	require"Zframework.languages"
TASK=	require"Zframework.task"
FILE=	require"Zframework.file"
PROFILE=require"Zframework.profile"
THEME=	require"Zframework.theme"

local ms,kb=love.mouse,love.keyboard

local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_discard,gc_present=gc.discard,gc.present
local gc_setColor,gc_draw,gc_rectangle=gc.setColor,gc.draw,gc.rectangle
local gc_print=gc.print
local setFont=setFont

local int,rnd,abs=math.floor,math.random,math.abs
local min,sin=math.min,math.sin
local ins,rem=table.insert,table.remove
local SCR=SCR

local mx,my,mouseShow=-20,-20,false
local touching--First touching ID(userdata)
local xOy=SCR.xOy
joysticks={}

local devMode

local infoCanvas=gc.newCanvas(108,27)
local function updatePowerInfo()
	local state,pow=love.system.getPowerInfo()
	gc.setCanvas(infoCanvas)gc_push("transform")gc.origin()
	gc.clear(0,0,0,.25)
	if state~="unknown"then
		gc.setLineWidth(4)
		local charging=state=="charging"
		if state=="nobattery"then
			gc_setColor(1,1,1)
			gc.setLineWidth(2)
			gc.line(74,SCR.safeX+5,100,22)
		elseif pow then
			if charging then	gc_setColor(0,1,0)
			elseif pow>50 then	gc_setColor(1,1,1)
			elseif pow>26 then	gc_setColor(1,1,0)
			elseif pow<26 then	gc_setColor(1,0,0)
			else				gc_setColor(.5,0,1)
			end
			gc_rectangle("fill",76,6,pow*.22,14)
			if pow<100 then
				setFont(15)
				gc_setColor(0,0,0)
				gc_print(pow,77,1)
				gc_print(pow,77,3)
				gc_print(pow,79,1)
				gc_print(pow,79,3)
				gc_setColor(1,1,1)
				gc_print(pow,78,2)
			end
		end
		gc_draw(IMG.batteryImage,73,3)
	end
	setFont(25)
	gc_print(os.date("%H:%M"),3,-5)
	gc_pop()gc.setCanvas()
end
-------------------------------------------------------------
local lastX,lastY=0,0--Last click pos
function love.mousepressed(x,y,k,touch)
	if touch then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	if devMode==1 then
		DBP(("(%d,%d)<-%d,%d ~~(%d,%d)<-%d,%d"):format(
			mx,my,
			mx-lastX,my-lastY,
			int(mx/10)*10,int(my/10)*10,
			int((mx-lastX)/10)*10,int((my-lastY)/10)*10
		))
	end
	if SCN.swapping then return end
	if SCN.mouseDown then
		SCN.mouseDown(mx,my,k)
	elseif k==2 then
		SCN.back()
	end
	if k==1 then
		WIDGET.press(mx,my)
	end
	lastX,lastY=mx,my
	SYSFX.newTap(3,mx,my,30)
end
function love.mousemoved(x,y,dx,dy,touch)
	if touch then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	if SCN.swapping then return end
	dx,dy=dx/SCR.k,dy/SCR.k
	if SCN.mouseMove then SCN.mouseMove(mx,my,dx,dy)end
	if ms.isDown(1) then
		WIDGET.drag(mx,my,dx,dy)
	else
		WIDGET.cursorMove(mx,my)
	end
end
function love.mousereleased(x,y,k,touch)
	if touch or SCN.swapping then return end
	mx,my=xOy:inverseTransformPoint(x,y)
	WIDGET.release(mx,my)
	if SCN.mouseUp then SCN.mouseUp(mx,my,k)end
	if lastX and SCN.mouseClick and(mx-lastX)^2+(my-lastY)^2<62 then
		SCN.mouseClick(mx,my,k)
	end
end
function love.wheelmoved(x,y)
	if SCN.swapping then return end
	if SCN.wheelMoved then SCN.wheelMoved(x,y)end
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
	if SCN.touchDown then SCN.touchDown(x,y)end
	if kb.hasTextInput()then kb.setTextInput(false)end
end
function love.touchmoved(_,x,y,dx,dy)
	if SCN.swapping then return end
	x,y=xOy:inverseTransformPoint(x,y)
	if SCN.touchMove then SCN.touchMove(x,y,dx/SCR.k,dy/SCR.k)end
	if WIDGET.sel then
		if touching then
			WIDGET.drag(x,y,dx,dy)
		end
	else
		WIDGET.cursorMove(x,y)
		if not WIDGET.sel then
			touching=false
		end
	end
end
function love.touchreleased(id,x,y)
	if SCN.swapping then return end
	x,y=xOy:inverseTransformPoint(x,y)
	if id==touching then
		WIDGET.press(x,y)
		WIDGET.release(x,y)
		touching=false
		if WIDGET.sel and not WIDGET.sel.keepFocus then
			WIDGET.sel=false
		end
	end
	if SCN.touchUp then SCN.touchUp(x,y)end
	if(x-lastX)^2+(y-lastY)^2<62 then
		if SCN.touchClick then SCN.touchClick(x,y)end
		SYSFX.newTap(3,x,y,30)
	end
end

local function noDevkeyPressed(key)
	if key=="f1"then
		PROFILE.switch()
	elseif key=="f2"then
		LOG.print(string.format("System:%s[%s]\nluaVer:%s\njitVer:%s\njitVerNum:%s",SYSTEM,jit.arch,_VERSION,jit.version,jit.version_num))
	elseif key=="f3"then
		for _=1,8 do
			local P=PLY_ALIVE[rnd(#PLY_ALIVE)]
			if P~=PLAYERS[1]then
				P.lastRecv=PLAYERS[1]
				P:lose()
			end
		end
	elseif key=="f4"then	if not kb.isDown("lalt","ralt")then LOG.copy()end
	elseif key=="f5"then	if WIDGET.sel then DBP(WIDGET.sel)end
	elseif key=="f6"then	for k,v in next,_G do DBP(k,v)end
	elseif key=="f7"then	if love._openConsole then love._openConsole()end
	elseif key=="f8"then	devMode=nil	LOG.print("DEBUG OFF",COLOR.yellow)
	elseif key=="f9"then	devMode=1	LOG.print("DEBUG 1",COLOR.yellow)
	elseif key=="f10"then	devMode=2	LOG.print("DEBUG 2",COLOR.yellow)
	elseif key=="f11"then	devMode=3	LOG.print("DEBUG 3",COLOR.yellow)
	elseif key=="f12"then	devMode=4	LOG.print("DEBUG 4",COLOR.yellow)
	elseif key=="\\"then	_G["\100\114\97\119\70\87\77"]=NULL
	elseif devMode==2 then
		if WIDGET.sel then
			local W=WIDGET.sel
			if key=="left"then W.x=W.x-10
			elseif key=="right"then W.x=W.x+10
			elseif key=="up"then W.y=W.y-10
			elseif key=="down"then W.y=W.y+10
			elseif key==","then W.w=W.w-10
			elseif key=="."then W.w=W.w+10
			elseif key=="/"then W.h=W.h-10
			elseif key=="'"then W.h=W.h+10
			elseif key=="["then W.font=W.font-5
			elseif key=="]"then W.font=W.font+5
			else return true
			end
		else
			return true
		end
	else
		return true
	end
end
function love.keypressed(key)
	mouseShow=false
	if devMode and not noDevkeyPressed(key)then
		return
	elseif key=="f8"then
		devMode=1
		LOG.print("DEBUG ON",COLOR.yellow)
	elseif key=="f11"then
		switchFullscreen()
	elseif not SCN.swapping then
		if SCN.keyDown then
			SCN.keyDown(key)
		elseif key=="escape"then
			SCN.back()
		else
			WIDGET.keyPressed(key)
		end
	end
end
function love.keyreleased(i)
	if SCN.swapping then return end
	if SCN.keyUp then SCN.keyUp(i)end
end

function love.textedited(texts)
	EDITING=texts
end
function love.textinput(texts)
	WIDGET.textinput(texts)
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
	if SCN.gamepadDown then SCN.gamepadDown(i)
	elseif SCN.keyDown then SCN.keyDown(keyMirror[i]or i)
	elseif i=="back"then SCN.back()
	else WIDGET.gamepadPressed(keyMirror[i]or i)
	end
end
function love.gamepadreleased(_,i)
	if SCN.swapping then return end
	if SCN.gamepadUp then SCN.gamepadUp(i)end
end
--[[
function love.joystickpressed(JS,k)
	mouseShow=false
	if SCN.swapping then return end
	if SCN.gamepadDown then SCN.gamepadDown(i)
	elseif SCN.keyDown then SCN.keyDown(keyMirror[i]or i)
	elseif i=="back"then SCN.back()
	else WIDGET.gamepadPressed(i)
	end
end
function love.joystickreleased(JS,k)
	if SCN.swapping then return end
	if SCN.gamepadUp then SCN.gamepadUp(i)
	end
end
function love.joystickaxis(JS,axis,val)

end
function love.joystickhat(JS,hat,dir)

end
function love.sendData(data)end
function love.receiveData(id,data)end
]]
local lastGCtime=0
function love.lowmemory()
	if TIME()-lastGCtime>6.26 then
		collectgarbage()
		lastGCtime=TIME()
		LOG.print("[auto GC] low MEM 设备内存过低","warn")
	end
end
function love.resize(w,h)
	SCR.resize(w,h)
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

local yield=coroutine.yield
local function secondLoopThread()
	local mainLoop=love.run()
	repeat yield()until mainLoop()
end
function love.errorhandler(msg)
	if not msg then msg="Unknown error" end

	--Generate error message
	local err={"Error:"..msg}
	local c=2
	for l in debug.traceback("",2):gmatch("(.-)\n")do
		if c>2 then
			if not l:find("boot")then
				err[c]=l:gsub("^\t*","")
				c=c+1
			end
		else
			err[2]="Traceback"
			c=3
		end
	end
	DBP(table.concat(err,"\n",1,c-2))

	--Reset something
	love.audio.stop()
	gc.reset()

	if LOADED and #ERRDATA<3 then
		BG.set("none")
		local scn=SCN and SCN.cur or"NULL"
		ERRDATA[#ERRDATA+1]={mes=err,scene=scn}

		--Write messages to log file
		love.filesystem.append("conf/error.log",
			os.date("%Y/%m/%d %A %H:%M:%S\n")..
			#ERRDATA.." crash(es) "..SYSTEM.."-"..VERSION_NAME.."  scene: "..scn.."\n"..
			table.concat(err,"\n",1,c-2).."\n\n"
		)

		--Get screencapture
		gc.captureScreenshot(function(_)ERRDATA[#ERRDATA].shot=gc.newImage(_)end)
		gc.present()

		--Create a new mainLoop thread to keep game alive
		local status,resume=coroutine.status,coroutine.resume
		local loopThread=coroutine.create(secondLoopThread)
		local res,threadErr
		repeat
			res,threadErr=resume(loopThread)
		until status(loopThread)=="dead"
		if not res then
			love.errorhandler(threadErr)
			return
		end
	else
		ms.setVisible(true)

		local errorMsg
		errorMsg=LOADED and
			"Too many errors or fatal error occured.\nPlease restart the game."or
			"An error has occurred during loading.\nError info has been created, and you can send it to the author."
		while true do
			love.event.pump()
			for E,a,b in love.event.poll()do
				if E=="quit"or a=="escape"then
					destroyPlayers()
					return true
				elseif E=="resize"then
					SCR.resize(a,b)
				end
			end
			gc.clear(.3,.5,.9)
			gc_push("transform")
			gc.replaceTransform(xOy)
			setFont(100)gc_print(":(",100,0,0,1.2)
			setFont(40)gc.printf(errorMsg,100,160,SCR.w0-100)
			setFont(20)
			gc_print(SYSTEM.."-"..VERSION_NAME.."                          scene:"..(SCN and SCN.cur or"NULL"),100,660)
			gc.printf(err[1],100,360,1260-100)
			gc_print("TRACEBACK",100,450)
			for i=4,#err-2 do
				gc_print(err[i],100,400+20*i)
			end
			gc_pop()
			gc_present()
			love.timer.sleep(.26)
		end
	end
end
local WS=WS
local WSnames={"app","user","play","stream","chat"}
local WScolor={
	{1,.5,.5,.7},
	{1,.8,.3,.7},
	{1,1,.4,.7},
	{.4,1,.7,.7},
	{.5,.8,1,.7},
}
local devColor={
	COLOR.white,
	COLOR.lMagenta,
	COLOR.lGreen,
	COLOR.lBlue,
}
love.draw,love.update=nil--remove default draw/update
function love.run()
	local SCN=SCN
	local SETTING=SETTING

	local TIME=TIME
	local STEP,WAIT=love.timer.step,love.timer.sleep
	local FPS=love.timer.getFPS
	local MINI=love.window.isMinimized
	local PUMP,POLL=love.event.pump,love.event.poll

	local frameTimeList={}

	local lastFrame=TIME()
	local lastFreshPow=lastFrame
	local FCT=0--Framedraw counter, from 0~99

	love.resize(gc.getWidth(),gc.getHeight())

	--Scene Launch
	while #SCN.stack>0 do SCN.pop()end
	SCN.push("quit","slowFade")
	SCN.init(#ERRDATA==0 and"load"or"error")

	return function()
		local _

		local t=TIME()
		local dt=t-lastFrame
		lastFrame=t

		--EVENT
		PUMP()
		for N,a,b,c,d,e in POLL()do
			if love[N]then
				love[N](a,b,c,d,e)
			elseif N=="quit"then
				destroyPlayers()
				return a or true
			end
		end

		--UPDATE
		STEP()
		TASK.update()
		VOC.update()
		BG.update(dt)
		SYSFX.update(dt)
		TEXT.update()
		if SCN.update then SCN.update(dt)end--Scene Updater
		if SCN.swapping then SCN.swapUpdate()end--Scene swapping animation
		WIDGET.update()--Widgets animation
		LOG.update()
		WS.update(dt)

		--DRAW
		if not MINI()then
			FCT=FCT+SETTING.frameMul
			if FCT>=100 then
				FCT=FCT-100

				--Draw background
				BG.draw()

				gc_push("transform")
					gc.replaceTransform(xOy)

					--Draw scene contents
					if SCN.draw then SCN.draw()end

					--Draw widgets
					WIDGET.draw()

					--Draw cursor
					if mouseShow then
						local R=int((t+1)/2)%7+1
						_=minoColor[SETTING.skin[R]]
						gc_setColor(_[1],_[2],_[3],min(abs(1-t%2),.3))
						_=SCS[R][0]
						gc_draw(TEXTURE.miniBlock[R],mx,my,t%3.14159265359*4,16,16,_[2]+.5,#BLOCKS[R][0]-_[1]-.5)
						gc_setColor(1,1,1)
						gc_draw(TEXTURE[ms.isDown(1)and"cursor_hold"or"cursor"],mx,my,nil,nil,nil,8,8)
					end
					SYSFX.draw()
					TEXT.draw()
				gc_pop()

				--Draw power info.
				gc_setColor(1,1,1)
				if SETTING.powerInfo then
					gc_draw(infoCanvas,SCR.safeX,0,0,SCR.k)
				end

				--Draw scene swapping animation
				if SCN.swapping then
					_=SCN.stat
					_.draw(_.time)
				end

				--Draw FPS
				gc_setColor(1,1,1)
				setFont(15)
				_=SCR.h
				gc_print(FPS(),SCR.safeX+5,_-20)

				--Debug info.
				if devMode then
					--Left-down infos
					gc_setColor(devColor[devMode])
					gc_print("MEM     "..gcinfo(),SCR.safeX+5,_-40)
					gc_print("Lines    "..FREEROW.getCount(),SCR.safeX+5,_-60)
					gc_print("Cursor  "..int(mx+.5).." "..int(my+.5),SCR.safeX+5,_-80)
					gc_print("Voices  "..VOC.getQueueCount(),SCR.safeX+5,_-100)
					gc_print("Tasks   "..TASK.getCount(),SCR.safeX+5,_-120)

					--Update & draw frame time
					ins(frameTimeList,1,dt)rem(frameTimeList,126)
					gc_setColor(1,1,1,.3)
					for i=1,#frameTimeList do
						gc_rectangle("fill",150+2*i,_-20,2,-frameTimeList[i]*4000)
					end

					--Websocket status
					gc_push("transform")
					gc.translate(SCR.w,0)
					gc.scale(SCR.k)
					for i=1,5 do
						local status=WS.status(WSnames[i])
						gc_setColor(WScolor[i])
						gc_rectangle("fill",0,20*i,-80,-20)
						if status=="dead"then
							gc_setColor(1,1,1)
							gc_draw(TEXTURE.ws_dead,-20,20*i-20)
						elseif status=="connecting"then
							gc_setColor(1,1,1,.5+.3*sin(t*6.26))
							gc_draw(TEXTURE.ws_connecting,-20,20*i-20)
						elseif status=="running"then
							gc_setColor(1,1,1)
							gc_draw(TEXTURE.ws_running,-20,20*i-20)
						end
						local t1,t2,t3=WS.getTimers(WSnames[i])
						gc_setColor(1,1,1,t1)gc_rectangle("fill",-60,20*i,-20,-20)
						gc_setColor(0,1,0,t2)gc_rectangle("fill",-40,20*i,-20,-20)
						gc_setColor(1,0,0,t3)gc_rectangle("fill",-20,20*i,-20,-20)
					end
					gc_pop()

					--Slow devmode
					if devMode==3 then WAIT(.1)
					elseif devMode==4 then WAIT(.5)
					end
				end
				LOG.draw()

				gc_present()

				--SPEED UPUPUP!
				if SETTING.cleanCanvas then gc_discard()end
			end
		end

		--Fresh power info.
		if t-lastFreshPow>2.6 then
			if SETTING.powerInfo and LOADED then
				updatePowerInfo()
				lastFreshPow=t
			end
			if gc.getWidth()~=SCR.w then
				love.resize(gc.getWidth(),gc.getHeight())
			end
		end

		--Keep 60fps
		_=TIME()-lastFrame
		if _<.016 then WAIT(.016-_)end
		while TIME()-lastFrame<1/60-5e-6 do WAIT(0)end
	end
end