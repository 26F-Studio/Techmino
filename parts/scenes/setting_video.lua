local gc=love.graphics

local scene={}

function scene.enter()
    DiscordRPC.update("Tweaking Settings")
end
function scene.leave()
    saveSettings()
end


function scene.fileDropped(file)
    if pcall(gc.newImage,file) then
        love.filesystem.write('conf/customBG',file:read('data'))
        SETTING.bg='custom'
        applySettings()
    else
        MES.new('error',text.customBGloadFailed)
    end
end

local fakeBlock={{true}}
function scene.draw()
    local skinLib=SKIN.lib[SETTING.skinSet]
    gc.push('transform')
    gc.translate(720,149-WIDGET.scrollPos)
    gc.scale(2)
    gc.setColor(1,1,1)
    PLY.draw.drawGhost[SETTING.ghostType](fakeBlock,0,0,SETTING.ghost,skinLib,math.floor(TIME()*3)%16+1)
    gc.pop()

    gc.push('transform')
    gc.setColor(1,1,1)
    local T=skinLib[1]
    gc.translate(0,1610-WIDGET.scrollPos)
    gc.setShader(SHADER.blockSatur)
    gc.draw(T,435,0)gc.draw(T,465,0)gc.draw(T,465,30)gc.draw(T,495,30)
    gc.setShader(SHADER.fieldSatur)
    for i=1,8 do
        gc.draw(skinLib[i],330+30*i,100)
        gc.draw(skinLib[i+8],330+30*i,130)
    end
    gc.setShader()
    gc.pop()
end

local function _msaaShow(S)
    S=S.disp()
    return S==0 and 0 or 2^S
end

scene.widgetScrollHeight=1200
scene.widgetList={
    WIDGET.newText{name='title',          x=640,y=15,lim=630,font=80},

    WIDGET.newButton{name='sound',        x=200,y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_sound','swipeR')},
    WIDGET.newButton{name='game',         x=1080,y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_game','swipeL')},

    WIDGET.newSwitch{name='block',        x=380,y=180,lim=300,disp=SETval('block'),code=SETrev('block')},
    WIDGET.newSwitch{name='smooth',       x=380,y=250,lim=300,disp=SETval('smooth'),code=SETrev('smooth')},
    WIDGET.newSwitch{name='upEdge',       x=380,y=320,lim=300,disp=SETval('upEdge'),code=SETrev('upEdge')},
    WIDGET.newSwitch{name='bagLine',      x=380,y=390,lim=300,disp=SETval('bagLine'),code=SETrev('bagLine')},

    WIDGET.newSelector{name='ghostType',  x=915,y=180,        w=350,list={'color','gray','colorCell','grayCell','colorLine','grayLine'},disp=SETval('ghostType'),code=SETsto('ghostType')},
    WIDGET.newSlider{name='ghost',        x=740,y=240,lim=280,w=350,axis={0,1},disp=SETval('ghost'),     show="percent",code=SETsto('ghost')},
    WIDGET.newSlider{name='center',       x=740,y=300,lim=280,w=350,axis={0,1},disp=SETval('center'),    show="percent",code=SETsto('center')},
    WIDGET.newSlider{name='grid',         x=740,y=360,lim=280,w=350,axis={0,.4},disp=SETval('grid'),     show="percent",code=SETsto('grid')},
    WIDGET.newSlider{name='lineNum',      x=740,y=420,lim=280,w=350,axis={0,1},disp=SETval('lineNum'),   show="percent",code=SETsto('lineNum')},

    WIDGET.newSlider{name='lockFX',       x=330,y=460,lim=280,w=540,axis={0,5,1},disp=SETval('lockFX'),  code=SETsto('lockFX')},
    WIDGET.newSlider{name='dropFX',       x=330,y=520,lim=280,w=540,axis={0,5,1},disp=SETval('dropFX'),  code=SETsto('dropFX')},
    WIDGET.newSlider{name='moveFX',       x=330,y=580,lim=280,w=540,axis={0,5,1},disp=SETval('moveFX'),  code=SETsto('moveFX')},
    WIDGET.newSlider{name='clearFX',      x=330,y=640,lim=280,w=540,axis={0,5,1},disp=SETval('clearFX'), code=SETsto('clearFX')},
    WIDGET.newSlider{name='splashFX',     x=330,y=700,lim=280,w=540,axis={0,5,1},disp=SETval('splashFX'),code=SETsto('splashFX')},
    WIDGET.newSlider{name='shakeFX',      x=330,y=760,lim=280,w=540,axis={0,5,1},disp=SETval('shakeFX'), code=SETsto('shakeFX')},
    WIDGET.newSlider{name='atkFX',        x=330,y=820,lim=280,w=540,axis={0,5,1},disp=SETval('atkFX'),   code=SETsto('atkFX')},

    WIDGET.newSelector{name='frame',      x=400,y=890,lim=280,w=460,list={8,10,13,17,22,29,37,47,62,80,100},disp=SETval('frameMul'),code=function(v) SETTING.frameMul=v;Z.setFrameMul(SETTING.frameMul) end},

    WIDGET.newSwitch{name='text',         x=450,y=980,lim=360,disp=SETval('text'),          code=SETrev('text')},
    WIDGET.newSwitch{name='score',        x=450,y=1030,lim=360,disp=SETval('score'),        code=SETrev('score')},
    WIDGET.newSwitch{name='bufferWarn',   x=450,y=1100,lim=360,disp=SETval('bufferWarn'),   code=SETrev('bufferWarn')},
    WIDGET.newSwitch{name='showSpike',    x=450,y=1150,lim=360,disp=SETval('showSpike'),    code=SETrev('showSpike')},
    WIDGET.newSwitch{name='nextPos',      x=450,y=1220,lim=360,disp=SETval('nextPos'),      code=SETrev('nextPos')},
    WIDGET.newSwitch{name='highCam',      x=450,y=1270,lim=360,disp=SETval('highCam'),      code=SETrev('highCam')},
    WIDGET.newSwitch{name='warn',         x=450,y=1340,lim=360,disp=SETval('warn'),         code=SETrev('warn')},

    WIDGET.newSwitch{name='clickFX',      x=950,y=980,lim=360,disp=SETval('clickFX'),       code=function() SETTING.clickFX=not SETTING.clickFX; applySettings() end},
    WIDGET.newSwitch{name='power',        x=950,y=1030,lim=360,disp=SETval('powerInfo'),    code=function() SETTING.powerInfo=not SETTING.powerInfo; applySettings() end},
    WIDGET.newSwitch{name='clean',        x=950,y=1100,lim=360,disp=SETval('cleanCanvas'),  code=function() SETTING.cleanCanvas=not SETTING.cleanCanvas; applySettings() end},
    WIDGET.newSwitch{name='fullscreen',   x=950,y=1150,lim=360,disp=SETval('fullscreen'),   code=function() SETTING.fullscreen=not SETTING.fullscreen; applySettings() end,hideF=function() return MOBILE end},
    WIDGET.newSwitch{name='portrait',     x=950,y=1150,lim=360,disp=SETval('portrait'),     code=function() SETTING.portrait=not SETTING.portrait; saveSettings(); MES.new('warn',text.settingWarn2,6.26) end,hideF=function() return not MOBILE end},
    WIDGET.newSlider{name='msaa',         x=950,y=1220,lim=360,w=200,axis={0,4,1},disp=SETval('msaa'),show=_msaaShow,
        code=function(v)
            SETTING.msaa=v
            if TASK.lock('warnMessage',6.26) then
                MES.new('warn',text.settingWarn2,6.26)
            end
        end
    },

    WIDGET.newKey{name='bg_on',           x=680,y=1290,w=200,h=60,font=25,code=function() SETTING.bg='on' ; applySettings() end},
    WIDGET.newKey{name='bg_off',          x=900,y=1290,w=200,h=60,font=25,code=function() SETTING.bg='off'; applySettings() end},
    WIDGET.newKey{name='bg_custom',       x=1120,y=1290,w=200,h=60,font=25,
        code=function()
            if love.filesystem.getInfo('conf/customBG') then
                SETTING.bg='custom'
                applySettings()
            else
                MES.new('info',text.customBGhelp)
            end
        end
    },
    WIDGET.newSlider{name='bgAlpha', x=800,y=1365,w=420,
        axis={0,.8},disp=SETval('bgAlpha'),
        code=function(v)
            SETTING.bgAlpha=v
            if BG.cur=='fixColor' then
                BG.send(v,v,v)
            else
                BG.send(v)
            end
        end,
        hideF=function() return SETTING.bg=='on' end
    },
    WIDGET.newSelector{name='defaultBG', x=680,y=1465,w=200,color='G',
        list={'space','bg1','bg2','rainbow','rainbow2','aura','rgb','glow','matrix','cubes','tunnel','galaxy','quarks','blockfall','blockrain','blockhole','blockspace'},
        disp=SETval('defaultBG'),
        code=function(v)
            SETTING.defaultBG=v
            applySettings()
        end,
        hideF=function() return SETTING.bg~='on' end
    },
    WIDGET.newKey{name='resetDbg',x=680,y=1540,w=200,h=60,font=20,
        code=function()
            SETTING.defaultBG='space'
            scene.widgetList.defaultBG:reset()
            applySettings()
        end,
        hideF=function() return SETTING.bg~='on' or SETTING.defaultBG=='space' end
    },
    WIDGET.newKey{name='bg_custom_base64',x=1010,y=1502.5,w=420,h=135,align='M',
        code=function()
            local okay,data=pcall(love.data.decode,"data","base64",CLIPBOARD.get())
            if okay and pcall(gc.newImage,data) then
                love.filesystem.write('conf/customBG',data)
                SETTING.bg='custom'
                applySettings()
            else
                MES.new('error',text.customBGloadFailed)
            end
        end,
        -- hideF=function() return SETTING.bg=='off' end
    },
    WIDGET.newSwitch{name='lockBG',x=450,y=1465,lim=200,
        disp=SETval('lockBG'),
        code=function()
            SETTING.lockBG=not SETTING.lockBG
            applySettings('lockBG')
        end,
        hideF=function() return SETTING.bg~='on' end
    },

    WIDGET.newSwitch{name='noTheme',x=450,y=1540,
        disp=SETval('noTheme'),
        code=function()
            SETTING.noTheme=not SETTING.noTheme
            local ct=THEME.calculate()
            if SETTING.noTheme and type(ct)=='string' and ct:sub(1,6)~='season' then
                if TASK.lock('warnMessage',6.26) then
                    MES.new('warn',text.settingWarn2,6.26)
                end
            else
                THEME.set(THEME.calculate(),GAME.playing)
                WIDGET.setWidgetList(scene.widgetList)
            end
        end
    },

    WIDGET.newSelector{name='blockSatur', x=800,y=1640,w=300,color='lN',
        list={'normal','soft','gray','light','color'},
        disp=SETval('blockSatur'),
        code=function(v) SETTING.blockSatur=v; applySettings() end
    },
    WIDGET.newSelector{name='fieldSatur', x=800,y=1740,w=300,color='lN',
        list={'normal','soft','gray','light','color'},
        disp=SETval('fieldSatur'),
        code=function(v) SETTING.fieldSatur=v; applySettings() end
    },

    WIDGET.newButton{name='back',         x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
