return {
    env={
        drop=30,lock=60,infHold=true,
        freshLimit=15,ospin=false,
        hook_drop=require'parts.eventsets.c4wCheck_easy'.hook_drop,
        eventSet='c4wBase',
        bg='rgb',bgm='oxygen',
    },
    score=function(P) return {math.min(P.stat.row,100),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Lines   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.row
        if L>=100 then
            local T=P.stat.time
            return
                T<=32.6 and 5 or
                T<=49.5 and 4 or
                T<=94.2 and 3 or
                2
        else
            return
                L>=42 and 1 or
                L>=26 and 0
        end
    end,
}
