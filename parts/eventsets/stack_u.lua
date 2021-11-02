return{
    fieldH=21,
    fillClear=false,
    mesDisp=function(P)
        setFont(60)
        mStr(P.stat.row,63,280)
        mText(TEXTOBJ.line,63,350)
    end,
    dropPiece=function(P)
        if #P.field>20 then
            local cc=P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
            local h=20-cc-P.garbageBeneath-3
            if h>0 then
                P:garbageRise(21,h,2e10-1)
                if P.garbageBeneath>=20 then
                    P:lose()
                end
            end
        end
    end,
}