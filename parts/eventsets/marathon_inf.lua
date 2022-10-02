local dropSpeed={
    50,42,35,30,25,20,16,13,11,10,
    9,8,7,6,5,5,4,4,3,3,
    3,2,2,2,2,1,1,1,1,1,
    .5,.5,.5,.5,.25,.25,.25,.125,.125,-- Total 39 numbers, switch to 20G when reach 400 lines
}
local lockDelay={
    57,54,51,48,46,44,42,40,38,36,
    34,32,30,28,26,25,24,23,22,21,
    20,20,19,19,18,18,17,17,16,16,
    15,15,14,14,13,13,13,12,12,12,
    11,11,11,11,11,10,10,10,10,10,
    9,9,9,9,9,9,8,8,8,8,
    8,8,8,8,7,7,7,7,7,7,
    7,7,6,6,6,6,6,6,6,6,
    5,5,5,5,5,5,5,5,5,5,
    4,4,4,4,4,4,4,4,4,4,
    3,3,3,3,3,3,3,3,3,3,
    2,2,2,2,2,2,2,2,2,2,
    1,1,1,1,1,1,1,1,1,-- Finish at 1700
}

return
{
    drop=60,lock=60,
    wait=8,fall=20,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
    end,
    task=function(P)
        P.modeData.target=10
    end,
    hook_drop=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target%300==0 then
                P.gameEnv.wait=P.gameEnv.wait-1
            end
            if P.modeData.target%100==0 then
                P.gameEnv.fall=P.gameEnv.fall-1
            end
            if P.modeData.target<400 then
                P.gameEnv.drop=dropSpeed[P.modeData.target/10]
            elseif P.modeData.target==400 then
                P:set20G(true)
            elseif P.modeData.target<1700 then
                P.gameEnv.lock=lockDelay[(P.modeData.target-400)/10]
            else
                P.stat.row=1700
                P:win('finish')
                return
            end
            P.modeData.target=P.modeData.target+10
            SFX.play('reach')
        end
    end
}