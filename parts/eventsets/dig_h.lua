return{
    task=function(P)
        while true do
            YIELD()
            if P.control then
                local D=P.modeData
                D.timer=D.timer+1
                if D.timer>=math.max(90,180-D.wave)then
                    P:garbageRise(21,1,P:getHolePos())
                    P.stat.recv=P.stat.recv+1
                    D.timer=0
                    D.wave=D.wave+1
                end
            end
        end
    end,
}