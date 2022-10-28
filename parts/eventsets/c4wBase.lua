local rem=table.remove

return {
    mesDisp=function(P)
        setFont(45)
        GC.mStr(P.combo,63,310)
        GC.mStr(P.modeData.maxCombo,63,400)
        mText(TEXTOBJ.combo,63,358)
        mText(TEXTOBJ.maxcmb,63,450)
    end,
    task=function(P)
        local F=P.field
        for i=1,24 do
            F[i]=LINE.new(20)
            P.visTime[i]=LINE.new(20)
            for x=4,7 do F[i][x]=0 end
        end
        if P.holeRND:random()<.6 then
            local initCell={11,14,12,13,21,24}
            for _=1,3 do
                _=rem(initCell,P.holeRND:random(#initCell))
                F[math.floor(_/10)][3+_%10]=20
            end
        else
            local initCell={11,12,13,14,21,22,23,24}
            rem(initCell,P.holeRND:random(5,8))
            rem(initCell,P.holeRND:random(1,4))
            for _=1,6 do
                _=rem(initCell,P.holeRND:random(#initCell))
                F[math.floor(_/10)][3+_%10]=20
            end
        end
    end
}
