local waitSpeed={15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,7}

return
{
    drop=0,
    wait=60,
    fall=0,
	lock=5,
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
					P.modeData.lock=4
				end
                P.gameEnv.wait=waitSpeed[P.modeData.target/10]
                P.modeData.target=P.modeData.target+10
                SFX.play('reach')
            end
        end
    end
}
