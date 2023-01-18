return {
    env={
        drop=10,lock=30,
        freshLimit=15,
        eventSet='dig_u',
        bg='bg2',bgm='shift',
    },
    score=function(P) return {P.modeData.wave,P.stat.row} end,
    scoreDisp=function(D) return D[1].." Waves   "..D[2].." Lines" end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local W=P.modeData.wave
        return
        W>=150 and 5 or
        W>=110 and 4 or
        W>=80 and 3 or
        W>=50 and 2 or
        W>=20 and 1 or
        P.stat.row>=5 and 0
    end,
}
