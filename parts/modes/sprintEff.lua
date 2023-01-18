return {
    env={
        drop=60,lock=60,
        eventSet='sprintEff_40',
        bg='bg2',bgm='race',
    },
    score=function(P) return {P.stat.atk/P.stat.row,P.stat.time} end,
    scoreDisp=function(D) return string.format("%.3f",D[1]).." Efficiency   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.row<40 then return end
        local E=P.stat.atk/P.stat.row
        return math.min(math.floor(E),5)
    end,
}
