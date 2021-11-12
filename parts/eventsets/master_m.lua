return
{
    das=6,
    arr=2,
    drop=0,
    lock=15,
    wait=6,
    fall=2,
    freshLimit=15,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        PLY.draw.drawTargetLine(P,200-P.stat.row)
    end,
    task=function(P)
        P.modeData.target=10
    end,
    hook_drop=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==200 then
                P:win('finish')
            else
                P.gameEnv.lock=math.max(6,P.gameEnv.lock-1)
                if P.modeData.target<100 then
                    P.modeData.target=P.modeData.target+10
                else
                    P.modeData.target=200
                end
                SFX.play('reach')
            end
        end
    end
}
