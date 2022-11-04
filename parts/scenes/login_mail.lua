local scene={}

local function _getCode()
    local email=scene.widgetList.email:getText()
    if not STRING.simpEmailCheck(email) then
        MES.new('error',text.wrongEmail)
    else
        USER.email=email
        NET.getCode(email)
    end
end
local function _codeLogin()
    local code=scene.widgetList.code:getText():upper()
    if #code~=8 then
        MES.new('error',text.wrongCode)
    else
        NET.codeLogin(USER.email,code)
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

function scene.sceneInit()
    scene.widgetList.email:setText(USER.email or "")
    scene.widgetList.code:clear()
end

function scene.keyDown(key,rep)
    if key=='escape' and not rep then
        SCN.back()
    elseif key=='return' or key=='kpenter' then
        if #scene.widgetList.code:getText():upper()==0 then
            _getCode()
        else
            _codeLogin()
        end
    elseif key=='v' and love.keyboard.isDown('lctrl','rctrl') then
        _paste()
    else
        return true
    end
end

scene.widgetList={
    WIDGET.newText{name='title',        x=80,  y=50,font=70,align='L'},
    WIDGET.newButton{name='login_pw',   x=1080,y=100,w=260,h=80,color='lY',code=function() SCN.swapTo('login_pw','swipeR') end},

    WIDGET.newInputBox{name='email',    x=380, y=200,w=626,h=60,limit=128},
    WIDGET.newKey{name='send',          x=640, y=330,w=300,h=80,font=40,code=_getCode},

    WIDGET.newInputBox{name='code',     x=380, y=400,w=626,h=60,regex="[0-9a-zA-Z]",limit=8},
    WIDGET.newKey{name='verify',        x=640, y=530,w=300,h=80,font=40,code=_codeLogin},
    WIDGET.newKey{name='paste',         x=850, y=530,w=80,font=40,fText=CHAR.icon.import,code=_paste},

    WIDGET.newButton{name='back',       x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
