local dropSpeed={50,40,30,24,18,14,10,8,6,5,4,3,2,1,1,.5,.5,.25,.25}

return
{
    task=function(P)
        P.gameEnv.drop=60
        P.gameEnv.wait=8
        P.gameEnv.fall=20

        P.modeData.target=10
    end,
    dropPiece=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==200 then
                P:win('finish')
            else
                P.gameEnv.drop=dropSpeed[P.modeData.target/10]
                P.modeData.target=P.modeData.target+10
                SFX.play('reach')
            end
        end
    end
}