return {
    env={
        pushSpeed=6,
        eventSet='dig_40l',
        bg='bg1',bgm='way',
    },
    score=function(P) return {P.stat.time,P.stat.piece} end,
    scoreDisp=function(D) return STRING.time(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]<b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.dig<40 then return end
        local T=P.stat.time
        return
        T<=50 and 5 or
        T<=70 and 4 or
        T<=90 and 3 or
        T<=120 and 2 or
        T<=180 and 1 or
        0
    end,
}
