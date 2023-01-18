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
                if D.timer>=math.max(60,180-2*D.wave) and P.atkBufferSum<15 then
                    if D.wave==90 then
                        P:win('finish')
                    else
                        local s
                        if D.wave%3<2 then
                            table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=1,countdown=0,cd0=0,time=0,sent=false,lv=1})
                            s=1
                        else
                            table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=3,countdown=60,cd0=60,time=0,sent=false,lv=2})
                            s=3
                        end
                        P.atkBufferSum=P.atkBufferSum+s
                        P.stat.recv=P.stat.recv+s
                        if D.wave==60 then
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
