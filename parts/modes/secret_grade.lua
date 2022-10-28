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
        return "Grade "..tostring(11-index)
    elseif index<20 then -- S1 - S9 ranks
        return "S"..index-10
    elseif index<24 then -- GM, GM+, TM, TM+ ranks
        local r={"GM","GM+","TM","TM+"}
        return r[index-19]
    else
        return "TM+"..getSmallNum(index-22)
    end
end

return {
    env={
        drop=180,lock=180,
        hang=15,
        eventSet='secret_grade',
        bg='bg2',bgm='race',
    },
    score=function(P) return {P.modeData.rankPts,P.stat.piece} end,
    scoreDisp=function(D) return getRank(D[1]).."   "..D[2].." Pieces" end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local G=P.modeData.rankPts
        return
        G>=23 and 5 or
        G>=21 and 4 or
        G>=19 and 3 or
        G>=15 and 2 or
        G>=11 and 1 or
        G>=7 and 0
    end,
}
