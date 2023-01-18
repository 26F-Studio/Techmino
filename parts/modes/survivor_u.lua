return {
    env={
        drop=5,lock=60,
        fall=10,
        freshLimit=15,
        pushSpeed=2,
        eventSet='survivor_u',
        bg='welcome',bgm='here',
    },
    score=function(P) return {P.modeData.wave,P.stat.time} end,
    scoreDisp=function(D) return D[1].." Waves   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local W=P.modeData.wave
        return
        W>=35 and 5 or
        W>=26 and 4 or
        W>=20 and 3 or
        W>=10 and 2 or
        W>=5 and 1 or
        W>=1 and 0
    end,
}
