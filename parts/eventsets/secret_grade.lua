local gc_setColor,gc_draw=love.graphics.setColor,love.graphics.draw
local ply_applyField=PLY.draw.applyField
local function GetOpenHole(num)
    return -math.abs(((num-1) % 18)-9)+10
end
local F={}
local ranks={"10","9","8","7","6","5","4","3","2","1","S1","S2","S3","S4","S5","S6","S7","S8","S9","GM","GM+","TM","TM+","TM+₂","TM+₃", "TM+₄","TM+₅"}
--     lines:  0   1   2   3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20    21   22     23     24      25     26
return
{
    fkey1=function(P)P.modeData.showGuide=not P.modeData.showGuide end,
    mesDisp=function(P)
        mText(TEXTOBJ.grade,63,190)
        setFont(55)
        mStr(ranks[P.modeData.rankPts],63,125)
        
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
        PLY.draw.cancelField(P)
    end,
    task=function(P)
        P.modeData.rankPts=1
        P.modeData.showGuide=true
        for i=1,50 do
            F[i] = {}
            local h=GetOpenHole(i)
            for j=1,10 do
                F[i][j]=h==j and -1 or 21
            end
        end
    end,
    hook_drop=function(P)
        local Pf=P.field
        local D=P.modeData
        D.rankPts=1
        for i=1,#P.field do
            local h=GetOpenHole(i)
            for j=1,10 do
                if P.field[i][j]>0 and h==j then return end
                if P.field[i][j]==0 and h~=j then return end
            end
            if i==#P.field then return end
            if P.field[i+1][h]==0 then return end
            D.rankPts=D.rankPts+1
        end
    end
}
