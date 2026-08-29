local scene={}

local verName=("%s  %s  %s"):format(SYSTEM,VERSION.string,VERSION.name)
local tipLength=720
local tip=GC.newText(getFont(30),"")
local scrollX-- Tip scroll position
local flash=0

local LX=280-- Primary left column center x (align 'R')
local RX=1000-- Primary right column center x (align 'L')
local HIDE_L=-1200-- Off-screen left (hidden)
local HIDE_R=2400-- Off-screen right (hidden)
local submenu=false
local targetMain,targetSub={},{}
local pos={
    -- 6 primary big buttons (slide away when Quick Play submenu opens)
    qplay   ={LX,HIDE_L},
    online  ={LX,HIDE_L},
    custom  ={LX,HIDE_L},
    settings={RX,HIDE_R},
    stat    ={RX,HIDE_R},
    replays ={RX,HIDE_R},
    -- Quick Play submenu (slide in when open)
    qp_40l  ={HIDE_L,LX},
    qp_sprint={HIDE_L,LX},
    qp_lock ={HIDE_L,LX},
    offline ={HIDE_R,RX},
    back    ={HIDE_R,RX},
    -- 4 persistent small square icon buttons (2 per side, mirrored with the left pair, never slide)
    music   ={90,90},
    notice  ={210,210},
    lang    ={1070,1070},
    dict    ={1190,1190},
    -- Persistent bottom buttons (About: align 'R' far-left; How-to-play: align 'L' far-right, mirrored)
    about   ={0,0},
    manual  ={1280,1280},
}
local PRIM_WIDGETS={'qplay','online','custom','settings','stat','replays'}
local SUB_WIDGETS={'qp_40l','qp_sprint','qp_lock','offline','back'}
local SLIDE_W={}
for _,n in next,PRIM_WIDGETS do SLIDE_W[n]=true end
for _,n in next,SUB_WIDGETS do SLIDE_W[n]=true end
local function setSubmenu(v)
    submenu=v
    for _,n in next,PRIM_WIDGETS do scene.widgetList[n].hide=v end
    for _,n in next,SUB_WIDGETS do scene.widgetList[n].hide=not v end
end
local enterConsole=coroutine.wrap(function()
    while true do
        Snd('bell',.6,'A4',.7,'E5',1,MATH.coin('A5','B5'))coroutine.yield()
        Snd('bell',.6,'A4',.7,'F5',1,MATH.coin('C6','D6'))coroutine.yield()
        Snd('bell',.6,'A4',.7,'G5',1,MATH.coin('E6','G6'))coroutine.yield()
        Snd('bell',.6,'A4',.7,'A5',1,'A6')SFX.play('ren_mega')SCN.go('app_console')coroutine.yield()
    end
end)
function scene.enter()
    if THEME.cur=='halloween' then
        TASK.new(function()
            TEST.yieldT(.26)
            while SCN.cur=='main' do
                flash=.355
                SFX.play('clear_'..math.random(4,6),1,math.random()*2-1,-9-math.random()*3)
                TEST.yieldT(.626+math.random()*6.26)
            end
        end)
    end
    BG.set()

    -- Set tip
    tip:set(text.getTip())
    scrollX=tipLength

    -- Set quick-play-button text
    scene.resize()

    -- Create demo player
    destroyPlayers()
    GAME.modeEnv=NONE
    GAME.setting={}
    PLY.newDemoPlayer(1)
    PLAYERS[1]:setPosition(520,140,.8)

    DiscordRPC.update("In Main Menu")
    setSubmenu(false)
end

function scene.resize()
end

function scene.mouseDown(x,y)
    if x>=400 and x<=880 and y>=10 and y<=110 then
        enterConsole()
    end
end
scene.touchDown=scene.mouseDown
local function _testButton(W)
    if WIDGET.isFocus(W) then
        return true
    else
        WIDGET.focus(W)
    end
end
function scene.keyDown(key,isRep)
    if isRep then return true end
    if submenu then
        if key=='q' then
            if _testButton(scene.widgetList.qp_40l) then loadGame('sprint_40l',true) end
        elseif key=='w' then
            if _testButton(scene.widgetList.qp_sprint) then loadGame('sprint_100l',true) end
        elseif key=='e' then
            if _testButton(scene.widgetList.qp_lock) then loadGame('sprintLock',true) end
        elseif key=='r' then
            if _testButton(scene.widgetList.offline) then SCN.go('mode') end
        elseif key=='escape' or key=='backspace' then
            if _testButton(scene.widgetList.back) then setSubmenu(false) end
        else
            return true
        end
    else
        if key=='1' then
            if _testButton(scene.widgetList.qplay) then setSubmenu(true) end
        elseif key=='a' then
            if _testButton(scene.widgetList.online) then NET.login(true) end
        elseif key=='z' then
            if _testButton(scene.widgetList.custom) then SCN.go('customGame') end
        elseif key=='p' then
            if _testButton(scene.widgetList.stat) then SCN.go('stat') end
        elseif key==',' then
            if _testButton(scene.widgetList.replays) then SCN.go('replays') end
        elseif key=='-' then
            if _testButton(scene.widgetList.settings) then SCN.go('setting_game') end
        elseif key=='2' then
            if _testButton(scene.widgetList.music) then SCN.go('music') end
        elseif key=='3' then
            if _testButton(scene.widgetList.notice) then NET.getNotice() end
        elseif key=='4' then
            if _testButton(scene.widgetList.lang) then SCN.go('lang') end
        elseif key=='x' then
            if _testButton(scene.widgetList.about) then SCN.go('about') end
        elseif key=='h' then
            if _testButton(scene.widgetList.manual) then
                SCN.go('textReader',nil,FILE.load('parts/language/manual_'..(SETTING.locale:find'zh' and 'zh' or SETTING.locale:find'ja' and 'ja' or SETTING.locale:find'vi' and 'vi' or 'en')..'.txt','-string'):split('\n'),15,'cubes')
            end
        elseif key=='b' then
            if _testButton(scene.widgetList.dict) then SCN.go('dict') end
        elseif key=='c' then
            enterConsole()
        elseif key=='escape' then
            if tryBack() then
                VOC.play('bye')
                SCN.back()
            end
        else
            return true
        end
    end
end

function scene.update(dt)
    if dt>.26 then return end
    if flash>0 then flash=flash-dt*.6 end
    PLAYERS[1]:update(dt)
    scrollX=scrollX-162*dt
    if scrollX<-tip:getWidth() then
        scrollX=tipLength
        tip:set(text.getTip())
    end
    local L=scene.widgetList
    local T=submenu and targetSub or targetMain
    for i=1,#L do
        local tx=T[i]
        local sh=SLIDE_W[L[i].name] and (WIDGET.isFocus(L[i]) and (tx<640 and 100 or -100) or 0) or 0
        L[i].x=MATH.expApproach(L[i].x,tx-L[i].w*.5+sh,dt*9)
    end
end

local function _tipStencil()
    GC.rectangle('fill',0,0,tipLength,42)
end
function scene.draw()
    -- Version
    setFont(20)
    GC.setColor(.6,.6,.6)
    GC.mStr(verName,640,110)

    -- Title
    GC.setColor(1,1,1)
    mDraw(TEXTURE.title_color,640,60,nil,.43)

    -- Tip
    GC.setColor(COLOR.Z)
    GC.push('transform')
    GC.translate(280,650)
    GC.setLineWidth(2)
    GC.rectangle('line',0,0,tipLength,42,3)
    GC.stencil(_tipStencil)
    GC.setStencilTest('equal',1)
    GC.draw(tip,0+scrollX,0)
    GC.setColor(1,1,1,.2)
    GC.setStencilTest()
    GC.pop()

    if THEME.cur=='halloween' then
        GC.setColor(1,1,1)
        GC.mDraw(TEXTURE.spiderweb,480,50,.26,1.26)
        GC.mDraw(TEXTURE.spiderweb,816,94.2,.62)

        GC.setColor(COLOR.O)
        GC.mDraw(TEXTURE.miniBlock[1],1126,90,-.16,40)
        GC.setColor(COLOR.lO)
        GC.setLineWidth(12)
        GC.line(1037,25,1032,101)
        GC.line(1099,16,1082,93)
        GC.line(1151,16,1113,169)
        GC.line(1196,83,1184,159)
        GC.line(1244,101,1235,150)
        GC.push('transform')
        GC.translate(1126,90)
        GC.setColor(.1,.5,.1)
        GC.setLineWidth(16)
        GC.line(20,-30,48,-60,70,-65)
        GC.rotate(.162)
        GC.setColor(COLOR.D)
        FONT.set(20)
        GC.mStr(text.pumpkin,0,-13)
        GC.pop()
    end

    -- Player
    PLAYERS[1]:draw()

    if flash>0 then
        GC.replaceTransform(SCR.origin)
        GC.setColor(1,1,1,flash)
        GC.rectangle('fill',0,0,SCR.w,SCR.h)
        GC.replaceTransform(SCR.xOy)
    end
end

scene.widgetList={
    -- 6 primary big buttons (slide away when Quick Play submenu opens)
    WIDGET.newButton{name='qplay',   x=-1200,y=220,w=400,h=100,color='lR',font=45,align='R',edge=30,code=pressKey'1'},
    WIDGET.newButton{name='online',  x=-1200,y=360,w=400,h=100,color='lV',font=45,align='R',edge=30,code=pressKey'a'},
    WIDGET.newButton{name='custom',  x=-1200,y=500,w=400,h=100,color='lS',font=45,align='R',edge=30,code=pressKey'z'},

    WIDGET.newButton{name='settings',x=2480,y=220,w=400,h=100,color='lO',font=45,align='L',edge=30,code=pressKey'-'},
    WIDGET.newButton{name='stat',    x=2480,y=360,w=400,h=100,color='lL',font=40,align='L',edge=30,code=pressKey'p'},
    WIDGET.newButton{name='replays', x=2480,y=500,w=400,h=100,color='lC',font=40,align='L',edge=30,code=pressKey','},

    -- Quick Play submenu (hidden until opened)
    WIDGET.newButton{name='qp_40l',   x=HIDE_L,y=220,w=400,h=100,color='lM',font=40,align='R',edge=30,code=pressKey'q',hide=true},
    WIDGET.newButton{name='qp_sprint',x=HIDE_L,y=360,w=400,h=100,color='lM',font=40,align='R',edge=30,code=pressKey'w',hide=true},
    WIDGET.newButton{name='qp_lock',  x=HIDE_L,y=500,w=400,h=100,color='lM',font=40,align='R',edge=30,code=pressKey'e',hide=true},
    WIDGET.newButton{name='offline',  x=HIDE_R,y=220,w=400,h=100,color='lY',font=40,align='L',edge=30,code=pressKey'r',hide=true},
    WIDGET.newButton{name='back',     x=HIDE_R,y=360,w=400,h=100,color='lB',font=40,align='L',edge=30,code=pressKey'escape',hide=true},

    -- 4 persistent small square icon buttons (2 per side)
    WIDGET.newButton{name='music', x=90, y=80,w=100,h=100,color='lY',code=pressKey'2',font=70,fText=CHAR.icon.music},
    WIDGET.newButton{name='notice',x=210,y=80,w=100,h=100,color='lG',code=pressKey'3',font=70,fText=CHAR.key.winMenu},
    WIDGET.newButton{name='lang',  x=1070,y=80,w=100,h=100,color='lN',code=pressKey'4',font=70,fText=CHAR.icon.language},
    WIDGET.newButton{name='dict',  x=1190,y=80,w=100,h=100,color='lG',code=pressKey'b',font=70,fText=CHAR.icon.zBook},

    -- Persistent bottom buttons (About: align 'R' far-left; How-to-play: align 'L' far-right, mirrored)
    WIDGET.newButton{name='about',  x=0,y=671,w=240,h=56,color='lB',align='R',edge=12,code=pressKey'x',font=30,fText=CHAR.icon.info},
    WIDGET.newButton{name='manual', x=1280,y=671,w=240,h=56,color='lR',align='L',edge=12,code=pressKey'h',font=30,fText=CHAR.icon.help},
}
for i=1,#scene.widgetList do
    local p=pos[scene.widgetList[i].name]
    targetMain[i]=p[1]
    targetSub[i]=p[2]
end
return scene
