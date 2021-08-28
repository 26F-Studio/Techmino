return
{
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        PLY.draw.drawTargetLine(P,200-P.stat.row)
    end,
    task=function(P)
        P.gameEnv.drop=.5
        P.gameEnv.wait=8
        P.gameEnv.fall=20

        P.modeData.target=50
    end,
    dropPiece=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==50 then
                P.gameEnv.drop=.25
                P.modeData.target=100
                SFX.play('reach')
            elseif P.modeData.target==100 then
                P:set20G(true)
                P.modeData.target=200
                SFX.play('reach')
            else
                P:win('finish')
            end
        end
    end
}
