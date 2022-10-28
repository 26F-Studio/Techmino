return {
    env={
        drop=60,lock=60,
        eventSet='checkLine_400',
        bg='rainbow',bgm='push',
    },
    score=function(P) return {P.stat.time,P.stat.piece} end,
    scoreDisp=function(D) return STRING.time(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]<b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.row<400 then return end
        local T=P.stat.time
        return
        T<=300 and 5 or
        T<=380 and 4 or
        T<=500 and 3 or
        T<=626 and 2 or
        T<=800 and 1 or
        0
    end,
}
