return
{
    drop=0,lock=15,
    wait=10,fall=10,
    noTele=true,
    das=5,arr=1,
    nextCount=2,
    sequence='his',
    mission={4,4,4,64},
    missionKill=true,
    freshLimit=12,
    noInitSZO=true,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.modeData.pt,P.modeData.target)
    end,
    hook_drop=function(P)
        local p=P.modeData.pt+P.lastPiece.row
        if p>=P.modeData.target then
            local ENV=P.gameEnv
            local T=P.modeData.target
            -- Stage 1: clear 3 techrash
            if T==12 then-- Stage 2: swap color of S/Z & J/L
                P:stageComplete(1)
                P.waiting=30
                P.curMission=false

                ENV.skin[1],ENV.skin[2]=ENV.skin[2],ENV.skin[1]
                ENV.skin[3],ENV.skin[4]=ENV.skin[4],ENV.skin[3]

                ENV.lock=14
                ENV.wait=7
                ENV.fall=7
                P:setNext(4)

                P.modeData.target=26
                SFX.play('reach')
            elseif T==26 then-- Stage 3: dig to bottom
                P:stageComplete(2)
                if not P.holdQueue[1] then-- 1 up if ban hold
                    P.life=P.life+1
                end
                P.waiting=45
                ENV.skin[1],ENV.skin[2]=ENV.skin[2],ENV.skin[1]
                ENV.skin[3],ENV.skin[4]=ENV.skin[4],ENV.skin[3]

                for i=1,10 do
                    if P.field[i] then
                        for j=1,10 do
                            if P.field[i][j]>0 then
                                P.field[i][j]=17
                                P.visTime[i][j]=15
                            end
                        end
                        for _=1,5 do
                            P.field[i][P.holeRND:random(10)]=0
                        end
                    else
                        P.field[i]=LINE.new(0)
                        P.visTime[i]=LINE.new(30)
                        for j=1,10 do
                            if P.holeRND:random()>.9 then
                                P.field[i][j]=P.holeRND:random(16)
                            end
                        end
                        P.field[i][P.holeRND:random(10)]=0
                    end
                    P.field[i].garbage=true
                end
                P.garbageBeneath=10
                for i=1,10 do
                    P:createClearingFX(i,1.5)
                end
                SYSFX.newShade(2.5,P.absFieldX,P.y+300*P.size,300*P.size,300*P.size)

                ENV.lock=13
                ENV.wait=6
                ENV.fall=6
                P:setNext(5)

                P.modeData.target=42
                SFX.play('reach')
            elseif T==42 then-- Stage 4: survive in high speed
                if P.garbageBeneath==0 then
                    P:stageComplete(3)
                    P.waiting=30
                    ENV.lock=11
                    P:setNext(6)
                    P:setHold(false)
                    ENV.bone=true

                    P.modeData.target=62
                    SFX.play('reach')
                else
                    p=41
                end
            elseif T==62 then-- Stage 5: survive without easy-fresh rule
                P:stageComplete(4)
                P.life=P.life+1
                ENV.lock=13
                ENV.wait=5
                ENV.fall=5

                ENV.easyFresh=false

                P.modeData.target=126
                SFX.play('reach')
            elseif T==126 then-- Stage 6: speed up
                P:stageComplete(5)
                P.life=P.life+1

                ENV.lock=11
                ENV.wait=4
                ENV.fall=4

                P.modeData.target=162
                SFX.play('reach')
            elseif T==162 then-- Stage 7: speed up+++
                P:stageComplete(6)
                P.life=P.life+1

                ENV.lock=10

                P:setHold(true)
                P:setInvisible(180)

                P.modeData.target=226
                SFX.play('reach')
            elseif T==226 then-- Stage 8: final invisible
                P:stageComplete(7)
                P.life=P.life+1

                ENV.bone=false
                P:setInvisible(90)

                P.modeData.target=259
                SFX.play('reach')
            elseif T==259 then-- Stage 9: ending
                P:stageComplete(8)
                P.life=P.life+1
                for i=1,7 do ENV.skin[i]=P.holeRND:random(16) end

                P:setInvisible(40)
                ENV.lock=15
                P.curMission=1
                ENV.mission={4,4,4,4,4,4,4,4}
                ENV.missionKill=false

                P.modeData.target=260
                p=260
                SFX.play('warn_2')
                SFX.play('reach')
            else
                p=260
            end
        end
        P.modeData.pt=p
    end,
    task=function(P)
        P.modeData.target=12
    end,
}
