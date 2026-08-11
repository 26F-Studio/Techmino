return {
    env={
        lock=1e99, infHold=true,
        bg='bg2',bgm='way',
        mesDisp=function(P)
            setFont(55)
            GC.mStr(10-P.modeData.digQuad,63,265)
        end,
        hook_drop=function(P)
            if P.lastPiece.row>0 and P.lastPiece.row<4 then
                P:lose()
            else
                P.modeData.digQuad=P.stat.dig
                if P.lastPiece.row==4 and P.lastPiece.dig==0 then
                    P.modeData.extraQuad=P.modeData.extraQuad+1
                end
            end
            if P.stat.dig==10 then
                P:win('finish')
            end
        end,
        task=function(P)
            local last=-1
            for _=1,10 do
                local garbage=last
                repeat
                    garbage=P:getHolePos()
                until garbage~=last
                last=garbage
                P:garbageRise(21,1,garbage)
            end
            P.fieldBeneath=0
            P.modeData.digQuad,P.modeData.extraQuad=0,0
        end,
    },
    score=function(P) return {P.modeData.digQuad,P.stat.time} end,
    scoreDisp=function(D) return D[1].." Lines "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local dig=P.modeData.digQuad
        local extraQuad=P.modeData.extraQuad
        return MATH.clamp((
            dig==10 and 5 or
            dig>=7 and 4 or
            dig>=5 and 3 or
            dig>=3 and 2 or
            dig>=2 and 1 or
            0
        )-math.floor(extraQuad^.62),0,5)
    end,
}
