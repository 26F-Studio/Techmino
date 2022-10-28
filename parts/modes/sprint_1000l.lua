return {
    env={
        drop=60,lock=60,
        eventSet='checkLine_1000',
        bg='rainbow',bgm='push',
    },
    score=function(P) return {P.stat.time,P.stat.piece} end,
    scoreDisp=function(D) return STRING.time(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]<b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.row<1000 then return end
        local T=P.stat.time
        return
        T<=750 and 5 or
        T<=900 and 4 or
        T<=1260 and 3 or
        T<=1620 and 2 or
        T<=2000 and 1 or
        0
    end,
}
