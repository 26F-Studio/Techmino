return{
    dropPiece=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==200 then
                P:win('finish')
            else
                P.modeData.bpm=120+2*P.modeData.target/10
                P.modeData.beatFrame=math.floor(3600/P.modeData.bpm)
                P.gameEnv.fall=P.modeData.beatFrame
                P.gameEnv.wait=math.max(P.gameEnv.wait-1,0)
                if P.modeData.target==50 then
                    P.gameEnv.das=5
                    P.gameEnv.drop=.25
                elseif P.modeData.target==100 then
                    P.gameEnv.das=4
                    P:set20G(true)
                end
                P.modeData.target=P.modeData.target+10
                SFX.play('reach')
            end
        end
    end,
    task=function(P)
        P.gameEnv.drop=.5
        P.gameEnv.lock=1e99
        P.gameEnv.wait=5
        P.gameEnv.fall=30

        P.modeData.target=10
        P.modeData.bpm=120
        P.modeData.beatFrame=30
        P.modeData.counter=30
        while true do
            YIELD()
            P.modeData.counter=P.modeData.counter-1
            if P.modeData.counter==0 then
                P.modeData.counter=P.modeData.beatFrame
                SFX.play('click',.3)
                P:switchKey(6,true)
                P:pressKey(6)
                P:switchKey(6,false)
            end
        end
    end,
}