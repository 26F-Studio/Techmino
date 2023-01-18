return {
    env={
        drop=10,lock=60,
        freshLimit=15,
        hook_drop={
            require'parts.eventsets.backfire_60'.hook_drop,
            require'parts.eventsets.checkAttack_100'.hook_drop,
        },
        mesDisp=function(P)
            setFont(60)
            GC.mStr(P.stat.atk,63,280)
            mText(TEXTOBJ.atk,63,350)
        end,
        bg='tunnel',bgm='echo',
    },
    score=function(P) return {math.min(math.floor(P.stat.atk),100),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Attack  "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.atk
        if L>=100 then
            local T=P.stat.time
            return
            T<50 and 5 or
            T<65 and 4 or
            T<100 and 3 or
            T<130 and 2 or
            1
        else
            return
            L>=50 and 0
        end
    end,
}
