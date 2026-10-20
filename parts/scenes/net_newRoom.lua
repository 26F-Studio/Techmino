local scene={}
local options={track='authoritative',pauseOnDisconnect=true,pauseOnAbsence=true,pauseLimitSeconds=10,spectators=true}
local editing=false
local revision=false
local name=WIDGET.newInputBox{x=40,y=155,w=750,h=60,limit=128}
local password=WIDGET.newInputBox{x=40,y=300,w=750,h=60,secret=true,limit=64}
local function settings()
    return {pauseOnDisconnect=options.pauseOnDisconnect,pauseOnAbsence=options.pauseOnAbsence,pauseLimitSeconds=options.pauseLimitSeconds,spectators=options.spectators}
end
local function submit()
    local roomName=STRING.trim(name:getText())
    if roomName=='' then roomName=USERS.getUsername(USER.uid).."'s room" end
    if editing then
        NET.roomCommand('room.update',{expectedRevision=revision,name=roomName,settings=settings()},function(snapshot,err)
            if not err and NET.roomStore:apply(snapshot) then SCN.back() end
        end)
    else
        NET.createRoom{name=roomName,password=password:getText()~='' and password:getText() or nil,track=options.track,settings=settings()}
    end
end
function scene.enter()
    editing=SCN.args[1]=='edit' and NET.roomStore.snapshot~=false
    if editing then
        local room=NET.roomStore.snapshot
        revision=room.revision
        name:setText(room.name)
        options.track=room.track
        for key,value in pairs(room.settings) do if options[key]~=nil then options[key]=value end end
    else name:setText('') end
    password:clear()
    DiscordRPC.update(editing and 'Editing room settings' or 'Creating an online room')
end
function scene.keyDown(key,rep)
    if rep then return true end
    if key=='escape' then SCN.back() elseif key=='return' or key=='kpenter' then submit() else return true end
end
function scene.draw()
    FONT.set(24)
    love.graphics.setColor(1,1,1)
    love.graphics.printf('Only the complete default source netBattle rules are enabled online.\nAuthoritative matches render trusted server state; relay results are unverified.\nCapacity: 10 players + 20 spectators. Round limit: 15 minutes.',40,590,940,'left')
    if editing then love.graphics.printf('Editing revision '..revision,850,120,350,'left') end
end
scene.widgetList={
    WIDGET.newText{x=40,y=35,align='L',font=50,fText='Room settings'},
    WIDGET.newText{x=40,y=110,align='L',font=28,fText='Room name'},name,
    WIDGET.newText{x=40,y=255,align='L',font=28,fText='Password (empty removes it)'},password,
    WIDGET.newSelector{x=1080,y=165,w=310,font=25,fText='Track',list={'authoritative','relay'},disp=function() return options.track end,code=function(value) options.track=value end,hideF=function() return editing end},
    WIDGET.newButton{x=1080,y=320,w=310,h=95,font=24,fText='Change password',code=function() NET.roomCommand('room.password',{password=password:getText()}) end,hideF=function() return not editing end},
    WIDGET.newSwitch{x=340,y=440,lim=280,font=25,fText='Pause on disconnect',disp=function() return options.pauseOnDisconnect end,code=function() options.pauseOnDisconnect=not options.pauseOnDisconnect end},
    WIDGET.newSwitch{x=730,y=440,lim=280,font=25,fText='Pause on temporary absence',disp=function() return options.pauseOnAbsence end,code=function() options.pauseOnAbsence=not options.pauseOnAbsence end},
    WIDGET.newSwitch{x=340,y=525,lim=280,font=25,fText='Allow spectators',disp=function() return options.spectators end,code=function() options.spectators=not options.spectators end},
    WIDGET.newSelector{x=930,y=520,w=350,font=24,fText='Single pause cap (seconds)',list={5,10,30},disp=function() return options.pauseLimitSeconds end,code=function(value) options.pauseLimitSeconds=value end},
    WIDGET.newButton{x=1080,y=450,w=310,h=110,font=32,fText='Apply / create',code=submit},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
