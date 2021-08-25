local gc=love.graphics
local sin=math.sin

local author={
    blank="MrZ (old works)",
    race="MrZ (old works)",
    infinite="MrZ (old works)",
    push="MrZ (old works)",
    way="MrZ (old works)",
    reason="MrZ (old works)",
    cruelty="MrZ (old works)",
    final="MrZ (old works)",
    ["end"]="MrZ (old works)",
    battle="Aether & MrZ",
    empty="ERM",
    ["how feeling"]="????",
    moonbeam="Beethoven & MrZ",
    ["secret7th remix"]="柒栎流星",
    ["jazz nihilism"]="Trebor",
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
    if key=="down"then
        if S<#bgmList then
            selected=S+1
            SFX.play('move',.7)
        end
    elseif key=="up"then
        if S>1 then
            selected=S-1
            SFX.play('move',.7)
        end
    elseif not isRep then
        if key=="return"or key=="space"then
            if BGM.nowPlay~=bgmList[S]then
                BGM.play(bgmList[S])
                if SETTING.bgm>0 then SFX.play('click')end
            else
                BGM.stop()
            end
        elseif key=="tab"then
            SCN.swapTo('sound','none')
        elseif key=="escape"then
            SCN.back()
        end
    end
end

function scene.draw()
    gc.setColor(COLOR.Z)

    setFont(50)
    gc.print(bgmList[selected],320,355)
    setFont(35)
    if selected>1 then          gc.print(bgmList[selected-1],320,350-30)end
    if selected<#bgmList then   gc.print(bgmList[selected+1],320,350+65)end
    setFont(20)
    if selected>2 then          gc.print(bgmList[selected-2],320,350-50)end
    if selected<#bgmList-1 then gc.print(bgmList[selected+2],320,350+110)end

    gc.draw(TEXTURE.title,840,220,nil,.5,nil,580,118)
    if BGM.nowPlay then
        local t=TIME()
        setFont(45)
        gc.setColor(sin(t*.5)*.2+.8,sin(t*.7)*.2+.8,sin(t)*.2+.8)
        gc.print(BGM.nowPlay,710,508)
        setFont(35)
        gc.setColor(1,sin(t*2.6)*.5+.5,sin(t*2.6)*.5+.5)
        gc.print(author[BGM.nowPlay]or"MrZ",680,465)

        local a=-t%2.3/2
        if a<1 then
            gc.setColor(1,1,1,a)
            gc.draw(TEXTURE.title_color,840,220,nil,.5+.062-.062*a,.5+.126-.126*a,580,118)
        end

        gc.setColor(1,1,1,.4)
        gc.setLineWidth(4)
        gc.line(500,600,900,600)
        gc.setColor(COLOR.Z)
        gc.circle('fill',500+400*BGM.playing:tell()/BGM.playing:getDuration(),600,6)
    end
end

scene.widgetList={
    WIDGET.newText{name="title",  x=30,y=30,font=80,align='L'},
    WIDGET.newText{name="arrow",  x=270,y=360,font=45,align='L'},
    WIDGET.newText{name="now",    x=700,y=500,font=50,align='R',hideF=function()return not BGM.nowPlay end},
    WIDGET.newSlider{name="bgm",  x=760,y=80,w=400,disp=SETval("bgm"),code=function(v)SETTING.bgm=v BGM.freshVolume()end},
    WIDGET.newButton{name="up",   x=200,y=250,w=120,code=pressKey"up",hideF=function()return selected==1 end,fText=GC.DO{32,32,{'setLW',4},{'line',2,28,16,4,30,28}}},
    WIDGET.newButton{name="play", x=200,y=390,w=120,code=pressKey"space",fText=GC.DO{64,64,{'fPoly',14+3,10,14+3,54,55+3,32}}},
    WIDGET.newButton{name="down", x=200,y=530,w=120,code=pressKey"down",hideF=function()return selected==#bgmList end,fText=GC.DO{32,32,{'setLW',4},{'line',2,4,16,28,30,4}}},
    WIDGET.newButton{name="sound",x=1140,y=540,w=170,h=80,font=40,code=pressKey"tab"},
    WIDGET.newButton{name="back", x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene