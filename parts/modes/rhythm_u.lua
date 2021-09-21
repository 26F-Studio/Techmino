return{
    color=COLOR.magenta,
    env={
        das=6,minarr=1,minsdarr=1,
        keyCancel={6},
        eventSet='rhythm_u',
        bg='bg2',bgm='secret7th',
    },
    slowMark=true,
    score=function(P)return{math.min(P.stat.row,200),P.stat.time}end,
    scoreDisp=function(D)return D[1].." Lines   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local L=P.stat.row
        return
        L>=200 and 5 or
        L>=170 and 4 or
        L>=140 and 3 or
        L>=100 and 2 or
        L>=50 and 1 or
        L>=20 and 0
    end,
}
