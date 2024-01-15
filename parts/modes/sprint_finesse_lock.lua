return {
    env={
        arr=0,
        drop=1e99,lock=60,
        freshLimit=15,
        eventSet='sprint_finesse_lock',
        bg='flink',bgm='infinite',
    },
    getRank=function(P)
        if P.stat.row<40 then return end
        local T=P.stat.time
        return
            T<=30 and 5 or
            T<=42 and 4 or
            T<=62 and 3 or
            T<=126 and 2 or
            T<=226 and 1 or
            0
    end,
}
