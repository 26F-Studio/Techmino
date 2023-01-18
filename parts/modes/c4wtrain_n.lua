return {
    env={
        drop=30,lock=60,infHold=true,
        freshLimit=15,ospin=false,
        hook_drop=require'parts.eventsets.c4wCheck_easy'.hook_drop,
        eventSet='c4wBase',
        bg='rgb',bgm='oxygen',
    },
    score=function(P) return {math.min(P.modeData.maxCombo,100),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Combo   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.row
        if L>=100 then
            local T=P.stat.time
            return
            T<=32 and 5 or
            T<=50 and 4 or
            T<=80 and 3 or
            2
        else
            return
            L>=60 and 2 or
            L>=30 and 1 or
            L>=10 and 0
        end
    end,
}
