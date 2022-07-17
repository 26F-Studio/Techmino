local gc=love.graphics

local scene={}

local verName=("%s  %s  %s"):format(SYSTEM,VERSION.string,VERSION.name)
local tipLength=760
local tip=gc.newText(getFont(30),"")
local scrollX--Tip scroll position

local widgetX0={
    -10,-10,-10,-10,
    1290,1290,1290,1290,
}
local enterConsole=coroutine.wrap(function()
    while true do
        Snd('bell',.6,'A4',.7,'E5',1,MATH.coin('A5','B5'))YIELD()
        Snd('bell',.6,'A4',.7,'F5',1,MATH.coin('C6','D6'))YIELD()
        Snd('bell',.6,'A4',.7,'G5',1,MATH.coin('E6','G6'))YIELD()
        Snd('bell',.6,'A4',.7,'A5',1,'A6')SFX.play('ren_mega')SCN.go('app_console')YIELD()
    end
end)
function scene.sceneInit()
    BG.set()

    --Set tip
    tip:set(text.getTip())
    scrollX=tipLength

    --Set quick-play-button text
    scene.resize()

    --Create demo player
    destroyPlayers()
    GAME.modeEnv=NONE
    GAME.setting={}
    PLY.newDemoPlayer(1)
    PLAYERS[1]:setPosition(520,140,.8)
end

function scene.resize()
    local qpModeName=text.modes[STAT.lastPlay]and text.modes[STAT.lastPlay][1]or"["..STAT.lastPlay.."]"
    scene.widgetList[2]:setObject(text.WidgetText.main.qplay..qpModeName)
end

function scene.mouseDown(x,y)
    if x>=400 and x<=880 and y>=10 and y<=110 then
        enterConsole()
    end
end
scene.touchDown=scene.mouseDown
local function _testButton(n)
    if NET.getlock('access_and_login')then
        MES.new('warn',text.wsConnecting)
    else
        if WIDGET.isFocus(scene.widgetList[n])then
            return true
        else
            WIDGET.focus(scene.widgetList[n])
        end
    end
end
function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='1'then
        if _testButton(1)then
            SCN.go('mode')
        end
    elseif key=='q'then
        if _testButton(2)then
            loadGame(STAT.lastPlay,true)
        end
    elseif key=='a'then
        if _testButton(3)then
            if WS.status('app')=='running'then
                NET.tryLogin(false)
            elseif WS.status('app')=='dead'then
                NET.wsconn_app()
                SFX.play('connect')
                MES.new('info',text.wsConnecting)
            end
        end
    elseif key=='z'then
        if _testButton(4)then
            SCN.go('customGame')
        end
    elseif key=='-'then
        if _testButton(5)then
            SCN.go('setting_game')
        end
    elseif key=='p'then
        if _testButton(6)then
            SCN.go('stat')
        end
    elseif key=='l'then
        if _testButton(7)then
            SCN.go('dict')
        end
    elseif key==','then
        if _testButton(8)then
            SCN.go('replays')
        end
    elseif key=='2'then
        if _testButton(9)then
            SCN.go('music')
        end
    elseif key=='3'then
        if _testButton(10)then
            SCN.go('lang')
        end
    elseif key=='x'then
        if _testButton(11)then
            SCN.go('about')
        end
    elseif key=='m'then
        if _testButton(12)then
            SCN.go('manual')
        end
    elseif key=='c'then
        enterConsole()
    elseif key=='escape'then
        if tryBack()then
            VOC.play('bye')
            SCN.swapTo('quit','slowFade')
        end
    else
        return true
    end
end

function scene.update(dt)
    if dt>.26 then return end
    PLAYERS[1]:update(dt)
    scrollX=scrollX-162*dt
    if scrollX<-tip:getWidth()then
        scrollX=tipLength
        tip:set(text.getTip())
    end
    local L=scene.widgetList
    for i=1,8 do
        L[i].x=MATH.expApproach(L[i].x,(widgetX0[i]-400+(WIDGET.isFocus(L[i])and(i<5 and 100 or -100)or 0)),dt*9)
    end
end

local function _tipStencil()
    gc.rectangle('fill',0,0,tipLength,42)
end
function scene.draw()
    --Version
    setFont(20)
    gc.setColor(.6,.6,.6)
    mStr(verName,640,110)

    --Title
    gc.setColor(1,1,1)
    mDraw(TEXTURE.title_color,640,60,nil,.43)

    --Tip
    gc.setColor(COLOR.Z)
    gc.push('transform')
    gc.translate(260,650)
    gc.setLineWidth(2)
    gc.rectangle('line',0,0,tipLength,42,3)
    gc.stencil(_tipStencil)
    gc.setStencilTest('equal',1)
    gc.draw(tip,0+scrollX,0)
    gc.setColor(1,1,1,.2)
    gc.setStencilTest()
    gc.pop()

    --Player
    PLAYERS[1]:draw()

    --Profile
    drawSelfProfile()

    --Player count
    drawOnlinePlayerCount()

    --Connecting mark
    if NET.getlock('access_and_login')then
        gc.setColor(COLOR.Z)
        gc.setLineWidth(10)
        local t=TIME()*6.26%6.2832
        gc.arc('line','open',scene.widgetList[3].x+865,450,40,t,t+4.26)
    end
end

scene.widgetList={
    WIDGET.newButton{name='offline',x=-1200,y=210,w=800,h=100,color='lR',font=45,align='R',edge=30,code=pressKey'1'},
    WIDGET.newButton{name='qplay',  x=-1200,y=330,w=800,h=100,color='lM',font=40,align='R',edge=30,code=pressKey'q'},
    WIDGET.newButton{name='online', x=-1200,y=450,w=800,h=100,color='lV',font=45,align='R',edge=30,code=pressKey'a'},
    WIDGET.newButton{name='custom', x=-1200,y=570,w=800,h=100,color='lS',font=45,align='R',edge=30,code=pressKey'z'},

    WIDGET.newButton{name='setting',x=2480,y=210,w=800,h=100, color='lO',font=40,align='L',edge=30,code=pressKey'-'},
    WIDGET.newButton{name='stat',   x=2480,y=330,w=800,h=100, color='lL',font=40,align='L',edge=30,code=pressKey'p'},
    WIDGET.newButton{name='dict',   x=2480,y=450,w=800,h=100, color='lG',font=40,align='L',edge=30,code=pressKey'l'},
    WIDGET.newButton{name='replays',x=2480,y=570,w=800,h=100, color='lC',font=40,align='L',edge=30,code=pressKey','},

    WIDGET.newButton{name='music',  x=120,y=80,w=100,         color='lO',code=pressKey'2',font=70,fText=CHAR.icon.music},
    WIDGET.newButton{name='lang',   x=280,y=80,w=100,         color='lN',code=pressKey'3',font=70,fText=CHAR.icon.language},
    WIDGET.newButton{name='about',  x=-110,y=670,w=600,h=70,  color='lB',align='R',edge=20,code=pressKey'x',font=50,fText=CHAR.icon.info},
    WIDGET.newButton{name='manual', x=1390,y=670,w=600,h=70,  color='lR',align='L',edge=20,code=pressKey'm',font=50,fText=CHAR.icon.help},
}
return scene
