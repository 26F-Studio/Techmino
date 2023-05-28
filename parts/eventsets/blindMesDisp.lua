return {
    mesDisp=function(P)
        mText(TEXTOBJ.techrash,63,420)
        setFont(75)
        GC.mStr(P.stat.clears[4],63,340)
        PLY.draw.applyField(P)
        GC.setColor(1,1,1,.1)
        GC.draw(IMG.electric,0,106,0,2.6)
        PLY.draw.cancelField()
    end,
}
