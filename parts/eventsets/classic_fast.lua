return{
    task=function(P)
        P.modeData.target=10
    end,
    dropPiece=function(P)
        local D=P.modeData
        if P.stat.row>=D.target then
            D.target=D.target+10
            if D.target==110 then
                P.gameEnv.drop,P.gameEnv.lock=2,2
                SFX.play('blip_1')
            elseif D.target==200 then
                P.gameEnv.drop,P.gameEnv.lock=1,1
                SFX.play('blip_1')
            else
                SFX.play('reach')
            end
        end
    end,
}