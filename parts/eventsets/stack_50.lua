return{
    fillClear=false,
    dropPiece=function(P)
        if #P.field>P.gameEnv.fieldH then
            local cc=P:checkClear(P.field,P.garbageBeneath+1,#P.field-P.garbageBeneath)
            if cc>0 then
                SFX.play('clear_'..math.min(cc,6))
                P:showText(text.clear[cc]or cc.."-crash",0,0,60,'beat',.4)
                P:removeClearedLines()
                P.falling=P.gameEnv.fall
                P.stat.row=P.stat.row+cc
            end
            local h=math.ceil((P.gameEnv.fieldH-cc-P.garbageBeneath)/2)
            if h>0 then
                P:garbageRise(21,h,2e10-1)
                if P.garbageBeneath>=P.gameEnv.fieldH then
                    P:lose()
                end
            end
        end
    end,
}