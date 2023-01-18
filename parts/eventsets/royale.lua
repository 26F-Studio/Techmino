return {
    layout='royale',
    fkey1=function(P)
        P:changeAtkMode(P.atkMode<3 and P.atkMode+2 or 5-P.atkMode)
        P.swappingAtkMode=45
    end,
    mesDisp=function(P)
        setFont(35)
        GC.mStr(#PLY_ALIVE.."/"..#PLAYERS,63,175)
        GC.mStr(P.modeData.ko,80,215)
        GC.draw(TEXTOBJ.ko,60-TEXTOBJ.ko:getWidth(),222)

        setFont(20)
        GC.setColor(1,.5,0,.6)
        GC.print(P.badge,103,227)
        GC.setColor(.97,.97,.97)

        setFont(25)
        GC.mStr(text.powerUp[P.strength],63,290)
        GC.setColor(1,1,1)
        for i=1,P.strength do
            GC.draw(IMG.badgeIcon,16*i+6,260)
        end
    end,
}
