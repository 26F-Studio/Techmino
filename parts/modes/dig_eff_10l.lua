return {
    env={
        drop=120,lock=1e99,
        infHold=true,
        pushSpeed=6,
        eventSet='dig_10l',
        bg='bg1',bgm='way',
    },
    score=function(P) return {P.stat.piece,P.stat.time} end,
    scoreDisp=function(D) return D[1].." Pieces   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]<b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.dig<10 then return end
        local P=P.stat.piece
        return
        P<=12 and 5 or
        P<=18 and 4 or
        P<=25 and 3 or
        P<=30 and 2 or
        P<=40 and 1 or
        0
    end,
}
