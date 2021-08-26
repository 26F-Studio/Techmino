local dropSpeed={[0]=40,33,27,20,16,12,11,10,9,8,7,6,5,4,3,3,2,2,1,1}

return{
    dropPiece=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==200 then
                P:win('finish')
            else
                P.modeData.bpm=40+2*P.modeData.target/10
                P.modeData.beatFrame=math.floor(3600/P.modeData.bpm)
                P.gameEnv.fall=P.modeData.beatFrame
                P.gameEnv.wait=math.max(P.gameEnv.wait-2,0)
                P.gameEnv.drop=dropSpeed[P.modeData.target/10]
                P.modeData.target=P.modeData.target+10
                SFX.play('reach')
            end
        end
    end,
    task=function(P)
        P.modeData.target=10
        P.modeData.bpm=40
        P.modeData.beatFrame=90
        P.modeData.counter=90
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