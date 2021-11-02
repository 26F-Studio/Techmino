return{
    fillClear=false,
    mesDisp=function(P)
        setFont(60)
        mStr(P.stat.row,63,280)
        mText(TEXTOBJ.line,63,350)
    end,
    dropPiece=function(P)
        if #P.field>P.gameEnv.fieldH then
            local cc=P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
            local h=P.gameEnv.fieldH-cc-P.garbageBeneath-2
            if h>0 then
                P:garbageRise(21,h,2e10-1)
                if P.garbageBeneath>=P.gameEnv.fieldH then
                    P:lose()
                end
            end
        end
    end,
}