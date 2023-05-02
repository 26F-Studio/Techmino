return {
    mesDisp=function(P)
        setFont(60)
        GC.mStr(P.modeData.tsd,63,250)
        mText(TEXTOBJ.tsd,63,315)
        local L=P.modeData.history
        if L[1] and L[1]==L[2] and L[1]==L[3] then
            PLY.draw.applyField(P)
            GC.setColor(1,.3,.3,.2)
            GC.rectangle('fill',30*L[1]-30,0,30,600)
            PLY.draw.cancelField()
        end
    end,
    hook_drop=function(P)
        local C=P.lastPiece
        if C.row>0 then
            if C.id==5 and C.row==2 and C.spin then
                local L=P.modeData.history
                if L[1]==C.centX and L[1]==L[2] and L[1]==L[3] then
                    P:showText("STACK",0,-140,40,'flicker',.3)
                    P:lose()
                else
                    P.modeData.tsd=P.modeData.tsd+1
                    table.insert(L,1,C.centX)
                    L[4]=nil
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
