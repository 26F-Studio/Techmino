return {
    env={
        drop=60,lock=60,
        eventSet='sprintMD',
        bg='aura',bgm='waterfall',
    },
    getRank=function(P)
        if P.stat.row<40 then return end
        local T=P.stat.time
        return
            T<=30 and 5 or
            T<=42 and 5 or
            T<=60 and 4 or
            T<=100 and 3 or
            T<=150 and 2 or
            T<=210 and 1 or
            0
    end,
}
