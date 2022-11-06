local emailBox=WIDGET.newInputBox{name='email',x=380,y=200,w=500,h=60,limit=128}
local passwordBox=WIDGET.newInputBox{name='password',x=380,y=300,w=620,h=60,secret=true,regex="[ -~]",limit=64}

local showEmail=true

local function _login()
    local email,password=emailBox:getText(),passwordBox:getText()
    if not STRING.simpEmailCheck(email) then
        MES.new('error',text.wrongEmail) return
    elseif #password==0 then
        MES.new('error',text.noPassword) return
    end
    NET.pwLogin(email,password)
end

local scene={}

function scene.enter()
    showEmail=false
    emailBox.secret=true
    emailBox:setText(USER.email)
    passwordBox:setText("")
end

function scene.keyDown(key,rep)
    if rep then return true end
    if key=='return' then
        _login()
    else
        return true
    end
end

scene.widgetList={
    WIDGET.newText{name='title',       x=80,  y=50,font=70,align='L'},
    WIDGET.newButton{name='login_mail',x=1080,y=100,w=260,h=80,color='lY',code=function() SCN.swapTo('login_mail','swipeL') end},
    emailBox,
    passwordBox,
    WIDGET.newSwitch{name='showEmail', x=550, y=420,disp=function() return showEmail end,code=function() showEmail=not showEmail emailBox.secret=not showEmail end},
    WIDGET.newKey{name='login',        x=1140,y=540,w=170,h=80,font=40,code=pressKey'return'},
    WIDGET.newButton{name='back',      x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
