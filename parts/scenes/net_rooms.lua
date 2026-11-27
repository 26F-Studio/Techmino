local scene={}
local serial=-1
local timer=0
local list=WIDGET.newListBox{name='roomList',x=40,y=90,w=800,h=435,lineH=55,drawF=function(room,index,selected)
    if selected then love.graphics.setColor(1,1,1,.2) love.graphics.rectangle('fill',0,0,800,55) end
    love.graphics.setColor(1,1,1)
    FONT.set(24)
    love.graphics.printf(index..'. '..room.name,12,3,545,'left')
    FONT.set(18)
    love.graphics.printf(room.track..' / '..room.phase..(room.passwordProtected and ' / password' or ''),12,32,545,'left')
    love.graphics.printf(room.players..'/10 players + '..room.spectators..'/20 spectators',520,18,267,'right')
end}
local password=WIDGET.newInputBox{x=355,y=550,w=485,h=50,secret=true,limit=64,hideF=function() local room=list:getSel() return not room or not room.passwordProtected end}
local function refresh()
    if NET.connectionState=='ready' then NET.listRooms() timer=10 end
end
local function join(role)
    local room=list:getSel()
    if not room then return end
    NET.enterRoom(room.id,room.passwordProtected and password:getText() or nil,role)
end
function scene.enter()
    BG.set()
    serial=-1
    refresh()
    DiscordRPC.update('Browsing online rooms')
end
function scene.keyDown(key,rep)
    if rep then return true end
    if key=='escape' then SCN.back()
    elseif key=='r' then refresh()
    elseif key=='return' or key=='kpenter' then join(love.keyboard.isDown('lshift','rshift') and 'spectator' or 'player')
    else return true end
end
function scene.update(dt)
    if serial~=NET.roomStore.listSerial then list:setList(NET.roomStore.rooms) serial=NET.roomStore.listSerial end
    timer=timer-dt
    if timer<=0 and not NET.roomStore.listPending then refresh() end
end
function scene.draw()
    drawSelfProfile()
    drawNetworkStatus()
    local room=list:getSel()
    FONT.set(22)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(room and (room.track=='authoritative' and 'Server-authoritative\nDefault source netBattle / TRS\nTeams supported' or 'Casual relay\nClient-simulated results are unverified\nNo authoritative ranking') or 'Select a room to join or watch.',865,160,375,'left')
    if NET.roomStore.listPending then love.graphics.printf('Loading rooms...',40,545,260,'left') end
end
scene.widgetList={
    WIDGET.newText{x=45,y=25,align='L',font=45,fText='Techmino rooms'},list,password,
    WIDGET.newButton{x=170,y=635,w=220,h=90,font=28,fText='Refresh',code=refresh},
    WIDGET.newButton{x=410,y=635,w=220,h=90,font=28,fText='Create room',code=goScene('net_newRoom','swipeL')},
    WIDGET.newButton{x=650,y=635,w=220,h=90,font=28,fText='Join player',code=function() join('player') end},
    WIDGET.newButton{x=890,y=635,w=220,h=90,font=28,fText='Spectate',code=function() join('spectator') end},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
