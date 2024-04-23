local scene={}
local textBox=WIDGET.newTextBox{name='texts',x=30,y=45,w=1000,h=640,font=20,fix=true}

function scene.enter()
    --[[
        Argument:
        [1] - Text (in table format). Default to "No text!"
        [2] - Font size (in number)
        [3] - Background (in string format)
    ]]

    if SCN.args[1] then
        if type(SCN.args[1])=='string' then
            local _
            _,showingText=FONT.get(20):getWrap(SCN.args[1],960)
        else
            assert(type(SCN.args[1])=='table','textViewer: SCN.args[1] must be string or table of text')
            showingText=SCN.args[1]
        end
    else showingText={'No text!'} end

    textBox.font=SCN.args[2] or 20
    textBox:setTexts(showingText)
    textBox:reset()

    BG.set(SCN.args[3])
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end

function scene.keyDown(key)
    if key=='up' then
        textBox:scroll(-5)
    elseif key=='down' then
        textBox:scroll(5)
    elseif key=='pageup' then
        textBox:scroll(-20)
    elseif key=='pagedown' then
        textBox:scroll(20)
    elseif key=='escape' then
        SCN.back()
    end
end

scene.widgetList={
    textBox,
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
