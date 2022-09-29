local function GetLevelStr(lvl)
    local list={[0]="00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","00","0A","14","1E","28","32","3C","46","50","5A","64","6E","78","82","8C","96","A0","AA","B4","BE","C6","20","E6","20","06","21","26","21","46","21","66","21","86","21","A6","21","C6","21","E6","21","06","22","26","22","46","22","66","22","86","22","A6","22","C6","22","E6","22","06","23","26","23","85","A8","29","F0","4A","4A","4A","4A","8D","07","20","A5","A8","29","0F","8D","07","20","60","A6","49","E0","15","10","53","BD","D6","96","A8","8A","0A","AA","E8","BD","EA","96","8D","06","20","CA","A5","BE","C9","01","F0","1E","A5","B9","C9","05","F0","0C","BD","EA","96","38","E9","02","8D","06","20","4C","67","97","BD","EA","96","18","69","0C","8D","06","20","4C","67","97","BD","EA","96","18","69","06","8D","06","20","A2","0A","B1","B8","8D","07","20","C8","CA","D0","F7","E6","49","A5","49","C9","14","30","04","A9","20","85","49","60","A5","B1","29","03","D0","78","A9","00","85","AA","A6","AA","B5","4A","F0","5C","0A","A8","B9","EA","96","85","A8","A5","BE","C9","01","D0","0A","A5","A8","18","69","06","85","A8","4C","BD","97","A5","B9","C9","04","D0","0A","A5","A8","38","E9","02","85","A8","4C","BD","97","A5","A8"}
    lvl=lvl%256
    return list[lvl]
end
local function GetGravity(lvl)
    lvl=lvl%256
    return
    lvl==0 and 48 or
    lvl==1 and 43 or
    lvl==2 and 38 or
    lvl==3 and 33 or
    lvl==4 and 28 or
    lvl==5 and 23 or
    lvl==6 and 18 or
    lvl==7 and 13 or
    lvl==8 and 8 or
    lvl==9 and 6 or
    lvl<13 and 5 or
    lvl<16 and 4 or
    lvl<19 and 3 or
    lvl<29 and 2 or
    1
end
local gc_setColor,abs=love.graphics.setColor,math.abs
local movement,spawnTime,firstMoveTime
local hz,realHz,mistime,mt --mistime is in MILLISECONDS, not seconds
local function onMove(n,t)
    if movement==0 then
        firstMoveTime=t
        mt=((t-spawnTime)*1000)
        mistime=(
            mt<1 and "0 ms"or
            mt<99.5 and ("%.1f"):format(tostring(mt)).." ms"or
            mt<999.5 and math.floor(mt).." ms"or
            ("%.1f"):format(mt/1000).." s"
        )
    end
    movement=movement+n
    if abs(movement)>=2 then hz=abs(movement/(t-firstMoveTime))end
    realHz=abs(movement/(t-spawnTime))
end
local function hzGetColor(_hz)
    if _hz<10 or _hz~=_hz then return{1,1,1}
    elseif _hz<15 then return{1,1,0}
    elseif _hz<18 then return{1,.75,0}
    elseif _hz<25 then return{1,.5,0}
    elseif _hz<40 then return{1,0,0}
    elseif _hz<1e99 then return{.5,0,1}
    else return{1,0,1}end
end
local function mistimeGetColor(t)
    if t<1 then return{0,1,1}
    else return {COLOR.hsv(math.max(.4-1/9*math.log(t,20),0),1,1)}end
end
return{
    das=16,arr=6,
    sddas=2,sdarr=2,
    irs=false,ims=false,
    drop=2,lock=2,
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
        mStr(GetLevelStr(P.modeData.lvl),63,210)
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

        gc_setColor(hzGetColor(hz))
        local dispHz=(
            (hz~=hz or hz<.005) and "-----"or -- nan
            hz==math.huge and "∞"or
            hz>=99.5 and math.floor(hz)or
            hz>=9.95 and ("%.1f"):format(hz)or
            ("%.2f"):format(hz)
        )
        setFont(50)
        mStr(dispHz,40,40)
        gc_setColor(1,1,1)
        setFont(24)
        mStr("Hz",110,65)

        dispHz=(
            (realHz~=realHz or realHz<.005) and "-----"or -- nan
            realHz==math.huge and "∞"or
            realHz>=99.5 and math.floor(realHz)or
            realHz>=9.95 and ("%.1f"):format(realHz)or
            ("%.2f"):format(realHz)
        )
        setFont(20)
        mStr({"(",hzGetColor(realHz),dispHz,{1,1,1}," Hz - ",mistimeGetColor(mt),mistime,{1,1,1},")"},40,100)
    end,
    task=function(P)
        P.modeData.lvl=19
        P.modeData.target=10
        movement=0
        spawnTime=P.stat.time
        firstMoveTime=P.stat.time
        hz=0
        realHz=0
        mistime="0 ms"
        mt=0
    end,
    hook_drop=function(P)
        local D=P.modeData
        D.drought=P.lastPiece.id==7 and 0 or D.drought+1
        if P.stat.row>=D.target then
            --if D.target>=200 then
                D.lvl=D.lvl+1
            --end
            local dropSpd=GetGravity(D.lvl)
            if dropSpd~=P.gameEnv.drop then
                P.gameEnv.drop,P.gameEnv.lock=dropSpd,dropSpd
                P.gameEnv.sddas,P.gameEnv.sdarr=dropSpd,dropSpd
                SFX.play('warn_1')
            else
                SFX.play('reach')
            end
            D.target=D.target+10
        end
    end,
    hook_spawn=function(P)
        spawnTime=P.stat.time
        firstMoveTime=P.stat.time
        movement=0
    end,
    hook_left=function(P)onMove(-1,P.stat.time)end,
    hook_right=function(P)onMove(1,P.stat.time)end,
}
