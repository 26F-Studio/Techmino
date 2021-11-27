local gc=love.graphics

local sin=math.sin

local scene={}

function scene.sceneInit()
    BG.set()
end

function scene.mouseDown(x,y)
    if x>55 and y>550 and x<510 and y<670 then
        loadGame('stack_e',true)
    end
end
scene.touchDown=scene.mouseDown

function scene.keyDown(key)
    if key=='space'then
        loadGame('stack_e',true)
    else
        return true
    end
end

function scene.draw()
    --Texts
    setFont(20)
    gc.setColor(COLOR.Z)
    for i=1,#text.aboutTexts do
        gc.printf(text.aboutTexts[i],150,35*i+50,1000,'center')
    end

    --Lib used
    setFont(15)
    gc.print(text.used,50,325)

    --Logo
    local t=TIME()
    gc.draw(TEXTURE.title,280,610,.1,.4+.03*sin(t*2.6),nil,580,118)
    gc.setLineWidth(3)

    if SYSTEM~='iOS'then
        --QR Code frame
        gc.rectangle('line',18,18,263,263)
        gc.rectangle('line',1012,18,250,250)

        --Support text
        gc.setColor(1,1,1,sin(t*20)*.3+.6)
        setFont(30)
        mStr(text.support,150+sin(t*4)*20,283)
        mStr(text.support,1138-sin(t*4)*20,270)
    end
end

scene.widgetList={
    WIDGET.newImage{name='pay1',    x=20,  y=20,hide=SYSTEM=='iOS'},
    WIDGET.newImage{name='pay2',    x=1014,y=20,hide=SYSTEM=='iOS'},
    WIDGET.newButton{name='staff',  x=1140,y=380,w=220,h=80,font=35,code=goScene'staff'},
    WIDGET.newButton{name='his',    x=1140,y=470,w=220,h=80,font=35,code=goScene'history'},
    WIDGET.newButton{name='legals', x=1140,y=560,w=220,h=80,font=35,code=goScene'legals'},
    WIDGET.newButton{name='qq',     x=1140,y=650,w=220,h=80,font=35,code=function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,hide=MOBILE},
    WIDGET.newButton{name='back',   x=640, y=600,w=170,h=80,font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
