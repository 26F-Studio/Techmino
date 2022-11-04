local scene={}

local function _setPW()
    local code=scene.widgetList.code:getText():upper()
    local password= scene.widgetList.password:getText()
    local password2=scene.widgetList.password2:getText()
    if #code~=8 then
        MES.new('error',text.wrongCode)
    elseif #password==0 or #password2==0 then
        MES.new('error',text.noPassword)
    elseif password~=password2 then
        MES.new('error',text.diffPassword)
    else
        NET.setPW(code,password)
    end
end
local function _paste()
    local t=love.system.getClipboardText()
    if t then
        t=STRING.trim(t)
        if #t==8 and t:match("[0-9]+") then
            scene.widgetList.code:setText(t)
            return
        end
    end
    MES.new('warn',text.wrongCode)
end

function scene.enter()
    if SCN.args[1] then
        scene.widgetList.code:setText(SCN.args[1])
    end
end
function scene.keyDown(key,rep)
    if key=='escape' and not rep then
        SCN.back()
    elseif key=='return' or key=='kpenter' then
        if #scene.widgetList.code:getText()==0 then
            NET.getCode(USER.email)
        else
            _setPW()
        end
    elseif key=='v' and love.keyboard.isDown('lctrl','rctrl') then
        _paste()
    else
        return true
    end
end

scene.widgetList={
    WIDGET.newText{name='title',        x=80,  y=50,font=70,align='L'},

    WIDGET.newInputBox{name='code',     x=380, y=170,w=626,h=60,regex="[0-9a-zA-Z]",limit=8},
    WIDGET.newKey{name='send',          x=640, y=300,w=300,h=80,font=40,code=function() NET.getCode(USER.email) end},

    WIDGET.newInputBox{name='password', x=380, y=370,w=626,h=60,secret=true,regex="[ -~]",limit=64},
    WIDGET.newInputBox{name='password2',x=380, y=470,w=626,h=60,secret=true,regex="[ -~]",limit=64},
    WIDGET.newKey{name='setPW',         x=640, y=600,w=350,h=80,font=40,code=_setPW},
    WIDGET.newKey{name='paste',         x=850, y=300,w=80,font=40,fText=CHAR.icon.import,code=_paste},

    WIDGET.newButton{name='back',       x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
