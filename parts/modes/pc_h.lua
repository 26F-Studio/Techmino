return {
    env={
        drop=60,lock=120,
        fall=10,
        freshLimit=15,
        ospin=false,
        mesDisp=function(P)
            setFont(60)
            GC.mStr(P.stat.pc,63,340)
            mText(TEXTOBJ.pc,63,410)
        end,
        eventSet='checkLine_100',
        bg='rgb',bgm='truth',
    },
    score=function(P) return {P.stat.pc,P.stat.time} end,
    scoreDisp=function(D) return D[1].." PCs   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.pc
        return
        L>=24 and 5 or
        L>=20 and 4 or
        L>=16 and 3 or
        L>=12 and 2 or
        L>=8 and 1 or
        L>=1 and 0
    end,
}
