local gc=love.graphics

local scene={}

function scene.enter()
    BG.set()
end
function scene.leave()
    saveSettings()
end

function scene.draw()
    gc.push('transform')
    gc.translate(410,540-WIDGET.scrollPos)

    -- Draw mino
    local t=TIME()
    local b=math.floor(t*2)%16+1
    gc.setShader(SHADER.blockSatur)
    gc.setColor(1,1,1)
    mDraw(SKIN.lib[SETTING.skinSet][b],0,0,t%6.2832,2)
    gc.setColor(1,1,1,t*2%1)
    mDraw(SKIN.lib[SETTING.skinSet][b%16+1],0,0,t%6.2832,2)
    gc.setShader()

    -- Draw center
    gc.setColor(1,1,1)
    mDraw(RSlist[SETTING.RS].centerTex,0,0,0,1.2)

    gc.pop()
end

scene.widgetList={
    WIDGET.newText{name='title',      x=640,y=15,lim=630,font=80},

    WIDGET.newButton{name='graphic',  x=200,  y=80,  w=240,h=80,color='lC',font=35,code=swapScene('setting_video','swipeR')},
    WIDGET.newButton{name='sound',    x=1080, y=80,  w=240,h=80,color='lC',font=35,code=swapScene('setting_sound','swipeL')},

    WIDGET.newButton{name='style',    x=250,  y=540, w=200,h=70,font=35,code=goScene'setting_skin'},

    WIDGET.newButton{name='ctrl',     x=290,  y=220, w=320,h=80,font=35,code=goScene'setting_control'},
    WIDGET.newButton{name='key',      x=640,  y=220, w=320,h=80,color=MOBILE and 'dH',font=35,             code=goScene'setting_key'},
    WIDGET.newButton{name='touch',    x=990,  y=220, w=320,h=80,color=not MOBILE and 'dH',font=35,         code=goScene'setting_touch',hideF=function() return not SETTING.VKSwitch end},
    WIDGET.newSwitch{name='showVK',   x=1100, y=150, lim=400,                    disp=SETval('VKSwitch'), code=SETrev('VKSwitch')},
    WIDGET.newSlider{name='reTime',   x=330,  y=320, w=300,lim=180,axis={.5,3,.25},disp=SETval('reTime'), code=SETsto('reTime'),show=SETval('reTime')},
    WIDGET.newSelector{name='RS',     x=300,  y=420, w=300,color='S',            disp=SETval('RS'),       code=SETsto('RS'),list={'TRS','SRS','SRS_plus','SRS_X','BiRS','ARS_Z','DRS_weak','ASC','ASC_plus','C2','C2_sym','N64','N64_plus','Classic','Classic_plus','None','None_plus'}},
    WIDGET.newSelector{name='menuPos',x=980,  y=320, w=300,color='O',            disp=SETval('menuPos'),  code=SETsto('menuPos'),list={'left','middle','right'}},
    WIDGET.newSwitch{name='sysCursor',x=1060, y=400, lim=580,                    disp=SETval('sysCursor'),code=function() SETTING.sysCursor=not SETTING.sysCursor applySettings() end},
    WIDGET.newSwitch{name='autoPause',x=1060, y=470, lim=580,                    disp=SETval('autoPause'),code=SETrev('autoPause')},
    WIDGET.newSwitch{name='autoSave', x=1060, y=540, lim=580,                    disp=SETval('autoSave'), code=SETrev('autoSave')},
    WIDGET.newSwitch{name='simpMode', x=960,  y=670, lim=480,                    disp=SETval('simpMode'),
        code=function()
            SETTING.simpMode=not SETTING.simpMode
            local p=TABLE.find(SCN.stack,'main') or TABLE.find(SCN.stack,'main_simple')
            SCN.stack[p]=SETTING.simpMode and 'main_simple' or 'main'
        end},
    WIDGET.newButton{name='back',     x=1140, y=640, w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
