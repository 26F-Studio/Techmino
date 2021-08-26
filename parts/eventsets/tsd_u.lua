return{
    dropPiece=function(P)
        local C=P.lastPiece
        if C.row>0 then
            if C.id==5 and C.row==2 and C.spin then
                if TABLE.find(P.modeData.history,C.centX)then
                    P:showText("STACK",0,-140,40,'flicker',.3)
                    P:lose()
                else
                    P.modeData.tsd=P.modeData.tsd+1
                    table.insert(P.modeData.history,1,C.centX)
                    P.modeData.history[5]=nil
                end
            else
                P:lose()
            end
        end
    end,
    task=function(P)
        P.modeData.history={}
    end,
}