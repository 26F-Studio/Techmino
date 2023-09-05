return {
    env={
        drop=180,lock=180,
        hang=15,
        eventSet='secret_grade',
        bg='bg2',bgm='race',
    },
    score=function(P) return {P.modeData.rankPts,P.stat.piece} end,
    scoreDisp=function(D) return getSecretGradeText(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local G=P.modeData.rankPts
        return
        G>=23 and 5 or
        G>=21 and 4 or
        G>=19 and 3 or
        G>=15 and 2 or
        G>=11 and 1 or
        G>=7 and 0
    end,
}
