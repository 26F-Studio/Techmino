return {
    env={
        sequence="bagES",
        eventSet='master_final',
        bg='lightning',bgm='rectification',
    },
    slowMark=true,
    score=function(P) return {P.modeData.pt,P.stat.time} end,
    scoreDisp=function(D) return D[1].."P   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local S=P.modeData.pt
        return
        S>=1000 and 5 or
        S>=800 and 4 or
        S>=600 and 3 or
        S>=400 and 2 or
        S>=200 and 1 or
        S>=50 and 0
    end,
}
