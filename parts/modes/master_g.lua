local gradeList={
    "Grade 9","Grade 8","Grade 7","Grade 6","Grade 5","Grade 4","Grade 3","Grade 2","Grade 1",
    "S1","S2","S3","S4","S5","S6","S7","S8","S9",
    "m1","m2","m3","m4","m5","m6","m7","m8","m9",
    "M","MK","MV","MO","MM-","MM","MM+","GM-","GM","GM+","TM-","TM","TM+"
}

return {
    env={
        freshLimit=15,
        fieldH=19,
        sequence='bagES',
        eventSet='master_g',
        bg='bg2',bgm='secret7th',
    },
    slowMark=true,
    score=function(P) return {P.modeData.gradePts,P.stat.time} end,
    scoreDisp=function(D) return(gradeList[D[1]] or D[1]).."   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or (a[1]==b[1] and a[2]<b[2]) end,
    getRank=function(P)
        local G=P.modeData.gradePts
        return
            G>=40 and 5 or -- TM+
            G>=32 and 4 or -- MM- - TM
            G>=26 and 3 or -- m8 - MO
            G>=19 and 2 or -- m1 - m7
            G>=10 and 1 or  -- S1 - S9
            0

            -- Table of grades vs values
            -- 9 8 7 6 5 4 3 2 1 S1 S2 S3 S4 S5 S6 S7 S8 S9 m1 m2 m3 m4 m5 m6 m7 m8 m9  M MK MV MO MM- MM MM+ GM- GM GM+ TM- TM TM+
            -- 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31  32 33  34  35 36  37  38 39  40
    end,
}
