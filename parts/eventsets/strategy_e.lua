local waitSpeed={60,59,58,57,56,55,54,52,50,48,46,44,42,40,38,36,34,32,30}

return
{
    drop=0,
    wait=60,
    fall=0,
	lock=7,
	freshLimit=12,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        PLY.draw.drawTargetLine(P,200-P.stat.row)
    end,
    task=function(P)
        P.modeData.target=10
    end,
    hook_drop=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target==200 then
                P:win('finish')
            else
				if P.modeData.target==100 then
					P.modeData.lock=6
				end
                P.gameEnv.wait=waitSpeed[P.modeData.target/10]
                P.modeData.target=P.modeData.target+10
                SFX.play('reach')
            end
        end
    end
}
