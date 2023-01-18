return {
    env={
        noTele=true,
        mindas=7,minarr=1,minsdarr=1,
        sequence="bagES",
        eventSet='marathon_inf',
        bg='bg2',bgm='push',
    },
    slowMark=true,
    score=function(P) return {P.stat.score,P.stat.row,P.stat.time} end,
    scoreDisp=function(D) return D[1].."P   "..D[2].."L   "..STRING.time(D[3]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        return P.stat.row>=26 and 0
    end,
}
