local CHAT={}

CHAT.messages={}
CHAT.inputText=""
CHAT.isOpen=false
CHAT.scrollY=0
CHAT.maxMessages=100

local gc=love.graphics
local gc_setColor=gc.setColor
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local gc_push,gc_pop=gc.push,gc.pop
local gc_setScissor=gc.setScissor

local function _addMessage(username,message)
    table.insert(CHAT.messages,{
        time=os.time(),
        username=username,
        message=message
    })
    if #CHAT.messages>CHAT.maxMessages then
        table.remove(CHAT.messages,1)
    end
end

function CHAT.open()
    CHAT.isOpen=true
    CHAT.scrollY=0
end

function CHAT.close()
    CHAT.isOpen=false
end

function CHAT.toggle()
    if CHAT.isOpen then
        CHAT.close()
    else
        CHAT.open()
    end
end

function CHAT.clear()
    CHAT.messages={}
    CHAT.scrollY=0
end

function CHAT.sendMessage()
    if #CHAT.inputText>0 then
        local username=USER.uid and USERS.getUsername(USER.uid) or "Guest"
        _addMessage(username,CHAT.inputText)
        if NET.global_chat then
            NET.global_chat(CHAT.inputText)
        end
        CHAT.inputText=""
    end
end

function CHAT.receiveMessage(username,message)
    _addMessage(username,message)
    if not CHAT.isOpen then
        SFX.play('notify',.3)
    end
end

function CHAT.keyDown(key)
    if not CHAT.isOpen then return false end
    
    if key=='escape' then
        CHAT.close()
        return true
    elseif key=='return' or key=='kpenter' then
        CHAT.sendMessage()
        return true
    elseif key=='backspace' then
        CHAT.inputText=CHAT.inputText:sub(1,-2)
        return true
    end
    return false
end

function CHAT.textInput(t)
    if not CHAT.isOpen then return false end
    if #CHAT.inputText<256 then
        CHAT.inputText=CHAT.inputText..t
    end
    return true
end

function CHAT.mouseClick(x,y)
    if not CHAT.isOpen then return false end
    
    local boxX,boxY=700,100
    local boxW,boxH=560,520
    
    local screenX,screenY=SCR.xOy:transformPoint(x,y)
    
    if screenX<boxX or screenX>boxX+boxW or screenY<boxY or screenY>boxY+boxH then
        return false
    end
    
    return true
end

function CHAT.wheelMoved(y)
    if not CHAT.isOpen then return end
    CHAT.scrollY=math.max(0,CHAT.scrollY-y*20)
end

function CHAT.update(dt)
end

function CHAT.draw()
    if not CHAT.isOpen then return end
    
    local boxX,boxY=700,100
    local boxW,boxH=560,520
    
    gc_push('transform')
    gc_replaceTransform(SCR.xOy)
    
    gc_setColor(.1,.1,.1,.95)
    gc_rectangle('fill',boxX,boxY,boxW,boxH,8)
    gc_setColor(.5,.5,.5,1)
    gc.setLineWidth(2)
    gc_rectangle('line',boxX,boxY,boxW,boxH,8)
    
    setFont(28)
    gc_setColor(COLOR.lY)
    gc_print("Global Chat",boxX+10,boxY+8)
    
    local msgY=boxY+45
    local msgH=boxH-100
    local msgW=boxW-20
    
    gc_setScissor(boxX,boxY+40,boxW,msgH)
    
    setFont(18)
    local y=msgY+msgH-25
    for i=#CHAT.messages,1,-1 do
        local msg=CHAT.messages[i]
        local timeStr=os.date("%H:%M",msg.time)
        local fullMsg="["..timeStr.."] "..msg.username..": "..msg.message
        
        gc_setColor(.5,.5,.5,1)
        gc_print("["..timeStr.."]",boxX+10,y)
        gc_setColor(.9,.9,1,1)
        gc_print(msg.username..":",boxX+65,y)
        gc_setColor(1,1,1,1)
        gc_printf(msg.message,boxX+65+#msg.username*10+10,y,msgW-100,'left')
        
        y=y-22
        if y<boxY+40 then break end
    end
    
    gc_setScissor()
    
    local inputY=boxY+boxH-50
    gc_setColor(.15,.15,.15,1)
    gc_rectangle('fill',boxX+10,inputY,boxW-100,40,4)
    gc_setColor(.6,.6,.6,1)
    gc.setLineWidth(1)
    gc_rectangle('line',boxX+10,inputY,boxW-100,40,4)
    
    setFont(20)
    gc_setColor(1,1,1,1)
    gc_print(CHAT.inputText..(love.timer.getTime()%1<.5 and "|" or ""),boxX+15,inputY+10)
    
    gc_setColor(.4,.8,.4,1)
    gc_rectangle('fill',boxX+boxW-80,inputY,70,40,4)
    gc_setColor(1,1,1,1)
    setFont(18)
    gc_printf("Send",boxX+boxW-80,inputY+10,70,'center')
    
    gc_pop()
end

return CHAT
