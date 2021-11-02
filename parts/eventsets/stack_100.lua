return{
    fillClear=false,
    dropPiece=function(P)
        if #P.field>P.gameEnv.fieldH then
            local cc=P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
            local h=P.gameEnv.fieldH-cc-P.garbageBeneath
            if h>0 then
                P:garbageRise(21,h,2e10-1)
                if P.garbageBeneath>=P.gameEnv.fieldH then
                    P:lose()
                end
            end
        end
    end,
}