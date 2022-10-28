return {
    drop=0,lock=12,
    wait=10,fall=10,
    noTele=true,
    das=5,arr=1,
    freshLimit=15,
    easyFresh=false,bone=true,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.modeData.pt,P.modeData.target)
    end,
    hook_drop=function(P)
        local D=P.modeData

        local c=#P.clearedRow
        if c==0 and D.pt%100==99 then return end
        local s=c<3 and c+1 or c==3 and 5 or 7
        if P.combo>7 then s=s+2
        elseif P.combo>3 then s=s+1
        end
        D.pt=D.pt+s

        if D.pt%100==99 then
            SFX.play('warn_1')
        elseif D.pt>=D.target then-- Level up!
            s=D.target/100-- range from 1 to 9
            local E=P.gameEnv
            if s<4 then
                P:stageComplete(s)
                -- First 300
                if s~=1 then E.lock=E.lock-1 end
                if s~=2 then E.wait=E.wait-1 end
                if s~=3 then E.fall=E.fall-1 end
                D.target=D.target+100
            elseif s<10 then
                if s==5 then BGM.play('distortion') end
                P:stageComplete(s)
                if s==4 or s==7 then E.das=E.das-1 end
                if s%3==0 then E.lock=E.lock-1
                elseif s%3==1 then E.wait=E.wait-1
                elseif s%3==2 then E.fall=E.fall-1
                end
                D.target=D.target+100
            else
                D.pt=1000
                P:win('finish')
            end
            SFX.play('reach')
        end
    end,
    task=function(P)
        P.modeData.pt=0
        P.modeData.target=100
    end,
}
