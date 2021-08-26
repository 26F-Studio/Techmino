local gc=love.graphics

return{
    color=COLOR.magenta,
    env={
        drop=30,lock=60,
        freshLimit=15,
        ospin=false,
        eventSet='tsd_h',
        bg='matrix',bgm='vapor',
    },
    mesDisp=function(P)
        setFont(60)
        mStr(P.modeData.tsd,63,250)
        mText(drawableText.tsd,63,315)
        local L=P.modeData.history
        if L[1]and L[1]==L[2]and L[1]==L[3]then
            PLY.draw.applyField(P)
            gc.setColor(1,.5,.5,.2)
            gc.rectangle('fill',30*L[1]-30,0,30,600)
            PLY.draw.cancelField(P)
        end
    end,
    score=function(P)return{P.modeData.tsd,P.stat.time}end,
    scoreDisp=function(D)return D[1].."TSD   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local T=P.modeData.tsd
        return
        T>=20 and 5 or
        T>=18 and 4 or
        T>=15 and 3 or
        T>=11 and 2 or
        T>=7 and 1 or
        T>=3 and 0
    end,
}