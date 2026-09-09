local scene={}

local CARD=require'parts.userCard'
local AUTH=require'parts.authModal'
local LOBBY=require'parts.lobbyPanel'

local gc=love.graphics
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf

local matchmaking=false
local searchTimer=0

local function _startMatchmaking()
    if not USER.uid then
        MES.new('error',text.serverDown)
        return
    end
    matchmaking=true
    searchTimer=0
    NET.ranked_join()
end

local function _cancelMatchmaking()
    matchmaking=false
    searchTimer=0
    NET.ranked_leave()
end

function scene.enter()
    CARD.reset()
    CARD.enter()
    BG.set()
    matchmaking=false
    searchTimer=0
    DiscordRPC.update("Ranked Lobby")
end

function scene.leave()
    CARD.leave()
    AUTH.close()
    if matchmaking then
        NET.ranked_leave()
        matchmaking=false
    end
end

function scene.keyDown(key,rep)
    if AUTH.isOpen() and AUTH.keyDown(key,rep) then return true end
    if LOBBY.keyDown(key) then return true end
    if key=='escape' and not rep then
        if LOBBY.isAnyOpen() then
            if LOBBY.chat and LOBBY.chat.visible then LOBBY.chat:toggle() end
            if LOBBY.playerList and LOBBY.playerList.visible then LOBBY.playerList:toggle() end
        elseif NET.matchFoundPending and NET.matchFoundCountdown>0 then
            NET.matchFoundPending=false
            NET.matchFoundCountdown=0
            NET.matchFoundSeed=nil
            NET.ranked_leave()
            matchmaking=false
            searchTimer=0
        elseif matchmaking then
            _cancelMatchmaking()
        else
            SCN.go('lobby')
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
    if matchmaking then
        searchTimer=searchTimer+dt
    end
    if NET.matchFoundPending and NET.matchFoundCountdown>0 then
        NET.updateMatchFoundCountdown(dt)
    end
end

function scene.draw()
    if NET.matchFoundPending and NET.matchFoundCountdown>0 then
        gc_setColor(0,0,0,.7)
        gc_rectangle('fill',0,0,1280,720)
        setFont(50)
        gc_setColor(COLOR.lG)
        gc_printf(text.matchFound or "Match Found!",0,180,1280,'center')

        local oppName="???"
        if NET.matchFoundOppId then
            oppName=USERS.getUsername(NET.matchFoundOppId) or "Player"
        end
        local myElo=STAT.elo or 1200
        local oppElo=1200
        for i=1,#NET.onlinePlayers do
            if NET.onlinePlayers[i].id==NET.matchFoundOppId then
                oppElo=NET.onlinePlayers[i].elo or 1200
                break
            end
        end

        setFont(30)
        gc_setColor(COLOR.Z)
        gc_printf("You  ("..myElo..")",0,280,1280,'center')
        gc_printf(text.matchFoundVS or "VS",0,330,1280,'center')
        gc_setColor(COLOR.lR)
        gc_printf(oppName.."  ("..oppElo..")",0,380,1280,'center')

        setFont(35)
        gc_setColor(COLOR.lY)
        local cd=math.ceil(NET.matchFoundCountdown)
        gc_printf((text.matchFoundStarting or "Starting in %ds"):format(cd),0,480,1280,'center')
        return
    end

    -- Title
    setFont(50)
    gc_setColor(COLOR.Z)
    gc_print(text.rankedMode or "Ranked Mode",60,40)

    -- Match info panel
    gc_translate(400,150)
        gc_setColor(.12,.12,.12,.9)
        gc_rectangle('fill',0,0,480,300,8)
        gc_setColor(1,1,1)
        gc_setLineWidth(2)
        gc_rectangle('line',0,0,480,300,8)

        setFont(30)
        gc_setColor(COLOR.lY)
        gc_printf("1v1",0,15,480,'center')

        setFont(20)
        gc_setColor(COLOR.lH)
        if matchmaking then
            local dots=string.rep('.',math.floor(searchTimer*2)%4)
            gc_printf("Searching for opponent"..dots,0,80,480,'center')
            gc_printf(("Search time: %.1fs"):format(searchTimer),0,120,480,'center')
        else
            gc_printf("Find a matched opponent",0,80,480,'center')
            gc_printf("based on your rating",0,110,480,'center')
        end

        -- Stats
        setFont(18)
        gc_setColor(COLOR.lN)
        local elo = (USER.uid and STAT.elo) or 1200
        gc_printf(text.elo.." "..elo,20,180,200,'left')
        local rank = (USER.uid and STAT.globalRank) or 0
        local rankStr = rank > 0 and ("#"..rank) or "Unranked"
        gc_printf(text.globalRank.." "..rankStr,20,210,200,'left')
    gc_translate(-400,-150)
end

function scene.overDraw()
    LOBBY.draw()
    LOBBY.drawToggleButtons()
    CARD.draw()
    AUTH.draw()
end

scene.widgetList={
    WIDGET.newKey{name='match',      x=640,y=520,w=360,h=90,font=38,color='lG',
        code=function()
            if matchmaking then
                _cancelMatchmaking()
            else
                _startMatchmaking()
            end
        end,
        hideF=function() return not USER.uid end},
    WIDGET.newButton{name='back',    x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
