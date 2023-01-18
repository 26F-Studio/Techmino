return {
    env={
        drop=60,lock=60,
        freshLimit=15,
        ospin=false,
        eventSet='techrash_n',
        bg='matrix',bgm='magicblock',
    },
    getRank=function(P)
        local T=P.stat.clear[7][4]
        return
        T>=100 and 5 or
        T>=75 and 4 or
        T>=50 and 3 or
        T==30 and 2 or
        T>=15 and 1 or
        T>=5 and 0
    end,
}
