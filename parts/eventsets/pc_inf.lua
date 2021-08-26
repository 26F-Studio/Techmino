return function(P)
    if P.lastPiece.pc then
        P.gameEnv.heightLimit=4
        if P.stat.pc%5==0 then
            P.gameEnv.drop=math.max(P.gameEnv.drop-1,1)
        end
    else
        P.gameEnv.heightLimit=P.gameEnv.heightLimit-P.lastPiece.row
    end
    if #P.field>P.gameEnv.heightLimit then
        P:lose()
    end
end