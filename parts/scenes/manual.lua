local scene={}

function scene.sceneInit()
    BG.set('cubes')
    local fileData=love.filesystem.read('parts/language/manual_'..(SETTING.locale:find'zh'and'zh'or'en')..'.txt')
    if fileData then
        WIDGET.active.texts:setTexts(STRING.split(fileData,'\n'))
    else
        WIDGET.active.texts:setTexts{"[manual file not found]"}
    end

end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end
function scene.keyDown(key)
    if key=="up"then
        WIDGET.active.texts:scroll(-5)
    elseif key=="down"then
        WIDGET.active.texts:scroll(5)
    elseif key=="pageup"then
        WIDGET.active.texts:scroll(-20)
    elseif key=="pagedown"then
        WIDGET.active.texts:scroll(20)
    elseif key=="escape"then
        SCN.back()
    end
end

scene.widgetList={
    WIDGET.newTextBox{name="texts",x=30,y=45,w=1000,h=640,font=15,fix=true},
    WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
