return {
    env={
        nextCount=3,
        freshLimit=15,
        pushSpeed=2,
        eventSet='defender_l',
        bg='rainbow2',bgm='storm',
    },
    score=function(P) return {P.modeData.wave,P.stat.time} end,
    scoreDisp=function(D) return D[1].." Waves   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local W=P.modeData.wave
        return
        W>=100 and 5 or
        W>=80 and 4 or
        W>=55 and 3 or
        W>=30 and 2 or
        W>=20 and 1 or
        W>=5 and 0
    end,
}
