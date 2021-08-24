local gc=love.graphics
local abs=math.abs

local scenes={}

local SCN={
    cur='NULL',          --Current scene name
    swapping=false,      --If Swapping
    stat={
        tar=false,       --Swapping target
        style=false,     --Swapping style
        changeTime=false,--Loading point
        time=false,      --Full swap time
        draw=false,      --Swap draw  func
    },
    stack={},--Scene stack

    scenes=scenes,

    --Events
    update=false,
    draw=false,
    mouseClick=false,
    touchClick=false,
    mouseDown=false,
    mouseMove=false,
    mouseUp=false,
    wheelMoved=false,
    touchDown=false,
    touchUp=false,
    touchMove=false,
    keyDown=false,
    keyUp=false,
    gamepadDown=false,
    gamepadUp=false,
    fileDropped=false,
    directoryDropped=false,
    resize=false,
    socketRead=false,
}--Scene datas, returned

function SCN.add(name,scene)
    scenes[name]=scene
    if scene.widgetList then
        setmetatable(scene.widgetList,WIDGET.indexMeta)
    end
end

function SCN.swapUpdate()
    local S=SCN.stat
    S.time=S.time-1
    if S.time==S.changeTime then
        --Scene swapped this moment
        SCN.init(S.tar,SCN.cur)
    end
    if S.time==0 then
        SCN.swapping=false
    end
end
function SCN.init(s,org)
    love.keyboard.setTextInput(false)

    local S=scenes[s]
    SCN.cur=s

    WIDGET.setScrollHeight(S.widgetScrollHeight)
    WIDGET.setWidgetList(S.widgetList)
    SCN.sceneInit=S.sceneInit
    SCN.sceneBack=S.sceneBack
    SCN.mouseDown=S.mouseDown
    SCN.mouseMove=S.mouseMove
    SCN.mouseUp=S.mouseUp
    SCN.mouseClick=S.mouseClick
    SCN.wheelMoved=S.wheelMoved
    SCN.touchDown=S.touchDown
    SCN.touchUp=S.touchUp
    SCN.touchMove=S.touchMove
    SCN.touchClick=S.touchClick
    SCN.keyDown=S.keyDown
    SCN.keyUp=S.keyUp
    SCN.gamepadDown=S.gamepadDown
    SCN.gamepadUp=S.gamepadUp
    SCN.fileDropped=S.fileDropped
    SCN.directoryDropped=S.directoryDropped
    SCN.resize=S.resize
    SCN.socketRead=S.socketRead
    SCN.update=S.update
    SCN.draw=S.draw
    if S.sceneInit then S.sceneInit(org)end
end
function SCN.push(tar,style)
    if not SCN.swapping then
        local m=#SCN.stack
        SCN.stack[m+1]=tar or SCN.cur
        SCN.stack[m+2]=style or'fade'
    end
end
function SCN.pop()
    local s=SCN.stack
    s[#s],s[#s-1]=nil
end

local swap={
    none={duration=1,changeTime=0,draw=function()end},
    flash={duration=8,changeTime=1,draw=function()gc.clear(1,1,1)end},
    fade={duration=30,changeTime=15,draw=function(t)
        t=t>15 and 2-t/15 or t/15
        gc.setColor(0,0,0,t)
        gc.rectangle('fill',0,0,SCR.w,SCR.h)
    end},
    fade_togame={duration=120,changeTime=20,draw=function(t)
        t=t>20 and(120-t)/100 or t/20
        gc.setColor(0,0,0,t)
        gc.rectangle('fill',0,0,SCR.w,SCR.h)
    end},
    slowFade={duration=180,changeTime=90,draw=function(t)
        t=t>90 and 2-t/90 or t/90
        gc.setColor(0,0,0,t)
        gc.rectangle('fill',0,0,SCR.w,SCR.h)
    end},
    swipeL={duration=30,changeTime=15,draw=function(t)
        t=t/30
        gc.setColor(.1,.1,.1,1-abs(t-.5))
        t=t*t*(3-2*t)*2-1
        gc.rectangle('fill',t*SCR.w,0,SCR.w,SCR.h)
    end},
    swipeR={duration=30,changeTime=15,draw=function(t)
        t=t/30
        gc.setColor(.1,.1,.1,1-abs(t-.5))
        t=t*t*(2*t-3)*2+1
        gc.rectangle('fill',t*SCR.w,0,SCR.w,SCR.h)
    end},
    swipeD={duration=30,changeTime=15,draw=function(t)
        t=t/30
        gc.setColor(.1,.1,.1,1-abs(t-.5))
        t=t*t*(2*t-3)*2+1
        gc.rectangle('fill',0,t*SCR.h,SCR.w,SCR.h)
    end},
}--Scene swapping animations
function SCN.swapTo(tar,style)--Parallel scene swapping, cannot back
    if scenes[tar]then
        if not SCN.swapping and tar~=SCN.cur then
            if not style then style='fade'end
            SCN.swapping=true
            local S=SCN.stat
            S.tar,S.style=tar,style
            S.time=swap[style].duration
            S.changeTime=swap[style].changeTime
            S.draw=swap[style].draw
        end
    else
        MES.new('warn',"No Scene: "..tar)
    end
end
function SCN.go(tar,style)--Normal scene swapping, can back
    if scenes[tar]then
        SCN.push()
        SCN.swapTo(tar,style)
    else
        MES.new('warn',"No Scene: "..tar)
    end
end
function SCN.back()
    if SCN.swapping then return end

    --Leave scene
    if SCN.sceneBack then SCN.sceneBack()end

    --Poll&Back to previous Scene
    local m=#SCN.stack
    if m>0 then
        SCN.swapTo(SCN.stack[m-1],SCN.stack[m])
        SCN.stack[m],SCN.stack[m-1]=nil
    end
end
return SCN