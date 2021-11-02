NONE={}function NULL()end
EDITING=""
LOADED=false
ERRDATA={}

--Pure lua modules (basic)
COLOR=      require'Zframework.color'
TABLE=      require'Zframework.tableExtend'
STRING=     require'Zframework.stringExtend'
PROFILE=    require'Zframework.profile'
JSON=       require'Zframework.json'
TEST=       require'Zframework.test'

do--Add pcall & MES for JSON lib
    local encode,decode=JSON.encode,JSON.decode
    JSON.encode=function(val)
        local a,b=pcall(encode,val)
        if a then
            return b
        elseif MES then
            MES.traceback()
        end
    end
    JSON.decode=function(str)
        local a,b=pcall(decode,str)
        if a then
            return b
        elseif MES then
            MES.traceback()
        end
    end
end

--Pure lua modules (complex)
LOG=        require'Zframework.log'
REQUIRE=    require'Zframework.require'
TASK=       require'Zframework.task'
WS=         require'Zframework.websocket'
LANG=       require'Zframework.languages'
THEME=      require'Zframework.theme'

--Love-based modules (basic)
FILE=       require'Zframework.file'
WHEELMOV=   require'Zframework.wheelScroll'
SCR=        require'Zframework.screen'
SCN=        require'Zframework.scene'
LIGHT=      require'Zframework.light'

--Love-based modules (complex)
GC=         require'Zframework.gcExtend'
FONT=       require'Zframework.font'
TEXT=       require'Zframework.text'
SYSFX=      require'Zframework.sysFX'
MES=        require'Zframework.message'
BG=         require'Zframework.background'
WIDGET=     require'Zframework.widget'
VIB=        require'Zframework.vibrate'
SFX=        require'Zframework.sfx'
IMG=        require'Zframework.image'
BGM=        require'Zframework.bgm'
VOC=        require'Zframework.voice'

local ms,kb=love.mouse,love.keyboard

local gc=love.graphics
local gc_push,gc_pop,gc_clear,gc_discard=gc.push,gc.pop,gc.clear,gc.discard
local gc_replaceTransform,gc_present=gc.replaceTransform,gc.present
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line,gc_circle,gc_print=gc.draw,gc.line,gc.circle,gc.print

local WIDGET,SCR,SCN=WIDGET,SCR,SCN
local xOy=SCR.xOy
local ITP=xOy.inverseTransformPoint

local mx,my,mouseShow=-20,-20,false
joysticks={}

local devMode

local batteryImg=GC.DO{31,20,
    {'fRect',1,0,26,2},
    {'fRect',1,18,26,2},
    {'fRect',0,1,2,18},
    {'fRect',26,1,2,18},
    {'fRect',29,3,2,14},
}
local infoCanvas=gc.newCanvas(108,27)
local function updatePowerInfo()
    local state,pow=love.system.getPowerInfo()
    gc.setCanvas(infoCanvas)
    gc_push('transform')
    gc.origin()
    gc_clear(0,0,0,.25)
    if state~='unknown'then
        gc_setLineWidth(4)
        local charging=state=='charging'
        if state=='nobattery'then
            gc_setColor(1,1,1)
            gc_setLineWidth(2)
            gc_line(74,SCR.safeX+5,100,22)
        elseif pow then
            if charging then    gc_setColor(0,1,0)
            elseif pow>50 then  gc_setColor(1,1,1)
            elseif pow>26 then  gc_setColor(1,1,0)
            elseif pow==26 then gc_setColor(.5,0,1)
            else                gc_setColor(1,0,0)
            end
            gc.rectangle('fill',76,6,pow*.22,14)
            if pow<100 then
                FONT.set(15)
                gc.setColor(COLOR.D)
                gc_print(pow,77,1)
                gc_print(pow,77,3)
                gc_print(pow,79,1)
                gc_print(pow,79,3)
                gc_setColor(COLOR.Z)
                gc_print(pow,78,2)
            end
        end
        gc_draw(batteryImg,73,3)
    end
    FONT.set(25)
    gc_print(os.date("%H:%M"),3,-5)
    gc_pop()
    gc.setCanvas()
end
-------------------------------------------------------------
local lastX,lastY=0,0--Last click pos
function love.mousepressed(x,y,k,touch)
    if touch then return end
    mouseShow=true
    mx,my=ITP(xOy,x,y)
    if devMode==1 then
        print(("(%d,%d)<-%d,%d ~~(%d,%d)<-%d,%d"):format(
            mx,my,
            mx-lastX,my-lastY,
            math.floor(mx/10)*10,math.floor(my/10)*10,
            math.floor((mx-lastX)/10)*10,math.floor((my-lastY)/10)*10
        ))
    end
    if SCN.swapping then return end
    if SCN.mouseDown then SCN.mouseDown(mx,my,k)end
    WIDGET.press(mx,my,k)
    lastX,lastY=mx,my
    if SETTING.clickFX then SYSFX.newTap(3,mx,my)end
end
function love.mousemoved(x,y,dx,dy,touch)
    if touch then return end
    mouseShow=true
    mx,my=ITP(xOy,x,y)
    if SCN.swapping then return end
    dx,dy=dx/SCR.k,dy/SCR.k
    if SCN.mouseMove then SCN.mouseMove(mx,my,dx,dy)end
    if ms.isDown(1)then
        WIDGET.drag(mx,my,dx/SCR.k,dy/SCR.k)
    else
        WIDGET.cursorMove(mx,my)
    end
end
function love.mousereleased(x,y,k,touch)
    if touch or SCN.swapping then return end
    mx,my=ITP(xOy,x,y)
    if SCN.mouseUp then SCN.mouseUp(mx,my,k)end
    if WIDGET.sel then
        WIDGET.release(mx,my)
    else
        if lastX and SCN.mouseClick and(mx-lastX)^2+(my-lastY)^2<62 then
            SCN.mouseClick(mx,my,k)
        end
    end
end
function love.wheelmoved(x,y)
    if SCN.swapping then return end
    if SCN.wheelMoved then
        SCN.wheelMoved(x,y)
    else
        WIDGET.unFocus()
        WIDGET.drag(0,0,0,100*y)
    end
end

function love.touchpressed(id,x,y)
    mouseShow=false
    if SCN.swapping then return end
    if not SCN.mainTouchID then
        SCN.mainTouchID=id
        WIDGET.unFocus(true)
        love.touchmoved(id,x,y,0,0)
    end
    x,y=ITP(xOy,x,y)
    lastX,lastY=x,y
    WIDGET.cursorMove(x,y)
    if SCN.touchDown then SCN.touchDown(x,y)end
    if kb.hasTextInput()then kb.setTextInput(false)end
end
function love.touchmoved(_,x,y,dx,dy)
    if SCN.swapping then return end
    x,y=ITP(xOy,x,y)
    if SCN.touchMove then SCN.touchMove(x,y,dx/SCR.k,dy/SCR.k)end
    WIDGET.drag(x,y,dx/SCR.k,dy/SCR.k)
end
function love.touchreleased(id,x,y)
    if SCN.swapping then return end
    x,y=ITP(xOy,x,y)
    if id==SCN.mainTouchID then
        WIDGET.press(x,y,1)
        WIDGET.release(x,y)
        WIDGET.cursorMove(x,y)
        WIDGET.unFocus()
        SCN.mainTouchID=false
    end
    if SCN.touchUp then SCN.touchUp(x,y)end
    if(x-lastX)^2+(y-lastY)^2<62 then
        if SCN.touchClick then SCN.touchClick(x,y)end
        if SETTING.clickFX then SYSFX.newTap(3,x,y)end
    end
end

local fnKey={NULL,NULL,NULL,NULL,NULL,NULL,NULL}
local function noDevkeyPressed(key)
    if key=="f1"then      fnKey[1]()
    elseif key=="f2"then  fnKey[2]()
    elseif key=="f3"then  fnKey[3]()
    elseif key=="f4"then  fnKey[4]()
    elseif key=="f5"then  fnKey[5]()
    elseif key=="f6"then  fnKey[6]()
    elseif key=="f7"then  fnKey[7]()
    elseif key=="f8"then  devMode=nil MES.new('info',"DEBUG OFF",.2)
    elseif key=="f9"then  devMode=1   MES.new('info',"DEBUG 1")
    elseif key=="f10"then devMode=2   MES.new('info',"DEBUG 2")
    elseif key=="f11"then devMode=3   MES.new('info',"DEBUG 3")
    elseif key=="f12"then devMode=4   MES.new('info',"DEBUG 4")
    elseif devMode==2 then
        local W=WIDGET.sel
        if W then
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
function love.keypressed(key,_,isRep)
    mouseShow=false
    if devMode and not noDevkeyPressed(key)then
        return
    elseif key=="f8"then
        devMode=1
        MES.new('info',"DEBUG ON",.2)
    elseif key=="f11"then
        SETTING.fullscreen=not SETTING.fullscreen
        applyFullscreen()
        saveSettings()
    elseif not SCN.swapping then
        if SCN.keyDown then
            if EDITING==""then
                SCN.keyDown(key,isRep)
            end
        elseif key=="escape"and not isRep then
            SCN.back()
        else
            WIDGET.keyPressed(key,isRep)
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
    table.insert(joysticks,JS)
    MES.new('info',"Joystick added")
end
function love.joystickremoved(JS)
    local i=TABLE.find(joysticks,JS)
    if i then
        table.remove(joysticks,i)
        MES.new('info',"Joystick removed")
    end
end
local keyMirror={
    dpup='up',
    dpdown='down',
    dpleft='left',
    dpright='right',
    start='return',
    back='escape',
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
function love.filedropped(file)
    if SCN.fileDropped then SCN.fileDropped(file)end
end
function love.directorydropped(dir)
    if SCN.directoryDropped then SCN.directoryDropped(dir)end
end
local lastGCtime=0
function love.lowmemory()
    if love.timer.getTime()-lastGCtime>6.26 then
        collectgarbage()
        lastGCtime=love.timer.getTime()
        MES.new('check',"[auto GC] low MEM 设备内存过低")
    end
end
function love.resize(w,h)
    SCR.resize(w,h)
    if BG.resize then BG.resize(w,h)end
    if SCN.resize then SCN.resize(w,h)end
    WIDGET.resize(w,h)
    FONT.reset()

    SHADER.warning:send('w',w*SCR.dpi)
end

local onFocus=NULL
function love.focus(f)onFocus(f)end

local yield=coroutine.yield
local function secondLoopThread()
    local mainLoop=love.run()
    repeat yield()until mainLoop()
end
function love.errorhandler(msg)
    if type(msg)~='string'then
        msg="Unknown error"
    elseif msg:find("Invaild UTF-8")and text then
        msg=text.tryAnotherBuild
    end

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
    print(table.concat(err,"\n",1,c-2))

    --Reset something
    love.audio.stop()
    gc.reset()

    if LOADED and #ERRDATA<3 then
        BG.set('none')
        local scn=SCN and SCN.cur or"NULL"
        table.insert(ERRDATA,{mes=err,scene=scn})

        --Write messages to log file
        love.filesystem.append('conf/error.log',
            os.date("%Y/%m/%d %A %H:%M:%S\n")..
            #ERRDATA.." crash(es) "..love.system.getOS().."-"..VERSION.string.."  scene: "..scn.."\n"..
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
        until status(loopThread)=='dead'
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
                if E=='quit'or a=='escape'then
                    return true
                elseif E=='resize'then
                    SCR.resize(a,b)
                end
            end
            gc_clear(.3,.5,.9)
            gc_push('transform')
            gc_replaceTransform(SCR.xOy)
            FONT.set(100)gc_print(":(",100,0,0,1.2)
            FONT.set(40)gc.printf(errorMsg,100,160,SCR.w0-100)
            FONT.set(20)
            gc_print(love.system.getOS().."-"..VERSION.string.."                          scene:"..(SCN and SCN.cur or"NULL"),100,660)
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
love.threaderror=nil

love.draw,love.update=nil--remove default draw/update

local devColor={
    COLOR.Z,
    COLOR.lM,
    COLOR.lG,
    COLOR.lB,
}
local WS=WS
local WSnames={'app','user','play','stream','chat','manage'}
local wsBottomImage do
    local L={78,18,
        {'clear',1,1,1,0},
        {'setCL',1,1,1,.3},
        {'fRect',60,0,18,18},
    }
    for i=0,59 do
        table.insert(L,{'setCL',1,1,1,i*.005})
        table.insert(L,{'fRect',i,0,1,18})
    end
    wsBottomImage=GC.DO(L)
end
local ws_deadImg=GC.DO{20,20,
    {'setFT',20},
    {'setCL',1,.3,.3},
    {'mText',"X",11,-1},
}
local ws_connectingImg=GC.DO{20,20,
    {'setFT',20},
    {'setLW',3},
    {'mText',"C",11,-1},
}
local ws_runningImg=GC.DO{20,20,
    {'setFT',20},
    {'setCL',.5,1,0},
    {'mText',"R",11,-1},
}

local function drawCursor(_,x,y)
    gc_setColor(1,1,1)
    gc_setLineWidth(2)
    gc_circle(ms.isDown(1)and'fill'or'line',x,y,6)
end
local function showPowerInfo()return true end
local onQuit=NULL

function love.run()
    local love=love

    local BG=BG
    local TEXT_update,TEXT_draw=TEXT.update,TEXT.draw
    local MES_update,MES_draw=MES.update,MES.draw
    local WS_update=WS.update
    local TASK_update=TASK.update
    local SYSFX_update,SYSFX_draw=SYSFX.update,SYSFX.draw
    local WIDGET_update,WIDGET_draw=WIDGET.update,WIDGET.draw

    local STEP,WAIT=love.timer.step,love.timer.sleep
    local FPS,MINI=love.timer.getFPS,love.window.isMinimized
    local PUMP,POLL=love.event.pump,love.event.poll

    local timer,SETTING,VERSION=love.timer.getTime,SETTING,VERSION

    local frameTimeList={}
    local lastFrame=timer()
    local lastFreshPow=lastFrame
    local FCT=0--Framedraw counter, from 0~99

    love.resize(gc.getWidth(),gc.getHeight())

    --Scene Launch
    while #SCN.stack>0 do SCN.pop()end
    SCN.push('quit','slowFade')
    SCN.init(#ERRDATA==0 and'load'or'error')

    return function()
        local _

        local time=timer()
        local dt=time-lastFrame
        lastFrame=time

        --EVENT
        PUMP()
        for N,a,b,c,d,e in POLL()do
            if love[N]then
                love[N](a,b,c,d,e)
            elseif N=='quit'then
                onQuit()
                return a or true
            end
        end

        --UPDATE
        STEP()
        VOC.update()
        BG.update(dt)
        TEXT_update(dt)
        MES_update(dt)
        WS_update(dt)
        TASK_update(dt)
        SYSFX_update(dt)
        if SCN.update then SCN.update(dt)end
        if SCN.swapping then SCN.swapUpdate(dt)end
        WIDGET_update(dt)

        --DRAW
        if not MINI()then
            FCT=FCT+SETTING.frameMul
            if FCT>=100 then
                FCT=FCT-100

                local safeX=SCR.safeX
                gc_replaceTransform(SCR.origin)
                    gc_setColor(1,1,1)
                    BG.draw()
                gc_replaceTransform(SCR.xOy)
                    if SCN.draw then SCN.draw()end
                    WIDGET_draw()
                    SYSFX_draw()
                    TEXT_draw()

                    --Draw cursor
                    if mouseShow then
                        drawCursor(time,mx,my)
                    end
                gc_replaceTransform(SCR.xOy_ul)
                    MES_draw()
                gc_replaceTransform(SCR.origin)
                    --Draw power info.
                    if showPowerInfo()then
                        gc_setColor(1,1,1)
                        gc_draw(infoCanvas,safeX,0,0,SCR.k)
                    end

                    --Draw scene swapping animation
                    if SCN.swapping then
                        gc_setColor(1,1,1)
                        _=SCN.stat
                        _.draw(_.time)
                    end
                gc_replaceTransform(SCR.xOy_d)
                    --Draw Version string
                    gc_setColor(.8,.8,.8,.4)
                    FONT.set(20)
                    mStr(VERSION.string,0,-30)
                gc_replaceTransform(SCR.xOy_dl)
                    --Draw FPS
                    FONT.set(15)
                    gc_setColor(1,1,1)
                    gc_print(FPS(),safeX+5,-20)

                    --Debug info.
                    if devMode then
                        --Left-down infos
                        gc_setColor(devColor[devMode])
                        gc_print("MEM     "..gcinfo(),safeX+5,-40)
                        gc_print("Lines    "..FREEROW.getCount(),safeX+5,-60)
                        gc_print("Tasks   "..TASK.getCount(),safeX+5,-80)
                        gc_print("Voices  "..VOC.getQueueCount(),safeX+5,-100)

                        --Update & draw frame time
                        table.insert(frameTimeList,1,dt)table.remove(frameTimeList,126)
                        gc_setColor(1,1,1,.3)
                        for i=1,#frameTimeList do
                            gc.rectangle('fill',150+2*i,-20,2,-frameTimeList[i]*4000)
                        end

                        --Cursor pos disp
                        gc_replaceTransform(SCR.origin)
                            local x,y=SCR.xOy:transformPoint(mx,my)
                            gc_setLineWidth(1)
                            gc_line(x,0,x,SCR.h)
                            gc_line(0,y,SCR.w,y)
                            local t=math.floor(mx+.5)..","..math.floor(my+.5)
                            gc.setColor(COLOR.D)
                            gc_print(t,x+1,y)
                            gc_print(t,x+1,y-1)
                            gc_print(t,x+2,y-1)
                            gc_setColor(COLOR.Z)
                            gc_print(t,x+2,y)

                        gc_replaceTransform(SCR.xOy_dr)
                            --Websocket status
                            for i=1,6 do
                                local status=WS.status(WSnames[i])
                                gc_setColor(1,1,1)
                                gc.draw(wsBottomImage,-79,20*i-139)
                                if status=='dead'then
                                    gc_draw(ws_deadImg,-20,20*i-140)
                                elseif status=='connecting'then
                                    gc_setColor(1,1,1,.5+.3*math.sin(time*6.26))
                                    gc_draw(ws_connectingImg,-20,20*i-140)
                                elseif status=='running'then
                                    gc_draw(ws_runningImg,-20,20*i-140)
                                end
                                local t1,t2,t3=WS.getTimers(WSnames[i])
                                gc_setColor(.9,.9,.9,t1)gc.rectangle('fill',-60,20*i-122,-16,-16)
                                gc_setColor(.3,1,.3,t2)gc.rectangle('fill',-42,20*i-122,-16,-16)
                                gc_setColor(1,.2,.2,t3)gc.rectangle('fill',-24,20*i-122,-16,-16)
                            end
                    end
                gc_present()

                --SPEED UPUPUP!
                if SETTING.cleanCanvas then gc_discard()end
            end
        end

        --Fresh power info.
        if time-lastFreshPow>2.6 then
            if showPowerInfo()then
                updatePowerInfo()
                lastFreshPow=time
            end
            if gc.getWidth()~=SCR.w or gc.getHeight()~=SCR.h then
                love.resize(gc.getWidth(),gc.getHeight())
            end
        end

        --Slow devmode
        if devMode then
            if devMode==3 then
                WAIT(.1)
            elseif devMode==4 then
                WAIT(.5)
            end
        end

        --Keep 60fps
        _=timer()-lastFrame
        if _<.0162 then WAIT(.0162-_)end
        while timer()-lastFrame<1/60 do end
    end
end

local Z={}

function Z.setIfPowerInfo(func)showPowerInfo=func end

--[Warning] Color and line width is uncertain value, set it in the function.
function Z.setCursor(func)drawCursor=func end

--Change F1~F7 events of devmode (F8 mode)
function Z.setOnFnKeys(list)
    assert(type(list)=='table')
    for i=1,7 do fnKey[i]=type(list[i])=='function'and list[i]or NULL end
end

function Z.setOnFocus(func)onFocus=type(func)=='function'and func or NULL end

function Z.setOnQuit(func)onQuit=type(func)=='function'and func or NULL end

return Z
