local death_lock={12,11,10,9,8, 7,7,7,6,6}
local death_wait={10, 9, 8,7,6, 6,5,4,4,3}
local death_fall={10, 9, 8,7,6, 5,5,4,3,3}

return{
    drop=0,
    lock=death_lock[1],
    wait=death_wait[1],
    fall=death_fall[1],
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
            SFX.play('reach')
            E.lock=death_lock[s]
            E.wait=death_wait[s]
            E.fall=death_fall[s]
            E.das=math.floor(6.9-s*.4)
            if s==1 then
                BG.set('rainbow')
            elseif s==2 then
                BG.set('rainbow2')
            elseif s==3 then
                BG.set('glow')
            elseif s==5 then
                if P.stat.frame>183*60 then
                    D.pt=500
                    P:win('finish')
                    return
                else
                    P.gameEnv.freshLimit=10
                    BG.set('lightning')
                    BGM.play('secret7th remix')
                end
            elseif s==10 then
                D.pt=1000
                P:win('finish')
                return
            end
            D.target=D.target+100
            P:stageComplete(s)
        end
    end,
    task=function(P)
        P.modeData.pt=0
        P.modeData.target=100
    end,
}
