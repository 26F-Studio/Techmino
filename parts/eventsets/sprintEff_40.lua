return {
    mesDisp=function(P)
        setFont(45)
        GC.mStr(("%d"):format(P.stat.atk),63,270)
        mText(TEXTOBJ.atk,63,323)
        GC.mStr(("%.2f"):format(P.stat.atk/P.stat.row),63,370)
        mText(TEXTOBJ.eff,63,423)

        setFont(55)
        local r=40-P.stat.row
        if r<0 then r=0 end
        GC.mStr(r,63,170)
        PLY.draw.drawTargetLine(P,r)
    end,
    hook_drop=function(P)
        if P.stat.row>=40 then
            P:win('finish')
        end
    end
}
