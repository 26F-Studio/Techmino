return {
    mesDisp=function(P)
        setFont(55)
        GC.mStr(P.modeData.wave,63,200)
        GC.mStr(20+4*math.min(math.floor(P.modeData.wave/10),2),63,320)
        mText(TEXTOBJ.wave,63,260)
        mText(TEXTOBJ.nextWave,63,380)
    end,
    task=function(P)
        while true do
            coroutine.yield()
            if P.control and P.atkBufferSum<4 then
                local D=P.modeData
                if D.wave==50 then
                    P:win('finish')
                else
                    local s
                    local t=800-10*D.wave-- 800~700~600~500
                    if D.wave<10 then
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(5,6)),amount=9,countdown=t,cd0=t,time=0,sent=false,lv=3})
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(4,7)),amount=11,countdown=t,cd0=t+62,time=0,sent=false,lv=4})
                        s=20
                    elseif D.wave<20 then
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(3,8)),amount=11,countdown=t,cd0=t,time=0,sent=false,lv=4})
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(4,7)),amount=13,countdown=t,cd0=t+62,time=0,sent=false,lv=5})
                        s=24
                    else
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(2)*9-8),amount=14,countdown=t,cd0=t,time=0,sent=false,lv=5})
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(3,8)),amount=14,countdown=t+62,cd0=t,time=0,sent=false,lv=5})
                        s=28
                    end
                    P.atkBufferSum=P.atkBufferSum+s
                    P.stat.recv=P.stat.recv+s
                    if D.wave%10==0 then
                        if D.wave==10 then
                            P:_showText(text.great,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=4
                        elseif D.wave==20 then
                            P:_showText(text.awesome,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=5
                        elseif D.wave==30 then
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                        end
                    end
                    P:shakeField(10)
                    D.wave=D.wave+1
                end
            end
        end
    end
}
