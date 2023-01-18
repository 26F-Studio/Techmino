local scene={}
function scene.enter()
    BG.set('cubes')
    local fileData=love.filesystem.read("legals.md")
    if fileData then
        scene.widgetList.texts:setTexts(fileData:split('\n'))
    else
        scene.widgetList.texts:setTexts{"[legals.md not found]"}
    end
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end
function scene.keyDown(key)
    if key=='up' then
        scene.widgetList.texts:scroll(-5)
    elseif key=='down' then
        scene.widgetList.texts:scroll(5)
    elseif key=='pageup' then
        scene.widgetList.texts:scroll(-20)
    elseif key=='pagedown' then
        scene.widgetList.texts:scroll(20)
    elseif key=='escape' then
        SCN.back()
    end
end

scene.widgetList={
    WIDGET.newTextBox{name='texts',x=30,y=45,w=1000,h=640,font=15,fix=true},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
