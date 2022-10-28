local inv_lock={60,50,45,40,37, 34,32,30,28,26}
local inv_wait={12,11,11,10,10, 10,10, 9, 9, 9}
local inv_fall={18,16,14,13,12, 12,11,11,10,10}
local inv_hide={20,17,14,11, 8,  5, 3, 2, 1, 0}
local hidetimer=0
local held=false

return {
    drop=0,
    lock=inv_lock[1],
    wait=inv_wait[1],
    fall=inv_fall[1],
    ghost=false,
    noTele=true,
    das=10,arr=1,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.modeData.pt,P.modeData.target)
    end,
    hook_drop=function(P)
        local D=P.modeData

        local c=#P.clearedRow
        if c==0 and D.pt%100==99 then
            if D.pt<1000 then
                hidetimer=0-inv_wait[(P.modeData.pt/100-(P.modeData.pt%100)/100)+1]
                if c>0 then hidetimer=hidetimer-inv_fall[(P.modeData.pt/100-(P.modeData.pt%100)/100)+1] end
            end
            return
        end
        local s=c<3 and c+1 or c==3 and 5 or 7
        if P.combo>7 then s=s+2
        elseif P.combo>3 then s=s+1
        end
        D.pt=D.pt+s
        held=false
        if D.pt<1000 then
            hidetimer=0-inv_wait[(P.modeData.pt/100-(P.modeData.pt%100)/100)+1]
            if c>0 then hidetimer=hidetimer-inv_fall[(P.modeData.pt/100-(P.modeData.pt%100)/100)+1] end
        end

        if D.pt%100==99 then
            SFX.play('warn_1')
        elseif D.pt>=D.target then-- Level up!
            s=D.target/100
            local E=P.gameEnv
            E.lock=inv_lock[s]
            E.wait=inv_wait[s]
            E.fall=inv_fall[s]

            if s==2 then
                E.das=8
            elseif s==4 then
                BG.set('rgb')
            elseif s==5 then
                E.das=7
            elseif s==7 then
                E.das=6
                BGM.play('far')
            elseif s==8 then
                BG.set('none')
            elseif s==10 then
                D.pt=1000
                P:win('finish')
                return
            end
            D.target=D.target+100
            P:stageComplete(s)
            SFX.play('reach')
        end
    end,
    task=function(P)
        P.modeData.pt=0
        P.modeData.target=100
        while true do
            coroutine.yield()
            if P.holdTime==0 and P.waiting<=0 and not held then
                hidetimer=0
                held=true
            end
            hidetimer=hidetimer+1
            if hidetimer>inv_hide[(P.modeData.pt/100-(P.modeData.pt%100)/100)+1] then
                P.gameEnv.block=false
            else
                P.gameEnv.block=true
            end
        end
    end,
}
