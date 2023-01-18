return {
    mesDisp=function(P)
        setFont(55)
        GC.mStr(40-P.stat.dig,63,265)
    end,
    hook_drop=function(P)
        for _=1,math.min(10,40-P.stat.dig)-P.garbageBeneath do
            P:garbageRise(21,1,P:getHolePos())
        end
        if P.stat.dig==40 then
            P:win('finish')
        end
    end,
    task=function(P)
        for _=1,10 do
            P:garbageRise(21,1,P:getHolePos())
        end
        P.fieldBeneath=0
    end,
}
