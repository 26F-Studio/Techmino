local sectionName={"D","C","B","A","A+","S-","S","S+","S+","SS","SS","U","U","X","X+"}

return{
    color=COLOR.lBlue,
    env={
        noTele=true,
        minarr=1,
        nextCount=3,
        sequence='hisPool',
        visible='fast',
        freshLimit=15,
        noInitSZO=true,
        eventSet='master_ex',
        bg='blockspace',bgm='hope',
    },
    slowMark=true,
    mesDisp=function(P)
        mText(drawableText.line,63,300)
        mText(drawableText.techrash,63,420)
        mText(drawableText.grade,63,170)
        setFont(55)
        mStr(P.modeData.rankName,63,110)
        setFont(20)
        mStr(("%.1f"):format(P.modeData.rankPoint/10),63,198)
        setFont(75)
        mStr(P.stat.row,63,220)
        mStr(P.stat.clears[4],63,340)
    end,
    score=function(P)return{P.modeData.rankPoint,P.stat.score}end,
    scoreDisp=function(D)return sectionName[math.floor(D[1]/10)+1].."   "..D[2]end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]>b[2]end,
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