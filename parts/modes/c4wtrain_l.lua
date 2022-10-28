return {
    env={
        drop=5,lock=30,
        freshLimit=15,ospin=false,
        hook_drop=require'parts.eventsets.c4wCheck_hard'.hook_drop,
        eventSet='c4wBase',
        bg='rgb',bgm='oxygen',
    },
    score=function(P) return {math.min(P.modeData.maxCombo,100),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Combo   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.modeData.maxCombo
        if L==100 then
            local T=P.stat.time
            return
            T<=40 and 5 or
            T<=60 and 4 or
            3
        else
            return
            L>=70 and 3 or
            L>=40 and 2 or
            L>=20 and 1 or
            L>=5 and 0
        end
    end,
}
