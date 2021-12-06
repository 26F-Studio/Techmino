local dropSpeed={100,80,60,48,36,28,20,16,12,10,8,6,4,2,2,1,1,.5,.5}

return
{
    drop=120,
    wait=8,
    fall=20,
    fieldH=10,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        PLY.draw.drawTargetLine(P,200-P.stat.row)
    end,
    task=function(P)
        local F=P.field
        for i=1,24 do
            F[i]=LINE.new(20)
            P.visTime[i]=LINE.new(20)
            for x=3,7 do F[i][x]=0 end
        end
        P.modeData.target=10
    end,
    hook_drop=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==200 then
                P:win('finish')
            else
                P.gameEnv.drop=dropSpeed[P.modeData.target/10]
                P.modeData.target=P.modeData.target+10
                SFX.play('reach')
            end
        end
    end
}
