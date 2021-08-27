local gc=love.graphics

return{
    color=COLOR.green,
    env={
        noTele=true,
        mindas=7,minarr=1,minsdarr=1,
        keyCancel={6},
        eventSet='rhythm_e',
        bg='bg2',bgm='push',
    },
    slowMark=true,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)

        setFont(30)
        mStr(P.modeData.bpm,63,178)

        gc.setLineWidth(4)
        gc.circle('line',63,200,30)

        local beat=P.modeData.counter/P.modeData.beatFrame
        gc.setColor(1,1,1,1-beat)
        gc.setLineWidth(3)
        gc.circle('line',63,200,30+45*beat)
    end,
    score=function(P)return{math.min(P.stat.row,200),P.stat.time}end,
    scoreDisp=function(D)return D[1].." Lines   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local L=P.stat.row
        return
        L>=200 and 5 or
        L>=170 and 4 or
        L>=140 and 3 or
        L>=100 and 2 or
        L>=50 and 1 or
        L>=20 and 0
    end,
}