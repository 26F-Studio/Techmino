return{
    das=16,
    arr=6,
    sddas=2,
    sdarr=2,
    irs=false,
    ims=false,
    drop=3,
    lock=3,
    wait=10,
    fall=25,
    freshLimit=0,
    fieldH=19,
    nextCount=1,
    holdCount=0,
    RS='Classic',
    sequence='rnd',
    noTele=true,
    keyCancel={5,6},
    mesDisp=function(P)
        setFont(75)
        local r=P.modeData.target*.1
        mStr(r<11 and 18 or r<22 and r+8 or("%02x"):format(r*10-220),63,210)
        mText(drawableText.speedLV,63,290)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
    end,
    task=function(P)
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
