return
{
    drop=1,
    wait=8,
    fall=20,
    fieldH=10,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        PLY.draw.drawTargetLine(P,200-P.stat.row)
    end,
    task=function(P)
        local F=P.field
        for i=1,24 do
            F[i]=LINE.new(20)
            P.visTime[i]=LINE.new(20)
            for x=3,7 do F[i][x]=0 end
        end
        P.modeData.target=50
    end,
    hook_drop=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==50 then
                P.gameEnv.drop=.5
                P.modeData.target=100
                SFX.play('reach')
            elseif P.modeData.target==100 then
                P.gameEnv.drop=.25
                P.modeData.target=150
                SFX.play('reach')
            elseif P.modeData.target==150 then
                P:set20G(true)
                P.modeData.target=200
                SFX.play('reach')
            else
                P:win('finish')
            end
        end
    end
}
