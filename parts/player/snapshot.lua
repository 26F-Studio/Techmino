-- snapshot.lua — Player state snapshot/restore for rollback netcode
-- (plan_rollback.md Component 3, §3.1).
--
-- The authoritative sim server (Teblocks-GameServer) drives both players'
-- Tetris from the shared seed + committed input stream. Each client predicts
-- locally (zero perceived input lag) and reconciles to the server's snapshots
-- by restoring its nearest confirmed-frame snapshot and re-simulating forward
-- with the now-confirmed inputs. This file implements the per-player half of
-- that loop: capturing and restoring the rollback-relevant state.
--
-- Field list is derived from plan_rollback.md §"Snapshot fields" plus
-- parts/player/dump_state.lua (which the golden test harness already proved
-- captures everything a sim fork needs to be replayed byte-for-byte).
--
-- The seqGen coroutine (P.newNext) is *not* snapshotted directly: it is
-- rebuilt on restore from gameEnv.sequence using the restored seqRND state.
-- seqGenerators are pure functions of RNG draws, so the RNG state alone is
-- sufficient to reproduce the sequence. This avoids deep-coroutine plumbing.

local M={}

local function _copyTable(t)
    if type(t)~='table' then return t end
    return TABLE.copy(t)
end

local function _snapField(field)
    -- field is a list-of-lists [y][x]; snapshot as rows of ints.
    local rows={}
    for y=1,#field do
        local r=field[y]
        local out={}
        for x=1,#r do out[x]=r[x] or 0 end
        rows[y]=out
    end
    return rows
end

local function _restoreField(field, rows)
    for y=1,#rows do
        local r=rows[y]
        local dst=field[y]
        if not dst then
            dst={}
            field[y]=dst
        end
        for x=1,#r do dst[x]=r[x] end
    end
    -- If the live field is taller than the snapshot (e.g. garbageRise happened
    -- after this snapshot), trim the surplus rows.
    for y=#rows+1,#field do field[y]=nil end
end

local function _snapRNG(P)
    return {
        seqRND=P.seqRND and P.seqRND:getState(),
        atkRND=P.atkRND and P.atkRND:getState(),
        holeRND=P.holeRND and P.holeRND:getState(),
        aiRND=P.aiRND and P.aiRND:getState(),
    }
end

local function _restoreRNG(P, rng)
    if rng.seqRND and P.seqRND then P.seqRND:setState(rng.seqRND) end
    if rng.atkRND and P.atkRND then P.atkRND:setState(rng.atkRND) end
    if rng.holeRND and P.holeRND then P.holeRND:setState(rng.holeRND) end
    if rng.aiRND and P.aiRND then P.aiRND:setState(rng.aiRND) end
end

local function _snapStat(stat)
    if not stat then return nil end
    local function cpArr(a,n)
        local o={}
        for i=1,n do o[i]=a and a[i] or 0 end
        return o
    end
    return {
        frame=stat.frame, time=stat.time, score=stat.score,
        piece=stat.piece, row=stat.row, dig=stat.dig,
        atk=stat.atk, digatk=stat.digatk,
        send=stat.send, recv=stat.recv, pend=stat.pend, off=stat.off,
        key=stat.key, rotate=stat.rotate, hold=stat.hold,
        extraPiece=stat.extraPiece, finesseRate=stat.finesseRate,
        pc=stat.pc, hpc=stat.hpc, b2b=stat.b2b, b3b=stat.b3b,
        maxCombo=stat.maxCombo, maxFinesseCombo=stat.maxFinesseCombo,
        clear=cpArr(stat.clear,29),
        clears=cpArr(stat.clears,29),
        spin=cpArr(stat.spin,29),
        spins=cpArr(stat.spins,29),
        combo=stat.combo,
        finesseCombo=stat.finesseCombo,
        finesseComboTime=stat.finesseComboTime,
        regame=stat.regame, win=stat.win,
    }
end

local function _restoreStat(stat, s)
    if not s then return end
    for k,v in next,s do stat[k]=v end
end

-- M.snapshot(P) — capture every field that diverges between two clients
-- running the same input stream from the same seed. Cosmetic state
-- (swingOffset/shakeTimer, x/y/size, dropFX/moveFX/lockFX/clearFX, tasks,
-- bonus, draw canvas, skin, B2B display value) is excluded — it is regenerated
-- from sim state by the existing render path.
function M.snapshot(P)
    local C=P.cur
    return {
        -- timeline
        frameRun=P.frameRun,
        trigFrame=P.trigFrame,
        -- board + visible pieces
        field=_snapField(P.field),
        visTime=_copyTable(P.visTime),
        garbageBeneath=P.garbageBeneath,
        fieldBeneath=P.fieldBeneath,
        fieldUp=P.fieldUp,
        -- active piece
        curX=P.curX, curY=P.curY, ghoY=P.ghoY, minY=P.minY,
        cur=C and _copyTable(C) or nil,
        dropDelay=P.dropDelay, lockDelay=P.lockDelay,
        waiting=P.waiting, falling=P.falling,
        freshTime=P.freshTime, spinLast=P.spinLast,
        ctrlCount=P.ctrlCount,
        movDir=P.movDir, moving=P.moving, downing=P.downing,
        -- queues
        nextQueue=_copyTable(P.nextQueue),
        holdQueue=_copyTable(P.holdQueue),
        holdTime=P.holdTime,
        holdIXSFromNext=P.holdIXSFromNext,
        pieceCount=P.pieceCount,
        -- RNGs
        rng=_snapRNG(P),
        -- attack/garbage
        atkBuffer=_copyTable(P.atkBuffer),
        atkBufferSum=P.atkBufferSum,
        atkBufferSum1=P.atkBufferSum1,
        inTransitAttacks=_copyTable(P.inTransitAttacks),
        lastRecv=P.lastRecv,
        -- scoring
        stat=_snapStat(P.stat),
        combo=P.combo,
        b2b=P.b2b,
        finesseCombo=P.finesseCombo,
        finesseComboTime=P.finesseComboTime,
        lastPiece=_copyTable(P.lastPiece),
        -- input buffers
        keyPressing=_copyTable(P.keyPressing),
        bufferedIRS=P.bufferedIRS,
        bufferedIHS=P.bufferedIHS,
        bufferedIMS=P.bufferedIMS,
        bufferedDelay=P.bufferedDelay,
        -- stream
        stream=_copyTable(P.stream),
        streamProgress=P.streamProgress,
        -- status
        alive=P.alive,
        control=P.control,
        timing=P.timing,
        life=P.life,
        result=P.result,
        clearingRow=_copyTable(P.clearingRow),
        clearedRow=_copyTable(P.clearedRow),
        dropTime=_copyTable(P.dropTime),
        -- mode-private bag (default-metatable: zero-on-read; fine to shallow copy)
        modeData=P.modeData,
    }
end

-- M.restore(P, s) — inverse of snapshot. Rebuilds the seqGen coroutine from
-- gameEnv.sequence so the piece sequence stays in sync with the restored
-- seqRND state. The seqGen is *not* snapshotted itself: seqGenerators are
-- pure functions of RNG draws, so the RNG state alone is enough to reproduce
-- the sequence.
function M.restore(P, s)
    if not s then return end
    P.frameRun=s.frameRun
    P.trigFrame=s.trigFrame
    _restoreField(P.field, s.field)
    P.visTime=s.visTime or {}
    P.garbageBeneath=s.garbageBeneath
    P.fieldBeneath=s.fieldBeneath
    P.fieldUp=s.fieldUp

    P.curX=s.curX; P.curY=s.curY
    P.ghoY=s.ghoY; P.minY=s.minY
    P.cur=s.cur and TABLE.copy(s.cur) or nil
    P.dropDelay=s.dropDelay
    P.lockDelay=s.lockDelay
    P.waiting=s.waiting
    P.falling=s.falling
    P.freshTime=s.freshTime
    P.spinLast=s.spinLast
    P.ctrlCount=s.ctrlCount
    P.movDir=s.movDir
    P.moving=s.moving
    P.downing=s.downing

    P.nextQueue=s.nextQueue or {}
    P.holdQueue=s.holdQueue or {}
    P.holdTime=s.holdTime
    P.holdIXSFromNext=s.holdIXSFromNext
    P.pieceCount=s.pieceCount

    _restoreRNG(P, s.rng or {})
    -- Rebuild the seqGen coroutine from the restored seqRND. The first
    -- resume passes (seqRND, seqData); subsequent resumes pass (field, stat)
    -- matching parts/player/init.lua:366-372.
    if P.seqGen and P.gameEnv and P.gameEnv.sequence then
        local getSeqGen=require'parts.player.seqGenerators'
        local seqCalled=false
        local initSZOcount=0
        local bagLineCounter=0
        local seqGen=coroutine.create(getSeqGen(P.gameEnv.sequence))
        P.newNext=function()
            local status,piece
            if seqCalled then
                status,piece=coroutine.resume(seqGen,P.field,P.stat)
            else
                status,piece=coroutine.resume(seqGen,P.seqRND,P.gameEnv.seqData)
                seqCalled=true
            end
            if not status then
                assert(piece=='cannot resume dead coroutine')
            elseif piece then
                if P.gameEnv.noInitSZO and initSZOcount<5 then
                    initSZOcount=initSZOcount+1
                    if piece==1 or piece==2 or piece==6 then
                        return P:newNext()
                    else
                        initSZOcount=5
                    end
                end
                P:getNext(piece,bagLineCounter)
                bagLineCounter=0
            else
                if P.gameEnv.bagLine then
                    bagLineCounter=bagLineCounter+1
                end
                P:newNext()
            end
        end
    end

    P.atkBuffer=s.atkBuffer or {}
    P.atkBufferSum=s.atkBufferSum
    P.atkBufferSum1=s.atkBufferSum1
    P.inTransitAttacks=s.inTransitAttacks or {}
    P.lastRecv=s.lastRecv

    _restoreStat(P.stat, s.stat)
    P.combo=s.combo
    P.b2b=s.b2b
    P.finesseCombo=s.finesseCombo
    P.finesseComboTime=s.finesseComboTime
    P.lastPiece=s.lastPiece and TABLE.copy(s.lastPiece) or nil

    P.keyPressing=s.keyPressing or {}
    P.bufferedIRS=s.bufferedIRS
    P.bufferedIHS=s.bufferedIHS
    P.bufferedIMS=s.bufferedIMS
    P.bufferedDelay=s.bufferedDelay

    P.stream=s.stream or {}
    P.streamProgress=s.streamProgress

    P.alive=s.alive
    P.control=s.control
    P.timing=s.timing
    P.life=s.life
    P.result=s.result
    P.clearingRow=s.clearingRow or {}
    P.clearedRow=s.clearedRow or {}
    P.dropTime=s.dropTime or {}

    P.modeData=s.modeData
end

return M