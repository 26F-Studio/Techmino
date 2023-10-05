local scene={}

local selected-- Mod selected

local function _modComp(a,b)
    return a.no<b.no
end
local function _remMod(M)
    local i=TABLE.find(GAME.mod,M)
    if i then
        table.remove(GAME.mod,i)
    end
end
local function _toggleMod(M,back)
    if M.sel==0 then
        table.insert(GAME.mod,M)
        table.sort(GAME.mod,_modComp)
    end
    if M.list then
        if back then
            M.sel=(M.sel-1)%(#M.list+1)
        else
            M.sel=(M.sel+1)%(#M.list+1)
        end
    else
        M.sel=1-M.sel
    end
    if M.sel==0 then
        _remMod(M)
    end
    if M.unranked then
        SFX.play('touch',.6)
        SFX.play('lock')
    else
        SFX.play('touch')
        SFX.play('lock',.6)
    end
    scene.widgetList.unranked.hide=scoreValid()
end

function scene.enter()
    selected=false
    scene.widgetList.unranked.hide=scoreValid()
    BG.set('tunnel')
end

function scene.mouseMove(x,y)
    selected=false
    for _,M in next,MODOPT do
        if (x-M.x)^2+(y-M.y)^2<2000 then
            selected=M
            break
        end
    end
end
function scene.mouseDown(x,y,k)
    for _,M in next,MODOPT do
        if (x-M.x)^2+(y-M.y)^2<2000 then
            _toggleMod(M,k==2 or love.keyboard.isDown('lshift','rshift'))
            break
        end
    end
end

scene.touchMove=scene.mouseMove
function scene.touchDown(x,y)
    scene.mouseMove(x,y)
    scene.mouseDown(x,y)
end

function scene.keyDown(key)
    if key=='tab' or key=='delete' then
        if GAME.mod[1] then
            while GAME.mod[1] do
                table.remove(GAME.mod).sel=0
            end
            scene.widgetList.unranked.hide=scoreValid()
            SFX.play('hold')
        end
    elseif #key==1 then
        for _,M in next,MODOPT do
            if key==M.key then
                _toggleMod(M,love.keyboard.isDown('lshift','rshift'))
                selected=M
                break
            end
        end
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.update()
    for _,M in next,MODOPT do
        if M.sel==0 then
            if M.time>0 then
                M.time=M.time-1
            end
        else
            if M.time<10 then
                M.time=M.time+1
            end
        end
    end
end
function scene.draw()
    setFont(40)
    GC.setLineWidth(5)
    for _,M in next,MODOPT do
        GC.push('transform')
        GC.translate(M.x,M.y)
        local t=M.time*.01-- t range:0~0.1
        GC.scale(1+3*t)
        GC.rotate(t)
            local rad,side
            if M.unranked then
                rad,side=45,5
            else
                rad=40
            end
            local color=M.color
            GC.setColor(color[1],color[2],color[3],5*t)
            GC.circle('fill',0,0,rad,side)

            GC.setColor(color)
            GC.circle('line',0,0,rad,side)
            GC.setColor(COLOR.Z)
            GC.mStr(M.id,0,-27)
            if M.sel>0 and M.list then
                setFont(25)
                GC.setColor(1,1,1,10*t)
                GC.mStr(M.list[M.sel],20,8)
                setFont(40)
            end

            if M.list then
                GC.setColor(1,1,1,t*6)
                GC.arc('line','open',0,0,rad+6,0,(M.sel/#M.list)*6.2832)
            end
        GC.pop()
    end

    GC.setColor(COLOR.Z)
    if selected then
        setFont(30)
        GC.printf(text.modInfo[selected.name],70,540,950)
    else
        setFont(25)
        GC.printf(text.modInstruction,70,540,950)
    end
end

scene.widgetList={
    WIDGET.newText{name='title',   x=80,y=50,font=70,align='L'},
    WIDGET.newText{name='unranked',x=1200,y=60,color='Y',font=50,align='R'},
    WIDGET.newButton{name='reset', x=1140,y=540,w=170,h=80,font=25,code=pressKey'tab'},
    WIDGET.newButton{name='back',  x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
