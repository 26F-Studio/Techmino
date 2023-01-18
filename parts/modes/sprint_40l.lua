return {
    env={
        drop=60,lock=60,
        eventSet='checkLine_40',
        bg='bg2',bgm='race',
    },
    score=function(P) return {P.stat.time,P.stat.piece} end,
    scoreDisp=function(D) return STRING.time(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]<b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.row<40 then return end
        local T=P.stat.time
        return
            T<=26 and 5 or
            T<=36 and 4 or
            T<=52.6 and 3 or
            T<=92.9 and 2 or
            T<=183 and 1 or
            0
    end,
}
