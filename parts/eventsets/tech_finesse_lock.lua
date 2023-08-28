local function lockKey(P,keys)
    for _,v in next,keys do
        P.keyAvailable[v]=false
        VK.keys[v].ava=false
        VK.release(v)
    end
end
local function unlockKey(P,keys)
    for _,v in next,keys do
        P.keyAvailable[v]=true
        VK.keys[v].ava=true
    end
end
local function lockMovement(P)
    lockKey(P,{1,2})
end
local function lockRotation(P)
    lockKey(P,{3,4,5})
end
local function unlock(P)
    if P.cur and P.cur.name==6 and not P.gameEnv.skipOCheck then -- don't unlock rotation if O piece & no O-spin
        unlockKey(P,{1,2,6,7})
        return
    end
    unlockKey(P,{1,2,3,4,5,6,7})
end
local function resetLock(P)
    unlock(P)
    unlockKey(P,{8})

    P.modeData.moveCount=0
    P.modeData.rotations=0
    P.holdTime=1
end

local function onMove(P)
    if not P.cur then return end

    P.holdTime=0
    lockKey(P,{8})

    -- return if overhang
    if P:_roofCheck() then return end

    P.modeData.moveCount=P.modeData.moveCount+1
    if P.modeData.moveCount>=2 then lockMovement(P) end
end
local function onAutoMove(P)
    if P:_roofCheck() then unlock(P) end
end
local function onRotate(P)
    if not P.cur then return end

    P.holdTime=0
    lockKey(P,{8})

    -- return if overhang
    if P:_roofCheck() then return end

    P.modeData.rotations=P.modeData.rotations+1
    if P.modeData.rotations>=2 then lockRotation(P) end
end

return {
    arr=0,
    fineKill=true,
    mesDisp=function(P)
        setFont(45)
        GC.mStr(("%d"):format(P.stat.atk),63,190)
        GC.mStr(("%.2f"):format(P.stat.atk/P.stat.row),63,310)
        mText(TEXTOBJ.atk,63,243)
        mText(TEXTOBJ.eff,63,363)
    end,
    task=function(P)
        resetLock(P)
        local RSname=P.RS.name
        P.gameEnv.skipOCheck=(
            string.find(RSname,'TRS') or
            string.find(RSname,'BiRS') or
            string.find(RSname,'ASC')
        )
    end,
    hook_drop=function(P)
        resetLock(P)
        if P.stat.atk>=100 then
            P:win('finish')
        end
    end,
    hook_spawn=function(P)
        if P.gameEnv.skipOCheck then return end
        if P.cur.name==6 then
            lockRotation(P)
        else
            resetLock(P)
        end
    end,
    hook_hold=function(P)
        if P.gameEnv.skipOCheck then return end
        if P.cur.name==6 then
            lockRotation(P)
        else
            resetLock(P)
        end
    end,
    hook_left_manual=onMove, hook_right_manual=onMove,
    hook_left_auto=onAutoMove, hook_right_auto=onAutoMove,
    hook_rotLeft=onRotate, hook_rotRight=onRotate, hook_rot180=onRotate,
}
