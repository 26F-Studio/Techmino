local scene={}

local function _authorize()
    love.system.openURL(AUTHURL)
end
local function _submit()
    local tickets=scene.widgetList.ticket:getText():upper()
    if #tickets~=128 then
        MES.new('error',text.wrongCode)
    else
        USER.aToken=tickets:sub(1,64)
        USER.oToken=tickets:sub(65)
        NET.login()
    end
end
local function _paste()
    local t=love.system.getClipboardText()
    if t then
        t=STRING.trim(t)
        if #t==128 and t:match("[0-9A-Z]+") then
            scene.widgetList.ticket:setText(t)
            return
        end
    end
    MES.new('error',text.wrongCode)
end

function scene.enter()
    scene.widgetList.ticket:clear()
end

function scene.keyDown(key,rep)
    if key=='escape' and not rep then
        SCN.back()
    elseif key=='return' or key=='kpenter' then
        if #scene.widgetList.ticket:getText()==0 then
            _authorize()
        else
            _submit()
        end
    elseif key=='v' and love.keyboard.isDown('lctrl','rctrl') then
        _paste()
    else
        return true
    end
end

scene.widgetList={
    WIDGET.newText{name='title',        x=80,  y=50,font=70,align='L'},

    WIDGET.newInputBox{name='ticket',   x=280, y=200,w=730,h=320,font=30,regex="[0-9A-Z]",limit=128},

    WIDGET.newKey{name='authorize',     x=400, y=600,w=240,h=80,font=40,code=_authorize},
    WIDGET.newKey{name='paste',         x=645, y=600,w=240,h=80,font=40,code=_paste},
    WIDGET.newKey{name='submit',        x=890, y=600,w=240,h=80,font=40,code=_submit},

    WIDGET.newButton{name='back',       x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
