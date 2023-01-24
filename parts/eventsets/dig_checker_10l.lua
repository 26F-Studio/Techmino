return {
    mesDisp=function(P)
        setFont(55)
        GC.mStr(10-P.stat.dig,63,265)
    end,
    hook_drop=function(P)
        if P.stat.dig==10 then
            P:win('finish')
        end
    end,
    task=function(P)
        local r=P.holeRND:random(0,1)
        for y=1,10 do
            P.field[y]=LINE.new(0,true)
            P.visTime[y]=LINE.new(P.showTime*2)
            for x=1,10 do
                P.field[y][x]=(x+y+r)%2*21
            end
        end
        P.fieldBeneath=0
    end,
}
