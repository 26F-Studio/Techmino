return {
    fieldH=21,
    fillClear=false,
    mesDisp=function(P)
        setFont(60)
        GC.mStr(P.stat.row,63,280)
        mText(TEXTOBJ.line,63,350)
        PLY.draw.drawMarkLine(P,17,.3,1,1,TIME()%.42<.21 and .95 or .6)
    end,
    hook_die=function(P)
        local cc=P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
        if cc>0 then
            local clearH=cc+P.garbageBeneath
            if clearH<17 then
                P:garbageRise(21,17-clearH,2e10-1)
                if P.garbageBeneath>=17 then
                    P:lose()
                end
            elseif P.garbageBeneath>0 and clearH>17 then
                local bonus=math.min(P.garbageBeneath,clearH-17)
                if bonus>0 then
                    for _=1,bonus do
                        LINE.discard(table.remove(P.field,1))
                        LINE.discard(table.remove(P.visTime,1))
                    end
                    P.garbageBeneath=P.garbageBeneath-bonus
                end
            end
            P:freshBlock('push')
        end
    end,
}