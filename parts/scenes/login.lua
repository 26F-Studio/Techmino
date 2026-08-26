local scene={}

local CARD=require'parts.userCard'
local AUTH=require'parts.authModal'
local CHAT=require'parts.globalChat'

local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print=gc.print
local gc_line=gc.line
local setFont=FONT.set

local function _goCasual()
    CARD.leave()
    CHAT.close()
    SCN.go('net_rooms')
end
local function _goRanked()
    CARD.leave()
    CHAT.close()
    SCN.go('net_ranked')
end

local function _refreshOnline()
    NET.online_getPlayers()
end

local function _toggleChat()
    CHAT.toggle()
end

local onlineList=WIDGET.newListBox{name='onlineList',x=100,y=230,w=500,h=340,lineH=40,drawF=function(item,id,ifSel)
    setFont(30)
    if ifSel then
        gc_setColor(1,1,1,.3)
        gc_rectangle('fill',0,0,500,40)
    end
    gc_setColor(1,1,1)
    gc_print(id,10,-4)
    if type(item)=='table' then
        gc_setColor(.9,.9,1)
        gc_print(item.username or "Unknown",60,-4)
        if type(item.elo)=='number' then
            gc_setColor(COLOR.lY)
            gc_printf(tostring(item.elo),280,-4,120,'right')
        end
    end
end}

function scene.enter()
    CARD.reset()
    CARD.enter()
    NET.online_getPlayers()
    CHAT.open()
end

function scene.leave()
    CARD.leave()
    AUTH.close()
    CHAT.close()
end

function scene.keyDown(key,rep)
    if AUTH.isOpen() and AUTH.keyDown(key,rep) then return true end
    if CHAT.isOpen and CHAT.keyDown(key) then return true end
    if key=='escape' and not rep then
        if CHAT.isOpen then
            CHAT.close()
        else
            SCN.back()
        end
    elseif key=='return' or key=='kpenter' then
        _submit()
    elseif key=='v' and love.keyboard.isDown('lctrl','rctrl') then
        local t=CLIPBOARD.get()
        if t then
            t=STRING.trim(t)
            if #t==128 and t:match("^[0-9A-Z]+$") then
                scene.widgetList.ticket:setText(t)
            end
        end
    elseif key=='r' and love.keyboard.isDown('lctrl','rctrl') then
        _refreshOnline()
    elseif key=='c' and love.keyboard.isDown('lctrl','rctrl') then
        _toggleChat()
    else
        return true
    end
end

function scene.textInput(t)
    if AUTH.isOpen() and AUTH.textInput(t) then return true end
    if CHAT.isOpen and CHAT.textInput(t) then return true end
end

function scene.mouseClick(x,y)
    if AUTH.mouseClick(x,y) then return true end
    if CHAT.mouseClick(x,y) then return true end
    if CARD.mouseClick(x,y) then return true end
end

function scene.update(dt)
    CARD.update(dt)
    AUTH.update(dt)
    CHAT.update(dt)
    local list={}
    if NET.onlinePlayers then
        for _,p in next,NET.onlinePlayers do
            table.insert(list,p)
        end
    end
    onlineList:setList(list)
end

function scene.draw()
    CARD.draw()

    setFont(35)
    gc_setColor(COLOR.Z)
    gc_print(text.onlinePlayers or "Online Players",100,150)
    gc_setColor(1,1,1,.5)
    setFont(20)
    gc_print(text.onlinePlayerCount:repD(NET.onlineCount),100,192)

    gc_setColor(1,1,1,.2)
    gc_setLineWidth(1)
    gc_line(100,225,680,225)

    CHAT.draw()
    AUTH.draw()
end

scene.widgetList={
    WIDGET.newText{name='title',        x=80,  y=50,font=70,align='L'},

    WIDGET.newKey{name='Casual Mode',   x=220, y=650,w=240,h=80,font=35,color='lG',code=_goCasual},
    WIDGET.newKey{name='Ranked Mode',    x=470, y=650,w=240,h=80,font=35,color='lY',code=_goRanked},
    WIDGET.newKey{name='Chat',          x=720, y=650,w=120,h=80,font=30,color='lB',code=_toggleChat},

    WIDGET.newButton{name='back',       x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},

    onlineList,
}

return scene
