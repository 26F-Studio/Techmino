return{
    color=COLOR.lBlue,
    env={
        center=0,ghost=0,
        smooth=false,
        face={0,0,2,2,2,0,0},
        eventSet='classic_u',
        bg='rgb',bgm='magicblock',
    },
    slowMark=true,
    mesDisp=function(P)
        setFont(75)
        local r=P.modeData.target*.1
        mStr(r<22 and 29 or("%02x"):format(r*10-220),63,210)
        mText(drawableText.speedLV,63,290)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
    end,
    score=function(P)return{P.stat.score,P.stat.row}end,
    scoreDisp=function(D)return D[1].."   "..D[2].." Lines"end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local L=P.stat.row
        return
        L>=15 and 5 or
        L>=12 and 4 or
        L>=9 and 3 or
        L>=6 and 2 or
        L>=3 and 1 or
        L>=1 and 0
    end,
}
