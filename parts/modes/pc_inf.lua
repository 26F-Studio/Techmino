return {
    env={
        drop=20,lock=60,
        fall=10,
        freshLimit=8,
        ospin=false,
        eventSet='pc_inf',
        bg='rgb',bgm='moonbeam',
    },
    score=function(P) return {P.stat.pc,P.stat.time} end,
    scoreDisp=function(D) return D[1].." PCs   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.pc
        return
        L>=50 and 5 or
        L>=40 and 4 or
        L>=30 and 3 or
        L>=20 and 2 or
        L>=10 and 1 or
        L>=5 and 0
    end,
}
