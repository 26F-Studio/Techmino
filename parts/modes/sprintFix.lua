return {
    env={
        drop=60,lock=180,
        keyCancel={1,2,11,12,17,18,19,20},
        eventSet='checkLine_40',
        bg='aura',bgm='there',
    },
    getRank=function(P)
        local L=P.stat.row
        if L<40 then
            return
            L>25 and 2 or
            L>10 and 1 or
            L>5 and 0
        end
        local T=P.stat.time
        return
        T<=260 and 5 or
        T<=420 and 4 or
        3
    end,
}
