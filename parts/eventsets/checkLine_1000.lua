return {
    mesDisp=function(P)
        setFont(55)
        local r=1000-P.stat.row
        if r<0 then r=0 end
        GC.mStr(r,63,265)
        PLY.draw.drawTargetLine(P,r)
    end,
    hook_drop=function(P)
        if P.stat.row>=1000 then
            P:win('finish')
        end
    end
}
