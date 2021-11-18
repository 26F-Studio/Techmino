local waitSpeed={30,29,28,27,26,25,24,23,22,21,20,19,18,18,17,17,16,16,15}

return
{
    drop=0,
    wait=60,
    fall=0,
	lock=6,
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
					P.modeData.lock=5
				end
                P.gameEnv.wait=waitSpeed[P.modeData.target/10]
                P.modeData.target=P.modeData.target+10
                SFX.play('reach')
            end
        end
    end
}
