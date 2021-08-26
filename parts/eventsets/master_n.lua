local rush_lock={20,18,16,15,14, 14,13,12,11,11}
local rush_wait={12,11,11,10,10, 10,10, 9, 9, 9}
local rush_fall={18,16,14,13,12, 12,11,11,10,10}

return{
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
            E.lock=rush_lock[s]
            E.wait=rush_wait[s]
            E.fall=rush_fall[s]

            if s==2 then
                E.das=8
                BG.set('rainbow')
            elseif s==4 then
                BG.set('rainbow2')
            elseif s==5 then
                if P.stat.frame>260*60 then
                    D.pt=500
                    P:win('finish')
                    return
                else
                    P.gameEnv.freshLimit=10
                    E.das=7
                    BG.set('glow')
                    BGM.play('secret8th remix')
                end
            elseif s==7 then
                E.das=6
                BG.set('lightning')
            elseif s==9 then
                E.bone=true
            elseif s==10 then
                D.pt=1000
                P:win('finish')
                return
            end
            D.target=D.target+100
            P:_showText(text.stage:gsub("$1",s),0,-120,80,'fly')
            SFX.play('reach')
        end
    end,
    task=function(P)
        P:set20G(true)
        P.lockDelay=rush_lock[1]
        P.gameEnv.lock=rush_lock[1]
        P.gameEnv.wait=rush_wait[1]
        P.gameEnv.fall=rush_fall[1]

        P.modeData.pt=0
        P.modeData.target=100
    end,
}