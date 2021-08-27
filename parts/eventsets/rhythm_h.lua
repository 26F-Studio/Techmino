local dropSpeed={[0]=30,26,23,20,17,14,12,10,8,6,5,4,3,2,1,1,.5,.5,.25,.25}

return{
    dropPiece=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==200 then
                P:win('finish')
            else
                P.modeData.bpm=60+3*P.modeData.target/10
                P.modeData.beatFrame=math.floor(3600/P.modeData.bpm)
                P.gameEnv.fall=P.modeData.beatFrame
                P.gameEnv.wait=math.max(P.gameEnv.wait-1,0)
                P.gameEnv.drop=dropSpeed[P.modeData.target/10]
                P.modeData.target=P.modeData.target+10
                SFX.play('reach')
            end
        end
    end,
    task=function(P)
        P.gameEnv.drop=30
        P.gameEnv.lock=1e99
        P.gameEnv.wait=10
        P.gameEnv.fall=60

        P.modeData.target=10
        P.modeData.bpm=60
        P.modeData.beatFrame=60
        P.modeData.counter=60
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