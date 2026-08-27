local scene={}

local CARD=require'parts.userCard'
local AUTH=require'parts.authModal'
local LOBBY=require'parts.lobbyPanel'

local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local setFont=FONT.set

local R=false

local function _fmtDelta(d)
    if d>0 then return "+"..d end
    return tostring(d)
end
local function _name(uid)
    if uid==USER.uid then return "You" end
    local n=USERS.getUsername(uid)
    return n and #n>0 and n or "Player"
end

function scene.enter()
    CARD.reset()
    CARD.enter()
    BG.set()
    R=NET.rankedResult or false
    DiscordRPC.update("Ranked Results")
end

function scene.leave()
    CARD.leave()
    AUTH.close()
    -- Drop the match summary so a future visit (e.g. via back-navigation)
    -- never re-displays a previous match's results.
    NET.rankedResult=false
end

function scene.keyDown(key,rep)
    if AUTH.isOpen() and AUTH.keyDown(key,rep) then return true end
    if LOBBY.keyDown(key) then return true end
    if key=='escape' and not rep then
        if LOBBY.isAnyOpen() then
            if LOBBY.chat and LOBBY.chat.visible then LOBBY.chat:toggle() end
            if LOBBY.playerList and LOBBY.playerList.visible then LOBBY.playerList:toggle() end
        else
            SCN.go('net_ranked')
        end
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
    local won=R and R.winnerId==USER.uid

    -- Title
    setFont(60)
    gc_setColor(won and COLOR.lG or COLOR.lR)
    gc_printf(won and "Victory!" or "Defeat",0,70,1280,'center')

    setFont(22)
    gc_setColor(COLOR.lH)
    gc_printf("Ranked 1v1",0,150,1280,'center')

    if not R then
        setFont(25)
        gc_setColor(COLOR.Z)
        gc_printf("No match data",0,300,1280,'center')
        return
    end

    -- Winner
    setFont(30)
    gc_setColor(won and COLOR.lG or COLOR.lR)
    gc_printf("Winner: ".._name(R.winnerId),0,200,1280,'center')

    -- Player panels
    local function _panel(x,name,oldE,newE,delta,rank,isYou)
        -- Box
        gc_setColor(.12,.12,.12,.9)
        gc_rectangle('fill',x,280,400,300,8)
        gc_setColor(1,1,1)
        gc_setLineWidth(2)
        gc_rectangle('line',x,280,400,300,8)

        setFont(26)
        gc_setColor(isYou and COLOR.lY or COLOR.lH)
        gc_printf(name,x,300,400,'center')

        setFont(18)
        gc_setColor(COLOR.lN)
        gc_printf("Rating",x,360,400,'center')

        setFont(40)
        gc_setColor(COLOR.Z)
        gc_printf(oldE.."  →  "..newE,x,390,400,'center')

        setFont(28)
        gc_setColor(delta>=0 and COLOR.lG or COLOR.lR)
        gc_printf(_fmtDelta(delta).." ELO",x,450,400,'center')

        setFont(18)
        gc_setColor(COLOR.lN)
        gc_printf("Global rank #"..(rank>0 and rank or "—"),x,510,400,'center')
    end
    _panel(240,"You",R.myOld,R.myNew,R.myDelta,R.myRank,true)
    _panel(640,_name(R.oppId),R.oppOld,R.oppNew,R.oppDelta,R.oppRank,false)
end

function scene.overDraw()
    LOBBY.draw()
    LOBBY.drawToggleButtons()
    CARD.draw()
    AUTH.draw()
end

scene.widgetList={
    WIDGET.newKey{name='watch',   x=640,y=520,w=360,h=90,font=35,color='lB',
        code=function() NET.watchRankedReplay() end},
    WIDGET.newKey{name='rematch', x=480,y=620,w=320,h=90,font=35,color='lG',
        code=function() SCN.go('net_ranked') end},
    WIDGET.newButton{name='back',    x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
