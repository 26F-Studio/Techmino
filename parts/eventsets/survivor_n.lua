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
                if D.timer>=math.max(90,180-2*D.wave) and P.atkBufferSum<8 then
                    if D.wave==80 then
                        P:win('finish')
                    else
                        local d=D.wave+1
                        table.insert(P.atkBuffer,
                            d%4==0 and{line=generateLine(P.holeRND:random(10)),amount=1,countdown=60,cd0=60,time=0,sent=false,lv=1} or
                            d%4==1 and{line=generateLine(P.holeRND:random(10)),amount=2,countdown=70,cd0=70,time=0,sent=false,lv=1} or
                            d%4==2 and{line=generateLine(P.holeRND:random(10)),amount=3,countdown=80,cd0=80,time=0,sent=false,lv=2} or
                            d%4==3 and{line=generateLine(P.holeRND:random(10)),amount=4,countdown=90,cd0=90,time=0,sent=false,lv=3}
                        )
                        P.atkBufferSum=P.atkBufferSum+d%4+1
                        P.stat.recv=P.stat.recv+d%4+1
                        if D.wave==45 then
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                        end
                        D.timer=0
                        D.wave=d
                    end
                end
            end
        end
    end,
}
