local gc=love.graphics
local dropSpeed={[0]=30,26,23,20,17,14,12,10,8,6,5,4,3,2,1,1,.5,.5,.25,.25}

return{
    drop=30,
    lock=1e99,
    wait=10,
    fall=60,
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
    hook_drop=function(P)
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
                P:act_hardDrop()
            end
        end
    end,
}
