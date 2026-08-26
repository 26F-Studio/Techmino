local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local gc_push,gc_pop=gc.push,gc.pop
local gc_replaceTransform=gc.replaceTransform
local gc_translate=gc.translate
local gc_line=gc.line
local setFont=FONT.set

local LOBBY={}
LOBBY.playerList=nil
LOBBY.chat=nil

CHAT={}
CHAT.messages={}
CHAT.maxMessages=100
CHAT.inputText=""
CHAT.focused=false

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
    if LOBBY.chat and not LOBBY.chat.visible then
        SFX.play('notify',.3)
    end
end

function LOBBY.init()
    if LOBBY.playerList then return end
    
    LOBBY.playerList=PANEL.new('playerList','left')
    LOBBY.playerList:setSize(520,720)
    LOBBY.playerList:setTitle("Online Players")
    
    function LOBBY.playerList:drawContent()
        gc_setColor(1,1,1,.5*self.alpha)
        setFont(16)
        gc_print((text.onlinePlayerCount or "$1 online"):repD(NET.onlineCount),20,150)
        
        gc_setColor(1,1,1,.2*self.alpha)
        gc_setLineWidth(1)
        gc_line(20,180,self.w-20,180)
        
        setFont(18)
        gc_setColor(1,1,1,self.alpha)
        local y=200
        if NET.onlinePlayers then
            for i,p in ipairs(NET.onlinePlayers) do
                if y>680 then break end
                gc_print(p.username or "Guest",30,y)
                if type(p.elo)=='number' then
                    gc_setColor(COLOR.lY)
                    gc_printf(tostring(p.elo),self.w-120,y,100,'right')
                    gc_setColor(1,1,1,self.alpha)
                end
                y=y+28
            end
        end
    end
    
    LOBBY.chat=PANEL.new('globalChat','right')
    LOBBY.chat:setSize(560,720)
    LOBBY.chat:setTitle("Global Chat")
    
    function LOBBY.chat:drawContent()
        gc_setColor(1,1,1,.2*self.alpha)
        gc_setLineWidth(1)
        gc_line(10,45,self.w-10,45)
        
        setFont(16)
        local y=620
        for i=#CHAT.messages,1,-1 do
            local msg=CHAT.messages[i]
            local timeStr=os.date("%H:%M",msg.time)
            
            gc_setColor(.5,.5,.5,self.alpha)
            gc_print("["..timeStr.."]",10,y)
            gc_setColor(.9,.9,1,self.alpha)
            gc_print(msg.username..":",60,y)
            gc_setColor(1,1,1,self.alpha)
            gc_print(msg.message,60+#msg.username*9+10,y)
            
            y=y-20
            if y<60 then break end
        end
        
        local inputY=670
        gc_setColor(.15,.15,.15,self.alpha)
        gc_rectangle('fill',10,inputY,self.w-100,35,4)
        gc_setColor(CHAT.focused and .8 or .5,CHAT.focused and .8 or .5,CHAT.focused and .8 or .5,self.alpha)
        gc_setLineWidth(1)
        gc_rectangle('line',10,inputY,self.w-100,35,4)
        
        setFont(16)
        if #CHAT.inputText==0 and not CHAT.focused then
            gc_setColor(.5,.5,.5,self.alpha)
            gc_print("Type a message...",15,inputY+8)
        else
            gc_setColor(1,1,1,self.alpha)
            gc_print(CHAT.inputText,15,inputY+8)
        end
        
        gc_setColor(.2,.5,.2,self.alpha)
        gc_rectangle('fill',self.w-80,inputY,70,35,4)
        gc_setColor(.4,.8,.4,self.alpha)
        gc_setLineWidth(1)
        gc_rectangle('line',self.w-80,inputY,70,35,4)
        setFont(16)
        gc_setColor(1,1,1,self.alpha)
        gc_printf("Send",self.w-80,inputY+8,70,'center')
    end
end

function LOBBY.update(dt)
    LOBBY.init()
    LOBBY.playerList:update(dt)
    LOBBY.chat:update(dt)
end

function LOBBY.draw()
    LOBBY.init()
    LOBBY.playerList:draw()
    LOBBY.chat:draw()
end

function LOBBY.drawToggleButtons()
    LOBBY.init()
    LOBBY.playerList:drawToggleButton()
    LOBBY.chat:drawToggleButton()
end

function LOBBY.mouseClick(x,y)
    LOBBY.init()
    if LOBBY.playerList:checkToggleButtonClick(x,y) then return true end
    if LOBBY.chat:checkToggleButtonClick(x,y) then return true end
    
    if LOBBY.chat.visible and LOBBY.chat.alpha>0.5 then
        local screenX,screenY=SCR.xOy:transformPoint(x,y)
        local inputY=670
        if screenX>=LOBBY.chat.x+10 and screenX<=LOBBY.chat.x+LOBBY.chat.w-90 and screenY>=inputY and screenY<=inputY+35 then
            CHAT.focused=true
            love.keyboard.setTextInput(true)
            return true
        end
        if screenX>=LOBBY.chat.x+LOBBY.chat.w-80 and screenX<=LOBBY.chat.x+LOBBY.chat.w-10 and screenY>=inputY and screenY<=inputY+35 then
            CHAT.sendMessage()
            return true
        end
    end
    
    if CHAT.focused then
        love.keyboard.setTextInput(false)
    end
    CHAT.focused=false
    return false
end

function LOBBY.keyDown(key)
    if not CHAT.focused then return false end
    if key=='backspace' then
        CHAT.inputText=CHAT.inputText:sub(1,-2)
        return true
    elseif key=='return' or key=='kpenter' then
        CHAT.sendMessage()
        return true
    end
    return false
end

function LOBBY.textInput(t)
    if not CHAT.focused then return false end
    if #CHAT.inputText<256 then
        CHAT.inputText=CHAT.inputText..t
    end
    return true
end

function LOBBY.isAnyOpen()
    return (LOBBY.playerList and LOBBY.playerList.visible) or (LOBBY.chat and LOBBY.chat.visible)
end

return LOBBY
