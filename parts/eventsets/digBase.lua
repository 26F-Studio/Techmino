return{
    task=function(P)
        for _=1,10 do
            P:garbageRise(21,1,P:getHolePos())
        end
        P.fieldBeneath=0
    end,
}
