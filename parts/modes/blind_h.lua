return {
    env={
        drop=15,lock=45,
        fall=10,
        dropFX=0,lockFX=0,
        visible='none',
        score=false,
        freshLimit=15,
        mesDisp=require"parts.eventsets.blindMesDisp".mesDisp,
        eventSet='checkLine_200',
        bg='rgb',bgm='sugar fairy',
    },
    score=function(P) return {math.min(P.stat.row,200),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Lines   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.row
        if L>=200 then
            local T=P.stat.time
            return
            T<=180 and 5 or
            T<=240 and 4 or
            3
        else
            return
            L>=150 and 3 or
            L>=90 and 2 or
            L>=40 and 1 or
            L>=1 and 0
        end
    end,
}
