local scene={}

local state
local code

local function _getCode()
    local email=WIDGET.active.email:getText()
    if not STRING.simpEmailCheck(email)then
        MES.new('error',text.wrongEmail)
    else
        NET.getCode(email)
    end
end

local function _codeLogin()
    code=WIDGET.active.code:getText():upper()
    if #code~=8 then
        MES.new('error',"Wrong code length")
    else
        NET.codeLogin(code)
    end
end

local function _setPW()
    local password= WIDGET.active.password:getText()
    local password2=WIDGET.active.password2:getText()
    if #password==0 or #password2==0 then
        MES.new('error',text.noPassword)
    elseif password~=password2 then
        MES.new('error',text.diffPassword)
    else
        NET.setPW(code,password)
    end
end

function scene.sceneInit()
    state=1
    scene.fileDropped(state)
end

function scene.keyDown(key,rep)
    if key=='escape' and not rep then
        if state==1 then
            SCN.back()
        else
            scene.fileDropped(state-1)
        end
    elseif key=='return' then
        if state==1 then
            _getCode()
        elseif state==2 then
            _codeLogin()
        elseif state==3 then
            _setPW()
        end
    else
        return true
    end
end

function scene.fileDropped(arg)-- Not designed for this, but it works and no side effects
    if type(arg)~='number' then return end
    state=arg
    scene.widgetList.email.     hide=arg~=1
    scene.widgetList.send.      hide=arg~=1
    scene.widgetList.code.      hide=arg~=2
    scene.widgetList.verify.    hide=arg~=2
    scene.widgetList.password.  hide=arg~=3
    scene.widgetList.password2. hide=arg~=3
    scene.widgetList.setPW.     hide=arg~=3
end

scene.widgetList={
    WIDGET.newText{name='title',        x=80,  y=50,font=70,align='L'},
    WIDGET.newButton{name='login',      x=1140,y=100,w=170,h=80,color='lY',code=function()SCN.swapTo('login','swipeL')end},

    WIDGET.newInputBox{name='email',    x=380, y=300,w=626,h=60,limit=128},
    WIDGET.newKey{name='send',          x=640, y=430,w=250,h=80,font=40,code=_getCode},

    WIDGET.newInputBox{name='code',     x=380, y=300,w=626,h=60,limit=8},
    WIDGET.newKey{name='verify',        x=640, y=430,w=300,h=80,font=40,code=_codeLogin},

    WIDGET.newInputBox{name='password', x=380, y=250,w=626,h=60,secret=true,regex="[ -~]",limit=64},
    WIDGET.newInputBox{name='password2',x=380, y=350,w=626,h=60,secret=true,regex="[ -~]",limit=64},
    WIDGET.newKey{name='setPW',         x=640, y=480,w=350,h=80,font=40,code=_setPW},

    WIDGET.newButton{name='back',       x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
