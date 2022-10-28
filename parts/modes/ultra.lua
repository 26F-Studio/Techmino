return {
    env={
        noTele=true,
        minarr=1,minsdarr=1,
        drop=60,lock=60,
        fall=20,
        eventSet='ultra',
        bg='fan',bgm='sakura',
    },
    slowMark=true,
    score=function(P) return {P.stat.score} end,
    scoreDisp=function(D) return tostring(D[1]) end,
    comp=function(a,b) return a[1]>b[1] end,
    getRank=function(P)
        local T=P.stat.score
        return
        T>=62000 and 5 or
        T>=50000 and 4 or
        T>=26000 and 3 or
        T>=10000 and 2 or
        T>=6200 and 1
    end,
}
