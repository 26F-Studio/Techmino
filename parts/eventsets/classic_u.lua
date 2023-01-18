local function GetLevelStr(lvl)
    local list={"01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","00","0A","14","1E","28","32","3C","46","50","5A","64","6E","78","82","8C","96","A0","AA","B4","BE","C6","20","E6","20","06","21","26","21","46","21","66","21","86","21","A6","21","C6","21","E6","21","06","22","26","22","46","22","66","22","86","22","A6","22","C6","22","E6","22","06","23","26","23","85","A8","29","F0","4A","4A","4A","4A","8D","07","20","A5","A8","29","0F","8D","07","20","60","A6","49","E0","15","10","53","BD","D6","96","A8","8A","0A","AA","E8","BD","EA","96","8D","06","20","CA","A5","BE","C9","01","F0","1E","A5","B9","C9","05","F0","0C","BD","EA","96","38","E9","02","8D","06","20","4C","67","97","BD","EA","96","18","69","0C","8D","06","20","4C","67","97","BD","EA","96","18","69","06","8D","06","20","A2","0A","B1","B8","8D","07","20","C8","CA","D0","F7","E6","49","A5","49","C9","14","30","04","A9","20","85","49","60","A5","B1","29","03","D0","78","A9","00","85","AA","A6","AA","B5","4A","F0","5C","0A","A8","B9","EA","96","85","A8","A5","BE","C9","01","D0","0A","A5","A8","18","69","06","85","A8","4C","BD","97","A5","B9","C9","04","D0","0A","A5","A8","38","E9","02","85","A8","4C","BD","97","A5","A8"}
    list[0]="00"
    lvl=lvl%256
    return list[lvl]
end
return {
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
        GC.mStr(GetLevelStr(P.modeData.lvl),63,210)
        mText(TEXTOBJ.speedLV,63,290)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        if P.modeData.drought>7 then
            if P.modeData.drought<=14 then
                GC.setColor(1,1,1,P.modeData.drought/7-1)
            else
                local gb=P.modeData.drought<=21 and 2-P.modeData.drought/14 or .5
                GC.setColor(1,gb,gb)
            end
            setFont(50)
            GC.mStr(P.modeData.drought,63,130)
            mDraw(MODES.drought_l.icon,63,200,nil,.5)
        end
    end,
    task=function(P)
        P.modeData.lvl=29
        P.modeData.target=10
    end,
    hook_drop=function(P)
        local D=P.modeData
        D.drought=P.lastPiece.id==7 and 0 or D.drought+1
        if P.stat.row>=D.target then
            if D.target>=200 then P:win('finish') return end
            SFX.play('reach')
            D.lvl=D.lvl+1
            D.target=D.target+10
        end
    end,
}
