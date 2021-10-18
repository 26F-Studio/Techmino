return{
    mesDisp=function(P)
        setFont(60)
        mStr(P.stat.clear[7][4],63,250)
        mText(TEXTOBJ.techrash,63,315)
    end,
    dropPiece=function(P)
        if P.lastPiece.row>0 and P.lastPiece.row<4 then
            P:lose()
        end
    end,
}
