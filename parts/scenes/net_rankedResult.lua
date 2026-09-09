local scene={}

local CARD=require'parts.userCard'
local AUTH=require'parts.authModal'
local LOBBY=require'parts.lobbyPanel'

local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local setFont=FONT.set
local mStr=GC.mStr

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

    setFont(52)
    gc_setColor(won and COLOR.lG or COLOR.lR)
    mStr(won and "Victory!" or "Defeat",640,60)

    setFont(22)
    gc_setColor(COLOR.lH)
    gc_printf("Ranked 1v1",0,120,1280,'center')

    if not R then
        setFont(25)
        gc_setColor(COLOR.Z)
        gc_printf("No match data",0,320,1280,'center')
        return
    end

    local PANEL_W=380
    local PANEL_H=240
    local PANEL_Y=200
    local GAP=40
    local leftX=640-PANEL_W-GAP/2
    local rightX=640+GAP/2

    local function _panel(x,name,oldE,newE,delta,rank,isYou)
        gc_setColor(.12,.12,.12,.9)
        gc_rectangle('fill',x,PANEL_Y,PANEL_W,PANEL_H,8)
        gc_setColor(1,1,1)
        gc_setLineWidth(2)
        gc_rectangle('line',x,PANEL_Y,PANEL_W,PANEL_H,8)

        setFont(24)
        gc_setColor(isYou and COLOR.lY or COLOR.lH)
        gc_printf(name,x,PANEL_Y+18,PANEL_W,'center')

        setFont(16)
        gc_setColor(COLOR.lN)
        gc_printf("Rating",x,PANEL_Y+58,PANEL_W,'center')

        setFont(34)
        gc_setColor(COLOR.Z)
        gc_printf(oldE.."  ->  "..newE,x,PANEL_Y+88,PANEL_W,'center')

        setFont(26)
        gc_setColor(delta>=0 and COLOR.lG or COLOR.lR)
        gc_printf(_fmtDelta(delta).." ELO",x,PANEL_Y+135,PANEL_W,'center')

        setFont(16)
        gc_setColor(COLOR.lN)
        local rankStr=rank>0 and ("#"..rank) or "Unranked"
        gc_printf("Global Rank "..rankStr,x,PANEL_Y+185,PANEL_W,'center')
    end
    _panel(leftX,"You",R.myOld,R.myNew,R.myDelta,R.myRank,true)
    _panel(rightX,_name(R.oppId),R.oppOld,R.oppNew,R.oppDelta,R.oppRank,false)
end

function scene.overDraw()
    LOBBY.draw()
    LOBBY.drawToggleButtons()
    CARD.draw()
    AUTH.draw()
end

scene.widgetList={
    WIDGET.newKey{name='watch',   x=470,y=520,w=340,h=80,font=34,color='lB',
        code=function() NET.watchRankedReplay() end},
    WIDGET.newKey{name='rematch', x=490,y=620,w=300,h=80,font=34,color='lG',
        code=function() SCN.go('net_ranked') end},
    WIDGET.newButton{name='back',    x=1080,y=620,w=180,h=80,sound='back',font=55,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
