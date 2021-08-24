return{
    color=COLOR.green,
    env={
        drop=60,lock=180,
        noTele=true,
        keyCancel={1,2},
        dropPiece=function(P)if P.stat.row>=40 then P:win('finish')end end,
        bg='aura',bgm='waterfall',
    },
    mesDisp=function(P)
        setFont(55)
        local r=40-P.stat.row
        if r<0 then r=0 end
        mStr(r,63,265)
        PLY.draw.drawTargetLine(P,r)
    end,
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