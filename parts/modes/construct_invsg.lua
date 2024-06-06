return {
    env={
        fieldH=13,
        drop=180,lock=600,
        hang=40,
        infHold=true,
        eventSet='construct_invsg',
        bg='bg2',bgm='race',
    },
    score=function(P) return {P.modeData.maxRankPts,P.stat.piece} end,
    scoreDisp=function(D) return getConstructGradeText(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local G=P.modeData.maxRankPts-1
        return
        G>=10 and 5 or
        G>=7 and 4 or
        G>=4 and 3 or
        G>=2 and 2 or
        G>=1 and 0
    end,
}
