local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local gc_push,gc_pop=gc.push,gc.pop
local gc_replaceTransform=gc.replaceTransform
local gc_setScissor=gc.setScissor

local WINDOW=require'Zframework.window'

local CHAT={}
local win

CHAT.messages={}
CHAT.inputText=""
CHAT.isOpen=false
CHAT.maxMessages=100
CHAT.alpha=0

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
    if not win then
        win=WINDOW.new('globalChat')
        win:setPosition(0,0)
        win:setSize(560,720)
        win:setTitle("Global Chat")
        win:addInputBox(10,620,440,40,"Type a message...",false)
        win:addButton("Send",460,620,90,40,function()
            local text=win:getInputText(1)
            if #text>0 then
                local username=USER.uid and USERS.getUsername(USER.uid) or "Guest"
                _addMessage(username,text)
                if NET.global_chat then
                    NET.global_chat(text)
                end
                win:setInputText(1,"")
            end
        end)
    end
    win:show()
    CHAT.isOpen=true
end

function CHAT.close()
    if win then win:hide() end
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
end

function CHAT.receiveMessage(username,message)
    _addMessage(username,message)
    if not CHAT.isOpen then
        SFX.play('notify',.3)
    end
end

function CHAT.update(dt)
    if win then win:update(dt) end
    CHAT.alpha=win and win.alpha or 0
end

function CHAT.draw()
    if not win or CHAT.alpha<=0 then return end
    
    local boxX,boxY=0,0
    local boxW,boxH=560,720
    
    gc_setColor(.1,.1,.1,.95*CHAT.alpha)
    gc_rectangle('fill',boxX,boxY,boxW,boxH,0,8,8,0)
    gc_setColor(.4,.4,.4,CHAT.alpha)
    gc_setLineWidth(2)
    gc_rectangle('line',boxX,boxY,boxW,boxH,0,8,8,0)
    
    gc_setColor(.2,.2,.2,CHAT.alpha)
    gc_rectangle('fill',boxX,boxY,boxW,35,0,8,0,0)
    
    setFont(22)
    gc_setColor(1,1,1,CHAT.alpha)
    gc_print("Global Chat",boxX+10,boxY+7)
    
    local msgY=boxY+45
    local msgH=boxH-120
    
    gc_setScissor(boxX,boxY+40,boxW,msgH)
    
    setFont(16)
    local y=msgY+msgH-22
    for i=#CHAT.messages,1,-1 do
        local msg=CHAT.messages[i]
        local timeStr=os.date("%H:%M",msg.time)
        
        gc_setColor(.5,.5,.5,CHAT.alpha)
        gc_print("["..timeStr.."]",boxX+10,y)
        gc_setColor(.9,.9,1,CHAT.alpha)
        gc_print(msg.username..":",boxX+60,y)
        gc_setColor(1,1,1,CHAT.alpha)
        gc_print(msg.message,boxX+60+#msg.username*9+10,y)
        
        y=y-20
        if y<boxY+40 then break end
    end
    
    gc_setScissor()
    
    local input=win.inputBoxes[1]
    if input then
        local ix,iy,iw,ih=boxX+input.x,boxY+input.y,input.w,input.h
        gc_setColor(.15,.15,.15,CHAT.alpha)
        gc_rectangle('fill',ix,iy,iw,ih,4)
        gc_setColor(input.focused and .8 or .5,input.focused and .8 or .5,input.focused and .8 or .5,CHAT.alpha)
        gc_setLineWidth(1)
        gc_rectangle('line',ix,iy,iw,ih,4)
        
        setFont(18)
        local displayText=input.text
        if #displayText==0 and not input.focused then
            gc_setColor(.5,.5,.5,CHAT.alpha)
            gc_print(input.placeholder,ix+5,iy+(ih-18)/2)
        else
            gc_setColor(1,1,1,CHAT.alpha)
            gc_print(displayText,ix+5,iy+(ih-18)/2)
        end
    end
    
    local btn=win.buttons[1]
    if btn then
        local bx,by,bw,bh=boxX+btn.x,boxY+btn.y,btn.w,btn.h
        gc_setColor(.2,.5,.2,CHAT.alpha)
        gc_rectangle('fill',bx,by,bw,bh,4)
        gc_setColor(.4,.8,.4,CHAT.alpha)
        gc_setLineWidth(1)
        gc_rectangle('line',bx,by,bw,bh,4)
        setFont(18)
        gc_setColor(1,1,1,CHAT.alpha)
        gc_printf(btn.label,bx,by+(bh-18)/2,bw,'center')
    end
end

function CHAT.mouseClick(x,y)
    if not win or CHAT.alpha<0.5 then return false end
    return win:mouseClick(x,y)
end

function CHAT.keyDown(key)
    if not win then return false end
    return win:keyDown(key)
end

function CHAT.textInput(t)
    if not win then return false end
    return win:textInput(t)
end

return CHAT
