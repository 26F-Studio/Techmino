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
                if D.timer>=math.max(30,80-.3*D.wave) then
                    P:garbageRise(20+D.wave%5,1,P:getHolePos())
                    P.stat.recv=P.stat.recv+1
                    D.timer=0
                    D.wave=D.wave+1
                end
            end
        end
    end,
}
