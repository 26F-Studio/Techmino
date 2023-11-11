local scene={}

function scene.enter()
    --[[
        Argument:
        [1] - Text (in table format). Default to "No text!"
        [2] - Font size (in number)
        [3] - Background (in string format)
    ]]
    

    scene.widgetList.texts:setTexts(SCN.args[1] and SCN.args[1] or {"No text!"})
    if SCN.args[2] then
        assert(type(SCN.args[2]=='number'), "2nd argument (background) must be a number!")
        scene.widgetList.texts.font=SCN.args[2]
    end
    if SCN.args[3] then
        assert(type(SCN.args[3]=='string'), "3rd argument (background) must be a string!")
        BG.set(SCN.args[3])
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
    WIDGET.newTextBox{name='texts',x=30,y=45,w=1000,h=640,font=20,fix=true},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
