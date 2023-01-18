local gc=love.graphics

local sin=math.sin

local scene={}

function scene.enter()
    BG.set()
end

function scene.mouseDown(x,y)
    if x>55 and y>550 and x<450 and y<670 then
        loadGame('stack_e',true)
    end
end
scene.touchDown=scene.mouseDown

function scene.keyDown(key)
    if key=='space' then
        loadGame('stack_e',true)
    else
        return true
    end
end

function scene.draw()
    -- Texts
    setFont(20)
    gc.setColor(COLOR.Z)
    for i=1,#text.aboutTexts do
        gc.print(text.aboutTexts[i],62,35*i)
    end

    -- Lib used
    setFont(15)
    gc.print(text.used,495,426)-- ❤Flandre❤

    -- Logo
    gc.draw(TEXTURE.title,280,610,.1,.4+.03*sin(TIME()*2.6),nil,580,118)
end

scene.widgetList={
    WIDGET.newButton{name='staff',  x=1140,y=340,w=200,h=80,font=35,code=goScene'staff'},
    WIDGET.newButton{name='his',    x=1140,y=440,w=200,h=80,font=35,code=goScene'history'},
    WIDGET.newButton{name='legals', x=1140,y=540,w=200,h=80,font=35,code=goScene'legals'},
    WIDGET.newButton{name='back',   x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
