local gc_setColor,gc_draw=love.graphics.setColor,love.graphics.draw
local ply_applyField=PLY.draw.applyField
local function getOpenHole(num)
    return -math.abs(((num-1) % 18)-9)+10
end
local F={}

-- local ranks={"10","9","8","7","6","5","4","3","2","1","S1","S2","S3","S4","S5","S6","S7","S8","S9","GM","GM+","TM","TM+","TM+₂","TM+₃", "TM+₄","TM+₅"}
--        lines:   0   1   2   3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20    21   22     23     24      25     26

local function getSmallNum(num)
    local smalldigit={[0]="₀","₁","₂","₃","₄","₅","₆","₇","₈","₉"}
    local str=tostring(num)
    local out=""
    for i=1,#str do
        out=out..smalldigit[tonumber(string.sub(str,i,i))]
    end
    return out
end

local function getRank(index)
    if index<11 then -- rank 10 - 1
        return tostring(11-index)
    elseif index<20 then -- S1 - S9 ranks
        return "S"..index-10
    elseif index<24 then -- GM, GM+, TM, TM+ ranks
        local r={"GM","GM+","TM","TM+"}
        return r[index-19]
    else
        return "TM+"..getSmallNum(index-22)
    end
end

local function generateGuide(num)
    local l=#F
    if l>num then 
        return 
    end
    for i=l,num do
        F[i] = {}
        local h=getOpenHole(i)
        for j=1,10 do
            F[i][j]=h==j and -1 or 21
        end
    end
end

return {
    fkey1=function(P) P.modeData.showGuide=not P.modeData.showGuide end,
    mesDisp=function(P)
        mText(TEXTOBJ.grade,63,190)
        mText(TEXTOBJ.line,63,310)
        setFont(55)
        GC.mStr(getRank(P.modeData.rankPts),63,125)
        GC.mStr(P.modeData.rankPts-1,63,245)
        ply_applyField(P)
        local mark=TEXTURE.puzzleMark
        gc_setColor(1,1,1)
        if P.modeData.showGuide then
            for y=1,P.modeData.rankPts+1 do for x=1,10 do
                local T=F[y][x]
                if T~=0 then
                    gc_draw(mark[T],30*x-30,600-30*y)
                end
            end end
        end
        PLY.draw.cancelField()
    end,
    task=function(P)
        P.modeData.rankPts=1
        P.modeData.showGuide=true
        generateGuide(10)
    end,
    hook_drop=function(P)
        local D=P.modeData
        D.rankPts=1
        for i=1,#P.field do
            local h=getOpenHole(i)
            local flag
            for j=1,10 do
                if P.field[i][j]>0 and h==j then flag=true break end-- goto post_pts_calc
                if P.field[i][j]==0 and h~=j then flag=true break end-- goto post_pts_calc
            end
            if flag then break end
            if i==#P.field then break end-- goto post_pts_calc
            if P.field[i+1][h]==0 then break end-- goto post_pts_calc
            D.rankPts=D.rankPts+1
        end
        -- ::post_pts_calc::
        generateGuide(D.rankPts+20)
    end
}
