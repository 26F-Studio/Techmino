local gc=love.graphics
local gc_setColor,gc_print=gc.setColor,gc.print
local sin=math.sin
local setFont=FONT.set

local author={
    blank="MrZ (old works)",
    ["end"]="MrZ (old works)",
    cruelty="MrZ (old works)",
    final="MrZ (old works)",
    infinite="MrZ (old works)",
    push="MrZ (old works)",
    race="MrZ (old works)",
    reason="MrZ (old works)",
    way="MrZ (old works)",
    battle="Aether & MrZ",
    moonbeam="Beethoven & MrZ",
    empty="ERM",
    ["how feeling"]="V.A.",
    ["sugar fairy"]="Tchaikovsky & MrZ",
    ["secret7th remix"]="柒栎流星",
    ["jazz nihilism"]="Trebor",
    ["race remix"]="柒栎流星",
    sakura="ZUN & C₂₉H₂₅N₃O₅",
    ["1980s"]="C₂₉H₂₅N₃O₅",
    malate="ZUN & C₂₉H₂₅N₃O₅",
    lounge="Hailey (cudsys) & MrZ",
}

local scene={}

local selected--Music selected

local bgmList=BGM.getList()
if #bgmList==0 then bgmList={"[NO BGM]"}end
function scene.sceneInit()
    selected=TABLE.find(bgmList,BGM.nowPlay)or 1
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end
function scene.keyDown(key,isRep)
    local S=selected
    if key=='down'then
        if S<#bgmList then
            selected=S+1
            SFX.play('touch',.7)
        end
    elseif key=='up'then
        if S>1 then
            selected=S-1
            SFX.play('touch',.7)
        end
    elseif not isRep then
        if key=='return'or key=='space'then
            if BGM.nowPlay~=bgmList[S]then
                BGM.play(bgmList[S])
                SFX.play('click')
            else
                BGM.stop()
                SFX.play('click')
            end
        elseif key=='tab'then
            SCN.swapTo('launchpad','none')
        elseif key=='escape'then
            SCN.back()
        elseif #key==1 and key:find'[0-9a-z]'then
            for _=1,#bgmList do
                selected=selected%#bgmList+1
                if bgmList[selected]:sub(1,1)==key then break end
            end
        end
    end
end

function scene.draw()
    gc_setColor(COLOR.Z)

    --Scroller
    gc.setLineWidth(2)
    gc.line(315,307,315,482)
    setFont(50)
    gc_print(bgmList[selected],320,355)
    setFont(35)
    if selected>1 then gc_print(bgmList[selected-1],322,350-30)end
    if selected<#bgmList then gc_print(bgmList[selected+1],322,350+65)end
    setFont(20)
    if selected>2 then gc_print(bgmList[selected-2],322,350-50)end
    if selected<#bgmList-1 then gc_print(bgmList[selected+2],322,350+110)end

    --Music player
    gc.draw(TEXTURE.title,840,220,nil,.5,nil,580,118)
    if BGM.nowPlay then
        local t=TIME()
        setFont(45)
        gc_setColor(sin(t*.5)*.2+.8,sin(t*.7)*.2+.8,sin(t)*.2+.8)
        gc_print(BGM.nowPlay,710,508)
        setFont(35)
        gc_setColor(1,sin(t*2.6)*.5+.5,sin(t*2.6)*.5+.5)
        gc_print(author[BGM.nowPlay]or"MrZ",670,465)

        local a=-t%2.3/2
        if a<1 then
            gc_setColor(1,1,1,a)
            gc.draw(TEXTURE.title_color,840,220,nil,.5+.062-.062*a,.5+.126-.126*a,580,118)
        end

        setFont(20)
        gc_setColor(COLOR.Z)
        local cur=BGM.playing:tell()
        local dur=BGM.playing:getDuration()
        gc_print(STRING.time_simp(cur%dur).." / "..STRING.time_simp(dur),480,626)
    end
end

scene.widgetList={
    WIDGET.newText{name='title',  x=30,y=30,font=80,align='L'},
    WIDGET.newText{name='arrow',  x=270,y=360,font=45,align='L'},
    WIDGET.newText{name='now',    x=700,y=500,font=50,align='R',hideF=function()return not BGM.nowPlay end},
    WIDGET.newSlider{name='slide',x=480,y=600,w=400,
        disp=function()return BGM.playing:tell()/BGM.playing:getDuration()%1 end,
        show=false,
        code=function(v)BGM.seek(v*BGM.playing:getDuration())end,
        hideF=function()return not BGM.nowPlay end
    },
    WIDGET.newSlider{name='bgm',  x=760,y=80,w=400,disp=SETval('bgm'),code=function(v)SETTING.bgm=v BGM.setVol(SETTING.bgm)end},
    WIDGET.newButton{name='up',   x=200,y=250,w=120,sound=false,code=pressKey'up',hideF=function()return selected==1 end,font=60,fText=CHAR.key.up},
    WIDGET.newButton{name='play', x=200,y=390,w=120,sound=false,font=65,fText=CHAR.icon.play_pause,code=pressKey'space'},
    WIDGET.newButton{name='down', x=200,y=530,w=120,sound=false,code=pressKey'down',hideF=function()return selected==#bgmList end,font=60,fText=CHAR.key.down},
    WIDGET.newButton{name='sound',x=1140,y=540,w=170,h=80,font=40,code=pressKey'tab'},
    WIDGET.newButton{name='back', x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
