return {
    drop=5,lock=60,
    fall=6,
    mesDisp=function(P)
        setFont(55)
        GC.mStr(P.modeData.wave,63,200)
        GC.mStr(P.modeData.rpm,63,320)
        mText(TEXTOBJ.wave,63,260)
        mText(TEXTOBJ.rpm,63,380)
    end,
    task=function(P)
        while true do
            coroutine.yield()
            if P.control then
                local D=P.modeData
                D.timer=D.timer+1
                if P.atkBufferSum<30 then
                    local t=
                        D.wave<=60 and 240-2*D.wave or
                        D.wave<=120 and 120-(D.wave-60) or
                        D.wave<=180 and math.floor(60-(D.wave-120)*.5) or
                        30
                    if D.timer>=t then
                        D.timer=0
                        for _=1,4 do
                            table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=1,countdown=5*t,cd0=5*t,time=0,sent=false,lv=2})
                        end
                        P.atkBufferSum=P.atkBufferSum+4
                        P.stat.recv=P.stat.recv+4
                        D.wave=D.wave+1
                        D.rpm=math.floor(144e3/t)*.1
                        if D.wave==60 then
                            P:_showText(text.great,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=3
                            P.dropDelay,P.gameEnv.drop=4,4
                        elseif D.wave==120 then
                            P:_showText(text.awesome,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=4
                            P.dropDelay,P.gameEnv.drop=3,3
                        elseif D.wave==180 then
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                            P.dropDelay,P.gameEnv.drop=2,2
                        end
                        P:shakeField(3)
                    end
                end
            end
        end
    end,
}
