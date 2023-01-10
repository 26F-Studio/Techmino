local garbagePatterns={
    {0,21,0,21,0,21,0,21,0,21},
    {21,0,21,0,21,0,21,0,21,0}
}
local pushGarbage=function(P)
    local t=P.showTime*2
    table.insert(P.field,1,LINE.new(0,true))
    table.insert(P.visTime,1,LINE.new(t))
    for i=1,10 do
        P.field[1][i]=garbagePatterns[P.modeData.parity+1][i]
    end
    P.modeData.parity=(P.modeData.parity+1)%2
    P.garbageBeneath=P.garbageBeneath+1
    P.fieldBeneath=P.fieldBeneath+30
end
return {
    mesDisp=function(P)
        setFont(55)
        GC.mStr(100-P.stat.dig,63,265)
    end,
    hook_drop=function(P)
        for _=1,math.min(10,100-P.stat.dig)-P.garbageBeneath do
            pushGarbage(P)
        end
        if P.stat.dig==100 then
            P:win('finish')
        end
    end,
    task=function(P)
        P.modeData.parity=P.holeRND:random(2)-1
        for _=1,10 do
            pushGarbage(P)
        end
        P.fieldBeneath=0
    end,
}
