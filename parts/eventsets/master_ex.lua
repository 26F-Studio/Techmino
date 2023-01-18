local sectionName={"D","C","B","A","A+","S-","S","S+","S+","SS","SS","U","U","X","X+"}
local passPoint=16

local function getRollGoal(P)
    -- get amount of grades needed for X+
    local rem=12.4-P.modeData.rankPoint/10
    if rem<=0 then return 0 end
    local goal=math.floor(rem)*4
    rem=rem%1
    return goal+(rem>0.3 and 4 or rem*10)
end

return {
    drop=0,lock=15,
    wait=15,fall=6,
    noTele=true,
    minarr=1,
    nextCount=3,
    sequence='hisPool',
    visible='fast',
    freshLimit=15,
    noInitSZO=true,
    mesDisp=function(P)
        local h=(3600-P.stat.frame)/10
        if h>0 then
            GC.setColor(1,1,1,.12)
            GC.rectangle('fill',0,475-h,125,h,4)
            GC.setColor(COLOR.Z)
        end
        mText(TEXTOBJ.line,63,310)
        mText(TEXTOBJ.techrash,63,420)
        mText(TEXTOBJ.grade,63,180)
        setFont(20)
        GC.mStr(("%.1f"):format(P.modeData.rankPoint/10),63,208)
        setFont(55)
        GC.mStr(P.modeData.rankName,63,125)
        setFont(75)
        GC.mStr(P.stat.row,63,230)
        GC.mStr(P.stat.clears[4],63,340)
        PLY.draw.drawTargetLine(P,getRollGoal(P))
    end,
    hook_drop=function(P)
        if P.modeData.rankPoint<140-passPoint then-- If Less then X
            local R=#P.clearedRow
            if R>0 then
                if R==4 then R=10 end-- Techrash +10
                P.modeData.rankPoint=math.min(P.modeData.rankPoint+R,140-passPoint)
                P.modeData.rankName=sectionName[math.floor(P.modeData.rankPoint/10)+1]
            end
        end
    end,
    task=function(P)
        P.modeData.rankPoint=0
        P.modeData.rankName=sectionName[1]
        while true do
            coroutine.yield()
            if P.stat.frame>=3600 then
                P.modeData.rankPoint=math.min(P.modeData.rankPoint+passPoint,140)
                P.modeData.rankName=sectionName[math.floor(P.modeData.rankPoint/10)+1]
                P:win('finish')
                return
            end
        end
    end,
}
