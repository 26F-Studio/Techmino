return{
    dropPiece=function(P)
        if P.stat.row>=40 then
            P:win('finish')
        end
    end
}