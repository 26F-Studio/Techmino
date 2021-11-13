return{
    mesDisp=function(P)
        setFont(45)
        mStr(("%.1f"):format(P.stat.atk),63,190)
        mStr(("%.2f"):format(P.stat.atk/P.stat.row),63,310)
        mText(TEXTOBJ.atk,63,243)
        mText(TEXTOBJ.eff,63,363)
        PLY.draw.drawTargetLine(P,40-P.stat.row)
    end,
    hook_drop=function(P)
        if P.stat.row>=40 then
            P:win('finish')
        end
    end
}
