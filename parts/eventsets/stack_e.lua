return{
    fieldH=20,
    fillClear=false,
    mesDisp=function(P)
        setFont(60)
        mStr(P.stat.row,63,280)
        mText(TEXTOBJ.line,63,350)
        PLY.draw.drawMarkLine(P,20,.3,1,1,TIME()%.42<.21 and .95 or .6)
    end,
    hook_drop=function(P)
        if #P.field>20 then
            local cc=P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
            local h=20-cc-P.garbageBeneath
            if h>0 then
                P:garbageRise(21,h,2e10-1)
                if P.garbageBeneath>=20 then
                    P:lose()
                end
            end
        end
    end,
}