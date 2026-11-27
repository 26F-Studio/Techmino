local Protocol=require'parts.online.protocol'
local Render={}
local scalarFields={
    'alive','control','timing','result','frameRun','endCounter','curX','curY','ghoY','minY',
    'dropDelay','lockDelay','freshTime','waiting','falling','fieldBeneath','fieldUp','garbageBeneath',
    'holdTime','holdIXSFromNext','pieceCount','combo','b2b','b2b1','dropSpeed','score1',
    'finesseCombo','finesseComboTime','atkBufferSum','atkBufferSum1','spike','spikeTime',
    'strength','badge','life','spinLast','bufferedIRS','bufferedIHS','movDir','moving','downing',
    'ctrlCount','atkMode','swappingAtkMode','keepVisible','showTime',
}
local arrayFields={'clearingRow','clearedRow','keyPressing','frameColor','atkBuffer'}
local recordFields={'swingOffset','lastPiece','stat'}
local environmentExclusions={eventSet=true,RS=true,sequence=true,skinSet=true,task=true,mesDisp=true,extraEvent=true,extraEventHandler=true}
local function finite(value)
    return type(value)=='number' and value==value and value~=math.huge and value~=-math.huge
end
local function dataTree(value,depth,budget)
    if depth>12 then return false end
    budget.count=budget.count+1
    if budget.count>100000 then return false end
    local kind=type(value)
    if kind=='number' then return finite(value) end
    if kind=='string' then return #value<=128 end
    if kind=='boolean' then return true end
    if kind~='table' then return false end
    for key,item in pairs(value) do
        if (type(key)~='string' or #key>64) and (not Protocol.integer(key,1,4096)) then return false end
        if not dataTree(item,depth+1,budget) then return false end
    end
    return true
end
local function validPiece(piece)
    if piece==false then return true end
    if type(piece)~='table' or not Protocol.integer(piece.id,1,29) or not Protocol.integer(piece.dir,0,3) or not Protocol.integer(piece.color,1,29) or piece.rs~='TRS' or type(piece.bk)~='table' or #piece.bk<1 or #piece.bk>5 then return false end
    local width=type(piece.bk[1])=='table' and #piece.bk[1] or 0
    if width<1 or width>5 then return false end
    for _,row in ipairs(piece.bk) do
        if type(row)~='table' or #row~=width then return false end
        for _,cell in ipairs(row) do if type(cell)~='boolean' then return false end end
    end
    return true
end
local function hydratePiece(piece)
    if not piece then return false end
    piece.RS=RSlist.TRS
    piece.sc=RSlist.TRS.centerPos[piece.id][piece.dir]
    return piece
end
function Render.validate(snapshot,match)
    if type(snapshot)~='table' or snapshot.schemaVersion~=1 or snapshot.matchId~=match.id or snapshot.seed~=match.seed or snapshot.rulesetVersion~=match.rulesetVersion or not Protocol.integer(snapshot.frame,0,54000) or snapshot.readyFrames~=180 or type(snapshot.players)~='table' or #snapshot.players~=#match.participants then return false end
    for index,player in ipairs(snapshot.players) do
        local member=match.participants[index]
        local state=type(player)=='table' and player.state
        if not state or player.accountId~=member.accountId or player.slot~=member.slot or player.team~=member.team or not dataTree(state,0,{count=0}) or type(state.field)~='table' or #state.field>512 or type(state.visTime)~='table' or #state.visTime~=#state.field or type(state.fieldGarbage)~='table' or #state.fieldGarbage~=#state.field or not validPiece(state.cur) or type(state.nextQueue)~='table' or #state.nextQueue>16 or type(state.holdQueue)~='table' or #state.holdQueue>6 or type(state.stat)~='table' or type(state.swingOffset)~='table' or type(state.lastPiece)~='table' or type(state.gameEnv)~='table' or type(state.alive)~='boolean' then return false end
        for rowIndex,row in ipairs(state.field) do
            if type(row)~='table' or #row~=10 or type(state.visTime[rowIndex])~='table' or #state.visTime[rowIndex]~=10 or type(state.fieldGarbage[rowIndex])~='boolean' then return false end
            for column=1,10 do
                if not Protocol.integer(row[column],0,29) or not finite(state.visTime[rowIndex][column]) then return false end
            end
        end
        for _,piece in ipairs(state.nextQueue) do if not validPiece(piece) or piece==false then return false end end
        for _,piece in ipairs(state.holdQueue) do if not validPiece(piece) or piece==false then return false end end
        for _,key in ipairs(arrayFields) do if type(state[key])~='table' then return false end end
    end
    return true
end
function Render.create(match)
    local setting=GAME.setting
    for _,member in ipairs(match.participants) do
        GAME.setting=TABLE.copy(setting)
        for key,value in pairs(member.tuning) do GAME.setting[key]=value end
        GAME.setting.RS='TRS'
        GAME.setting.face={0,0,0,0,0,0,0}
        PLY.newPlayer(member.slot,false,{uid=member.accountId,group=member.team})
        local P=PLAYERS[member.slot]
        P.uid=member.accountId
        P.sid=member.slot
        P.username=member.name
        P.type=match.track=='authoritative' and 'snapshot' or 'relay'
        P.sound=member.accountId==USER.uid and match.track=='relay'
        if match.track=='authoritative' then
            P.tasks={}
            P.control=false
            P.timing=false
        else
            P:startStreaming()
            -- Original recording grammar is retained, but accepted keys and attacks
            -- are applied to every local source player. These results are unverified.
            P.extraEvent=function(source,name,...)
                local handler=source.gameEnv.extraEventHandler[name]
                if not handler then return end
                for _,target in ipairs(PLAYERS) do handler(target,source,...) end
                if match:isParticipant() then
                    local eventId
                    for id,event in ipairs(source.gameEnv.extraEvent) do if event[1]==name then eventId=id break end end
                    if eventId then
                        local own=match.byAccount[USER.uid]
                        local values={own and own.frameRun or match.renderFrame,64+eventId,source.sid,...}
                        for _,value in ipairs(values) do GAME.rep[#GAME.rep+1]=value end
                    end
                end
            end
        end
        match.byAccount[member.accountId]=P
        match.bySlot[member.slot]=P
    end
    GAME.setting=setting
end
function Render.apply(snapshot,match)
    if not Render.validate(snapshot,match) then return false end
    for _,player in ipairs(snapshot.players) do
        local P=match.byAccount[player.accountId]
        local state=player.state
        for _,key in ipairs(scalarFields) do if state[key]~=nil then P[key]=state[key] end end
        for _,key in ipairs(arrayFields) do P[key]=state[key] end
        for _,key in ipairs(recordFields) do P[key]=state[key] end
        P.field=state.field
        P.visTime=state.visTime
        for index,row in ipairs(P.field) do row.garbage=state.fieldGarbage[index] end
        P.cur=hydratePiece(state.cur)
        P.nextQueue=state.nextQueue
        P.holdQueue=state.holdQueue
        for _,piece in ipairs(P.nextQueue) do hydratePiece(piece) end
        for _,piece in ipairs(P.holdQueue) do hydratePiece(piece) end
        for key,value in pairs(state.gameEnv) do
            if not environmentExclusions[key] and key:sub(1,5)~='hook_' and P.gameEnv[key]~=nil and (type(value)~='table' or key=='face' or key=='skin') then P.gameEnv[key]=value end
        end
        P.gameEnv.mesDisp={}
        P.skinLib=SKIN.lib[P.gameEnv.skinSet]
        P.tasks={}
        P.bonus={}
        P.dropFX,P.moveFX,P.lockFX,P.clearFX={},{},{},{}
        P.newNext=false
        P.authorityRank=player.rank
        P.authorityForfeited=player.forfeited
    end
    TABLE.clear(PLY_ALIVE)
    for _,P in ipairs(PLAYERS) do if P.alive then PLY_ALIVE[#PLY_ALIVE+1]=P end end
    match.renderFrame=snapshot.frame
    match.snapshot=snapshot
    return true
end
return Render
