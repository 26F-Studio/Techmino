return{
    color=COLOR.green,
    env={
        drop=60,lock=180,
        keyCancel={3,4,5},
        eventSet='checkLine_40',
        bg='aura',bgm='waterfall',
    },
    getRank=function(P)
        local L=P.stat.row
        if L<40 then
            return
            L>25 and 2 or
            L>10 and 1 or
            L>2 and 0
        end
        local T=P.stat.time
        return
        T<=60 and 5 or
        T<=100 and 4 or
        3
    end,
}
