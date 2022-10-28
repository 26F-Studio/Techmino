return {
    env={
        drop=60,lock=60,
        nextCount=0,holdCount=0,
        sequence='rnd',
        eventSet='checkLine_40',
        bg='aura',bgm='magicblock',
    },
    score=function(P) return {P.stat.time,P.stat.piece} end,
    scoreDisp=function(D) return STRING.time(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]<b[1] or (a[1]==b[1] and a[2]<b[2]) end,
    getRank=function(P)
        if P.stat.row<40 then return end
        local T=P.stat.time
        return
        T<=60 and 5 or
        T<=70 and 4 or
        T<=90 and 3 or
        T<=110 and 2 or
        T<=140 and 1 or
        0
    end,
}
