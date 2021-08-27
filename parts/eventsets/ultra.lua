local gc=love.graphics
local warnTime={60,90,105,115,116,117,118,119,120}

return{
    mesDisp=function(P)
        gc.setLineWidth(2)
        gc.rectangle('line',55,110,32,402)
        local T=P.stat.frame/60/120
        gc.setColor(2*T,2-2*T,.2)
        gc.rectangle('fill',56,511,30,(T-1)*400)
    end,
    task=function(P)
        P.modeData.stage=1
        while true do
            YIELD()
            if P.stat.frame/60>=warnTime[P.modeData.stage]then
                if P.modeData.stage<9 then
                    P.modeData.stage=P.modeData.stage+1
                    SFX.play('ready',.7+P.modeData.stage*.03)
                else
                    SFX.play('start')
                    P:win('finish')
                    return
                end
            end
        end
    end,
}