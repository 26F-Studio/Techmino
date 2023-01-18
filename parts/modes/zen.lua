return {
    env={
        drop=120,lock=120,
        infHold=true,
        eventSet='checkLine_200',
        bg='bg2',bgm='venus',
    },
    score=function(P) return {P.stat.score} end,
    scoreDisp=function(D) return tostring(D[1]) end,
    comp=function(a,b) return a[1]>b[1] end,
    getRank=function(P)
        local T=P.stat.score
        return
        T>=126000 and 5 or
        T>=100000 and 4 or
        T>=60000 and 3 or
        T>=30000 and 2 or
        T>=10000 and 1
    end,
}
