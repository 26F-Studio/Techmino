return {
    env={
        drop=20,lock=60,
        sequence='bag',
        seqData={1,1,2,2,3,3,4,4,5,5,6,6},
        nextCount=3,
        ospin=false,
        freshLimit=15,
        eventSet='checkLine_100',
        bg='blockfall',bgm='reason',
    },
    score=function(P) return {math.min(P.stat.row,100),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Lines   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.row
        if L>=100 then
            local T=P.stat.time
            return
            T<=80 and 5 or
            T<=100 and 4 or
            T<=150 and 3 or
            T<=210 and 2 or
            1
        else
            return
            L>=50 and 1 or
            L>=10 and 0
        end
    end,
}
