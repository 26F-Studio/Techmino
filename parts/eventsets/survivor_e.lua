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
                if D.timer>=math.max(60,150-2*D.wave) and P.atkBufferSum<4 then
                    if D.wave==100 then
                        P:win('finish')
                    else
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=1,countdown=30,cd0=30,time=0,sent=false,lv=1})
                        P.atkBufferSum=P.atkBufferSum+1
                        P.stat.recv=P.stat.recv+1
                        if D.wave==45 then
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                        end
                        D.timer=0
                        D.wave=D.wave+1
                    end
                end
            end
        end
    end,
}
