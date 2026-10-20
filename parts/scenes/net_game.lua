local scene={}
local textBox,inputBox=NET.textBox,NET.inputBox
local chatCount=-1
local function room() return NET.roomStore.snapshot end
local function member() return NET.roomStore:member(USER.uid) end
local function host() return room() and room().hostId==USER.uid end
local function lobby() return room() and room().phase=='lobby' end
local function active() return NET.match:isActive() end
local function target()
    local id=NETPLY.selectedId
    return id and NET.roomStore:member(id) and id or USER.uid
end
local function setRole(role)
    NET.roomCommand('room.role',{targetId=target(),role=role})
end
local function switchChat()
    textBox.hide=not textBox.hide
    inputBox.hide=textBox.hide
    if inputBox.hide then WIDGET.unFocus(true) else NET.match:releaseAll() WIDGET.focus(inputBox) end
end
local function quit()
    if tryBack() then NET.leaveRoom(function() SCN.backTo('net_menu') end) end
end
local function settings()
    if active() then NET.match:absentNow() end
    GAME.prevBG=BG.cur
    SCN.go('setting_game')
end
local function command(message)
    local args=STRING.split(message,' ')
    local operation=args[1]
    if operation=='/kick' then NET.roomCommand('room.kick',{targetId=args[2]})
    elseif operation=='/host' then NET.roomCommand('room.transfer',{targetId=args[2]})
    elseif operation=='/pw' then NET.roomCommand('room.password',{password=message:sub(5)})
    elseif operation=='/team' then NET.roomCommand('room.team',{targetId=args[3] or USER.uid,team=tonumber(args[2])})
    elseif operation=='/role' then NET.roomCommand('room.role',{targetId=args[2],role=args[3]})
    elseif operation=='/start' then NET.roomCommand('match.countdown')
    elseif operation=='/cancel' then NET.roomCommand('match.cancel')
    elseif operation=='/close' then if tryBack() then NET.roomCommand('room.close') end
    elseif operation=='/leave' or operation=='/quit' then quit()
    elseif operation=='/absent' then NET.match:absentNow()
    elseif operation=='/return' then NET.match:returnNow()
    else NET.report('INVALID_COMMAND','Commands: /kick UUID, /host UUID, /pw PASSWORD, /team N [UUID], /role UUID player|spectator, /start, /cancel, /close, /leave, /absent, /return.') end
end
local function sendChat()
    local message=STRING.trim(inputBox:getText())
    if #message==0 then switchChat() return end
    if message:sub(1,1)=='/' then command(message) inputBox:clear()
    elseif NET.chat(message) then inputBox:clear() end
end
local function press(action)
    if inputBox.hide and action and action>0 then
        if action>20 then NET.report('INPUT_UNSUPPORTED','Online default rules support the twenty source input actions only.') return end
        if NET.match:press(action) then VK.press(action) end
    end
end
local function release(action)
    if action and action>=1 and action<=20 and NET.match:release(action) then VK.release(action) end
end
function scene.enter()
    chatCount=-1
    if not room() then return end
    NET.match:returnNow()
    if GAME.prevBG then BG.set(GAME.prevBG) GAME.prevBG=false end
    DiscordRPC.update('Techmino / '..room().track)
end
function scene.leave()
    NET.match:releaseAll()
    NET.match:absentNow()
end
function scene.mouseMove(x,y) if not active() then NETPLY.mouseMove(x,y) end end
function scene.mouseDown(x,y,button)
    if button~=1 or not textBox.hide then return end
    if not active() then NETPLY.select(x,y)
    elseif NET.match.track=='relay' and NET.match:isParticipant() then
        for _,P in pairs(NET.match.bySlot) do
            if P.uid~=USER.uid and P.alive and x>=P.fieldX and x<=P.fieldX+300*P.size and y>=P.fieldY and y<=P.fieldY+600*P.size then
                NET.match:queueInput(2,0,P.sid)
                return
            end
        end
    end
end
function scene.touchDown(x,y)
    if not active() then NETPLY.select(x,y) return end
    if not SETTING.VKSwitch or not inputBox.hide or not NET.match:isParticipant() then return end
    local action=VK.on(x,y)
    if action then press(action) VK.touch(action,x,y) end
end
function scene.touchUp(x,y)
    local action=VK.on(x,y)
    if action then release(action) VK.release(action) end
end
function scene.keyDown(key,rep)
    if key=='escape' and not rep then if inputBox.hide then quit() else switchChat() end
    elseif key=='return' or key=='kpenter' then if inputBox.hide then switchChat() else sendChat() end
    elseif key=='/' and inputBox.hide and not rep then switchChat() inputBox:setText('/')
    elseif not inputBox.hide then inputBox:keypress(key) return true
    elseif rep then return true
    elseif active() then press(KEY_MAP.keyboard[key])
    elseif key=='space' then local self=member() if self then if self.role=='spectator' then NET.roomCommand('room.role',{targetId=USER.uid,role='player'}) else NET.ready(not self.ready) end end
    elseif key=='s' then settings()
    elseif key=='g' and host() then NET.roomCommand('match.countdown')
    else return true end
end
function scene.keyUp(key) release(KEY_MAP.keyboard[key]) end
function scene.gamepadDown(key)
    if key=='back' then scene.keyDown('escape') elseif active() then press(KEY_MAP.joystick[key]) end
end
function scene.gamepadUp(key) release(KEY_MAP.joystick[key]) end
function scene.update(dt)
    if not room() then if not SCN.swapping then SCN.backTo('net_menu') end return end
    if chatCount~=NET.roomStore.serial then
        textBox:clear()
        for _,message in ipairs(NET.roomStore.chat) do textBox:push{COLOR.Z,message.name..' ',COLOR.N,message.text} end
        chatCount=NET.roomStore.serial
    end
    if active() then VK.update(dt) end
end
function scene.draw()
    local current=room()
    if not current then return end
    local match=NET.match
    love.graphics.setColor(1,1,1)
    FONT.set(22)
    love.graphics.printf(current.name..' / '..current.track..' / '..current.phase,20,5,1080,'left')
    if active() or current.phase=='settling' then
        for _,P in ipairs(PLAYERS) do P:draw() end
        if match:isParticipant() and inputBox.hide then VK.draw() end
        FONT.set(20)
        love.graphics.setColor(1,1,1)
        love.graphics.printf('Server frame '..match.serverFrame..' / rendered '..match.renderFrame..' / input ack '..match.lastAckSeq..' / '..match.state,20,686,1200,'left')
        if match.track=='relay' then love.graphics.printf('CASUAL RELAY — client simulation and results are not authoritative. Click an opponent to target.',20,35,1120,'left') end
        if not match:isParticipant() then love.graphics.printf('Spectator: '..(match.catchupTarget and 'bounded replay catch-up' or 'live'),20,62,1120,'left') end
        if match.state=='paused' then
            FONT.set(32)
            love.graphics.printf('PAUSED / '..tostring(match.pauseReason)..' / until '..tostring(match.pauseUntil),80,310,1100,'center')
        elseif NET.recoverUntil then
            FONT.set(32)
            love.graphics.printf('Connection recovery (up to 10 seconds)',80,310,1100,'center')
        end
    elseif textBox.hide then
        NETPLY.draw()
        FONT.set(22)
        love.graphics.setColor(1,1,1)
        love.graphics.printf('Select a member to manage their role, team or host ownership.\nReady freezes your bounded control tuning for the next match.',30,650,800,'left')
        if match.state=='completed' then love.graphics.printf(match.track=='authoritative' and 'Previous match: server-derived result saved.' or 'Previous match: unverified casual result saved.',30,52,1000,'left') end
    end
    if match.countdown then
        FONT.set(60)
        love.graphics.setColor(1,.85,.3)
        love.graphics.printf('Starting in '..math.max(0,math.ceil(match.countdown-love.timer.getTime())),0,260,1280,'center')
    end
    if not textBox.hide then love.graphics.setColor(0,0,0,.5) love.graphics.rectangle('fill',0,75,1280,620) end
end
local function hideLobby() return not lobby() or not textBox.hide end
local function hideHost() return hideLobby() or not host() end
scene.widgetList={
    textBox,inputBox,
    WIDGET.newButton{x=945,y=150,w=250,h=60,font=24,fText='Ready / unready',code=function() local self=member() if self then NET.ready(not self.ready) end end,hideF=hideLobby},
    WIDGET.newButton{x=945,y=225,w=250,h=60,font=24,fText='Player',code=function() setRole('player') end,hideF=hideLobby},
    WIDGET.newButton{x=945,y=300,w=250,h=60,font=24,fText='Spectator',code=function() setRole('spectator') end,hideF=hideLobby},
    WIDGET.newSelector{x=945,y=375,w=250,font=23,fText='Selected team',list={0,1,2,3,4,5,6},disp=function() local selected=NET.roomStore:member(target()) return selected and selected.team or 0 end,code=function(team) NET.roomCommand('room.team',{targetId=target(),team=team}) end,hideF=hideLobby},
    WIDGET.newButton{x=945,y=455,w=250,h=60,font=23,fText='Transfer host',code=function() NET.roomCommand('room.transfer',{targetId=target()}) end,hideF=hideHost},
    WIDGET.newButton{x=945,y=530,w=250,h=60,font=23,fText='Kick selected',color='R',code=function() if tryBack() then NET.roomCommand('room.kick',{targetId=target()}) end end,hideF=hideHost},
    WIDGET.newButton{x=945,y=605,w=250,h=60,font=23,fText='Room settings',code=function() SCN.go('net_newRoom','swipeL','edit') end,hideF=hideHost},
    WIDGET.newButton{x=115,y=45,w=175,h=50,font=22,fText='Start (host)',code=function() NET.roomCommand('match.countdown') end,hideF=hideHost},
    WIDGET.newButton{x=305,y=45,w=175,h=50,font=22,fText='Cancel start',code=function() NET.roomCommand('match.cancel') end,hideF=function() return not host() or not room() or room().phase~='countdown' end},
    WIDGET.newButton{x=500,y=45,w=175,h=50,font=22,fText='Close room',color='R',code=function() if tryBack() then NET.roomCommand('room.close') end end,hideF=hideHost},
    WIDGET.newButton{x=705,y=45,w=170,h=50,font=22,fText='Chat',code=switchChat},
    WIDGET.newButton{x=1050,y=45,w=160,h=50,font=22,fText='Leave room',color='R',code=quit},
    WIDGET.newButton{x=1220,y=135,w=85,h=75,font=40,fText=CHAR.icon.settings,code=settings,hideF=function() return not textBox.hide end},
    WIDGET.newButton{x=1210,y=620,w=105,h=60,font=20,fText='Profile',code=function() if target() then NET.website('/profiles/'..target()) end end,hideF=hideLobby},
}
return scene
