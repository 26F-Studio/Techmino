local gc=love.graphics

return{
    mesDisp=function(P)
        mText(drawableText.techrash,63,420)
        setFont(75)
        mStr(P.stat.clears[4],63,340)
        PLY.draw.applyField(P)
        gc.setColor(1,1,1,.1)
        gc.draw(IMG.electric,0,106,0,2.6)
        PLY.draw.cancelField(P)
    end,
}