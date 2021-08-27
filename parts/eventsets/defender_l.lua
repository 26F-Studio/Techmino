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
                local t=math.max(240-2*D.wave,40)
                if D.counter>=t then
                    D.counter=0
                    for _=1,4 do
                        table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=1,countdown=5*t,cd0=5*t,time=0,sent=false,lv=2})
                    end
                    P.atkBufferSum=P.atkBufferSum+4
                    P.stat.recv=P.stat.recv+4
                    D.wave=D.wave+1
                    if D.wave<=75 then
                        D.rpm=math.floor(144e3/t)*.1
                        if D.wave==25 then
                            P:_showText(text.great,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=3
                            P.dropDelay,P.gameEnv.drop=4,4
                        elseif D.wave==50 then
                            P:_showText(text.awesome,0,-140,100,'appear',.6)
                            P.gameEnv.pushSpeed=4
                            P.dropDelay,P.gameEnv.drop=3,3
                        elseif D.wave==75 then
                            P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                            P.dropDelay,P.gameEnv.drop=2,2
                        end
                    end
                end
            end
        end
    end,
}