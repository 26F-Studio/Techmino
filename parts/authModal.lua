local AUTH={}

local _isOpen=false
AUTH.mode='login'
AUTH.widgets={}
AUTH.prevActive=nil
AUTH.overlayAlpha=0
AUTH.boxAlpha=0

local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_push,gc_pop=gc.push,gc.pop
local gc_replaceTransform=gc.replaceTransform
local gc_print=gc.print

local username=""
local password=""
local focusedField="username"

local function _close()
    if AUTH.prevActive then
        WIDGET.setWidgetList(AUTH.prevActive)
    end
    _isOpen=false
    AUTH.mode=nil
    AUTH.widgets={}
    AUTH.prevActive=nil
    username=""
    password=""
    focusedField="username"
    love.keyboard.setTextInput(false)
    WIDGET.unFocus(true)
end

local function _getFieldRect(fieldName)
    if fieldName=='username' then
        return 320,255,640,58
    elseif fieldName=='password' then
        return 320,370,640,58
    end
end

local function _getButtonRect(buttonName)
    if buttonName=='submit' then
        return 580,455,180,60
    elseif buttonName=='close' then
        return 340,455,180,60
    end
end

local function _pointInRect(px,py,rx,ry,rw,rh)
    return px>=rx and px<=rx+rw and py>=ry and py<=ry+rh
end

local function _drawInputBox(x,y,w,h,value,secret,focused)
    gc_setColor(.1,.1,.1,.9)
    gc_rectangle('fill',x,y,w,h,4)
    gc_setColor(focused and 1 or .6,focused and 1 or .6,focused and 1 or .6,1)
    gc_setLineWidth(2)
    gc_rectangle('line',x,y,w,h,4)

    setFont(25)
    gc_setColor(1,1,1)
    local displayText=secret and string.rep('*',#value) or value
    if #displayText==0 and not focused then
        gc_setColor(.5,.5,.5,1)
    end
    gc_print(displayText,x+10,y+(h-25)/2)
end

local function _drawButton(x,y,w,h,label,color)
    local r,g,b=1,1,1
    if color=='lG' then r,g,b=.4,1,.4
    elseif color=='lR' then r,g,b=1,.4,.4
    end

    gc_setColor(r*.7,g*.7,b*.7,.9)
    gc_rectangle('fill',x,y,w,h,6)
    gc_setColor(r,g,b,1)
    gc_setLineWidth(2)
    gc_rectangle('line',x,y,w,h,6)

    setFont(28)
    gc_setColor(1,1,1)
    gc_print(label,x+(w-#label*14)/2,y+(h-28)/2)
end

function AUTH.open(mode)
    if _isOpen then _close() end
    AUTH.mode='login'
    AUTH.prevActive=WIDGET.active
    AUTH.widgets={}
    username=""
    password=""
    focusedField="username"
    _isOpen=true
    love.keyboard.setTextInput(true)
end

function AUTH._submit()
    if #username==0 or #password==0 then
        MES.new('error', text.noUsername or 'Please enter username and password')
        return
    end
    NET.loginWithPassword(username, password)
    _close()
end

function AUTH.isOpen()
    return _isOpen
end

function AUTH.close()
    _close()
end

function AUTH.update(dt)
    WIDGET.locked=_isOpen
    if _isOpen then
        AUTH.overlayAlpha=math.min(AUTH.overlayAlpha+dt*10,0.7)
        AUTH.boxAlpha=math.min(AUTH.boxAlpha+dt*10,1)
    else
        AUTH.overlayAlpha=math.max(AUTH.overlayAlpha-dt*10,0)
        AUTH.boxAlpha=math.max(AUTH.boxAlpha-dt*10,0)
    end
end

function AUTH.draw()
    if AUTH.overlayAlpha<=0 and AUTH.boxAlpha<=0 then return end

    gc_push('transform')
    gc_replaceTransform(SCR.origin)
    if AUTH.overlayAlpha>0 then
        gc_setColor(0,0,0,AUTH.overlayAlpha)
        gc_rectangle('fill',0,0,SCR.w,SCR.h)
    end
    gc_pop()

    if AUTH.boxAlpha>0 then
        gc_push('transform')
        gc_replaceTransform(SCR.xOy)
        local w,h=700,480
        local x,y=290,120
        gc_setColor(.15,.15,.15,.95*AUTH.boxAlpha)
        gc_rectangle('fill',x,y,w,h,10)
        gc_setColor(1,1,1,AUTH.boxAlpha)
        gc_setLineWidth(2)
        gc_rectangle('line',x,y,w,h,10)

        setFont(42)
        gc_setColor(COLOR.Z[1],COLOR.Z[2],COLOR.Z[3],AUTH.boxAlpha)
        gc_print('Log In',320,155)

        setFont(22)
        gc_setColor(.7,.7,.7,AUTH.boxAlpha)
        gc_print("Username",320,225)
        _drawInputBox(320,255,640,58,username,false,focusedField=='username')

        gc_print("Password",320,340)
        _drawInputBox(320,370,640,58,password,true,focusedField=='password')

        _drawButton(580,455,180,60,'Log In','lG')
        _drawButton(340,455,180,60,'Close','lR')
        gc_pop()
    end
end

function AUTH.mouseClick(x,y)
    if not _isOpen then return false end

    love.keyboard.setTextInput(true)

    local fields={'username','password'}
    for _,fieldName in ipairs(fields) do
        local fx,fy,fw,fh=_getFieldRect(fieldName)
        if fx and _pointInRect(x,y,fx,fy,fw,fh) then
            focusedField=fieldName
            love.keyboard.setTextInput(true)
            return true
        end
    end

    local submitX,submitY,submitW,submitH=_getButtonRect('submit')
    if submitX and _pointInRect(x,y,submitX,submitY,submitW,submitH) then
        AUTH._submit()
        return true
    end

    local closeX,closeY,closeW,closeH=_getButtonRect('close')
    if closeX and _pointInRect(x,y,closeX,closeY,closeW,closeH) then
        _close()
        return true
    end

    local w,h=700,480
    local x1,y1=290,120
    local x2,y2=x1+w,y1+h
    if x<x1 or x>x2 or y<y1 or y>y2 then
        _close()
        return true
    end

    -- Prevent clicks outside the modal from closing it in fullscreen
    -- where coordinate transforms can be unreliable
    return true
end

function AUTH.keyDown(key,rep)
    if not _isOpen then return nil end

    if key=='escape' and not rep then
        _close()
        return true
    elseif (key=='return' or key=='kpenter') and not rep then
        AUTH._submit()
        return true
    elseif key=='tab' and not rep then
        local fields={'username','password'}
        for i,fieldName in ipairs(fields) do
            if fieldName==focusedField then
                focusedField=fields[(i%#fields)+1]
                break
            end
        end
        return true
    elseif key=='backspace' then
        if focusedField=='username' then
            username=username:sub(1,-2)
        elseif focusedField=='password' then
            password=password:sub(1,-2)
        end
        return true
    end

    return true
end

function AUTH.textInput(t)
    if not _isOpen then return nil end

    if focusedField=='username' and #username<64 then
        username=username..t
    elseif focusedField=='password' and #password<64 then
        password=password..t
    end

    return true
end

return AUTH
