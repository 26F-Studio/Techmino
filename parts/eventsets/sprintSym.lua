local oppo={
    [1]=7,[7]=1,[11]=3,[3]=11,[14]=14,[4]=4,[9]=9,
}
return {
    skin={
        1,7,11,3,14,4,9,
        1,7,2,6,10,2,13,5,9,15,10,11,3,12,2,16,8,4,
        10,13,2,8
    },
    mesDisp=function(P)
        setFont(55)
        local r=40-P.stat.row
        if r<0 then r=0 end
        GC.mStr(r,63,265)
        PLY.draw.drawTargetLine(P,r)
    end,
    hook_drop=function(P)
        local F=P.field
        for y=1,#F do
            local l=F[y]
            for x=1,5 do
                if l[x]>0 and l[11-x]>0 and oppo[l[x]]~=l[11-x] then
                    P:lose()
                    return
                end
            end
        end
        if P.stat.row>=40 then
            P:win('finish')
        end
    end
}
