local function onMove(P)
    if not P.cur then return end
    P.holdTime=0
    VK.keys[8].ava=false
    P.modeData.moveCount=P.modeData.moveCount+1
    if P.modeData.moveCount>=2 and (P.curY>P.gameEnv.fieldH-2 or P:_roofCheck()) then
        P.keyAvailable[1]=false
        P.keyAvailable[2]=false
        VK.keys[1].ava=false
        VK.keys[2].ava=false
    end
end
local function onRotate(P)
    if not P.cur then return end
    P.holdTime=0
    VK.keys[8].ava=false
    P.modeData.rotations=P.modeData.rotations+1
    if P.modeData.rotations>=2 and (P.curY>P.gameEnv.fieldH-2 or P:_roofCheck()) then
        P.keyAvailable[3]=false
        P.keyAvailable[4]=false
        P.keyAvailable[5]=false
        VK.keys[3].ava=false
        VK.keys[4].ava=false
        VK.keys[5].ava=false
    end
end
local function resetLock(P)
    for i=1,8 do
        P.keyAvailable[i]=true
        VK.keys[i].ava=true
    end
    P.modeData.moveCount=0
    P.modeData.rotations=0
    P.holdTime=1
end

return {
    arr=0,
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

        local C=P.lastPiece
        if C.row>0 then
            if not C.special then
                P:lose()
                return
            end
        end
        if P.stat.atk>=100 then
            P:win('finish')
        end
    end,
    hook_left_manual=onMove, hook_right_manual=onMove,
    hook_rotLeft=onRotate, hook_rotRight=onRotate, hook_rot180=onRotate
}
