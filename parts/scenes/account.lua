-- local gc=love.graphics

local scene={}

function scene.enter()

end

scene.widgetList={
    WIDGET.newText{name='title',x=80,y=50,font=70,align='L'},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
