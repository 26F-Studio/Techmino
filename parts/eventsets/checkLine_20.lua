return{
    dropPiece=function(P)
        if P.stat.row>=20 then
            P:win('finish')
        end
    end
}