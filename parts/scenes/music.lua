local sin=math.sin

local author={
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

local playing
local selected-- Music selected

local bgmList=BGM.getList()
if #bgmList==0 then bgmList={"[NO BGM]"} end

function scene.enter()
    playing=BGM.getPlaying()[1]
    selected=TABLE.find(bgmList,playing) or 1
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end
function scene.keyDown(key,isRep)
    local S=selected
    if key=='down' then
        if S<#bgmList then
            selected=S+1
            SFX.play('touch',.7)
        end
    elseif key=='up' then
        if S>1 then
            selected=S-1
            SFX.play('touch',.7)
        end
    elseif not isRep then
        if key=='return' or key=='space' then
            if playing~=bgmList[S] then
                BGM.play(bgmList[S])
                SFX.play('click')
            else
                BGM.stop()
                SFX.play('click')
            end
            playing=BGM.getPlaying()[1]
        elseif key=='tab' then
            SCN.swapTo('launchpad','none')
        elseif key=='escape' then
            SCN.back()
        elseif #key==1 and key:find'[0-9a-z]' then
            for _=1,#bgmList do
                selected=(selected-1+(love.keyboard.isDown('lshift','rshift') and -1 or 1))%#bgmList+1
                if bgmList[selected]:sub(1,1)==key then break end
            end
        end
    end
end

function scene.draw()
    local t=TIME()

    -- Character
    GC.push('transform')
        GC.setColor(1,1,1)
        GC.translate(906,456)
        GC.scale(.6)
        mDraw(IMG.z.character)
        mDraw(IMG.z.screen1, -91, -157+16*math.sin(t))
        mDraw(IMG.z.screen2, 120, -166+16*math.sin(t+1))
        GC.setColor(1,1,1,.7+.3*math.sin(.6*t)) mDraw(IMG.z.particle1, -50,                    42+6*math.sin(t*0.36))
        GC.setColor(1,1,1,.7+.3*math.sin(.7*t)) mDraw(IMG.z.particle2, 110+6*math.sin(t*0.92), 55)
        GC.setColor(1,1,1,.7+.3*math.sin(.8*t)) mDraw(IMG.z.particle3, -54+6*math.sin(t*0.48), -248)
        GC.setColor(1,1,1,.7+.3*math.sin(.9*t)) mDraw(IMG.z.particle4, 133,                    -305+6*math.sin(t*0.40))
    GC.pop()

    GC.setColor(COLOR.Z)

    -- Scroller
    GC.setLineWidth(2)
    GC.line(315,307,315,482)
    setFont(50)
    GC.print(bgmList[selected],320,355)
    setFont(35)
    if selected>1 then GC.print(bgmList[selected-1],322,350-30) end
    if selected<#bgmList then GC.print(bgmList[selected+1],322,350+65) end
    setFont(20)
    if selected>2 then GC.print(bgmList[selected-2],322,350-50) end
    if selected<#bgmList-1 then GC.print(bgmList[selected+2],322,350+110) end

    -- Title
    if playing then
        mDraw(TEXTURE.title,570,190,nil,.42)
        local a=-t%2.3/2.3
        GC.setColor(1,1,1,math.min(a,1))
        mDraw(TEXTURE.title_color,570,190,nil,.42+.062-.062*a)
    end

    -- Music player
    if playing then
        setFont(45)
        GC.shadedPrint(playing,710,508,'left',2)
        GC.setColor(sin(t*.5)*.2+.8,sin(t*.7)*.2+.8,sin(t)*.2+.8)
        GC.print(playing,710,508)

        setFont(35)
        local name=author[playing] or "MrZ"
        GC.setColor(.26,.26,.26)
        GC.print(name,670-1,465-1)
        GC.print(name,670-1,465+1)
        GC.print(name,670+1,465-1)
        GC.print(name,670+1,465+1)
        GC.setColor(1,sin(t*2.6)*.3+.7,sin(t*2.6)*.3+.7)
        GC.print(name,670,465)

        setFont(20)
        GC.setColor(COLOR.Z)
        local cur=BGM.tell()
        local dur=BGM.getDuration()
        GC.print(STRING.time_simp(cur%dur).." / "..STRING.time_simp(dur),480,626)
    end
end

scene.widgetList={
    WIDGET.newText{name='title',  x=30,y=30,font=80,align='L'},
    WIDGET.newText{name='arrow',  x=270,y=360,font=45,align='L'},
    WIDGET.newText{name='now',    x=700,y=500,font=50,align='R',hideF=function() return not playing end},
    WIDGET.newSlider{name='slide',x=480,y=600,w=400,
        disp=function() return playing and BGM.tell()/BGM.getDuration()%1 end,
        show=false,
        code=function(v) BGM.set('all','seek',v*BGM.getDuration()) end,
        hideF=function() return not playing end
    },
    WIDGET.newSlider{name='bgm',  x=760,y=80,w=400,disp=SETval('bgm'),code=function(v) SETTING.bgm=v BGM.setVol(SETTING.bgm) end},
    WIDGET.newButton{name='up',   x=200,y=250,w=120,sound=false,code=pressKey'up',hideF=function() return selected==1 end,font=60,fText=CHAR.key.up},
    WIDGET.newButton{name='play', x=200,y=390,w=120,sound=false,font=65,fText=CHAR.icon.play_pause,code=pressKey'space'},
    WIDGET.newButton{name='down', x=200,y=530,w=120,sound=false,code=pressKey'down',hideF=function() return selected==#bgmList end,font=60,fText=CHAR.key.down},
    WIDGET.newButton{name='sound',x=1140,y=540,w=170,h=80,font=40,code=pressKey'tab'},
    WIDGET.newButton{name='back', x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
