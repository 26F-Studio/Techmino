return {
    mesDisp=function(P)
        setFont(55)
        local r=40-P.stat.row
        if r<0 then r=0 end
        GC.mStr(r,63,265)
        PLY.draw.drawTargetLine(P,r)
    end,
    task=function(P)
        coroutine.yield()
        while true do
            for _=1,P.holeRND:random(40,200) do coroutine.yield() end
            local r=P.holeRND:random(7)
            if r==1 then
                if P.cur and not P:ifoverlap(P.cur.bk,P.curX-1,P.curY) then
                    P:createMoveFX('left')
                    P.curX=P.curX-1
                    P:freshBlock('move')
                end
            elseif r==2 then
                if P.cur and not P:ifoverlap(P.cur.bk,P.curX-1,P.curY) then
                    P:createMoveFX('left')
                    P.curX=P.curX-1
                    P:freshBlock('move')
                end
            elseif r==3 then
                P:act_rotRight()
            elseif r==4 then
                P:act_rotLeft()
            elseif r==5 then
                P:act_rot180()
            elseif r==6 then
                P:act_hardDrop()
            elseif r==7 then
                P:act_hold()
            end
        end
    end,
    hook_drop=function(P)
        if P.stat.row>=40 then
            P:win('finish')
        end
    end
}
