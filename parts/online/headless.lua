-- Trusted default-netBattle host. This file contains lifecycle/extraction code,
-- not a second rule implementation. Player, TRS, bag, attacks and marginTask
-- are executed from the canonical source modules in an isolated LuaJIT state.
local Headless={}

local scalarFields={
    'alive','control','timing','result','frameRun','endCounter',
    'curX','curY','ghoY','minY','dropDelay','lockDelay','freshTime',
    'waiting','falling','fieldBeneath','fieldUp','garbageBeneath',
    'holdTime','holdIXSFromNext','pieceCount','combo','b2b','b2b1',
    'dropSpeed','score1','finesseCombo','finesseComboTime',
    'atkBufferSum','atkBufferSum1','spike','spikeTime','strength','badge','life',
    'spinLast','bufferedIRS','bufferedIHS','bufferedDelay','movDir','moving','downing',
    'ctrlCount','atkMode','swappingAtkMode','keepVisible','showTime',
}
local arrayFields={'clearingRow','clearedRow','keyPressing','frameColor'}
local recordFields={'swingOffset','lastPiece','stat'}
local environmentExclusions={task=true,mesDisp=true,extraEventHandler=true}

function Headless.new(spec,host)
    assert(not TECHMINO_HEADLESS,'A headless VM can host only one match')
    assert(type(host.newRandomGenerator)=='function','A real LÖVE-compatible RNG is required')
    TECHMINO_HEADLESS=true
    local arrayMeta=host.arrayMetatable
    local function array(t) return arrayMeta and setmetatable(t,arrayMeta) or t end
    local function listCopy(t)
        local out=array({})
        for i=1,#t do
            if type(t[i])=='table' then out[i]=listCopy(t[i]) else out[i]=t[i] end
        end
        return out
    end
    local function recordCopy(t)
        local out={}
        for k,v in next,t do
            local kind=type(v)
            assert(kind~='function' and kind~='thread' and kind~='userdata','Non-render state cannot be serialized')
            if kind=='table' then
                out[k]=#v>0 and listCopy(v) or recordCopy(v)
            else
                assert(kind~='number' or v==v and v~=math.huge and v~=-math.huge,'Nonfinite source state')
                out[k]=v
            end
        end
        return out
    end

    -- These are exclusively presentation services. Coroutine Player.tasks,
    -- gravity, garbage pushing and the source speed/score calculation remain live.
    local function silent() end
    love={math={newRandomGenerator=host.newRandomGenerator},filesystem={read=host.sourceRead},data={}}
    GC={DO=function() return false end}
    SFX={play=silent}
    BGM={play=silent}
    VOC={play=silent,getFreeChannel=silent}
    VIB=silent
    SYSFX={newCell=silent,newAttack=silent}
    TEXT={update=function(_,texts) assert(#texts==0,'Presentation text escaped the headless boundary') end}
    TASK={}
    MES={new=function(_,message) error(message) end}
    SYSTEM='Headless'
    VERSION=require'version'
    TABLE=require'Zframework.tableExtend'
    MATH=require'Zframework.mathExtend'
    STRING=require'Zframework.stringExtend'
    for k,v in next,STRING do
        if type(v)=='function' and string[k]==nil then string[k]=v end
    end
    COLOR=require'Zframework.color'
    CHAR=require'parts.char'
    require'parts.gameTables'
    LINE=require'parts.line'
    RSlist=require'parts.RSlist'
    text=require'parts.language.lang_en'
    text.block=BLOCK_NAMES
    SKIN={lib={['Crystal (Scf)']={}}}
    require'parts.gameFuncs'
    PLY=require'parts.player.init'

    GAME.authority=true
    GAME.net=true
    GAME.playing=true
    GAME.frameStart=0
    GAME.seed=spec.seed
    GAME.setting={}
    GAME.recording=false
    NET={slotByAccount={},spectate=true,roomState={data=TABLE.copy(ROOMENV)}}
    NET.slotForAccount=function(accountId) return NET.slotByAccount[accountId] end
    NETPLY={list={}}
    USER.uid=false
    local match={frame=0,byAccount={},attacks=array({})}
    for i,p in ipairs(spec.roster) do
        assert(p.slot==i,'Authority roster slots must be contiguous and ordered')
        NETPLY.list[i]={uid=p.slot,group=p.team,config=p.tuning,playMode='Gamer'}
    end
    local mode=require'parts.modes.netBattle'
    GAME.curMode={name='netBattle'}
    GAME.modeEnv=TABLE.copy(mode.env)
    -- Disabling splash also isolates gameplay's LuaJIT target RNG from viewer
    -- cosmetics. netBattle.load still performs its source seed and roster shuffle.
    for _,k in ipairs{'lockFX','dropFX','moveFX','clearFX','splashFX','shakeFX','atkFX','text','score','showSpike'} do
        GAME.modeEnv[k]=false
    end
    playReadySFX=silent
    mode.load()
    assert(#PLAYERS==#spec.roster,'Source mode did not create the frozen roster')
    GAME.initPlayerCount=#PLAYERS
    for i,P in ipairs(PLAYERS) do
        local p=spec.roster[i]
        assert(P.sid==p.slot and P.type=='authority','Source participant identity mismatch')
        P:setPosition(0,0,1)
        -- The source initializer pre-fills only twelve held keys. Canonical
        -- extended actions are bindable too; filling their false tail prevents
        -- sparse Lua arrays from corrupting the trusted render representation.
        for action=13,20 do P.keyPressing[action]=false end
        match.byAccount[p.accountId]=P
        P.accountId=p.accountId
        P.authorityForfeited=false
        P.authorityTerminalFrame=false
        P.authorityRank=false
    end
    GAME.authorityEvent=function(name,source,target,amount,countdown,line,seenCount)
        assert(name=='attack','Unsupported authoritative event')
        assert(#match.attacks<640,'Authority frame attack budget exceeded')
        match.attacks[#match.attacks+1]={sourceSlot=source.sid,targetSlot=target,amount=amount,countdown=countdown,line=line,seenCount=seenCount}
    end

    local function captureTerminals()
        for _,P in ipairs(PLAYERS) do
            if P.result and P.authorityTerminalFrame==false then
                P.authorityTerminalFrame=match.frame
                P.authorityRank=P.result=='win' and 1 or #PLY_ALIVE+1
            end
        end
    end
    local function checkBounds()
        for _,P in ipairs(PLAYERS) do
            -- These are explicit resource aborts, not replacement topout/buffer
            -- rules. Never truncate a legal field or silently drop an attack.
            assert(#P.field<=512 and #P.visTime<=512,'Authority field budget exceeded')
            assert(#P.atkBuffer<=2048 and P.atkBufferSum<=4096,'Authority garbage budget exceeded')
            assert(#P.tasks<=8,'Authority coroutine budget exceeded')
            if P.inTransitAttacks then
                for _,attacks in next,P.inTransitAttacks do
                    assert(#attacks<=4096,'Authority attack journal budget exceeded')
                end
            end
        end
    end
    function match.step(inputs)
        match.frame=match.frame+1
        TABLE.clear(match.attacks)
        -- Across participants, order is frozen slot order, never socket arrival
        -- order. Events within each participant preserve their accepted sequence.
        for slot,P in ipairs(PLAYERS) do
            for i=1,#inputs,3 do
                if inputs[i]==slot and not P.result then
                    if inputs[i+1]==1 then P:pressKey(inputs[i+2])
                    else P:releaseKey(inputs[i+2]) end
                    captureTerminals()
                    checkBounds()
                end
            end
        end
        for _,P in ipairs(PLAYERS) do
            if P.alive then
                P:update(1/60)
                captureTerminals()
                checkBounds()
            end
        end
        -- No client recording, rendering task, or replay FX may accumulate here.
        TABLE.clear(GAME.rep)
    end
    function match.forfeit(accountId)
        local P=assert(match.byAccount[accountId],'Unknown frozen participant')
        if not P.result then
            P.authorityForfeited=true
            P:lose(true)
            captureTerminals()
            checkBounds()
            TABLE.clear(GAME.rep)
        end
    end
    function match.ended()
        local out=array({})
        for _,P in ipairs(PLAYERS) do if P.result then out[#out+1]=P.accountId end end
        return out
    end
    function match.standings()
        local out=array({})
        for _,P in ipairs(PLAYERS) do
            out[#out+1]={accountId=P.accountId,slot=P.sid,team=P.group,rank=P.authorityRank,result=P.result,
                forfeited=P.authorityForfeited,terminalFrame=P.authorityTerminalFrame,stats=recordCopy(P.stat)}
        end
        table.sort(out,function(a,b)
            if a.rank~=b.rank then
                if a.rank==false then return true end
                if b.rank==false then return false end
                return a.rank<b.rank
            end
            return a.slot<b.slot
        end)
        return out
    end
    function match.outcome()
        local winners=array({})
        for _,P in ipairs(PLAYERS) do
            if not P.result then return false end
            if P.result=='win' then winners[#winners+1]=P.sid end
        end
        return {winnerSlots=winners,standings=match.standings()}
    end
    local function pieceCopy(C)
        if not C then return false end
        return {id=C.id,dir=C.dir,name=C.name,color=C.color,bagLine=C.bagLine or 0,
            spinSeq=C.spinSeq or false,bk=listCopy(C.bk),rs=C.RS.name}
    end
    local function piecesCopy(queue)
        local out=array({})
        for i,C in ipairs(queue) do out[i]=pieceCopy(C) end
        return out
    end
    function match.snapshot()
        local players=array({})
        for i,P in ipairs(PLAYERS) do
            local state={field=array({}),fieldGarbage=array({}),visTime=listCopy(P.visTime),cur=pieceCopy(P.cur),
                nextQueue=piecesCopy(P.nextQueue),holdQueue=piecesCopy(P.holdQueue),atkBuffer=array({}),gameEnv={mesDisp=array({})},
                lockFX=array({}),dropFX=array({}),moveFX=array({}),clearFX=array({}),bonus=array({}),
                lastRecvSlot=P.lastRecv and P.lastRecv.sid or false,atkingSlot=P.atking and P.atking.sid or false}
            for y,row in ipairs(P.field) do
                state.field[y]=listCopy(row)
                state.fieldGarbage[y]=row.garbage==true
            end
            for _,k in ipairs(scalarFields) do
                local value=P[k]
                assert(type(value)~='number' or value==value and value~=math.huge and value~=-math.huge,'Nonfinite source state')
                if value==nil then state[k]=false
                elseif type(value)=='table' then state[k]=listCopy(value)
                else state[k]=value end
            end
            for _,k in ipairs(arrayFields) do state[k]=listCopy(P[k]) end
            for _,k in ipairs(recordFields) do state[k]=recordCopy(P[k]) end
            for j,A in ipairs(P.atkBuffer) do state.atkBuffer[j]=recordCopy(A) end
            for k,v in next,P.gameEnv do
                if not environmentExclusions[k] and k:sub(1,5)~='hook_' then
                    if type(v)=='table' then state.gameEnv[k]=listCopy(v)
                    elseif type(v)~='function' then state.gameEnv[k]=v end
                end
            end
            players[i]={accountId=P.accountId,slot=P.sid,team=P.group,tuning=recordCopy(spec.roster[i].tuning),
                forfeited=P.authorityForfeited,terminalFrame=P.authorityTerminalFrame,rank=P.authorityRank,state=state}
        end
        local attacks=array({})
        for i,A in ipairs(match.attacks) do attacks[i]=recordCopy(A) end
        return {schemaVersion=1,matchId=spec.matchId,seed=spec.seed,rulesetVersion=spec.rulesetVersion,
            readyFrames=180,frame=match.frame,players=players,attacks=attacks,outcome=match.outcome()}
    end
    checkBounds()
    return match
end

return Headless
