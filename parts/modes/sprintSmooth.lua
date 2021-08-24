return{
    color=COLOR.green,
    env={
        drop=0,lock=120,
        nextCount=3,
        das=0,arr=0,
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
        if P.stat.row<40 then return end
        local T=P.stat.time
        return
        T<=30 and 5 or
        T<=45 and 4 or
        T<=60 and 3 or
        T<=90 and 2 or
        T<=150 and 1 or
        0
    end,
}