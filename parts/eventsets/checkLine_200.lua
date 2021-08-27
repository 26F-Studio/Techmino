return{
    dropPiece=function(P)
        if P.stat.row>=200 then
            P:win('finish')
        end
    end
}