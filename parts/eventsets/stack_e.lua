return{
    fieldH=20,
    fillClear=false,
    mesDisp=function(P)
        setFont(60)
        mStr(P.stat.row,63,280)
        mText(TEXTOBJ.line,63,350)
        PLY.draw.drawMarkLine(P,20,.3,1,1,TIME()%.42<.21 and .95 or .6)
    end,
    hook_die=function(P)
        local cc=P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
        if cc>0 then
            local h=20-cc-P.garbageBeneath
            if h<-1 and P.garbageBeneath>0 then
                for i=1,math.min(P.garbageBeneath,-h-1) do
                    LINE.discard(table.remove(P.field,1))
                    LINE.discard(table.remove(P.visTime,1))
                end
            elseif h>0 then
                P:garbageRise(21,h,2e10-1)
                if P.garbageBeneath>=20 then
                    P:lose()
                end
            end
        end
    end,
}