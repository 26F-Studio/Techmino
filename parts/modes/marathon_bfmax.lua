return{
    color=COLOR.yellow,
    env={
        noTele=true,
        mindas=7,minarr=1,minsdarr=1,
        eventSet='marathon_bfmax',
        bg='bg2',bgm='blank',
    },
    slowMark=true,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        PLY.draw.drawTargetLine(P,200-P.stat.row)
    end,
    getRank=function(P)
        local L=P.stat.row
        if L>=200 then
            local T=P.stat.time
            return
            T<=400 and 5 or
            T<=600 and 4 or
            3
        else
            return
            L>=150 and 2 or
            L>=80 and 1 or
            L>=20 and 0
        end
    end,
}