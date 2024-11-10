local scene={}

function scene.enter()
    BG.set('cubes')
    local data=SCN.args[2]
    if data then
        local texts={"<"..SCN.args[1]..">"}
        for i=1,#data do
            table.insert(texts,("[$1] $2"):repD(data[i].id or "?",data[i].timestamp or "20??/??/??"))
            table.insert(texts,data[i].content)
            table.insert(texts,"")
            table.insert(texts,"——————————————————————————")
        end
        scene.widgetList.texts:setTexts(texts)
    else
        scene.widgetList.texts:setTexts({"No data"})
    end
    DiscordRPC.update("Checking Latest News")
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
    WIDGET.newTextBox{name='texts',x=30,y=45,w=1000,h=640,font=25,fix=true,lineH=45},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
