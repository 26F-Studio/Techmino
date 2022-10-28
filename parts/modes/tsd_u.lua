return {
    env={
        drop=60,lock=60,
        hang=15,
        freshLimit=15,
        ospin=false,
        eventSet='tsd_u',
        bg='matrix',bgm='vapor',
    },
    score=function(P) return {P.modeData.tsd,P.stat.time} end,
    scoreDisp=function(D) return D[1].."TSD   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local T=P.modeData.tsd
        return
        T>=20 and 5 or
        T>=18 and 4 or
        T>=16 and 3 or
        T>=13 and 2 or
        T>=10 and 1 or
        T>=4 and 0
    end,
}
