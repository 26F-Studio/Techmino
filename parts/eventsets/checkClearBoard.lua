return {
    hook_drop=function(P)
        if P.garbageBeneath==0 then
            local D=P.modeData
            D.finished=D.finished+1
            if FIELD[D.finished+1] then
                P.waiting=26
                for i=#P.field,1,-1 do
                    P.field[i],P.visTime[i]=nil
                end
                setField(P,D.finished+1)
                SYSFX.newShade(1.4,P.absFieldX,P.absFieldY,300*P.size,610*P.size,.6,.8,.6)
                SFX.play('warn_1')
            else
                P:win('finish')
            end
        end
    end,
}
