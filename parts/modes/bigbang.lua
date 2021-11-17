return{
    env={
        das=8,arr=1,
        drop=30,lock=30,
        holdCount=0,
        eventSet='bigbang',
        bg='blockhole',bgm='peak',
    },
    score=function(P)return{P.modeData.stage,P.stat.time}end,
    scoreDisp=function(D)return D[1].." Stage   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        do return 1 end
        local L=P.modeData.stage
        return
        L>=100 and 5 or
        L>=70 and 4 or
        L>=40 and 3 or
        L>=20 and 2 or
        L>=10 and 1 or
        L>=3 and 0
    end,
}
