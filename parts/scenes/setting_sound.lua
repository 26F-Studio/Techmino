local gc=love.graphics

local sin=math.sin
local rnd=math.random

local scene={}
local soundBeforeMute

local last--Last touch time
local jump--Animation timer(10 to 0)
local cv=SETTING.cv

function scene.sceneInit()
    last,jump=0,0
    cv=SETTING.cv
    WIDGET.active.cv:reset()
    BG.set()
end
function scene.sceneBack()
    saveSettings()
end

function scene.mouseDown(x,y)
    if x>780 and x<980 and y>470 and jump==0 then
        jump=10
        local t=TIME()-last
        if t>1 then
            if t>2.6 and t<3 and not GAME.playing then
                loadGame('sprintSmooth',true)
            else
                VOC.play(
                    (t<1.5 or t>15)and"doubt"or
                    rnd()<.8 and"happy"or
                    "egg"
                )
                last=TIME()
            end
        end
    end
end
function scene.touchDown(x,y)
    scene.mouseDown(x,y)
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
    if cv=="miya"then
        gc.draw(IMG.miyaCH)
        gc.setColor(1,1,1,.7)
        gc.draw(IMG.miyaF1,4,47+4*sin(t*.9))
        gc.draw(IMG.miyaF2,42,107+5*sin(t))
        gc.draw(IMG.miyaF3,93,126+3*sin(t*.7))
        gc.draw(IMG.miyaF4,129,98+3*sin(t*.5))
    elseif cv=="naki"then
        gc.draw(IMG.nakiCH,-30)
    elseif cv=="xiaoya"then
        gc.draw(IMG.xiaoyaCH,-30)
    end
    gc.translate(-x,-y)
end

scene.widgetList={
    WIDGET.newText{name="title",    x=640, y=15,font=80},

    WIDGET.newButton{name="game",   x=200, y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_game','swipeR')},
    WIDGET.newButton{name="graphic",x=1080,y=80,w=240,h=80,color='lC',font=35,code=swapScene('setting_video','swipeL')},

    WIDGET.newSlider{name="bgm",    x=300, y=190,w=420,color='lG',disp=SETval('bgm'),code=function(v)SETTING.bgm=v BGM.freshVolume()end},
    WIDGET.newSlider{name="sfx",    x=300, y=260,w=420,color='lC',change=function()SFX.play('blip_1')end,disp=SETval('sfx'),code=SETsto('sfx')},
    WIDGET.newSlider{name="stereo", x=300, y=330,w=420,color='lC',change=function()SFX.play('move',1,-1)SFX.play('lock',1,1)end,disp=SETval('stereo'),code=SETsto('stereo'),hideF=function()return SETTING.sx==0 end},
    WIDGET.newSlider{name="spawn",  x=300, y=400,w=420,color='lC',change=function()SFX.fplay('spawn_'..math.random(7),SETTING.sfx_spawn)end,disp=SETval('sfx_spawn'),code=SETsto('sfx_spawn')},
    WIDGET.newSlider{name="warn",   x=300, y=470,w=420,color='lC',change=function()SFX.fplay('warning',SETTING.sfx_warn)end,disp=SETval('sfx_warn'),code=SETsto('sfx_warn')},
    WIDGET.newSlider{name="vib",    x=300, y=540,w=420,color='lN',unit=10,change=function()VIB(2)end,disp=SETval('vib'),code=SETsto('vib')},
    WIDGET.newSlider{name="voc",    x=300, y=610,w=420,color='lN',change=function()VOC.play('test')end,disp=SETval('voc'),code=SETsto('voc')},

    WIDGET.newKey{name="mute",      x=1160,y=180,w=80,color='lR',fText=TEXTURE.mute,
        code=function()
            if  SETTING.sfx+SETTING.sfx_spawn+SETTING.sfx_warn+SETTING.bgm+SETTING.vib+SETTING.voc==0 then
                if not soundBeforeMute then
                    soundBeforeMute={1,0,.4,.7,0,0}
                end
                SETTING.sfx,SETTING.sfx_spawn,SETTING.sfx_warn,SETTING.bgm,SETTING.vib,SETTING.voc=unpack(soundBeforeMute)
                soundBeforeMute=false
            else
                soundBeforeMute={
                SETTING.sfx,SETTING.sfx_spawn,SETTING.sfx_warn,SETTING.bgm,SETTING.vib,SETTING.voc}
                SETTING.sfx,SETTING.sfx_spawn,SETTING.sfx_warn,SETTING.bgm,SETTING.vib,SETTING.voc=0,0,0,0,0,0
            end
            BGM.freshVolume()
        end},
    WIDGET.newSwitch{name="fine",   x=1150,y=270,disp=SETval('fine'),code=function()SETTING.fine=not SETTING.fine if SETTING.fine then SFX.play('finesseError',.6)end end},

    WIDGET.newSelector{name="cv",   x=1100,y=380,w=200,list={'miya','naki','xiaoya','miku'},disp=function()return cv end,code=function(i)cv=i end},
    WIDGET.newButton{name="apply",  x=1100,y=460,w=180,h=80,code=function()SETTING.cv=cv VOC.loadAll()end,hideF=function()return SETTING.cv==cv end},
    WIDGET.newButton{name="back",   x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene
