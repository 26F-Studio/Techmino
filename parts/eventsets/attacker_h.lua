return {
    mesDisp=function(P)
        setFont(55)
        GC.mStr(P.modeData.wave,63,200)
        GC.mStr("22",63,320)
        mText(TEXTOBJ.wave,63,260)
        mText(TEXTOBJ.nextWave,63,380)
    end,
    task=function(P)
        while true do
            coroutine.yield()
            if P.control and P.atkBufferSum==0 then
                local D=P.modeData
                if D.wave==50 then
                    P:win('finish')
                else
                    if D.wave<20 then
                        local t=1500-30*D.wave-- 1500~900
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(4,7)),amount=12,countdown=t,cd0=t,time=0,sent=false,lv=3})
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(3,8)),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=4})
                    else
                        local t=900-10*(D.wave-20)-- 900~600
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=14,countdown=t,cd0=t,time=0,sent=false,lv=4})
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(4,7)),amount=8,countdown=t,cd0=t,time=0,sent=false,lv=5})
                    end
                    P.atkBufferSum=P.atkBufferSum+22
                    P.stat.recv=P.stat.recv+22
                    if D.wave%10==0 then
                        if D.wave==20 then
                            P:_showText(text.great,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=3
                        elseif D.wave==50 then
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                        end
                    end
                    P:shakeField(9)
                    D.wave=D.wave+1
                end
            end
        end
    end
}
