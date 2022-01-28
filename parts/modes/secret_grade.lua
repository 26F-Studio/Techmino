local ranks={"Grade 10","Grade 9","Grade 8","Grade 7","Grade 6","Grade 5","Grade 4","Grade 3","Grade 2","Grade 1","S1","S2","S3","S4","S5","S6","S7","S8","S9","GM","GM+","TM","TM+","TM+₂","TM+₃", "TM+₄","TM+₅"}
-- index:         1         2          3        4         5          6         7        8         9         10     11   12   13   14   15   16   17   18   19   20   21    22   23     24     25      26     27
return{
    env={
        drop=180,lock=180,
        hang=15,
        eventSet='secret_grade',
        bg='bg2',bgm='race',
    },
    score=function(P)return{P.modeData.rankPts,P.stat.piece}end,
    scoreDisp=function(D)return ranks[D[1]].."   "..D[2].." Pieces"end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
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
