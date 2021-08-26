return{
    dropPiece=function(P)
        if P.stat.atk>=100 then
            P:win('finish')
        end
    end
}