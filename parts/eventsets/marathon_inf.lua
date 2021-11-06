local dropSpeed={50,40,30,24,18,14,10,8,6,5,4,3,2,1,1,.5,.5,.25,.125,0}

return
{
    drop=60,
    wait=8,
    fall=20,
    mesDisp=function(P)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
    end,
    task=function(P)
        P.modeData.target=10
    end,
    dropPiece=function(P)
        if P.stat.row>=P.modeData.target then
            if P.modeData.target>200 then
				P:set20G(true)
            else
				P.gameEnv.drop=dropSpeed[P.modeData.target/10]
            end
			P.modeData.target=P.modeData.target+10
            SFX.play('reach')
        end
    end
}