return {
    env={
        freshLimit=15,
        sequence='bagES',
        eventSet='master_g_modern',
        bg='bg3',bgm='secret7th',
    },
    score=function(P) return {P.modeData.gradePts,P.stat.time} end,
    scoreDisp=function(D) return(getMasterGradeModernText(D[1]) or D[1]).."   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or (a[1]==b[1] and a[2]<b[2]) end,
    getRank=function(P)
        local G=P.modeData.gradePts
        return
            G>=47 and 5 or -- ∞M+
            G>=41 and 4 or -- TM- - ∞M
            G>=31 and 3 or -- M - GM+
            G>=21 and 2 or -- m0 - m9
            G>=11 and 1 or  -- S0 - S9
            0

            -- Table of grades vs values
            -- 10 9 8 7 6 5 4 3 2 1  S0 S1 S2 S3 S4 S5 S6 S7 S8 S9 m0 m1 m2 m3 m4 m5 m6 m7 m8 m9  M MK MV MO MM- MM MM+ GM- GM GM+ TM- TM TM+ ΩM ΣM ∞M ∞M+
            -- 1  2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35  36  37  38 39  40  41 42  43 44 45 46  47
    end,
}