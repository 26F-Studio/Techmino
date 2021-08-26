return{
    dropPiece=function(P)
        if P.stat.row>=1000 then
            P:win('finish')
        end
    end
}