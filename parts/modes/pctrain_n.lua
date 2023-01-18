return {
    env={
        nextCount=4,
        holdCount=0,
        drop=120,lock=180,
        fall=20,
        eventSet='pctrain_n',
        bg='rgb',bgm='memory',
    },
    score=function(P) return {P.stat.pc,P.stat.time} end,
    scoreDisp=function(D) return D[1].." PCs   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.pc
        return
        L>=60 and 5 or
        L>=42 and 4 or
        L>=26 and 3 or
        L>=18 and 2 or
        L>=10 and 1 or
        L>=2 and 0
    end,
}
