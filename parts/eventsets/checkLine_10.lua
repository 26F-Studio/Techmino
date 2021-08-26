return{
    dropPiece=function(P)
        if P.stat.row>=10 then
            P:win('finish')
        end
    end
}