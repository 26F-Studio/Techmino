return {
    mesDisp=function(P)
        setFont(60)
        GC.mStr(P.modeData.wave,63,310)
        mText(TEXTOBJ.wave,63,375)
    end,
    task=function(P)
        while true do
            coroutine.yield()
            if P.control then
                local D=P.modeData
                D.timer=D.timer+1
                if D.timer>=math.max(60,150-D.wave) and P.atkBufferSum<20 then
                    if D.wave==110 then
                        P:win('finish')
                    else
                        local t=math.max(60,90-D.wave)
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3})
                        P.atkBufferSum=P.atkBufferSum+4
                        P.stat.recv=P.stat.recv+4
                        if D.wave==90 then
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                        end
                        P:shakeField(3)
                        D.timer=0
                        D.wave=D.wave+1
                    end
                end
            end
        end
    end,
}
