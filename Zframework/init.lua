NONE={}function NULL()end PAPER=love.graphics.newCanvas(1,1)
EDITING=""
LOADED=false

--Pure lua modules (basic)
MATH=       require'Zframework.mathExtend'
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
local KBisDown=kb.isDown

local gc=love.graphics
local gc_push,gc_pop,gc_clear,gc_discard=gc.push,gc.pop,gc.clear,gc.discard
local gc_replaceTransform,gc_present=gc.replaceTransform,gc.present
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line,gc_circle,gc_print=gc.draw,gc.line,gc.circle,gc.print

local WIDGET,SCR,SCN=WIDGET,SCR,SCN
local xOy=SCR.xOy
local ITP=xOy.inverseTransformPoint

local max,min=math.max,math.min

local devMode
local mx,my,mouseShow,cursorSpd=640,360,false,0
local jsState={}--map, joystickID->axisStates: {axisName->axisVal}
local errData={}--list, each error create {mes={errMes strings},scene=sceneNameStr}

local function drawCursor(_,x,y)
    gc_setColor(1,1,1)
    gc_setLineWidth(2)
    gc_circle(ms.isDown(1)and'fill'or'line',x,y,6)
end
local showPowerInfo=true
local showClickFX=true
local discardCanvas=false
local frameMul=100
local sleepInterval=1/60
local onQuit=NULL

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
        if state=='nobattery'then
            gc_setColor(1,1,1)
            gc_setLineWidth(2)
            gc_line(74,5,100,22)
        elseif pow then
            if state=='charging'then gc_setColor(0,1,0)
            elseif pow>50 then       gc_setColor(1,1,1)
            elseif pow>26 then       gc_setColor(1,1,0)
            elseif pow==26 then      gc_setColor(.5,0,1)
            else                     gc_setColor(1,0,0)
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
local function _updateMousePos(x,y,dx,dy)
    if SCN.swapping then return end
    dx,dy=dx/SCR.k,dy/SCR.k
    if SCN.mouseMove then SCN.mouseMove(x,y,dx,dy)end
    if ms.isDown(1)then
        WIDGET.drag(x,y,dx,dy)
    else
        WIDGET.cursorMove(x,y)
    end
end
local function _triggerMouseDown(x,y,k)
    if devMode==1 then
        print(("(%d,%d)<-%d,%d ~~(%d,%d)<-%d,%d"):format(
            x,y,
            x-lastX,y-lastY,
            math.floor(x/10)*10,math.floor(y/10)*10,
            math.floor((x-lastX)/10)*10,math.floor((y-lastY)/10)*10
        ))
    end
    if SCN.swapping then return end
    if SCN.mouseDown then SCN.mouseDown(x,y,k)end
    WIDGET.press(x,y,k)
    lastX,lastY=x,y
    if showClickFX then SYSFX.newTap(3,x,y)end
end
local function mouse_update(dt)
    if not KBisDown('lctrl','rctrl')and KBisDown('up','down','left','right')then
        local dx,dy=0,0
        if KBisDown('up')then    dy=dy-cursorSpd end
        if KBisDown('down')then  dy=dy+cursorSpd end
        if KBisDown('left')then  dx=dx-cursorSpd end
        if KBisDown('right')then dx=dx+cursorSpd end
        mx=max(min(mx+dx,1280),0)
        my=max(min(my+dy,720),0)
        if my==0 or my==720 then
            WIDGET.sel=false
            WIDGET.drag(0,0,0,-dy)
        end
        _updateMousePos(mx,my,dx,dy)
        cursorSpd=min(cursorSpd+dt*26,12.6)
    else
        cursorSpd=6
    end
end
local function gp_update(js,dt)
    local sx,sy=js._jsObj:getGamepadAxis('leftx'),js._jsObj:getGamepadAxis('lefty')
    if math.abs(sx)>.1 or math.abs(sy)>.1 then
        local dx,dy=0,0
        if sy<-.1 then dy=dy+2*sy*cursorSpd end
        if sy>.1 then  dy=dy+2*sy*cursorSpd end
        if sx<-.1 then dx=dx+2*sx*cursorSpd end
        if sx>.1 then  dx=dx+2*sx*cursorSpd end
        mx=max(min(mx+dx,1280),0)
        my=max(min(my+dy,720),0)
        if my==0 or my==720 then
            WIDGET.sel=false
            WIDGET.drag(0,0,0,-dy)
        end
        _updateMousePos(mx,my,dx,dy)
        cursorSpd=min(cursorSpd+dt*26,12.6)
    else
        cursorSpd=6
    end
end
function love.mousepressed(x,y,k,touch)
    if touch then return end
    mouseShow=true
    mx,my=ITP(xOy,x,y)
    _triggerMouseDown(mx,my,k)
end
function love.mousemoved(x,y,dx,dy,touch)
    if touch then return end
    mouseShow=true
    mx,my=ITP(xOy,x,y)
    _updateMousePos(mx,my,dx,dy)
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
    if SCN.touchDown then SCN.touchDown(x,y,id)end
    if kb.hasTextInput()then kb.setTextInput(false)end
end
function love.touchmoved(id,x,y,dx,dy)
    if SCN.swapping then return end
    x,y=ITP(xOy,x,y)
    if SCN.touchMove then SCN.touchMove(x,y,dx/SCR.k,dy/SCR.k,id)end
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
    if SCN.touchUp then SCN.touchUp(x,y,id)end
    if(x-lastX)^2+(y-lastY)^2<62 then
        if SCN.touchClick then SCN.touchClick(x,y)end
        if showClickFX then SYSFX.newTap(3,x,y)end
    end
end

local fnKey={NULL,NULL,NULL,NULL,NULL,NULL,NULL}
local function noDevkeyPressed(key)
    if key=='f1'then      fnKey[1]()
    elseif key=='f2'then  fnKey[2]()
    elseif key=='f3'then  fnKey[3]()
    elseif key=='f4'then  fnKey[4]()
    elseif key=='f5'then  fnKey[5]()
    elseif key=='f6'then  fnKey[6]()
    elseif key=='f7'then  fnKey[7]()
    elseif key=='f8'then  devMode=nil MES.new('info',"DEBUG OFF",.2)
    elseif key=='f9'then  devMode=1   MES.new('info',"DEBUG 1")
    elseif key=='f10'then devMode=2   MES.new('info',"DEBUG 2")
    elseif key=='f11'then devMode=3   MES.new('info',"DEBUG 3")
    elseif key=='f12'then devMode=4   MES.new('info',"DEBUG 4")
    elseif devMode==2 then
        local W=WIDGET.sel
        if W then
            if key=='left'then W.x=W.x-10
            elseif key=='right'then W.x=W.x+10
            elseif key=='up'then W.y=W.y-10
            elseif key=='down'then W.y=W.y+10
            elseif key==','then W.w=W.w-10
            elseif key=='.'then W.w=W.w+10
            elseif key=='/'then W.h=W.h-10
            elseif key=='\''then W.h=W.h+10
            elseif key=='['then W.font=W.font-5
            elseif key==']'then W.font=W.font+5
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
    elseif key=='f8'then
        devMode=1
        MES.new('info',"DEBUG ON",.2)
    elseif key=='f11'then
        SETTING.fullscreen=not SETTING.fullscreen
        applySettings()
        saveSettings()
    elseif not SCN.swapping then
        if EDITING==""and(not SCN.keyDown or SCN.keyDown(key,isRep))then
            local W=WIDGET.sel
            if key=='escape'and not isRep then
                SCN.back()
            elseif key=='up'or key=='down'or key=='left'or key=='right'then
                mouseShow=true
                if KBisDown('lctrl','rctrl')then
                    if W and W.arrowKey then W:arrowKey(key)end
                end
            elseif key=='space'or key=='return'then
                mouseShow=true
                if not isRep then
                    if showClickFX then SYSFX.newTap(3,mx,my)end
                    _triggerMouseDown(mx,my,1)
                end
            else
                if W and W.keypress then
                    W:keypress(key)
                end
            end
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

--analog sticks: -1, 0, 1 for neg, neutral, pos
--triggers: 0 for released, 1 for pressed
local jsAxisEventName={
    leftx={'leftstick_left','leftstick_right'},
    lefty={'leftstick_up','leftstick_down'},
    rightx={'rightstick_left','rightstick_right'},
    righty={'rightstick_up','rightstick_down'},
    triggerleft='triggerleft',
    triggerright='triggerright'
}
local gamePadKeys={'a','b','x','y','back','guide','start','leftstick','rightstick','leftshoulder','rightshoulder','dpup','dpdown','dpleft','dpright'}
local dPadToKey={
    dpup='up',
    dpdown='down',
    dpleft='left',
    dpright='right',
    start='return',
    back='escape',
}
function love.joystickadded(JS)
    table.insert(jsState,{
        _id=JS:getID(),
        _jsObj=JS,
        leftx=0,lefty=0,
        rightx=0,righty=0,
        triggerleft=0,triggerright=0
    })
    MES.new('info',"Joystick added")
end
function love.joystickremoved(JS)
    for i=1,#jsState do
        if jsState[i]._jsObj==JS then
            for j=1,#gamePadKeys do
                if JS:isGamepadDown(gamePadKeys[j])then
                    love.gamepadreleased(JS,gamePadKeys[j])
                end
            end
            love.gamepadaxis(JS,'leftx',0)
            love.gamepadaxis(JS,'lefty',0)
            love.gamepadaxis(JS,'rightx',0)
            love.gamepadaxis(JS,'righty',0)
            love.gamepadaxis(JS,'triggerleft',-1)
            love.gamepadaxis(JS,'triggerright',-1)
            MES.new('info',"Joystick removed")
            table.remove(jsState,i)
            break
        end
    end
end
function love.gamepadaxis(JS,axis,val)
    if jsState[1]and JS==jsState[1]._jsObj then
        local js=jsState[1]
        if axis=='leftx'or axis=='lefty'or axis=='rightx'or axis=='righty'then
            local newVal=--range: [0,1]
                val>.4 and 1 or
                val<-.4 and -1 or
                0
            if newVal~=js[axis]then
                if js[axis]==-1 then
                    love.gamepadreleased(JS,jsAxisEventName[axis][1])
                elseif js[axis]~=0 then
                    love.gamepadreleased(JS,jsAxisEventName[axis][2])
                end
                if newVal==-1 then
                    love.gamepadpressed(JS,jsAxisEventName[axis][1])
                elseif newVal==1 then
                    love.gamepadpressed(JS,jsAxisEventName[axis][2])
                end
                js[axis]=newVal
            end
        elseif axis=='triggerleft'or axis=='triggerright'then
            local newVal=val>.3 and 1 or 0--range: [0,1]
            if newVal~=js[axis]then
                if newVal==1 then
                    love.gamepadpressed(JS,jsAxisEventName[axis])
                else
                    love.gamepadreleased(JS,jsAxisEventName[axis])
                end
                js[axis]=newVal
            end
        end
    end
end
function love.gamepadpressed(_,key)
    mouseShow=false
    if not SCN.swapping then
        local cursorCtrl
        if SCN.gamepadDown then
            cursorCtrl=SCN.gamepadDown(key)
        elseif SCN.keyDown then
            cursorCtrl=SCN.keyDown(dPadToKey[key]or key)
        else
            cursorCtrl=true
        end
        if cursorCtrl then
            key=dPadToKey[key]or key
            mouseShow=true
            local W=WIDGET.sel
            if key=='back'then
                SCN.back()
            elseif key=='up'or key=='down'or key=='left'or key=='right'then
                mouseShow=true
                if W and W.arrowKey then W:arrowKey(key)end
            elseif key=='return'then
                mouseShow=true
                if showClickFX then SYSFX.newTap(3,mx,my)end
                _triggerMouseDown(mx,my,1)
            else
                if W and W.keypress then
                    W:keypress(key)
                end
            end
        end
    end
end
function love.gamepadreleased(_,i)
    if SCN.swapping then return end
    if SCN.gamepadUp then SCN.gamepadUp(i)end
end

function love.filedropped(file)
    if SCN.fileDropped then SCN.fileDropped(file)end
end
function love.directorydropped(dir)
    if SCN.directoryDropped then SCN.directoryDropped(dir)end
end
local autoGCcount=0
function love.lowmemory()
    collectgarbage()
    if autoGCcount<3 then
        autoGCcount=autoGCcount+1
        MES.new('check',"[auto GC] low MEM 设备内存过低")
    end
end

local onResize=NULL
function love.resize(w,h)
    if SCR.w==w and SCR.h==h then return end
    SCR.resize(w,h)
    if BG.resize then BG.resize(w,h)end
    if SCN.resize then SCN.resize(w,h)end
    WIDGET.resize(w,h)
    FONT.reset()
    onResize(w,h)
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
    elseif msg:find("Invalid UTF-8")and text then
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

    if LOADED and #errData<3 then
        BG.set('none')
        local scn=SCN and SCN.cur or"NULL"
        table.insert(errData,{mes=err,scene=scn})

        --Write messages to log file
        love.filesystem.append('conf/error.log',
            os.date("%Y/%m/%d %A %H:%M:%S\n")..
            #errData.." crash(es) "..love.system.getOS().."-"..VERSION.string.."  scene: "..scn.."\n"..
            table.concat(err,"\n",1,c-2).."\n\n"
        )

        --Get screencapture
        gc.captureScreenshot(function(_)errData[#errData].shot=gc.newImage(_)end)
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
local wsImg={}do
    local L={78,18,
        {'clear',1,1,1,0},
        {'setCL',1,1,1,.3},
        {'fRect',60,0,18,18},
    }
    for i=0,59 do
        table.insert(L,{'setCL',1,1,1,i*.005})
        table.insert(L,{'fRect',i,0,1,18})
    end
    wsImg.bottom=GC.DO(L)
    wsImg.dead=GC.DO{20,20,
        {'rawFT',20},
        {'setCL',1,.3,.3},
        {'mText',"X",11,-1},
    }
    wsImg.connecting=GC.DO{20,20,
        {'rawFT',20},
        {'setLW',3},
        {'mText',"C",11,-1},
    }
    wsImg.running=GC.DO{20,20,
        {'rawFT',20},
        {'setCL',.5,1,0},
        {'mText',"R",11,-1},
    }
end

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

    local timer,VERSION=love.timer.getTime,VERSION

    local frameTimeList={}
    local lastFrame=timer()
    local lastFreshPow=lastFrame
    local FCT=0--Framedraw counter, from 0~99

    love.resize(gc.getWidth(),gc.getHeight())

    --Scene Launch
    while #SCN.stack>0 do SCN.pop()end
    SCN.push('quit','slowFade')
    SCN.init(#errData==0 and'load'or'error')

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
        if mouseShow then mouse_update(dt)end
        if next(jsState)then gp_update(jsState[1],dt)end
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
            FCT=FCT+frameMul
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
                    if showPowerInfo then
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
                    gc_setColor(.9,.9,.9,.42)
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
                        gc_print("Tasks   "..TASK.getCount(),safeX+5,-60)
                        gc_print("Voices  "..VOC.getQueueCount(),safeX+5,-80)

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
                                gc.draw(wsImg.bottom,-79,20*i-139)
                                if status=='dead'then
                                    gc_draw(wsImg.dead,-20,20*i-140)
                                elseif status=='connecting'then
                                    gc_setColor(1,1,1,.5+.3*math.sin(time*6.26))
                                    gc_draw(wsImg.connecting,-20,20*i-140)
                                elseif status=='running'then
                                    gc_draw(wsImg.running,-20,20*i-140)
                                end
                                local t1,t2,t3=WS.getTimers(WSnames[i])
                                gc_setColor(.9,.9,.9,t1)gc.rectangle('fill',-60,20*i-122,-16,-16)
                                gc_setColor(.3,1,.3,t2)gc.rectangle('fill',-42,20*i-122,-16,-16)
                                gc_setColor(1,.2,.2,t3)gc.rectangle('fill',-24,20*i-122,-16,-16)
                            end
                    end
                gc_present()

                --SPEED UPUPUP!
                if discardCanvas then gc_discard()end
            end
        end

        --Fresh power info.
        if time-lastFreshPow>2.6 then
            if showPowerInfo then
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

        _=timer()-lastFrame
        if _<sleepInterval*.9626 then WAIT(sleepInterval*.9626-_)end
        while timer()-lastFrame<sleepInterval do end
    end
end

local Z={}

function Z.getJsState()return jsState end
function Z.getErr(i)
    if i=='#'then
        return errData[#errData]
    elseif i then
        return errData[i]
    else
        return errData
    end
end

function Z.setPowerInfo(bool)showPowerInfo=bool end
function Z.setCleanCanvas(bool)discardCanvas=bool end
function Z.setFrameMul(n)frameMul=n end
function Z.setMaxFPS(fps)sleepInterval=1/fps end
function Z.setClickFX(bool)showClickFX=bool end

--[Warning] Color and line width is uncertain value, set it in the function.
function Z.setCursor(func)drawCursor=func end

--Change F1~F7 events of devmode (F8 mode)
function Z.setOnFnKeys(list)
    assert(type(list)=='table',"Z.setOnFnKeys(list): list must be a table.")
    for i=1,7 do fnKey[i]=type(list[i])=='function'and list[i]or NULL end
end

function Z.setOnFocus(func)onFocus=assert(type(func)=='function'and func,"Z.setOnFocus(func): func must be a function")end

function Z.setOnResize(func)onResize=assert(type(func)=='function'and func,"Z.setOnResize(func): func must be a function")end

function Z.setOnQuit(func)onQuit=assert(type(func)=='function'and func,"Z.setOnQuit(func): func must be a function")end

return Z
