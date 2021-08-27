return{
    mesDisp=function(P)
        setFont(60)
        mStr(P.modeData.tsd,63,250)
        mText(drawableText.tsd,63,315)
    end,
    dropPiece=function(P)
        local C=P.lastPiece
        if C.row>0 then
            if C.id==5 and C.row==2 and C.spin then
                P.modeData.tsd=P.modeData.tsd+1
            else
                P:lose()
            end
        end
    end,
    task=function(P)
        P.modeData.history={}
    end,
}