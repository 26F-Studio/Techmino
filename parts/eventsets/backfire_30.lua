return {
    hook_drop=function(P)
        if P.lastPiece.atk>0 then
            P:receive(nil,P.lastPiece.atk,30,generateLine(P.holeRND:random(10)))
        end
    end,
}
