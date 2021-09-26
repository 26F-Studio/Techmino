return{
    dropPiece=function(P)
        if #PLY_ALIVE>1 then
            P.control=false
            local id1=P.sid
            local minMaxID,minID=1e99,1e99
            for i=1,#PLY_ALIVE do
                local id2=PLY_ALIVE[i].sid
                if id2>id1 then
                    minMaxID=math.min(minMaxID,id2)
                else
                    minID=math.min(minID,id2)
                end
            end
            PLY_ALIVE[minMaxID==1e99 and minID or minMaxID].control=true
        end
    end
}
