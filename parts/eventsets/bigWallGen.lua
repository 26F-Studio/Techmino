return {
    hook_drop=function(P)
        if P.lastPiece.row>0 then
            for _=1,#P.clearedRow do
                local h=#P.field
                P.field[h+1]=LINE.new(20)
                P.visTime[h+1]=LINE.new(20)
                for i=3,7 do P.field[h+1][i]=0 end
            end
            if P.combo>P.modeData.maxCombo then
                P.modeData.maxCombo=P.combo
            end
            if P.stat.row>=200 then
                P:win('finish')
            end
        end
    end
}
