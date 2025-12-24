local function GetLevelStr(lvl)
    local list={"01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","00","0A","14","1E","28","32","3C","46","50","5A","64","6E","78","82","8C","96","A0","AA","B4","BE","C6","20","E6","20","06","21","26","21","46","21","66","21","86","21","A6","21","C6","21","E6","21","06","22","26","22","46","22","66","22","86","22","A6","22","C6","22","E6","22","06","23","26","23","85","A8","29","F0","4A","4A","4A","4A","8D","07","20","A5","A8","29","0F","8D","07","20","60","A6","49","E0","15","10","53","BD","D6","96","A8","8A","0A","AA","E8","BD","EA","96","8D","06","20","CA","A5","BE","C9","01","F0","1E","A5","B9","C9","05","F0","0C","BD","EA","96","38","E9","02","8D","06","20","4C","67","97","BD","EA","96","18","69","0C","8D","06","20","4C","67","97","BD","EA","96","18","69","06","8D","06","20","A2","0A","B1","B8","8D","07","20","C8","CA","D0","F7","E6","49","A5","49","C9","14","30","04","A9","20","85","49","60","A5","B1","29","03","D0","78","A9","00","85","AA","A6","AA","B5","4A","F0","5C","0A","A8","B9","EA","96","85","A8","A5","BE","C9","01","D0","0A","A5","A8","18","69","06","85","A8","4C","BD","97","A5","B9","C9","04","D0","0A","A5","A8","38","E9","02","85","A8","4C","BD","97","A5","A8"}
    list[0]="00"
    lvl=lvl%256
    return list[lvl]
end
local function getHzColor(hz)
    if not hz or hz<10 then return{1,1,1}
    elseif hz<15 then return{1,1,0}
    elseif hz<18 then return{1,.75,0}
    elseif hz<25 then return{1,.5,0}
    elseif hz<40 then return{1,0,0}
    elseif hz<1e99 then return{.5,0,1}
    else return{1,0,1}end
end
local function getMistimeColor(t)
    if not t then return {1,1,1}
    elseif t<1 then return{0,1,1}
    else return {COLOR.hsv(math.max(.4-1/9*math.log(t,8),0),1,1)}end
end
local function onMove(P,dir)
    local D=P.modeData

    if not D.firstMoveTimestamp then
        D.firstMoveTimestamp=P.stat.time
    end

    D.lastMoveTimestamp=P.stat.time

    D.displacement=math.abs(P.curX+dir-D.spawnX)
end
local function createMoveHandler(dir)
    return function(P) onMove(P,dir) end
end
return {
    das=16,arr=6,
    sddas=1,sdarr=1,
    logicalIRS=false,logicalIMS=false,
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
        local D=P.modeData

        setFont(75)
        GC.mStr(GetLevelStr(D.lvl),63,210)
        mText(TEXTOBJ.speedLV,63,290)
        PLY.draw.drawProgress(P.stat.row,D.target)
        if D.drought>7 then
            if D.drought<=14 then
                GC.setColor(1,1,1,D.drought/7-1)
            else
                local gb=D.drought<=21 and 2-D.drought/14 or .5
                GC.setColor(1,gb,gb)
            end
            setFont(50)
            GC.mStr(D.drought,63,130)
            mDraw(MODES.drought_l.icon,63,200,nil,.5)
        end

        -- Draw Hz counters
        local spawnHz=(
            D.firstMoveTimestamp and
            D.displacement/(D.lastMoveTimestamp-D.spawnTimestamp)
            or nil
        )
        local moveHz=(
            D.firstMoveTimestamp and
            D.displacement/(D.lastMoveTimestamp-D.firstMoveTimestamp)
            or nil
        )
        local mistime=(
            D.firstMoveTimestamp and
            1000*(D.firstMoveTimestamp-D.spawnTimestamp)
            or nil
        )

        local spawnHzStr="---"
        if spawnHz then
            if spawnHz<10 then
                spawnHzStr=string.format("%.2f",spawnHz)
            elseif spawnHz<100 then
                spawnHzStr=string.format("%.1f",spawnHz)
            elseif spawnHz<1e99 then
                spawnHzStr=string.format("%.0f",spawnHz)
            else
                spawnHzStr="∞"
            end
        end

        local moveHzStr="---"
        if moveHz then
            if moveHz<10 then
                moveHzStr=string.format("%.2f",moveHz)
            elseif moveHz<100 then
                moveHzStr=string.format("%.1f",moveHz)
            elseif spawnHz<1e99 then
                moveHzStr=string.format("%.0f",moveHz)
            else
                moveHzStr="∞"
            end
        end

        local mistimeStr="---"
        if mistime then
            if mistime<10 then
                mistimeStr=string.format("%.2f",mistime)
            elseif mistime<100 then
                mistimeStr=string.format("%.1f",mistime)
            else
                mistimeStr=string.format("%.0f",mistime)
            end
        end

        GC.setColor(getHzColor(spawnHz))
        setFont(50)
        GC.mStr(spawnHzStr,30,40)

        GC.setColor(1,1,1)
        setFont(24)
        GC.mStr("Hz",110,65)

        setFont(20)
        GC.mStr(
            {
                "(",getHzColor(moveHz),moveHzStr,{1,1,1}," Hz - ",
                getMistimeColor(mistime),mistimeStr,{1,1,1}," ms)"
            },
            40,100
        )
    end,
    task=function(P)
        local D=P.modeData

        D.lvl=29
        D.target=10

        D.spawnX=0
        D.spawnTimestamp=P.stat.time
        D.firstMoveTimestamp=false
        D.lastMoveTimestamp=false
        D.displacement=0
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
    hook_spawn=function(P)
        local D=P.modeData
        D.spawnX=P.curX
        D.spawnTimestamp=P.stat.time
        D.firstMoveTimestamp=false
        D.lastMoveTimestamp=false
    end,
    hook_left=createMoveHandler(-1),
    hook_right=createMoveHandler(1),
}
