local scene={}

local CARD=require'parts.userCard'
local AUTH=require'parts.authModal'
local LOBBY=require'parts.lobbyPanel'

local gc=love.graphics
local gc_setColor=gc.setColor
local gc_print,gc_printf=gc.print,gc.printf
local setFont=FONT.set

local function _goCasual()
    CARD.leave()
    SCN.go('net_rooms')
end

local function _goRanked()
    CARD.leave()
    SCN.go('net_ranked')
end

local function _refreshOnline()
    NET.online_getPlayers()
end

function scene.enter()
    CARD.reset()
    CARD.enter()
    BG.set()
    NET.online_getPlayers()
end

function scene.leave()
    CARD.leave()
    AUTH.close()
end

function scene.keyDown(key,rep)
    if AUTH.isOpen() and AUTH.keyDown(key,rep) then return true end
    if LOBBY.keyDown(key) then return true end
    if key=='escape' and not rep then
        if LOBBY.isAnyOpen() then
            if LOBBY.chat and LOBBY.chat.visible then LOBBY.chat:toggle() end
            if LOBBY.playerList and LOBBY.playerList.visible then LOBBY.playerList:toggle() end
        else
            SCN.backTo('main')
        end
    elseif key=='return' or key=='kpenter' then
        CARD.openMenu()
    elseif key=='r' and love.keyboard.isDown('lctrl','rctrl') then
        _refreshOnline()
    else
        return true
    end
end

function scene.textInput(t)
    if AUTH.isOpen() and AUTH.textInput(t) then return true end
    if LOBBY.textInput(t) then return true end
end

function scene.mouseClick(x,y)
    if CARD.mouseClick(x,y) then return true end
    if AUTH.mouseClick(x,y) then return true end
    if LOBBY.mouseClick(x,y) then return true end
end

function scene.update(dt)
    CARD.update(dt)
    AUTH.update(dt)
    LOBBY.update(dt)
end

function scene.draw()
    setFont(50)
    gc_setColor(COLOR.Z)
    gc_printf("Teblocks",0,70,1280,'center')
    
    setFont(25)
    gc_setColor(COLOR.lH)
    gc_printf("Select a game mode to play",0,140,1280,'center')
end

function scene.overDraw()
    LOBBY.draw()
    LOBBY.drawToggleButtons()
    CARD.draw()
    AUTH.draw()
end

scene.widgetList={
    WIDGET.newKey{name='Casual Mode',   x=490, y=420,w=260,h=90,font=35,color='lG',code=_goCasual},
    WIDGET.newKey{name='Ranked Mode',    x=790, y=420,w=260,h=90,font=35,color='lY',code=_goRanked},
    WIDGET.newButton{name='back',       x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
