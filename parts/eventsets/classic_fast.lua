return{
    mesDisp=function(P)
        setFont(75)
        local r=P.modeData.target*.1
        mStr(r<11 and 18 or r<22 and r+8 or("%02x"):format(r*10-220),63,210)
        mText(drawableText.speedLV,63,290)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
    end,
    task=function(P)
        P.gameEnv.das=16
        P.gameEnv.arr=6
        P.gameEnv.sddas=2
        P.gameEnv.sdarr=2
        P.gameEnv.irs=false
        P.gameEnv.ims=false
        P.gameEnv.drop=3
        P.gameEnv.lock=3
        P.gameEnv.wait=10
        P.gameEnv.fall=25
        P.gameEnv.fieldH=19
        P.gameEnv.nextCount=1
        P.gameEnv.holdCount=0
        P.gameEnv.RS='Classic'
        P.gameEnv.sequence='rnd'
        P.gameEnv.noTele=true
        P.gameEnv.keyCancel={5,6}

        P.modeData.target=10
    end,
    dropPiece=function(P)
        local D=P.modeData
        if P.stat.row>=D.target then
            D.target=D.target+10
            if D.target==110 then
                P.gameEnv.drop,P.gameEnv.lock=2,2
                SFX.play('blip_1')
            elseif D.target==200 then
                P.gameEnv.drop,P.gameEnv.lock=1,1
                SFX.play('blip_1')
            else
                SFX.play('reach')
            end
        end
    end,
}