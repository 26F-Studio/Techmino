return {
    env={
        drop=30,lock=60,
        block=false,center=0,ghost=0,
        dropFX=0,lockFX=0,
        visible='none',
        score=false,
        freshLimit=15,
        mesDisp=require"parts.eventsets.blindMesDisp".mesDisp,
        eventSet='checkLine_100',
        bg='rgb',bgm='far',
    },
    score=function(P) return {math.min(P.stat.row,100),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Lines   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.row
        return
        L>=100 and 5 or
        L>=75 and 4 or
        L>=50 and 3 or
        L>=26 and 2 or
        L>=10 and 1 or
        L>=1 and 0
    end,
}
