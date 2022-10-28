return {
    env={
        pushSpeed=6,
        eventSet='dig_100l',
        bg='bg2',bgm='way',
    },
    score=function(P) return {P.stat.time,P.stat.piece} end,
    scoreDisp=function(D) return STRING.time(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]<b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.dig<100 then return end
        local T=P.stat.time
        return
        T<=120 and 5 or
        T<=160 and 4 or
        T<=240 and 3 or
        T<=360 and 2 or
        T<=480 and 1 or
        0
    end,
}
