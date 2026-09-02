-- dump_state.lua — one-off debug mode for the rollback golden-test harness.
--
-- Activated by the launch flag --dump-state (parsed in main.lua, sets
-- DUMP_STATE=true). When active, the local human player (P.id==1) writes a
-- deterministic snapshot of authoritative sim state at:
--   * every frameRun multiple of DUMP_FRAME_INTERVAL (default 60)
--   * every piece lock (immediately after Player:drop runs _checkClear)
--   * on top-out (Player:lose)
--
-- Output: one file per dump, in the save directory under
-- "dump_state/<prefix>_<frameRun>.json", where <prefix> is set per-match
-- via dump_state.setPrefix(). The Go sim_golden_test.go reads these files
-- and asserts byte-for-byte equality against the Go sim's state at the same
-- frameRun.
--
-- This file is a DEV/TEST ONLY facility: it has zero effect when DUMP_STATE
-- is not set, and it must not be wired into any shipped release path. The
-- golden harness regenerates the dump set on demand; the committed .rep +
-- .json snapshots are the reference.

local fs=love.filesystem
local JSON=require'Zframework.json'

local M={}
M.enabled=false
M.prefix="p1"
M.frameInterval=60        -- dump every N frames (0 = no periodic dump)
M.dir="dump_state"
M._initialized=false

function M.setEnabled(b) M.enabled=b end
function M.setPrefix(s) M.prefix=s or "p1" end
function M.setFrameInterval(n) M.frameInterval=n or 60 end

-- _field is P.field: a list-of-lists of cell ints (1-based [y][x]).
-- Serialize as rows of ints (0 = empty), top row first (y=1). This matches
-- the Go sim Field layout (rows[0] is the lowest; we emit bottom-up to
-- match the visual row order — the golden test reads field rows by index).
local function snapshotField(field)
    local rows={}
    for y=1,#field do
        local r=field[y]
        local out={}
        for x=1,#r do out[x]=r[x] or 0 end
        rows[y]=out
    end
    return rows
end

-- Snapshot the RNG state via :getState() (hex string). Only seqRND/atkRND/
-- holeRND matter for determinism; aiRND is unused in 1v1.
local function snapshotRNG(P)
    return {
        seqRND=P.seqRND and P.seqRND:getState(),
        atkRND=P.atkRND and P.atkRND:getState(),
        holeRND=P.holeRND and P.holeRND:getState(),
    }
end

-- Snapshot atkBuffer: a list of {send,time,count,bar} entries (see
-- Player:beAttacked / garbageRise). We emit the raw ints.
local function snapshotAtkBuffer(buf)
    local out={}
    for i=1,#buf do
        local b=buf[i]
        out[i]={b.send,b.time,b.count,b.bar}
    end
    return out
end

-- stat: the nested scoring table. The 29-entry clear/clears/spin/spins
-- arrays are the divergence-sensitive parts; emit them plus the scalars.
local function snapshotStat(stat)
    if not stat then return nil end
    local function cpArr(a,n)
        local o={}
        for i=1,n do o[i]=a and a[i] or 0 end
        return o
    end
    return {
        frame=stat.frame,
        time=stat.time,
        score=stat.score,
        piece=stat.piece,
        row=stat.row,
        dig=stat.dig,
        -- 29-entry arrays
        clear=cpArr(stat.clear,29),
        clears=cpArr(stat.clears,29),
        spin=cpArr(stat.spin,29),
        spins=cpArr(stat.spins,29),
        -- scalars
        maxCombo=stat.maxCombo,
        maxFinesseCombo=stat.maxFinesseCombo,
        extra=stat.extra,
        b2b=stat.b2b,
        b3b=stat.b3b,
        finesseCombo=stat.finesseCombo,
        key=stat.key,
        hold=stat.hold,
        regame=stat.regame,
        win=stat.win,
    }
end

-- Build the snapshot dict for player P at the current frameRun.
function M.snapshot(P, reason)
    local C=P.cur
    return {
        frameRun=P.frameRun,
        reason=reason,           -- "interval" | "lock" | "lose"
        curX=P.curX,
        curY=P.curY,
        ghoY=P.ghoY,
        minY=P.minY,
        dropDelay=P.dropDelay,
        lockDelay=P.lockDelay,
        downing=P.downing,
        waiting=P.waiting,
        falling=P.falling,
        control=P.control,
        timing=P.timing,
        alive=P.alive,
        combo=P.combo,
        b2b=P.b2b,
        pieceCount=P.pieceCount,
        nextCount=P.nextQueue and #P.nextQueue,
        holdCount=P.holdQueue and #P.holdQueue,
        cur=C and {id=C.id,dir=C.dir,color=C.color} or nil,
        fieldBeneath=P.fieldBeneath,
        garbageBeneath=P.garbageBeneath,
        fieldUp=P.fieldUp,
        field=snapshotField(P.field),
        atkBuffer=snapshotAtkBuffer(P.atkBuffer),
        atkBufferSum=P.atkBufferSum,
        inTransitAttacks=P.inTransitAttacks, -- raw table; diverges if mis-ordered
        stat=snapshotStat(P.stat),
        rng=snapshotRNG(P),
    }
end

function M._ensureDir()
    if M._initialized then return end
    M._initialized=true
    if not fs.getInfo(M.dir) then
        fs.createDirectory(M.dir)
    end
end

-- write writes a snapshot to dump_state/<prefix>_<frameRun>.json. Returns
-- the filename written (for logging).
function M.write(P, reason)
    if not M.enabled then return end
    M._ensureDir()
    local snap=M.snapshot(P, reason)
    local fname=("%s/%s_%05d.json"):format(M.dir, M.prefix, P.frameRun)
    -- reason suffix for lock/lose so multiple same-frame dumps don't collide.
    if reason=="lock" then
        fname=("%s/%s_%05d_lock.json"):format(M.dir, M.prefix, P.frameRun)
    elseif reason=="lose" then
        fname=("%s/%s_%05d_lose.json"):format(M.dir, M.prefix, P.frameRun)
    end
    local ok,err=fs.write(fname, JSON.encode(snap).."\n")
    if not ok then
        -- Don't crash the game over a dump failure; log to stderr-equivalent.
        print("[dump_state] write error: "..tostring(err))
    end
    return fname
end

-- onFrame is called from update_alive after P.frameRun increments. It
-- handles the periodic-interval dump. Lock/lose dumps are called directly
-- from Player:drop / Player:lose.
function M.onFrame(P)
    if not M.enabled or P.id~=1 then return end
    if M.frameInterval>0 and P.frameRun>180 and P.frameRun%M.frameInterval==0 then
        M.write(P, "interval")
    end
end

return M
