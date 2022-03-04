local gc=love.graphics
local gc_setColor=gc.setColor
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
        gc.setLineWidth(2)
        gc_setColor(.98,.98,.98,.8)
        gc.rectangle('line',-100,0,200,100,4)
        gc_setColor(.98,.98,.98,.4)
        gc.rectangle('fill',-100+2,0+2,200-4,100-4,2)
        gc_setColor(1,1,1,1)
        setFont(40)
        mStr("Score",0,0)
        gc_setColor(.6,.6,.6,1)
        local score_str=""
        local score_length=math.floor(math.log10(P.modeData.gameScore))
        for i=7,0,-1 do
            score_str=score_str..(math.floor(P.modeData.gameScore/(math.pow(10,i)))%10)
        end
        for i=1,8 do
            if score_length==-i+8 then gc_setColor(1,1,1,1) end
            mStr(string.sub(score_str,i,i),25*i-113,50)
        end
        gc_setColor(1,1,1,1)
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
        P.modeData.gameScore=0
    end,
    hook_drop=function(P)
        local D=P.modeData
        D.drought=P.lastPiece.id==7 and 0 or D.drought+1
        if P.stat.row>=D.target then
            if D.target==100 then
                P:win('finish')
            end
            D.target=D.target+10
            SFX.play('reach')
            D.target=D.target>=100 and 100 or D.target+10
            local r=D.target/10
            local l=#P.clearedRow
            P.modeData.gameScore=P.modeData.gameScore+((l==1 and 40 or l==2 and 100 or l==3 and 300 or 1200)*(r+30))
        elseif #P.clearedRow>0 then
            local r=D.target/10
            local l=#P.clearedRow
            P.modeData.gameScore=P.modeData.gameScore+((l==1 and 40 or l==2 and 100 or l==3 and 300 or 1200)*(r+30))
        end
    end,
}
