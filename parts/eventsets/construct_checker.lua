local gc_setColor,gc_draw=love.graphics.setColor,love.graphics.draw
local ply_applyField=PLY.draw.applyField

local holePatterns={
    {-1,21,-1,21,-1,21,-1,21,-1,21},
    {21,-1,21,-1,21,-1,21,-1,21,-1}
}

local targetField={}

local function generateGuide(y,mirror)
    local tfLength=#targetField
    if tfLength>y then return end
    mirror=mirror and 1 or 0
    for i=tfLength,y do
        table.insert(targetField,TABLE.shift(
            holePatterns[(i+mirror)%2+1]
        ))
    end
end

local function calculateRankPts(P)
    local points=1
    for y=1,#P.field do
        local flag
        for x=1,10 do
            -- X guide is filled
            if P.field[y][x]>0 and targetField[y][x]<0 then flag=true break end
            -- Block guide is empty
            if P.field[y][x]==0 and targetField[y][x]>0 then flag=true break end
        end
        if flag then break end
        points=points+1
    end
    P.modeData.rankPts=points
    P.modeData.maxRankPts=math.max(points,P.modeData.maxRankPts)
end

return {
    fkey1=function(P) P.modeData.showGuide=not P.modeData.showGuide end,
    fkey2=function(P)
        P.modeData.mirror=not P.modeData.mirror
        TABLE.cut(targetField)
        generateGuide(#P.field+10,P.modeData.mirror)
        calculateRankPts(P)
    end,
    mesDisp=function(P)
        local D=P.modeData
        mText(TEXTOBJ.grade,63,190)
        mText(TEXTOBJ.line,63,310)
        setFont(55)
        GC.mStr(getConstructGrade(D.rankPts),63,125)
        GC.mStr(D.rankPts-1,63,245)

        -- Display highest grade
        if D.maxRankPts>D.rankPts then
            gc_setColor(COLOR.lX)
            setFont(20)
            GC.mStr(text.highestGrade:repD(getConstructGrade(D.maxRankPts)),63,216)
            GC.mStr(text.highestGrade:repD(D.maxRankPts-1),63,336)
        end

        if not D.showGuide then return end
        ply_applyField(P)
        local mark=TEXTURE.puzzleMark
        local firstMistake=nil
        for y=1,D.rankPts+1 do
            for x=1,10 do
                local texture=targetField[y][x]
                -- Missing blocks
                if not P:solid(x,y) and texture>0 then
                    -- Missing block under overhang
                    if P:solid(x,y+1) then
                        firstMistake=firstMistake or y
                        gc_setColor(COLOR.R)
                    else
                        gc_setColor(COLOR.Z)
                    end
                    gc_draw(mark[texture],30*x-30,600-30*y)
                elseif texture<0 then
                    -- X always gets displayed, color changes based on whether there is a block there
                    if P:solid(x,y) then
                        gc_setColor(COLOR.R)
                        firstMistake=firstMistake or y
                    elseif D.rankPts>y then
                        gc_setColor(COLOR.G)
                    else
                        gc_setColor(COLOR.Z)
                    end
                    gc_draw(mark[texture],30*x-30,600-30*y)
                end
            end
            if y==firstMistake then
                gc_setColor(1,0,0,.2*(math.sin(2*TIME())+1))
                love.graphics.rectangle("fill",0,600-30*y,300,30)
            end
        end
        PLY.draw.cancelField()
    end,
    task=function(P)
        local D=P.modeData
        D.rankPts=1
        D.maxRankPts=1
        D.showGuide=true
        D.mirror=false
        TABLE.cut(targetField)
        generateGuide(10)
    end,
    hook_drop=function(P)
        local D=P.modeData
        calculateRankPts(P)
        generateGuide(#P.field+10)
    end
}
