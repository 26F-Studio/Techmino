return{
    mesDisp=function(P)
        setFont(55)
        mStr(P.modeData.wave,63,200)
        mStr(P.modeData.rpm,63,320)
        mText(drawableText.wave,63,260)
        mText(drawableText.rpm,63,380)
    end,
    task=function(P)
        while true do
            YIELD()
            if P.control then
                local D=P.modeData
                D.counter=D.counter+1
                local t=math.max(360-D.wave*2,60)
                if D.counter>=t then
                    D.counter=0
                    for _=1,3 do
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=1,countdown=2*t,cd0=2*t,time=0,sent=false,lv=1})
                    end
                    P.atkBufferSum=P.atkBufferSum+3
                    P.stat.recv=P.stat.recv+3
                    D.wave=D.wave+1
                    if D.wave<=90 then
                        D.rpm=math.floor(108e3/t)*.1
                        if D.wave==25 then
                            P:_showText(text.great,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=2
                            P.dropDelay,P.gameEnv.drop=20,20
                        elseif D.wave==50 then
                            P:_showText(text.awesome,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=3
                            P.dropDelay,P.gameEnv.drop=10,10
                        elseif D.wave==90 then
                            P.dropDelay,P.gameEnv.drop=5,5
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                        end
                    end
                end
            end
        end
    end
}
