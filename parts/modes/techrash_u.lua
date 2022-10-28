return {
    env={
        drop=60,lock=60,
        freshLimit=15,
        ospin=false,
        eventSet='techrash_u',
        bg='matrix',bgm='magicblock',
    },
    getRank=function(P)
        local T=P.stat.clear[7][4]
        return
        T>=20 and 5 or
        T>=16 and 4 or
        T>=12 and 3 or
        T==8 and 2 or
        T>=4 and 1 or
        T>=2 and 0
    end,
}
