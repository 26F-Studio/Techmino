local function tech_check_hard(P)
    local C=P.lastPiece
    if C.row>0 then
        if not C.special then
            P:lose()
            return
        end
    end
    if P.stat.atk>=100 then
        P:win('finish')
    end
end

return {
    env={
        arr=0,
        drop=1e99,lock=60,
        freshLimit=15,
        fineKill=true,
        hook_drop=tech_check_hard,
        bg='flink',bgm='infinite',
    },
    slowMark=true,
    score=function(P) return {P.stat.atk<=100 and math.floor(P.stat.atk) or 100,P.stat.time} end,
    scoreDisp=function(D) return D[1].." Attack  "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local A=P.stat.atk
        if A>=100 then
            local T=P.stat.time
            return
            T<50 and 5 or
            T<70 and 4 or
            T<100 and 3 or
            2
        else
            return
            A>=60 and 1 or
            A>=30 and 0
        end
    end,
}
