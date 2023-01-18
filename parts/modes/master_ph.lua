return {
    env={
        eventSet='master_ph',
        bg='blockspace',bgm='race remix',
    },
    slowMark=true,
    score=function(P) return {P.result=='win' and 260 or P.modeData.pt,P.stat.time} end,
    scoreDisp=function(D) return D[1].."P   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local p=P.modeData.pt
        return
        P.result=='win' and 5 or
        p>=226 and 4 or
        p>=162 and 3 or
        p>=62 and 2 or
        p>=42 and 1 or
        p>=26 and 0
    end,
}
