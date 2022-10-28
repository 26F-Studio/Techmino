return {
    env={
        drop=60,lock=60,
        eventSet='sprintSym',
        bg='aura',bgm='there',
    },
    getRank=function(P)
        if P.stat.row<40 then return end
        local T=P.stat.time
        return
            T<=40 and 5 or
            T<=60 and 5 or
            T<=90 and 4 or
            T<=120 and 3 or
            T<=150 and 2 or
            T<=240 and 1 or
            0
    end,
}
