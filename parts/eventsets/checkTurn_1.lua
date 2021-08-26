return{
    dropPiece=function(P)
        if #PLY_ALIVE>1 then
            P.control=false
            local ID=P.id
            repeat
                ID=ID+1
                if not PLAYERS[ID]then ID=1 end
            until PLAYERS[ID].alive or ID==P.id
            PLAYERS[ID].control=true
        end
    end
}