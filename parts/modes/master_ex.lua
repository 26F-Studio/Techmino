local sectionName={"D","C","B","A","A+","S-","S","S+","S+","SS","SS","U","U","X","X+"}

return {
    env={
        eventSet='master_ex',
        bg='blockspace',bgm='hope',
    },
    slowMark=true,
    score=function(P) return {P.modeData.rankPoint,P.stat.score} end,
    scoreDisp=function(D) return sectionName[math.floor(D[1]/10)+1].."   "..D[2] end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]>b[2] end,
    getRank=function(P)
        P=P.modeData.rankPoint
        return
            P==140 and 5 or
            P>=110 and 4 or
            P>=80 and 3 or
            P>=50 and 2 or
            P>=30 and 1 or
            P>=10 and 0
    end,
}
