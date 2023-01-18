return {
    env={
        drop=30,lock=60,
        freshLimit=5,
        eventSet='survivor_l',
        bg='glow',bgm='here',
    },
    score=function(P) return {P.modeData.wave,P.stat.time} end,
    scoreDisp=function(D) return D[1].." Waves   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local W=P.modeData.wave
        return
        W>=110 and 5 or
        W>=80 and 4 or
        W>=55 and 3 or
        W>=30 and 2 or
        W>=15 and 1 or
        W>=5 and 0
    end,
}
