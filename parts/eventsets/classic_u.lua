local gc_setColor=love.graphics.setColor
return{
    das=16,arr=6,
    sddas=1,sdarr=1,
    irs=false,ims=false,
    drop=1,lock=1,
    wait=10,fall=25,
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
        local r=P.modeData.target/10
        mStr(r==1 and 29 or("%02x"):format(r*10-20),63,210)
        mText(TEXTOBJ.speedLV,63,290)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        if P.modeData.drought>7 then
            if P.modeData.drought<=14 then
                gc_setColor(1,1,1,P.modeData.drought/7-1)
            else
                local gb=P.modeData.drought<=21 and 2-P.modeData.drought/14 or .5
                gc_setColor(1,gb,gb)
            end
            setFont(50)
            mStr(P.modeData.drought,63,130)
            mDraw(MODES.drought_l.icon,63,200,nil,.5)
        end
    end,
    task=function(P)
        P.modeData.target=10
    end,
    hook_drop=function(P)
        local D=P.modeData
        if P.stat.row>=D.target then
            if D.target==100 then
                P:win('finish')
                return
            end
            D.target=D.target+10
            SFX.play('reach')
        end
    end,
}
