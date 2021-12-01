local gc=love.graphics

local sin=math.sin

local scene={}

local last--Last touch time
local jump--Animation timer(10 to 0)
local sfxPack=SETTING.sfxPack
local vocPack=SETTING.vocPack

function scene.sceneInit()
    last,jump=0,0
    sfxPack=SETTING.sfxPack
    vocPack=SETTING.vocPack
    WIDGET.active.sfxPack:reset()
    WIDGET.active.vocPack:reset()
    BG.set()
end
function scene.sceneBack()
    saveSettings()
end

function scene.mouseDown(x,y)
    if x>780 and x<980 and y>470 and y<720 and jump==0 then
        jump=10
        local t=TIME()-last
        if t>1 then
            if t>2.6 and t<3 and not GAME.playing then
                loadGame('sprintSmooth',true)
            else
                VOC.play((t<1.26 or t>6.26)and'doubt'or'happy')
                last=TIME()
            end
        end
    end
end
scene.touchDown=scene.mouseDown

function scene.keyDown(key)
    if key=='space'then
        scene.mouseDown(942,626)
    else
        return true
    end
end

function scene.update()
    if jump>0 then
        jump=jump-1
    end
end

function scene.draw()
    gc.setColor(1,1,1)
    local t=TIME()
    local x,y=800,340+10*sin(t*.5)+(jump-10)*jump*.3
    gc.translate(x,y)
    if vocPack=="miya"then
        gc.draw(IMG.miyaCH)
        gc.setColor(1,1,1,.7)
        gc.draw(IMG.miyaF1,4,47+4*sin(t*.9))
        gc.draw(IMG.miyaF2,42,107+5*sin(t))
        gc.draw(IMG.miyaF3,93,126+3*sin(t*.7))
        gc.draw(IMG.miyaF4,129,98+3*sin(t*.5))
    elseif vocPack=="mono"then
        gc.draw(IMG.monoCH,-30)
    elseif vocPack=="xiaoya"then
        gc.draw(IMG.xiaoyaCH,-30)
    elseif vocPack=="miku"then
        gc.draw(IMG.mikuCH,-30)
    end
    gc.translate(-x,-y)
end

scene.widgetList={
    WIDGET.newText{name='title',      x=640, y=15,font=80},

    WIDGET.newButton{name='game',     x=200, y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_game','swipeR')},
    WIDGET.newButton{name='graphic',  x=1080,y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_video','swipeL')},

    WIDGET.newSlider{name='mainVol',  x=300, y=170,w=420,lim=220,color='lG',disp=SETval('mainVol'),    code=function(v)SETTING.mainVol=v love.audio.setVolume(SETTING.mainVol)end},
    WIDGET.newSlider{name='bgm',      x=300, y=240,w=420,lim=220,color='lG',disp=SETval('bgm'),        code=function(v)SETTING.bgm=v BGM.setVol(SETTING.bgm)end},
    WIDGET.newSlider{name='sfx',      x=300, y=310,w=420,lim=220,color='lC',disp=SETval('sfx'),        code=function(v)SETTING.sfx=v SFX.setVol(SETTING.sfx)end,         change=function()SFX.play('warn_1')end},
    WIDGET.newSlider{name='stereo',   x=300, y=380,w=420,lim=220,color='lC',disp=SETval('stereo'),     code=function(v)SETTING.stereo=v SFX.setStereo(SETTING.stereo)end,change=function()SFX.play('move',1,-1)SFX.play('lock',1,1)end,hideF=function()return SETTING.sfx==0 end},
    WIDGET.newSlider{name='spawn',    x=300, y=450,w=420,lim=220,color='lC',disp=SETval('sfx_spawn'),  code=function(v)SETTING.sfx_spawn=v end,                          change=function()SFX.fplay('spawn_'..math.random(7),SETTING.sfx_spawn)end,},
    WIDGET.newSlider{name='warn',     x=300, y=520,w=420,lim=220,color='lC',disp=SETval('sfx_warn'),   code=function(v)SETTING.sfx_warn=v end,                           change=function()SFX.fplay('warn_beep',SETTING.sfx_warn)end},
    WIDGET.newSlider{name='vib',      x=300, y=590,w=420,lim=220,color='lN',disp=SETval('vib'),unit=10,code=function(v)SETTING.vib=v end,                                change=function()if SETTING.vib>0 then VIB(SETTING.vib+2)end end},
    WIDGET.newSlider{name='voc',      x=300, y=660,w=420,lim=220,color='lN',disp=SETval('voc'),        code=function(v)SETTING.voc=v VOC.setVol(SETTING.voc)end,         change=function()VOC.play('test')end},

    WIDGET.newSwitch{name='autoMute', x=1150,y=180,lim=380,disp=SETval('autoMute'),code=SETrev('autoMute')},
    WIDGET.newSwitch{name='fine',     x=1150,y=250,lim=380,disp=SETval('fine'),code=function()SETTING.fine=not SETTING.fine if SETTING.fine then SFX.play('finesseError',.6)end end},

    WIDGET.newSelector{name='sfxPack',x=1100,y=330,w=200,color='lV',list=SFXPACKS,disp=function()return sfxPack end,code=function(i)sfxPack=i end},
    WIDGET.newButton{name='apply',    x=1100,y=400,w=180,h=60,code=function()SETTING.sfxPack=sfxPack SFX.load('media/effect/'..sfxPack..'/')end,hideF=function()return SETTING.sfxPack==sfxPack end},
    WIDGET.newSelector{name='vocPack',x=1100,y=470,w=200,color='lV',list=VOCPACKS,disp=function()return vocPack end,code=function(i)vocPack=i end},
    WIDGET.newButton{name='apply',    x=1100,y=540,w=180,h=60,code=function()SETTING.vocPack=vocPack VOC.load('media/vocal/'..vocPack..'/')end,hideF=function()return SETTING.vocPack==vocPack end},
    WIDGET.newButton{name='back',     x=1140,y=640,w=170,h=80,font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
