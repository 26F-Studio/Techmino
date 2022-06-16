local gc=love.graphics

return{
    drop=.5,
    lock=1e99,
    wait=5,
    fall=30,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)

        setFont(30)
        mStr(P.modeData.bpm,63,178)

        gc.setLineWidth(4)
        gc.circle('line',63,200,30)

        local beat=P.modeData.counter/P.modeData.beatFrame
        gc.setColor(1,1,1,1-beat)
        gc.setLineWidth(3)
        gc.circle('line',63,200,30+45*beat)
    end,
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
                P:act_hardDrop()
            end
        end
    end,
}
