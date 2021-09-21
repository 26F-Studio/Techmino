local rush_lock={20,18,16,15,14}
local rush_wait={12,10, 9, 8, 7}
local rush_fall={18,16,14,13,12}

return{
    drop=0,
    lock=rush_lock[1],
    wait=rush_wait[1],
    fall=rush_fall[1],
    mesDisp=function(P)
        PLY.draw.drawProgress(P.modeData.pt,P.modeData.target)
    end,
    dropPiece=function(P)
        local D=P.modeData

        local c=#P.clearedRow
        if c==0 and D.pt%100==99 then return end
        local s=c<3 and c+1 or c==3 and 5 or 7
        if P.combo>7 then s=s+2
        elseif P.combo>3 then s=s+1
        end
        D.pt=D.pt+s

        if D.pt%100==99 then
            SFX.play('blip_1')
        elseif D.pt>=D.target then--Level up!
            s=D.target/100
            local E=P.gameEnv
            BG.set(s==1 and'bg1'or s==2 and'bg2'or s==3 and'rainbow'or 'rainbow2')
            E.lock=rush_lock[s]
            E.wait=rush_wait[s]
            E.fall=rush_fall[s]
            E.das=10-s
            if s==2 then
                E.arr=2
            elseif s==4 then
                E.bone=true
            end

            if s==5 then
                D.pt=500
                P:win('finish')
            else
                D.target=D.target+100
                P:stageComplete(s)
            end
            SFX.play('reach')
        end
    end,
    task=function(P)
        P.modeData.pt=0
        P.modeData.target=100
    end,
}
