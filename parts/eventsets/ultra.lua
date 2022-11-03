local warnTime={60,90,105,115,116,117,118,119,120}
for i=1,#warnTime do warnTime[i]=warnTime[i]*60 end

return {
    mesDisp=function(P)
        GC.setLineWidth(2)
        GC.setColor(.98,.98,.98,.8)
        GC.rectangle('line',0,260,126,80,4)
        GC.setColor(.98,.98,.98,.4)
        GC.rectangle('fill',0+2,260+2,126-4,80-4,2)
        setFont(45)
        local t=P.stat.frame/60
        local T=("%.1f"):format(120-t)
        GC.setColor(COLOR.dH)
        GC.mStr(T,65,270)
        t=t/120
        GC.setColor(1.7*t,2.3-2*t,.3)
        GC.mStr(T,63,268)
    end,
    task=function(P)
        BGM.set('all','seek',0)
        P.modeData.section=1
        while true do
            coroutine.yield()
            while P.stat.frame>=warnTime[P.modeData.section] do
                if P.modeData.section<9 then
                    P.modeData.section=P.modeData.section+1
                    playReadySFX(3,.7+P.modeData.section*.03)
                else
                    playReadySFX(0,.7+P.modeData.section*.03)
                    P:win('finish')
                    return
                end
            end
        end
    end,
}
