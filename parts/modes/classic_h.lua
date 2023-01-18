return {
    env={
        center=0,ghost=0,
        smooth=false,
        face={0,0,2,2,2,0,0},
        eventSet='classic_h',
        bg='rgb',bgm='1980s',
    },
    slowMark=true,
    score=function(P) return {P.stat.score,P.stat.row} end,
    scoreDisp=function(D) return D[1].."   "..D[2].." Lines" end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.row
        return
        L>=200 and 5 or
        L>=140 and 4 or
        L>=100 and 3 or
        L>=60 and 2 or
        L>=30 and 1 or
        L>=1 and 0
    end,
}
