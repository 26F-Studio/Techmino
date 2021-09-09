local gc=love.graphics
local sectionName={"D","C","B","A","A+","S-","S","S+","S+","SS","SS","U","U","X","X+"}
local passPoint=16

return{
    drop=0,
    lock=15,
    wait=15,
    fall=6,
    mesDisp=function(P)
        gc.setColor(1,1,1,.1)
        local h=(3600-P.stat.frame)/10
        gc.rectangle('fill',0,475-h,125,h,4)
        gc.setColor(COLOR.Z)
        mText(drawableText.line,63,310)
        mText(drawableText.techrash,63,420)
        mText(drawableText.grade,63,180)
        setFont(20)
        mStr(("%.1f"):format(P.modeData.rankPoint/10),63,208)
        setFont(55)
        mStr(P.modeData.rankName,63,125)
        setFont(75)
        mStr(P.stat.row,63,230)
        mStr(P.stat.clears[4],63,340)
    end,
    dropPiece=function(P)
        if P.modeData.rankPoint<140-passPoint then--If Less then X
            local R=#P.clearedRow
            if R>0 then
                if R==4 then R=10 end--Techrash +10
                P.modeData.rankPoint=math.min(P.modeData.rankPoint+R,140-passPoint)
                P.modeData.rankName=sectionName[math.floor(P.modeData.rankPoint/10)+1]
            end
        end
    end,
    task=function(P)
        P.modeData.rankPoint=0
        P.modeData.rankName=sectionName[1]
        while true do
            YIELD()
            if P.stat.frame>=3600 then
                P.modeData.rankPoint=math.min(P.modeData.rankPoint+passPoint,140)
                P.modeData.rankName=sectionName[math.floor(P.modeData.rankPoint/10)+1]
                P:win('finish')
                return
            end
        end
    end,
}
