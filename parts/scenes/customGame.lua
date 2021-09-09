local gc,kb,sys=love.graphics,love.keyboard,love.system
local int=math.floor
local CUSTOMENV=CUSTOMENV

local function _notAir(L)
    for i=1,10 do
        if L[i]>0 then
            return true
        end
    end
end
local sList={
    visible={"show","easy","slow","medium","fast","none"},
    freshLimit={0,1,2,4,6,8,10,12,15,30,1e99},
    opponent={"X","9S Lv.1","9S Lv.2","9S Lv.3","9S Lv.4","9S Lv.5","CC Lv.1","CC Lv.2","CC Lv.3","CC Lv.4","CC Lv.5"},
    life={0,1,2,3,5,10,15,26,42,87,500},
    pushSpeed={1,2,3,5,15},
    fieldH={1,2,3,4,6,8,10,15,20,30,50,100},
    heightLimit={2,3,4,6,8,10,15,20,30,40,70,100,150,200,1e99},
    bufferLimit={4,6,10,15,20,40,100,1e99},

    drop={0,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
    lock={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
    wait={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
    fall={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
    eventSet=eventSetList,
}

local scene={}

local sure
local initField
local function _freshMiniFieldVisible()
    initField=false
    for y=1,20 do
        if _notAir(FIELD[1][y])then
            initField=true
            return
        end
    end
end
function scene.sceneInit()
    sure=0
    destroyPlayers()
    BG.set(CUSTOMENV.bg)
    BGM.play(CUSTOMENV.bgm)
    _freshMiniFieldVisible()
end
function scene.sceneBack()
    BGM.play()
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=="return"or key=="return2"then
        if CUSTOMENV.opponent~="X"then
            if CUSTOMENV.opponent:sub(1,2)=='CC'and CUSTOMENV.sequence=="fixed"then
                MES.new('error',text.ai_fixed)
                return
            end
            if #BAG>0 then
                for _=1,#BAG do
                    if BAG[_]>7 then
                        MES.new('error',text.ai_prebag)
                        return
                    end
                end
            end
            if #MISSION>0 then
                MES.new('error',text.ai_mission)
                return
            end
        end
        if key=="return2"or kb.isDown("lalt","lctrl","lshift")then
            if initField then
                FILE.save(CUSTOMENV,'conf/customEnv')
                loadGame('custom_puzzle',true)
            end
        else
            FILE.save(CUSTOMENV,'conf/customEnv')
            loadGame('custom_clear',true)
        end
    elseif key=="f"then
        SCN.go('custom_field','swipeD')
    elseif key=="s"then
        SCN.go('custom_sequence','swipeD')
    elseif key=="m"then
        SCN.go('custom_mission','swipeD')
    elseif key=="delete"then
        if sure>.3 then
            TABLE.cut(FIELD)TABLE.cut(BAG)TABLE.cut(MISSION)
            FIELD[1]=DATA.newBoard()
            _freshMiniFieldVisible()
            TABLE.clear(CUSTOMENV)
            TABLE.complete(require"parts.customEnv0",CUSTOMENV)
            for _,W in next,scene.widgetList do W:reset()end
            FILE.save(DATA.copyMission(),'conf/customMissions')
            FILE.save(DATA.copyBoards(),'conf/customBoards')
            FILE.save(DATA.copySequence(),'conf/customSequence')
            FILE.save(CUSTOMENV,'conf/customEnv')
            sure=0
            SFX.play('finesseError',.7)
            BG.set(CUSTOMENV.bg)
            BGM.play(CUSTOMENV.bgm)
        else
            sure=1
        end
    elseif key=="f1"then
        SCN.go('mod','swipeD')
    elseif key=="c"and kb.isDown("lctrl","rctrl")or key=="cC"then
        local str="Techmino Quest:"..DATA.copyQuestArgs().."!"
        if #BAG>0 then str=str..DATA.copySequence()end
        str=str.."!"
        if #MISSION>0 then str=str..DATA.copyMission()end
        sys.setClipboardText(str.."!"..DATA.copyBoards().."!")
        MES.new('check',text.exportSuccess)
    elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
        local str=sys.getClipboardText()
        local args=STRING.split(str:sub((str:find(":")or 0)+1),"!")
        if #args<4 then goto THROW_fail end
        if not(
            DATA.pasteQuestArgs(args[1])and
            DATA.pasteSequence(args[2])and
            DATA.pasteMission(args[3])
        )then goto THROW_fail end
        TABLE.cut(FIELD)
        FIELD[1]=DATA.newBoard()
        for i=4,#args do
            if args[i]:find("%S")and not DATA.pasteBoard(args[i],i-3)and i<#args then goto THROW_fail end
        end
        _freshMiniFieldVisible()
        MES.new('check',text.importSuccess)
        do return end
        ::THROW_fail::MES.new('error',text.dataCorrupted)
    elseif key=="escape"then
        FILE.save(CUSTOMENV,'conf/customEnv')
        SCN.back()
    else
        WIDGET.keyPressed(key)
    end
end

function scene.update(dt)
    if sure>0 then sure=sure-dt end
end

function scene.draw()
    gc.translate(0,-WIDGET.scrollPos)
    setFont(30)

    --Sequence
    if #MISSION>0 then
        gc.setColor(1,CUSTOMENV.missionKill and 0 or 1,int(TIME()*6.26)%2)
        gc.print("#"..#MISSION,70,220)
    end

    --Field content
    if initField then
        gc.push('transform')
        gc.translate(330,240)
        gc.scale(.5)
        gc.setColor(1,1,1)
        gc.setLineWidth(3)
        gc.rectangle('line',-2,-2,304,604)
        local F=FIELD[1]
        local cross=TEXTURE.puzzleMark[-1]
        local texture=SKIN.lib[SETTING.skinSet]
        for y=1,20 do for x=1,10 do
            local B=F[y][x]
            if B>0 then
                gc.draw(texture[B],30*x-30,600-30*y)
            elseif B==-1 then
                gc.draw(cross,30*x-30,600-30*y)
            end
        end end
        gc.pop()
        if #FIELD>1 then
            gc.setColor(1,1,int(TIME()*6.26)%2)
            gc.print("+"..#FIELD-1,490,220)
        end
    end

    --Sequence
    if #BAG>0 then
        gc.setColor(1,1,int(TIME()*6.26)%2)
        gc.print("#"..#BAG,615,220)
    end

    gc.setColor(COLOR.Z)
    gc.print(CUSTOMENV.sequence,610,250)

    --Confirm reset
    if sure>0 then
        gc.setColor(1,1,1,sure)
        gc.draw(TEXTURE.sure,920,50)
    end
    gc.translate(0,WIDGET.scrollPos)
end

scene.widgetScrollHeight=400
scene.widgetList={
    WIDGET.newText{name="title",   x=520,y=15,font=70,align='R'},

    WIDGET.newKey{name="reset",    x=1110,y=90,w=230,h=90,color='R',code=pressKey"delete"},
    WIDGET.newKey{name="mod",      x=1110,y=200,w=230,h=90,color='Z',code=pressKey"f1"},

    --Mission / Field / Sequence
    WIDGET.newKey{name="mission",  x=170,y=180,w=240,h=80,color='N',font=25,code=pressKey"m"},
    WIDGET.newKey{name="field",    x=450,y=180,w=240,h=80,color='A',font=25,code=pressKey"f"},
    WIDGET.newKey{name="sequence", x=730,y=180,w=240,h=80,color='W',font=25,code=pressKey"s"},

    WIDGET.newText{name="noMsn",   x=50, y=220,align='L',color='H',hideF=function()return MISSION[1]end},
    WIDGET.newText{name="defSeq",  x=610,y=220,align='L',color='H',hideF=function()return BAG[1]end},

    --Selectors
    WIDGET.newSelector{name="opponent",    x=170,y=330,w=260,color='R',list=sList.opponent,   disp=CUSval('opponent'),    code=CUSsto('opponent')},
    WIDGET.newSelector{name="life",        x=170,y=410,w=260,color='R',list=sList.life,       disp=CUSval('life'),        code=CUSsto('life')},
    WIDGET.newSelector{name="pushSpeed",   x=170,y=520,w=260,color='V',list=sList.pushSpeed,  disp=CUSval('pushSpeed'),   code=CUSsto('pushSpeed')},
    WIDGET.newSelector{name="garbageSpeed",x=170,y=600,w=260,color='V',list=sList.pushSpeed,  disp=CUSval('garbageSpeed'),code=CUSsto('garbageSpeed')},
    WIDGET.newSelector{name="visible",     x=170,y=710,w=260,color='lB',list=sList.visible,   disp=CUSval('visible'),     code=CUSsto('visible')},
    WIDGET.newSelector{name="freshLimit",  x=170,y=790,w=260,color='lB',list=sList.freshLimit,disp=CUSval('freshLimit'),  code=CUSsto('freshLimit')},

    WIDGET.newSelector{name="fieldH",      x=450,y=600,w=260,color='N',list=sList.fieldH,     disp=CUSval('fieldH'),      code=CUSsto('fieldH')},
    WIDGET.newSelector{name="heightLimit", x=450,y=710,w=260,color='S',list=sList.heightLimit,disp=CUSval('heightLimit'), code=CUSsto('heightLimit')},
    WIDGET.newSelector{name="bufferLimit", x=450,y=790,w=260,color='B',list=sList.bufferLimit,disp=CUSval('bufferLimit'), code=CUSsto('bufferLimit')},

    WIDGET.newSelector{name="drop",        x=730,y=330,w=260,color='O',list=sList.drop,disp=CUSval('drop'),code=CUSsto('drop')},
    WIDGET.newSelector{name="lock",        x=730,y=410,w=260,color='O',list=sList.lock,disp=CUSval('lock'),code=CUSsto('lock')},
    WIDGET.newSelector{name="wait",        x=730,y=520,w=260,color='G',list=sList.wait,disp=CUSval('wait'),code=CUSsto('wait')},
    WIDGET.newSelector{name="fall",        x=730,y=600,w=260,color='G',list=sList.fall,disp=CUSval('fall'),code=CUSsto('fall')},

    --Copy / Paste / Start
    WIDGET.newButton{name="copy",          x=1070,y=300,w=310,h=70,color='lR',font=25,code=pressKey"cC"},
    WIDGET.newButton{name="paste",         x=1070,y=380,w=310,h=70,color='lB',font=25,code=pressKey"cV"},
    WIDGET.newButton{name="clear",         x=1070,y=460,w=310,h=70,color='lY',font=35,code=pressKey"return"},
    WIDGET.newButton{name="puzzle",        x=1070,y=540,w=310,h=70,color='lM',font=35,code=pressKey"return2",hideF=function()return not initField end},
    WIDGET.newButton{name="back",          x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=pressKey"escape"},

    --Special rules
    WIDGET.newSwitch{name="ospin",         x=830, y=750,disp=CUSval('ospin'),    code=CUSrev('ospin')},
    WIDGET.newSwitch{name="fineKill",      x=830, y=840,disp=CUSval('fineKill'), code=CUSrev('fineKill')},
    WIDGET.newSwitch{name="b2bKill",       x=830, y=930,disp=CUSval('b2bKill'),  code=CUSrev('b2bKill')},
    WIDGET.newSwitch{name="easyFresh",     x=1170,y=750,disp=CUSval('easyFresh'),code=CUSrev('easyFresh')},
    WIDGET.newSwitch{name="deepDrop",      x=1170,y=840,disp=CUSval('deepDrop'), code=CUSrev('deepDrop')},
    WIDGET.newSwitch{name="bone",          x=1170,y=930,disp=CUSval('bone'),     code=CUSrev('bone')},

    --Rule set
    WIDGET.newSelector{name="eventSet",    x=310, y=880,w=360,color='H',list=sList.eventSet,disp=CUSval('eventSet'),code=CUSsto('eventSet')},

    --Next & Hold
    WIDGET.newSlider{name="nextCount",     x=140, y=960,w=180,unit=6, disp=CUSval('nextCount'),code=CUSsto('nextCount')},
    WIDGET.newSlider{name="holdCount",     x=140, y=1030,w=180,unit=6,disp=CUSval('holdCount'),code=CUSsto('holdCount')},
    WIDGET.newSwitch{name="infHold",       x=560, y=960,              disp=CUSval('infHold'),code=CUSrev('infHold'),hideF=function()return CUSTOMENV.holdCount==0 end},
    WIDGET.newSwitch{name="phyHold",       x=560, y=1030,             disp=CUSval('phyHold'),code=CUSrev('phyHold'),hideF=function()return CUSTOMENV.holdCount==0 end},

    --BG & BGM
    WIDGET.newSelector{name="bg",          x=840, y=1030,w=250,color='Y',list=BG.getList(),disp=CUSval('bg'),code=function(i)CUSTOMENV.bg=i BG.set(i)end},
    WIDGET.newSelector{name="bgm",         x=1120,y=1030,w=250,color='Y',list=BGM.getList(),disp=CUSval('bgm'),code=function(i)CUSTOMENV.bgm=i BGM.play(i)end},
}

return scene
