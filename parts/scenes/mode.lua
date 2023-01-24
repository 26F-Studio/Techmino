local gc_push,gc_pop=GC.push,GC.pop
local gc_translate,gc_scale,gc_rotate,gc_applyTransform=GC.translate,GC.scale,GC.rotate,GC.applyTransform
local gc_setColor,gc_setLineWidth=GC.setColor,GC.setLineWidth
local gc_draw,gc_line=GC.draw,GC.line
local gc_rectangle,gc_circle=GC.rectangle,GC.circle
local gc_print,gc_printf=GC.print,GC.printf

local ms,kb,tc=love.mouse,love.keyboard,love.touch

local max,min=math.max,math.min
local int,abs=math.floor,math.abs

local mapCam={
    sel=false,-- Selected mode ID
    xOy=love.math.newTransform(0,0,0,1),-- Transformation for map display
    keyCtrl=false,-- If controlling with key

    -- For auto zooming when enter/leave scene
    zoomMethod=false,
    zoomK=false,
}
local visibleModes
local touchDist
local grid

local scene={}

function scene.enter()
    grid=false
    BG.set()
    mapCam.zoomK=SCN.prev=='main' and 5 or 1
    visibleModes={}-- 1=unlocked, 2=locked but visible
    for name,M in next,MODES do
        if RANKS[name] and M.x then
            visibleModes[name]=1
            if M.unlock then
                for i=1,#M.unlock do
                    visibleModes[M.unlock[i]]=visibleModes[M.unlock[i]] or 2
                end
            end
        end
    end
end

local function _getK()
    return abs(mapCam.xOy:transformPoint(1,0)-mapCam.xOy:transformPoint(0,0))
end
local function _getPos()
    return mapCam.xOy:inverseTransformPoint(0,0)
end

local function _onModeRaw(x,y)
    for name,M in next,MODES do
        if visibleModes[name] and M.x then
            local s=M.size
            if M.shape==1 then
                if x>M.x-s and x<M.x+s and y>M.y-s and y<M.y+s then return name end
            elseif M.shape==2 then
                if abs(x-M.x)+abs(y-M.y)<s+12 then return name end
            elseif M.shape==3 then
                if (x-M.x)^2+(y-M.y)^2<(s+6)^2 then return name end
            end
        end
    end
end
local function _moveMap(dx,dy)
    local k=_getK()
    local x,y=_getPos()
    if x>1300 and dx<0 or x<-1500 and dx>0 then dx=0 end
    if y>420 and dy<0 or y<-1900 and dy>0 then dy=0 end
    mapCam.xOy:translate(dx/k,dy/k)
end
function scene.wheelMoved(_,dy)
    mapCam.keyCtrl=false
    local k=_getK()
    k=min(max(k+dy*.1,.3),1.6)/k
    mapCam.xOy:scale(k)

    local x,y=_getPos()
    mapCam.xOy:translate(x*(1-k),y*(1-k))
end
function scene.mouseMove(_,_,dx,dy)
    if ms.isDown(1) then
        _moveMap(dx,dy)
    end
    mapCam.keyCtrl=false
end
function scene.mouseClick(x,y)
    local _=mapCam.sel
    if not _ or x<920 then
        x,y=x-640,y-360
        x,y=mapCam.xOy:inverseTransformPoint(x,y)
        local SEL=_onModeRaw(x,y)
        if _~=SEL then
            if SEL then
                mapCam.moving=true
                _=MODES[SEL]
                mapCam.sel=SEL
                SFX.play('click')
            else
                mapCam.sel=false
            end
        elseif _ then
            scene.keyDown('return')
        end
    end
    mapCam.keyCtrl=false
end
function scene.touchDown()
    touchDist=false
end
function scene.touchMove(x,y,dx,dy)
    local L=tc.getTouches()
    if not L[2] then
        _moveMap(dx,dy)
    elseif not L[3] then
        x,y=SCR.xOy:inverseTransformPoint(tc.getPosition(L[1]))
        dx,dy=SCR.xOy:inverseTransformPoint(tc.getPosition(L[2]))-- Not delta!!!
        local d=(x-dx)^2+(y-dy)^2
        if d>100 then
            d=d^.5
            if touchDist then
                scene.wheelMoved(nil,(d-touchDist)*.02)
            end
            touchDist=d
        end
    end
    mapCam.keyCtrl=false
end
function scene.touchClick(x,y)
    scene.mouseClick(x,y)
end
function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='return' or key=='kpenter' then
        if mapCam.sel then
            if visibleModes[mapCam.sel]==2 then
                MES.new('info',text.unlockHint)
            else
                mapCam.keyCtrl=false
                loadGame(mapCam.sel)
            end
        end
    elseif key=='f1' then
        SCN.go('mod')
    elseif key=='f2' then
        grid=not grid
    elseif key=='escape' then
        if mapCam.sel then
            mapCam.sel=false
        else
            SCN.back()
        end
    end
end

function scene.update()
    local dx,dy=0,0
    local F
    if not SCN.swapping then
        if kb.isDown('up',   'w') then dy=dy+10 F=true end
        if kb.isDown('down', 's') then dy=dy-10 F=true end
        if kb.isDown('left', 'a') then dx=dx+10 F=true end
        if kb.isDown('right','d') then dx=dx-10 F=true end
        local js=Z.getJsState()[1]
        if js then
            local sx,sy=js._jsObj:getGamepadAxis('leftx'),js._jsObj:getGamepadAxis('lefty')
            if math.abs(sx)>.1 or math.abs(sy)>.1 then
                if sy<-.1 then dy=dy-12.6*sy end
                if sy>.1 then  dy=dy-12.6*sy end
                if sx<-.1 then dx=dx-12.6*sx end
                if sx>.1 then  dx=dx-12.6*sx end
                F=true
            end
        end
    end
    if F then
        mapCam.keyCtrl=true
        if kb.isDown('lctrl','rctrl','lalt','ralt') then
            scene.wheelMoved(nil,(dy-dx)*.026)
        else
            _moveMap(dx,dy)
            local x,y=_getPos()
            local SEL=_onModeRaw(x,y)
            if SEL and mapCam.sel~=SEL then
                mapCam.sel=SEL
                SFX.play('click')
            end
        end
    end

    local _=SCN.state.tar
    mapCam.zoomMethod=_=="game" and 1 or _=="mode" and 2
    if mapCam.zoomMethod==1 then
        _=mapCam.zoomK
        if _<.8 then _=_*1.05 end
        if _<1.1 then _=_*1.05 end
        mapCam.zoomK=_*1.05
    elseif mapCam.zoomMethod==2 then
        mapCam.zoomK=mapCam.zoomK^.9
    end
end

-- noRank/B/A/S/U/X
local baseRankColor={
    [0]={0,0,0,.3},
    {.2,.4,.6,.3},
    {.6,.85,.65,.3},
    {.85,.8,.3,.3},
    {.85,.5,.4,.3},
    {.85,.3,.8,.3},
}
local function _drawModeShape(M,S,drawType)
    if M.shape==1 then-- Rectangle
        gc_rectangle(drawType,M.x-S,M.y-S,2*S,2*S)
    elseif M.shape==2 then-- Diamond
        gc_circle(drawType,M.x,M.y,S+12,4)
    elseif M.shape==3 then-- Octagon
        gc_circle(drawType,M.x,M.y,S+6,8)
    end
end
function scene.draw()
    local _
    gc_push('transform')
    gc_translate(640,360)
    gc_rotate((mapCam.zoomK^.6-1))
    gc_scale(mapCam.zoomK^.7)
    gc_applyTransform(mapCam.xOy);

    if grid then
        gc_setColor(1,0,.26,.26)
        gc_setLineWidth(1)
        for x=-2000,2000,200 do
            gc_line(x,-2200,x,1000)
        end
        for y=-2200,1000,200 do
            gc_line(-2000,y,2000,y)
        end
        gc_setColor(1,0,.26,.626)
        gc_setLineWidth(2)
        gc_line(0,-2200,0,1000)
        gc_line(-2000,0,1000,0)
    end

    local R=RANKS
    local sel=mapCam.sel

    -- Lines connecting modes
    gc_setLineWidth(8)
    gc_setColor(1,1,1,.2)
    for name,M in next,MODES do
        if R[name] and M.unlock and M.x then
            for _=1,#M.unlock do
                local m=MODES[M.unlock[_]]
                gc_line(M.x,M.y,m.x,m.y)
            end
        end
    end

    -- Modes
    setFont(80)
    gc_setLineWidth(4)
    for name,M in next,MODES do
        local unlocked=visibleModes[name]
        if unlocked then
            local rank=R[name]
            local S=M.size

            -- Draw shapes on map
            if unlocked==1 then
                gc_setColor(baseRankColor[rank])
                _drawModeShape(M,S,'fill')
            end
            gc_setColor(1,1,sel==name and 0 or 1,unlocked==1 and .8 or .3)
            _drawModeShape(M,S,'line')

            -- Icon
            local icon=M.icon
            if icon then
                gc_setColor(unlocked==1 and COLOR.lH or COLOR.dH)
                local length=icon:getWidth()*.5
                gc_draw(icon,M.x,M.y,nil,S/length,nil,length,length)
            end

            -- Rank
            if unlocked==1 then
                name=RANK_CHARS[rank]
                if name then
                    gc_setColor(COLOR.dX)
                    GC.mStr(name,M.x+M.size*.7,M.y-50-M.size*.7)
                    gc_setColor(RANK_COLORS[rank])
                    GC.mStr(name,M.x+M.size*.7+4,M.y-50-M.size*.7-4)
                end
            end
        end
    end
    gc_pop()

    -- Score board
    if sel then
        local M=MODES[sel]
        gc_setColor(COLOR.lX)
        gc_rectangle('fill',920,0,360,720,5)-- Info board
        gc_setColor(COLOR.Z)
        setFont(40)GC.mStr(text.modes[sel][1],1100,5)
        setFont(30)GC.mStr(text.modes[sel][2],1100,50)
        setFont(25)gc_printf(text.modes[sel][3],920,110,360,'center')
        if M.slowMark then
            gc_draw(IMG.ctrlSpeedLimit,1230,50,nil,.4)
        end
        if M.score then
            mText(TEXTOBJ.highScore,1100,240)
            gc_setColor(COLOR.X)
            gc_rectangle('fill',940,290,320,280,5)-- Highscore board
            local L=M.records
            gc_setColor(1,1,1)
            if visibleModes[sel]==2 then
                mText(TEXTOBJ.modeLocked,1100,370)
            elseif L[1] then
                for i=1,#L do
                    local t=M.scoreDisp(L[i])
                    local f=int((30-#t*.5)/5)*5
                    setFont(f)
                    gc_print(t,955,275+25*i+17-f*.7)
                    _=L[i].date
                    if _ then
                        setFont(10)
                        gc_print(_,1155,285+25*i)
                    end
                end
            else
                mText(TEXTOBJ.noScore,1100,370)
            end
        end
    end
    if mapCam.keyCtrl then
        gc_setColor(1,1,1)
        gc_setLineWidth(4)
        gc_translate(640,360)
        gc_line(-20,0,20,0)
        gc_line(0,-20,0,20)
        gc_translate(-640,-360)
    end
end

scene.widgetList={
    WIDGET.newKey{name='mod',     x=140,y=655,w=220,h=80,font=35,code=goScene'mod'},
    WIDGET.newButton{name='start',x=1040,y=655,w=180,h=80,font=40,code=pressKey'return',hideF=function() return not mapCam.sel end},
    WIDGET.newButton{name='back', x=1200,y=655,w=120,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
