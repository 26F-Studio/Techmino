return {
    mesDisp=function(P)
        setFont(60)
        GC.mStr(P.modeData.tsd,63,250)
        mText(TEXTOBJ.tsd,63,315)
        PLY.draw.applyField(P)
        local L=P.modeData.history
        for i=1,#L do
            GC.setColor(1,.3,.3,.4-i*.05)
            GC.rectangle('fill',30*L[i]-30,0,30,600)
        end
        PLY.draw.cancelField()
    end,
    hook_drop=function(P)
        local C=P.lastPiece
        if C.row>0 then
            if C.id==5 and C.row==2 and C.spin then
                if TABLE.find(P.modeData.history,C.centX) then
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
