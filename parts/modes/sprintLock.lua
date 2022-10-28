return {
    env={
        drop=60,lock=180,
        keyCancel={3,4,5},
        eventSet='checkLine_40',
        bg='aura',bgm='there',
    },
    getRank=function(P)
        local L=P.stat.row
        return
        L>=40 and 5 or
        L>=32 and 4 or
        L>=24 and 3 or
        L>=16 and 2 or
        L>=10 and 1 or
        L>=5 and 0
    end,
}
