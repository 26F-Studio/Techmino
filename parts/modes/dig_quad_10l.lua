return {
    env={
        pushSpeed=6,
        bg='bg1',bgm='way',
        mesDisp=function(P)
            setFont(55)
            GC.mStr(10-P.stat.dig_quad,63,265)
        end,
        hook_drop=function(P)
            if P.lastPiece.row>0 and P.lastPiece.row<4 then
                P:lose()
            else
                P.stat.dig_quad = P.stat.dig
            end
            if P.stat.dig==10 then
                P:win('finish')
            end
        end,
        task=function(P)
            local last = -1
            for _=1,10 do
                local garbage = last
                repeat
                    garbage = P:getHolePos()
                until garbage ~= last
                last = garbage
                P:garbageRise(21,1,garbage)
            end
            P.fieldBeneath=0
            P.stat.dig_quad = 0
        end,
    },
    score=function(P) return {P.stat.dig_quad,P.stat.piece} end,
    scoreDisp=function(D) return D[1].." Techrash "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local dig = P.stat.dig_quad
        local piece = P.stat.piece
        if dig < 4 then return end
        return
        dig < 7 and 0 or
        dig < 10 and 1 or
        piece > 103 and 2 or
        piece > 92 and 3 or
        piece > 81 and 4 or
        5
    end,
}
