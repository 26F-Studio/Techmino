local function unlock(P)
    for i=1,7 do
        P.keyAvailable[i]=true
        VK.keys[i].ava=true
    end
end
local function resetLock(P)
    unlock(P)
    P.keyAvailable[8]=true
    VK.keys[8].ava=true

    P.modeData.moveCount=0
    P.modeData.rotations=0
    P.holdTime=1
end

local function onMove(P)
    if not P.cur then return end
    
    P.holdTime=0
    VK.keys[8].ava=false
    VK.release(8)
    
    -- return if overhang
    if P:_roofCheck() then return end

    P.modeData.moveCount=P.modeData.moveCount+1
    if P.modeData.moveCount>=2 then
        P.keyAvailable[1]=false
        P.keyAvailable[2]=false

        VK.keys[1].ava=false
        VK.keys[2].ava=false

        VK.release(1)
        VK.release(2)
    end
end
local function onAutoMove(P)
    print('automove')
    if P:_roofCheck() then unlock(P) end
end
local function onRotate(P)
    if not P.cur then return end

    P.holdTime=0
    VK.keys[8].ava=false
    VK.release(8)
    
    -- return if overhang
    if P:_roofCheck() then return end

    P.modeData.rotations=P.modeData.rotations+1
    if P.modeData.rotations>=2 then
        P.keyAvailable[3]=false
        P.keyAvailable[4]=false
        P.keyAvailable[5]=false

        VK.keys[3].ava=false
        VK.keys[4].ava=false
        VK.keys[5].ava=false

        VK.release(3)
        VK.release(4)
        VK.release(5)
    end
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
    end,
    hook_drop=function(P)
        resetLock(P)
        if P.stat.atk>=100 then
            P:win('finish')
        end
    end,
    hook_left_manual=onMove, hook_right_manual=onMove,
    hook_left_auto=onAutoMove, hook_right_auto=onAutoMove,
    hook_rotLeft=onRotate, hook_rotRight=onRotate, hook_rot180=onRotate,
}
