return{
    dropPiece=function(P)
        if P.stat.row>=400 then
            P:win('finish')
        end
    end
}