local gc=love.graphics

local sin=math.sin

local scene={}

local last1,last2-- Last touch/sound time
local sfxPack=SETTING.sfxPack
local vocPack=SETTING.vocPack

function scene.enter()
    last1,last2=0,0
    sfxPack=SETTING.sfxPack
    vocPack=SETTING.vocPack
    scene.widgetList.sfxPack:reset()
    scene.widgetList.vocPack:reset()
    BG.set()
end
function scene.leave()
    saveSettings()
end

function scene.mouseDown(x,y)
    local t1=TIME()-last1
    if x>780 and x<980 and y>470 and y<720 and t1>.626 then
        last1=TIME()
        local t2=TIME()-last2
        if t2>2.6 and t2<3 and not GAME.playing then
            loadGame('sprintSmooth',true)
        elseif vocPack==SETTING.vocPack then
            VOC.play((t2<1.26 or t2>6.26) and 'doubt' or 'happy')
            last2=TIME()
        end
    end
end
scene.touchDown=scene.mouseDown

function scene.keyDown(key)
    if key=='space' then
        scene.mouseDown(942,626)
    else
        return true
    end
end

function scene.draw()
    gc.setColor(1,1,1)
    gc.push('transform')
    local clickTime=TIME()-last1
    if vocPack=="miya" then
        gc.translate(780,340+6*sin(TIME()*.5))
        gc.draw(IMG.miyaGlow,-4,-4)
        if clickTime<1 then
            if TIME()%60>30 then
                gc.draw(IMG.miyaCH3)
            else
                gc.draw(IMG.miyaCH4)
            end
        elseif TIME()%2>.126 then
            gc.draw(IMG.miyaCH1)
        else
            gc.draw(IMG.miyaCH2)
        end
        gc.translate(0,-6*sin(TIME()*.5))
        gc.setColor(1,1,1,1-(clickTime))
        gc.draw(IMG.miyaHeart,162,52,nil,.3)
    elseif vocPack=="mono" then
        local jump=math.max(30-(clickTime)*60,0)%10
        gc.translate(730,340+6*sin(TIME()*.5)+(jump-10)*jump*.3)
        gc.draw(IMG.monoCH)
    elseif vocPack=="xiaoya" then
        gc.translate(770,340+4*sin(TIME()*.5))
        gc.draw(IMG.xiaoyaCH)
        gc.draw(IMG.xiaoyaOmino,16,168,26/(1+clickTime),.36,.36,33,37)
    elseif vocPack=="flore" then
        gc.translate(770+56*sin(clickTime*26)/(clickTime+.56)^2/20,300+12*sin(TIME()*.5))
        gc.draw(IMG.floreCH,nil,nil,nil)
    elseif vocPack=="miku" then
        gc.translate(700,320+12*sin(TIME()*.5))
        gc.draw(IMG.mikuCH,nil,nil,nil,.8)
    elseif vocPack=="zundamon" then
        gc.translate(770,300+12*sin(TIME()*.5))
        gc.draw(IMG.zundamonCH,nil,nil,nil,.8)
    end
    gc.pop()
end

scene.widgetList={
    WIDGET.newText{name='title',      x=640, y=15,lim=630,font=80},

    WIDGET.newButton{name='game',     x=200, y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_game','swipeR')},
    WIDGET.newButton{name='graphic',  x=1080,y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_video','swipeL')},

    WIDGET.newSlider{name='mainVol',  x=300, y=170,w=420,lim=220,color='lG',disp=SETval('mainVol'),          code=function(v) SETTING.mainVol=v love.audio.setVolume(SETTING.mainVol) end},
    WIDGET.newSlider{name='bgm',      x=300, y=240,w=420,lim=220,color='lG',disp=SETval('bgm'),              code=function(v) SETTING.bgm=v BGM.setVol(SETTING.bgm) end},
    WIDGET.newSlider{name='sfx',      x=300, y=310,w=420,lim=220,color='lC',disp=SETval('sfx'),              code=function(v) SETTING.sfx=v SFX.setVol(SETTING.sfx) end,         change=function() SFX.play('warn_1') end},
    WIDGET.newSlider{name='stereo',   x=300, y=380,w=420,lim=220,color='lC',disp=SETval('stereo'),           code=function(v) SETTING.stereo=v SFX.setStereo(SETTING.stereo) end,change=function() SFX.play('touch',1,-1)SFX.play('lock',1,1) end,hideF=function() return SETTING.sfx==0 end},
    WIDGET.newSlider{name='spawn',    x=300, y=450,w=420,lim=220,color='lC',disp=SETval('sfx_spawn'),        code=function(v) SETTING.sfx_spawn=v end,                          change=function() SFX.fplay('spawn_'..math.random(7),SETTING.sfx_spawn) end,},
    WIDGET.newSlider{name='warn',     x=300, y=520,w=420,lim=220,color='lC',disp=SETval('sfx_warn'),         code=function(v) SETTING.sfx_warn=v end,                           change=function() SFX.fplay('warn_beep',SETTING.sfx_warn) end},
    WIDGET.newSlider{name='vib',      x=300, y=590,w=420,lim=220,color='lN',disp=SETval('vib'),axis={0,10,1},code=function(v) SETTING.vib=v end,                                change=function() if SETTING.vib>0 then VIB(SETTING.vib+2) end end},
    WIDGET.newSlider{name='voc',      x=300, y=660,w=420,lim=220,color='lN',disp=SETval('voc'),              code=function(v) SETTING.voc=v VOC.setVol(SETTING.voc) end,         change=function() VOC.play('test') end},

    WIDGET.newSwitch{name='autoMute', x=1150,y=180,lim=380,disp=SETval('autoMute'),code=SETrev('autoMute')},
    WIDGET.newSwitch{name='fine',     x=1150,y=250,lim=380,disp=SETval('fine'),code=function() SETTING.fine=not SETTING.fine if SETTING.fine then SFX.play('finesseError',.6) end end},

    WIDGET.newSelector{name='sfxPack',x=1100,y=330,w=200,color='lV',list=SFXPACKS,disp=function() return sfxPack end,code=function(i) sfxPack=i end},
    WIDGET.newButton{name='apply',    x=1100,y=400,w=180,h=60,code=function() SETTING.sfxPack=sfxPack SFX.load('media/effect/'..sfxPack..'/') end,hideF=function() return SETTING.sfxPack==sfxPack end},
    WIDGET.newSelector{name='vocPack',x=1100,y=470,w=200,color='lV',list=VOCPACKS,disp=function() return vocPack end,code=function(i) vocPack=i end},
    WIDGET.newButton{name='apply',    x=1100,y=540,w=180,h=60,code=function() SETTING.vocPack=vocPack VOC.load('media/vocal/'..vocPack..'/') end,hideF=function() return SETTING.vocPack==vocPack end},
    WIDGET.newButton{name='back',     x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
