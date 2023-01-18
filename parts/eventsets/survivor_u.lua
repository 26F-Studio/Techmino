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
                if D.timer>=math.max(300,600-10*D.wave) and P.atkBufferSum<20 then
                    if D.wave==35 then
                        P:win('finish')
                    else
                        local t=math.max(300,480-12*D.wave)
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=2})
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3})
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=6,countdown=1.2*t,cd0=1.2*t,time=0,sent=false,lv=4})
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=6,countdown=1.5*t,cd0=1.5*t,time=0,sent=false,lv=5})
                        P.atkBufferSum=P.atkBufferSum+20
                        P.stat.recv=P.stat.recv+20
                        if D.wave==30 then
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                        end
                        P:shakeField(9)
                        D.timer=0
                        D.wave=D.wave+1
                    end
                end
            end
        end
    end,
}
