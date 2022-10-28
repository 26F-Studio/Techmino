return {
    hook_drop=function(P)
        if P.lastPiece.row==0 then
            P:lose()
        else
            for _=1,P.lastPiece.row do
                local h=#P.field
                P.field[h+1]=LINE.new(20)
                P.visTime[h+1]=LINE.new(20)
                for i=4,7 do P.field[h+1][i]=0 end
            end
            if P.combo>P.modeData.maxCombo then
                P.modeData.maxCombo=P.combo
            end
            if P.stat.row>=100 then
                P:win('finish')
            end
        end
    end
}
