local gc=love.graphics
local ins=table.insert
local mStr=GC.mStr

local scene={}

local selected-- if waiting for key
local keyList

local keyNames={
    normal={
        a='A',b='B',c='C',d='D',e='E',f='F',g='G',
        h='H',i='I',j='J',k='K',l='L',m='M',n='N',
        o='O',p='P',q='Q',r='R',s='S',t='T',
        u='U',v='V',w='W',x='X',y='Y',z='Z',
        f1='F1',f2='F2',f3='F3',f4='F4',f5='F5',f6='F6',
        f7='F7',f8='F8',f9='F9',f10='F10',f11='F11',f12='F12',
        backspace=CHAR.key.backspace,
        ['return']=CHAR.key.enter_or_return,
        kpenter='kp'..CHAR.key.enter_or_return,
        tab=CHAR.key.tab,
        capslock=CHAR.key.capslock,
        lshift='L shift',
        rshift='R shift',
        lctrl='L ctrl',
        rctrl='R ctrl',
        lalt='L alt',
        ralt='R alt',
        lgui='L'..CHAR.key.windows,
        rgui='R'..CHAR.key.windows,
        space=CHAR.key.space,
        delete='Del',
        pageup='PgUp',
        pagedown='PgDn',
        home='Home',
        [' end']='End',
        insert='Ins',
        numlock='Numlock',
        menu=CHAR.key.winMenu,
        up=CHAR.key.up,
        down=CHAR.key.down,
        left=CHAR.key.left,
        right=CHAR.key.right,
    },
    apple={
        kpenter=CHAR.key.macEnter,
        tab=CHAR.key.mactab,
        lshift='L'..CHAR.key.shift,
        rshift='R'..CHAR.key.shift,
        lctrl='L'..CHAR.key.macCtrl,
        rctrl='R'..CHAR.key.macCtrl,
        lalt='L'..CHAR.key.macOpt,
        ralt='R'..CHAR.key.macOpt,
        lgui='L'..CHAR.key.macCmd,
        rgui='R'..CHAR.key.macCmd,
        space=CHAR.key.space,
        delete=CHAR.key.macFowardDel,
        pageup=CHAR.key.macPgup,
        pagedown=CHAR.key.macPgdn,
        home=CHAR.key.macHome,
        [' end']=CHAR.key.macEnd,
        numlock=CHAR.key.clear,
    },
    controller={
        x=CHAR.controller.xboxX,
        y=CHAR.controller.xboxY,
        a=CHAR.controller.xboxA,
        b=CHAR.controller.xboxB,
        dpup=CHAR.controller.dpadU,
        dpdown=CHAR.controller.dpadD,
        dpleft=CHAR.controller.dpadL,
        dpright=CHAR.controller.dpadR,
        triggerleft=CHAR.controller.lt,
        triggerright=CHAR.controller.rt,
        leftshoulder=CHAR.controller.lb,
        rightshoulder=CHAR.controller.rb,
        leftstick_up=CHAR.controller.jsLU,
        leftstick_down=CHAR.controller.jsLD,
        leftstick_left=CHAR.controller.jsLL,
        leftstick_right=CHAR.controller.jsLR,
        rightstick_up=CHAR.controller.jsRU,
        rightstick_down=CHAR.controller.jsRD,
        rightstick_left=CHAR.controller.jsRL,
        rightstick_right=CHAR.controller.jsRR,
    },
}setmetatable(keyNames.apple,{__index=keyNames.normal})

local function _freshKeyList()
    keyList={} for i=0,20 do keyList[i]={} end

    local keynames=SYSTEM:find'OS' and keyNames.apple or keyNames.normal
    for k,v in next,KEY_MAP.keyboard do
        ins(keyList[v],{COLOR.lB,keynames[k] or k})
    end

    for b,v in next,KEY_MAP.joystick do
        ins(keyList[v],{COLOR.lR,keyNames.controller[b] or b})
    end
end

function scene.enter()
    selected=false
    _freshKeyList()
    BG.set('none')
end
function scene.leave()
    saveFile(KEY_MAP,'conf/key')
end

local forbbidenKeys={
    ["\\"]=true,
    ["return"]=true,
}
function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='escape' then
        if selected then
            selected=false
        else
            SCN.back()
        end
    elseif key=='backspace' then
        if selected then
            for k,v in next,KEY_MAP.keyboard do
                if v==selected then
                    KEY_MAP.keyboard[k]=nil
                end
            end
            _freshKeyList()
            selected=false
            SFX.play('finesseError',.5)
        end
    elseif selected then
        if not forbbidenKeys[key] then
            KEY_MAP.keyboard[key]=selected
            _freshKeyList()
            selected=false
            SFX.play('reach',.5)
        end
    else
        return true
    end
end
function scene.gamepadDown(key)
    if key=='back' then
        if selected then
            for k,v in next,KEY_MAP.joystick do
                if v==selected then
                    KEY_MAP.joystick[k]=nil
                end
            end
            _freshKeyList()
            selected=false
            SFX.play('finesseError',.5)
        else
            SCN.back()
        end
    elseif selected then
        KEY_MAP.joystick[key]=selected
        _freshKeyList()
        selected=false
        SFX.play('reach',.5)
    else
        return true
    end
end

function scene.draw()
    setFont(20)
    gc.setColor(COLOR.Z)
    gc.printf(text.keySettingInstruction,526,620,500,'right')

    for i=0,20 do
        for j=1,#keyList[i] do
            local key=keyList[i][j]
            local font=#key[2]<=4 and 35 or #key[2]<=7 and 25 or 15
            setFont(font)
            mStr(key,
                (i>10 and 820 or 200)+80*j,
                (
                    i>10 and 60*(i-10)-23 or
                    i>0 and 60*i-23 or
                    667
                )-font*.7
            )
        end
    end

    if selected then
        gc.setLineWidth(3)
        gc.setColor(TIME()%.26<.13 and COLOR.F or COLOR.Y)
        gc.rectangle('line',
            selected>10 and 860 or 240,
            selected>10 and 60*(selected-10)-50 or selected>0 and 60*selected-50 or 640,
            400,60
        )
    end
end

local function _setSel(i)
    if selected==i then
        selected=false
        SFX.play('rotate',.5)
    else
        selected=i
        SFX.play('lock',.5)
    end
end
scene.widgetList={
    WIDGET.newKey{name='a1',x=150,y=40, w=180,h=60,font=25,code=function() _setSel(1) end},
    WIDGET.newKey{name='a2',x=150,y=100,w=180,h=60,font=25,code=function() _setSel(2) end},
    WIDGET.newKey{name='a3',x=150,y=160,w=180,h=60,font=25,code=function() _setSel(3) end},
    WIDGET.newKey{name='a4',x=150,y=220,w=180,h=60,font=25,code=function() _setSel(4) end},
    WIDGET.newKey{name='a5',x=150,y=280,w=180,h=60,font=25,code=function() _setSel(5) end},
    WIDGET.newKey{name='a6',x=150,y=340,w=180,h=60,font=25,code=function() _setSel(6) end},
    WIDGET.newKey{name='a7',x=150,y=400,w=180,h=60,font=25,code=function() _setSel(7) end},
    WIDGET.newKey{name='a8',x=150,y=460,w=180,h=60,font=25,code=function() _setSel(8) end},
    WIDGET.newKey{name='a9',x=150,y=520,w=180,h=60,font=25,code=function() _setSel(9) end},
    WIDGET.newKey{name='a10',x=150,y=580,w=180,h=60,font=25,code=function() _setSel(10) end},

    WIDGET.newKey{name='a11',x=770,y=40, w=180,h=60,font=25,code=function() _setSel(11) end},
    WIDGET.newKey{name='a12',x=770,y=100,w=180,h=60,font=25,code=function() _setSel(12) end},
    WIDGET.newKey{name='a13',x=770,y=160,w=180,h=60,font=25,code=function() _setSel(13) end},
    WIDGET.newKey{name='a14',x=770,y=220,w=180,h=60,font=25,code=function() _setSel(14) end},
    WIDGET.newKey{name='a15',x=770,y=280,w=180,h=60,font=25,code=function() _setSel(15) end},
    WIDGET.newKey{name='a16',x=770,y=340,w=180,h=60,font=25,code=function() _setSel(16) end},
    WIDGET.newKey{name='a17',x=770,y=400,w=180,h=60,font=25,code=function() _setSel(17) end},
    WIDGET.newKey{name='a18',x=770,y=460,w=180,h=60,font=25,code=function() _setSel(18) end},
    WIDGET.newKey{name='a19',x=770,y=520,w=180,h=60,font=25,code=function() _setSel(19) end},
    WIDGET.newKey{name='a20',x=770,y=580,w=180,h=60,font=25,code=function() _setSel(20) end},

    WIDGET.newKey{name='restart',x=150,y=670,w=180,h=60,code=function() _setSel(0) end},

    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
