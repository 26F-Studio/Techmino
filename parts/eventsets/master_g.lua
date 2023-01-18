local regretDelay=-1
local int_grade=0
local grade_points=0
local int_grade_boosts={0,1,2,3,4,5,5,6,6,7,7,7,8,8,8,9,9,9,10,11,12,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26}
local coolList={false,false,false,false,false,false,false,false,false}
local regretList={false,false,false,false,false,false,false,false,false,false}
local gradeList={
    "9","8","7","6","5","4","3","2","1",
    "S1","S2","S3","S4","S5","S6","S7","S8","S9",
    "m1","m2","m3","m4","m5","m6","m7","m8","m9",
    "M","MK","MV","MO","MM-","MM","MM+","GM-","GM","GM+","TM-","TM","TM+"
}
local spd_lvl=0
local cools=0
local regrets=0
local prevSectTime=0
local isInRoll=false
local rollGrades=0
local cool_time={3120,3120,2940,2700,2700,2520,2520,2280,2280,0}
local reg_time= {5400,4500,4500,4080,3600,3600,3000,3000,3000,3000}
local prevDrop70=false -- determines if previous piece has level less than __70
local nextSpeedUp=false -- determines if the next section speed should be boosted by 100
local isInRollTrans=false
local function getGrav(l)
    return
    l<30  and 64   or
    l<35  and 43   or
    l<40  and 32   or
    l<50  and 26   or
    l<60  and 21   or
    l<70  and 16   or
    l<80  and 8    or
    l<90  and 6    or
    l<120 and 4    or
    l<160 and 3    or
    l<200 and 2    or
    l<220 and 64   or
    l<230 and 8    or
    l<233 and 4    or
    l<236 and 3    or
    l<243 and 2    or
    l<300 and 1    or
    l<360 and 0.5  or
    l<450 and 0.25 or
    0
end
local function getLock(l)
    return
    l<900  and 30 or
    l<1100 and 19 or
    15
end
local function getWait(l)
    return
    l<700  and 23 or
    l<800  and 16 or
    l<1000 and 12 or
    l<1100 and 7  or
    6
end
local function getFall(l)
    return
    l<500  and 25 or
    l<600  and 18 or
    l<700  and 12 or
    l<800  and 8 or
    4
end
local function getDas(l)
    return
    l<500  and 10 or
    l<900  and 8 or
    6
end
local function getGrade()
    if int_grade==nil then int_grade=0 end
    if rollGrades==nil then rollGrades=0 end
    return gradeList[math.max(math.min(math.floor(int_grade_boosts[math.min(int_grade+1,#int_grade_boosts)]+rollGrades+cools+1-regrets),#gradeList),1)]
end
local function addGrade(row, cmb, lvl) -- IGS = internal grade system
    if row<1 then return end
    local pts=0
    local cmb_mult=1.0
    local lvl_mult=math.floor(lvl/250)+1

    if row==1 then
        pts=int_grade<5 and 10 or int_grade<10 and 5 or 2
        cmb_mult=1.0
    elseif row==2 then
        pts=int_grade<3 and 20 or int_grade<6 and 15 or int_grade<10 and 10 or 12
        cmb_mult=cmb==1 and 1 or cmb<4 and 1.2 or cmb<8 and 1.4 or cmb<10 and 1.5 or 2.0
    elseif row==3 then
        pts=int_grade==0 and 40 or int_grade<4 and 30 or int_grade<7 and 20 or int_grade<10 and 15 or 13
        cmb_mult=cmb==1 and 1 or cmb<10 and 1+(cmb+2)*0.1 or 2
    else
        pts=int_grade==0 and 50 or int_grade<5 and 40 or 30
        cmb_mult=cmb==1 and 1 or cmb==2 and 1.5 or cmb<6 and (0.2*cmb)+1.2 or cmb<10 and (0.1*cmb)+1.7 or 3
    end

    grade_points=grade_points+(pts*cmb_mult*lvl_mult)
    if grade_points>=100 then
        grade_points=0
        int_grade=int_grade+1
    end
end
local function getRollGoal()
    -- get amount of grades needed for TM+
    local rem=#gradeList-(int_grade_boosts[math.min(int_grade+1,#int_grade_boosts)]+rollGrades+cools+1-regrets)
    if rem<=0 then return 0 end
    local goal=0
    if cools>8 then
        goal=math.floor(rem)*4
        rem=rem%1
        return goal+(rem>0.3 and 4 or rem*10)
    else
        goal=math.floor(rem/0.26)*4
        rem=rem%0.26
        return goal+(rem>0.12 and 4 or rem*25)
    end
end

return {
    drop=64,
    lock=30,
    wait=23,
    fall=25,
    keyCancel={10,11,12,14,15,16,17,18,19,20},
    das=16,arr=1,
    minsdarr=1,
    ihs=true,irs=true,ims=false,
    mesDisp=function(P)
        GC.setColor(1,1,1,1)
        setFont(45)
        mText(TEXTOBJ.grade,63,180)
        setFont(60)
        GC.mStr(getGrade(),63,110)  -- draw grade
        for i=1,10 do -- draw cool/regret history
            if not (coolList[i] or regretList[i]) then -- neither cool nor regret
                GC.setColor(0.6,0.6,0.6,P.modeData.pt<(i-1)*100 and 0.25 or 0.6)
            else
                GC.setColor(regretList[i] and 1 or 0, coolList[i] and 1 or 0, 0, 1)
            end
            GC.circle('fill',-10,150+i*25,10)
            GC.setColor(1,1,1,1)
        end
        if isInRoll then
            setFont(20)
            GC.mStr(("%.1f"):format(rollGrades),63,208) -- draw roll grades
            GC.setLineWidth(2)
            GC.setColor(.98,.98,.98,.8)
            GC.rectangle('line',0,240,126,80,4)
            GC.setColor(.98,.98,.98,.4)
            GC.rectangle('fill',0+2,240+2,126-4,80-4,2) -- draw time box
            setFont(45)
            local t=(P.stat.frame-prevSectTime)/60
            local T=("%.1f"):format(60-t)
            GC.setColor(COLOR.dH)
            GC.mStr(T,65,250) -- draw time
            t=t/60
            GC.setColor(1.7*t,2.3-2*t,.3)
            GC.mStr(T,63,248)
            PLY.draw.drawTargetLine(P,getRollGoal())
        else
            -- draw level counter
            setFont(20)
            GC.mStr(grade_points,63,208)
            setFont(45)
            if coolList[math.ceil(P.modeData.pt/100+0.01)] then
                GC.setColor(0,1,0,1)
            elseif P.stat.frame-prevSectTime > cool_time[math.ceil(P.modeData.pt/100+0.01)] then
                GC.setColor(0.7,0.7,0.7,1)
            end
            if coolList[math.ceil(P.modeData.pt/100+0.01)] and regretList[math.ceil(P.modeData.pt/100+0.01)] then
                GC.setColor(1,1,0,1)
            elseif regretList[math.ceil(P.modeData.pt/100+0.01)] then
                GC.setColor(1,0,0,1)
            end
            PLY.draw.drawProgress(P.modeData.pt,P.modeData.target)
        end
    end,
    hook_drop=function(P)
        local D=P.modeData

        local c=#P.clearedRow

        if cools>8 and isInRoll then
            rollGrades=rollGrades+(c==4 and 1 or 0.1*c)
            return
        elseif isInRoll then
            rollGrades=rollGrades+(c==4 and 0.26 or 0.04*c)
            return
        end

        if c==0 and D.pt+1>=D.target then return end
        local s=c<3 and c+1 or c==3 and 5 or 7
        if P.combo>7 then s=s+2
        elseif P.combo>3 then s=s+1
        end

        addGrade(c,P.combo,D.pt)

        D.pt=D.pt+s
        spd_lvl=spd_lvl+1

        P.gameEnv.drop=getGrav(spd_lvl)

        if (P.gameEnv.drop==0) then
            P:set20G(true)
        end

        if D.pt%100>70 and not prevDrop70 then
            if P.stat.frame-prevSectTime < cool_time[math.ceil(D.pt/100)] then
                cools=cools+1
                coolList[math.ceil(D.pt/100)]=true
                P:_showText("COOL!",0,-120,80,'fly',.8)
                nextSpeedUp=true
            end
            prevDrop70=true
        end

        if D.pt+1==D.target then
            SFX.play('warn_1')
        elseif D.pt>=D.target then-- Level up!
            spd_lvl=nextSpeedUp and spd_lvl+100 or spd_lvl
            nextSpeedUp=false
            prevDrop70=false
            s=D.target/100
            local E=P.gameEnv
            E.lock=getLock(spd_lvl)
            E.wait=getWait(spd_lvl)
            E.fall=getFall(spd_lvl)
            E.das=getDas(spd_lvl)

            if P.stat.frame-prevSectTime > reg_time[math.ceil(s)] then
                regrets=regrets+1
                regretDelay=60
            end
            prevSectTime=P.stat.frame
            if s==2 then
                BG.set('rainbow')
            elseif s==4 then
                BG.set('rainbow2')
            elseif s==5 then
                if P.stat.frame>420*60 then
                    D.pt=500
                    P:win('finish')
                    return
                else
                    BG.set('glow')
                    BGM.play('secret7th remix')
                end
            elseif s==6 then
                BG.set('lightning')
            elseif s>9 then
                if cools>8 then
                    if E.lockFX and E.lockFX>1 then E.lockFX=1 end
                    P:setInvisible(5)
                else
                    P:setInvisible(300)
                end
                D.pt=999
                P.waiting=240
                BGM.stop()
                isInRollTrans=true
                return
            end
            D.target=D.target<900 and D.target+100 or 999
            P:stageComplete(s)
            SFX.play('reach')
        end
    end,
    task=function(P)
        regretDelay=-1
        P.modeData.pt=0
        P.modeData.target=100
        int_grade=0
        grade_points=0
        rollGrades=0
        spd_lvl=0
        cools=0
        regrets=0
        prevSectTime=0
        isInRoll=false
        isInRollTrans=false
        prevDrop70=false
        nextSpeedUp=false
        coolList={false,false,false,false,false,false,false,false,false}
        regretList={false,false,false,false,false,false,false,false,false,false}
        local decayRate={125,80,80,50,45,45,45,40,40,40,40,40,30,30,30,20,20,20,20,20,15,15,15,15,15,15,15,15,15,15,10,10,10,9,9,9,8,8,8,7,7,7,6}
        local decayTimer=0
        while true do
            coroutine.yield()
            P.modeData.grade=getGrade()
            P.modeData.gradePts=math.max(math.min(math.floor(int_grade_boosts[math.min(int_grade+1,#int_grade_boosts)]+rollGrades+cools+1-regrets),#gradeList),1)
            if P.stat.frame-prevSectTime > reg_time[math.ceil(P.modeData.pt/100+0.01)] and not (isInRoll or isInRollTrans) then
                regretList[math.ceil(P.modeData.pt/100)]=true
            end
            if regretDelay>-1 then
                regretDelay=regretDelay-1
                if regretDelay==-1 then P:_showText("REGRET!!",0,-120,80,'beat',.8) end
            end
            if isInRollTrans then
                if P.waiting>=220 then
                    -- Make field invisible
                    for y=1,#P.field do for x=1,10 do
                        P.visTime[y][x]=P.waiting-220
                    end end
                elseif P.waiting==190 then
                    TABLE.cut(P.field)
                    TABLE.cut(P.visTime)
                elseif P.waiting==180 then
                    playReadySFX(3,3)
                    P:_showText("3",0,-120,120,'fly',1)
                elseif P.waiting==120 then
                    playReadySFX(2,1)
                    P:_showText("2",0,-120,120,'fly',1)
                elseif P.waiting==60 then
                    playReadySFX(1,1)
                    P:_showText("1",0,-120,120,'fly',1)
                elseif P.waiting==1 then
                    playReadySFX(0,1)
                    isInRollTrans=false
                    isInRoll=true
                    BGM.play('hope')
                    BG.set('blockspace')
                    prevSectTime=P.stat.frame
                end
            end
            if P.waiting<=0 and grade_points>0 and not isInRoll then
                decayTimer=decayTimer+1
                if decayTimer>=decayRate[math.min(int_grade+1,#decayRate)] then
                    decayTimer=0
                    grade_points=grade_points-1
                end
            elseif isInRoll and P.stat.frame>=prevSectTime+3599 then
                rollGrades=rollGrades+(cools>8 and 1.6 or 0.5)
                P.modeData.grade=getGrade()
                P.modeData.gradePts=math.min(math.floor(int_grade_boosts[math.min(int_grade+1,#int_grade_boosts)]+rollGrades+cools+1-regrets),#gradeList)
                coroutine.yield()
                P:win('finish')
            end
        end
    end,
}
