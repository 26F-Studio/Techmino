local gc=love.graphics

local scene={}

function scene.draw()
    --QR Code frame
    gc.setLineWidth(2)
    gc.rectangle('line',298,98,263,263)
    gc.rectangle('line',718,318,250,250)

    --Support text
    gc.setColor(1,1,1,MATH.sin(TIME()*20)*.3+.6)
    setFont(30)
    mStr(text.support,430+MATH.sin(TIME()*4)*20,363)
    mStr(text.support,844-MATH.sin(TIME()*4)*20,570)
end

scene.widgetList={
    WIDGET.newImage{name='pay1',  x=300,y=100},
    WIDGET.newImage{name='pay2',  x=720,y=320},
    WIDGET.newButton{name="back", x=1140,y=640,w=170,h=80,font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
