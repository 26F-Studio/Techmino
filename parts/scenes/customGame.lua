local gc,kb,sys=love.graphics,love.keyboard,love.system
local floor=math.floor

CUSTOMGAME_LOCAL={
    FIELD={},
    BAG={},
    MISSION={},
    CUSTOMENV={},
    CUSval=function(self,k) return function()   return self.CUSTOMENV[k] end end,
    CUSrev=function(self,k) return function()   self.CUSTOMENV[k]=not self.CUSTOMENV[k] end end,
    CUSsto=function(self,k) return function(i)  self.CUSTOMENV[k]=i end end,
}
local function CUSval(k) return CUSTOMGAME_LOCAL:CUSval(k) end
local function CUSrev(k) return CUSTOMGAME_LOCAL:CUSrev(k) end
local function CUSsto(k) return CUSTOMGAME_LOCAL:CUSsto(k) end
local function apply_locals()
    FIELD=CUSTOMGAME_LOCAL.FIELD
    BAG=CUSTOMGAME_LOCAL.BAG
    MISSION=CUSTOMGAME_LOCAL.MISSION
    CUSTOMENV=CUSTOMGAME_LOCAL.CUSTOMENV
end
do -- Initialize fields, sequence, missions, gameEnv for cutsom game
    local fieldData=loadFile('conf/customBoards','-string -canSkip')
    local fieldReinit=false
    if not fieldData then
        fieldReinit=true
    else
        fieldData=STRING.split(fieldData,"!")
        for i=1,#fieldData do
            local success,F=DATA.pasteBoard(fieldData[i])
            if not success then
                fieldReinit=true
                break
            end
            CUSTOMGAME_LOCAL.FIELD[i]=F
        end
    end
    if fieldReinit then
        CUSTOMGAME_LOCAL.FIELD={DATA.newBoard()}
    end
    local sequenceData=loadFile('conf/customSequence','-string -canSkip')
    if sequenceData then
        local success,bag=DATA.pasteSequence(sequenceData)
        if success then
            CUSTOMGAME_LOCAL.BAG=bag
        end
    end
    local missionData=loadFile('conf/customMissions','-string -canSkip')
    if missionData then
        local success,mission=DATA.pasteMission(missionData)
        if success then
            CUSTOMGAME_LOCAL.MISSION=mission
        end
    end
    local customData=loadFile('conf/customEnv','-canSkip')
    if customData and customData['version']==VERSION.code then
        TABLE.complete(customData,CUSTOMENV)
    end
    TABLE.complete(require"parts.customEnv0",CUSTOMENV)
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
    hang={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
    hurry={0,1,2,3,4,5,6,7,8,10,1e99},
    eventSet=EVENTSETS,
    holdMode={'hold','swap'},
}

local scene={}

function scene.enter()
    destroyPlayers()
    BG.set(CUSTOMGAME_LOCAL.CUSTOMENV.bg)
    BGM.play(CUSTOMGAME_LOCAL.CUSTOMENV.bgm)
end
function scene.leave()
    saveFile(CUSTOMGAME_LOCAL.CUSTOMENV,'conf/customEnv')
    BGM.play()
end

local function _play(mode)
    if CUSTOMGAME_LOCAL.CUSTOMENV.opponent~="X" then
        if CUSTOMGAME_LOCAL.CUSTOMENV.opponent:sub(1,2)=='CC' then
            if CUSTOMGAME_LOCAL.CUSTOMENV.sequence=='fixed' then
                MES.new('error',text.cc_fixed)
                return
            end
            if CUSTOMGAME_LOCAL.CUSTOMENV.holdMode=='swap' then
                MES.new('error',text.cc_swap)
                return
            end
        end
        if #CUSTOMGAME_LOCAL.BAG>0 then
            for _=1,#CUSTOMGAME_LOCAL.BAG do
                if CUSTOMGAME_LOCAL.BAG[_]>7 then
                    MES.new('error',text.ai_prebag)
                    return
                end
            end
        end
        if #CUSTOMGAME_LOCAL.MISSION>0 then
            MES.new('error',text.ai_mission)
            return
        end
    end
    saveFile(CUSTOMGAME_LOCAL.CUSTOMENV,'conf/customEnv')
    apply_locals()
    loadGame('custom_'..mode,true)
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='return' and kb.isDown('lctrl','lalt') or key=='play1' or key=='play2' then
        if (key=='play2' or kb.isDown('lalt')) and #CUSTOMGAME_LOCAL.FIELD[1]>0 then
            _play('puzzle')
        elseif key=='play1' or kb.isDown('lctrl') then
            _play('clear')
        end
    elseif key=='f' then
        apply_locals()
        SCN.go('custom_field','swipeD')
    elseif key=='s' then
        apply_locals()
        SCN.go('custom_sequence','swipeD')
    elseif key=='m' then
        apply_locals()
        SCN.go('custom_mission','swipeD')
    elseif key=='delete' then
        if tryReset() then
            TABLE.cut(CUSTOMGAME_LOCAL.FIELD)TABLE.cut(CUSTOMGAME_LOCAL.BAG)TABLE.cut(CUSTOMGAME_LOCAL.MISSION)
            CUSTOMGAME_LOCAL.FIELD[1]=DATA.newBoard()
            TABLE.clear(CUSTOMGAME_LOCAL.CUSTOMENV)
            TABLE.complete(require"parts.customEnv0",CUSTOMGAME_LOCAL.CUSTOMENV)
            for _,W in next,scene.widgetList do W:reset() end
            saveFile(DATA.copyMission(CUSTOMGAME_LOCAL.MISSION),'conf/customMissions')
            saveFile(DATA.copyBoards(CUSTOMGAME_LOCAL.FIELD),'conf/customBoards')
            saveFile(DATA.copySequence(CUSTOMGAME_LOCAL.BAG),'conf/customSequence')
            saveFile(CUSTOMGAME_LOCAL.CUSTOMENV,'conf/customEnv')
            SFX.play('finesseError',.7)
            BG.set(CUSTOMGAME_LOCAL.CUSTOMENV.bg)
            BGM.play(CUSTOMGAME_LOCAL.CUSTOMENV.bgm)
        end
    elseif key=='f1' then
        SCN.go('mod','swipeD')
    elseif key=='c' and kb.isDown('lctrl','rctrl') or key=='cC' then
        local str="Techmino Quest:"..DATA.copyQuestArgs(CUSTOMGAME_LOCAL.CUSTOMENV).."!"
        if #CUSTOMGAME_LOCAL.BAG>0 then str=str..DATA.copySequence(CUSTOMGAME_LOCAL.BAG) end
        str=str.."!"
        if #CUSTOMGAME_LOCAL.MISSION>0 then str=str..DATA.copyMission(CUSTOMGAME_LOCAL.MISSION) end
        sys.setClipboardText(str.."!"..DATA.copyBoards(CUSTOMGAME_LOCAL.FIELD).."!")
        MES.new('check',text.exportSuccess)
    elseif key=='v' and kb.isDown('lctrl','rctrl') or key=='cV' then
        local str=sys.getClipboardText()
        local args=str:sub((str:find(":") or 0)+1):split("!")
        repeat
            if #args<4 then break end-- goto THROW_fail
            local success,env=DATA.pasteQuestArgs(args[1])
            if not success then break end-- goto THROW_fail
            TABLE.cover(env,CUSTOMGAME_LOCAL.CUSTOMENV)

            local success,bag=DATA.pasteSequence(args[2])
            if not success then break end-- goto THROW_fail
            CUSTOMGAME_LOCAL.BAG=bag

            local success,mission=DATA.pasteMission(args[3])
            if not success then break end-- goto THROW_fail
            CUSTOMGAME_LOCAL.MISSION=mission

            TABLE.cut(CUSTOMGAME_LOCAL.FIELD)
            CUSTOMGAME_LOCAL.FIELD[1]=DATA.newBoard()
            for i=4,#args do
                if args[i]:find("%S") then
                    local success,F=DATA.pasteBoard(args[i])
                    if success then
                        CUSTOMGAME_LOCAL.FIELD[i-3]=F
                    else
                        if i<#args then break end-- goto THROW_fail
                    end
                end
            end
            MES.new('check',text.importSuccess)
            return
        until true
        -- ::THROW_fail::
        MES.new('error',text.dataCorrupted)
    else
        return true
    end
end

function scene.draw()
    gc.translate(0,-WIDGET.scrollPos)
    setFont(30)

    -- Sequence
    if #CUSTOMGAME_LOCAL.MISSION>0 then
        gc.setColor(1,CUSTOMGAME_LOCAL.CUSTOMENV.missionKill and 0 or 1,floor(TIME()*6.26)%2)
        gc.print("#"..#CUSTOMGAME_LOCAL.MISSION,70,220)
    end

    -- Field content
    if #CUSTOMGAME_LOCAL.FIELD[1]>0 then
        gc.push('transform')
        gc.translate(330,240)
        gc.scale(.5)
        gc.setColor(1,1,1)
        gc.setLineWidth(3)
        gc.rectangle('line',-2,-2,304,604)
        local F=CUSTOMGAME_LOCAL.FIELD[1]
        local cross=TEXTURE.puzzleMark[-1]
        local texture=SKIN.lib[SETTING.skinSet]
        for y=1,#F do for x=1,10 do
            local B=F[y][x]
            if B>0 then
                gc.draw(texture[B],30*x-30,600-30*y)
            elseif B==-1 then
                gc.draw(cross,30*x-30,600-30*y)
            end
        end end
        gc.pop()
        if #CUSTOMGAME_LOCAL.FIELD>1 then
            gc.setColor(1,1,floor(TIME()*6.26)%2)
            gc.print("+"..#CUSTOMGAME_LOCAL.FIELD-1,490,220)
        end
    end

    -- Sequence
    if #CUSTOMGAME_LOCAL.BAG>0 then
        gc.setColor(1,1,floor(TIME()*6.26)%2)
        gc.print("#"..#CUSTOMGAME_LOCAL.BAG,615,220)
    end
    gc.setColor(COLOR.Z)
    gc.print(CUSTOMGAME_LOCAL.CUSTOMENV.sequence,610,250)

    -- Mod indicator
    if #GAME.mod>0 then
        gc.setColor(.42,.26,.62,.62+.26*math.sin(TIME()*12.6))
        gc.rectangle('fill',1110-230/2,200-90/2,230,90,5,5)
    end

    gc.translate(0,WIDGET.scrollPos)
end

scene.widgetScrollHeight=450
scene.widgetList={
    WIDGET.newText{name='title',   x=40,y=15,lim=900,font=70,align='L'},

    WIDGET.newKey{name='reset',    x=1110,y=90,w=230,h=90,color='R',code=pressKey'delete'},
    WIDGET.newKey{name='mod',      x=1110,y=200,w=230,h=90,color='Z',code=pressKey'f1'},

    -- Mission / Field / Sequence
    WIDGET.newKey{name='mission',  x=170,y=180,w=240,h=80,color='N',font=25,code=pressKey'm'},
    WIDGET.newKey{name='field',    x=450,y=180,w=240,h=80,color='A',font=25,code=pressKey'f'},
    WIDGET.newKey{name='sequence', x=730,y=180,w=240,h=80,color='W',font=25,code=pressKey's'},

    WIDGET.newText{name='noMsn',   x=50, y=220,align='L',color='H',hideF=function() return CUSTOMGAME_LOCAL.MISSION[1] end},
    WIDGET.newText{name='defSeq',  x=610,y=220,align='L',color='H',hideF=function() return CUSTOMGAME_LOCAL.BAG[1] end},

    -- Selectors
    WIDGET.newSelector{name='opponent',    x=170,y=330,w=260,color='R',list=sList.opponent,   disp=CUSval('opponent'),    code=CUSsto('opponent')},
    WIDGET.newSelector{name='life',        x=170,y=410,w=260,color='R',list=sList.life,       disp=CUSval('life'),        code=CUSsto('life')},
    WIDGET.newSelector{name='pushSpeed',   x=170,y=520,w=260,color='V',list=sList.pushSpeed,  disp=CUSval('pushSpeed'),   code=CUSsto('pushSpeed')},
    WIDGET.newSelector{name='garbageSpeed',x=170,y=600,w=260,color='V',list=sList.pushSpeed,  disp=CUSval('garbageSpeed'),code=CUSsto('garbageSpeed')},
    WIDGET.newSelector{name='visible',     x=170,y=710,w=260,color='lB',list=sList.visible,   disp=CUSval('visible'),     code=CUSsto('visible')},
    WIDGET.newSelector{name='freshLimit',  x=170,y=790,w=260,color='lB',list=sList.freshLimit,disp=CUSval('freshLimit'),  code=CUSsto('freshLimit')},

    WIDGET.newSelector{name='fieldH',      x=450,y=600,w=260,color='N',list=sList.fieldH,     disp=CUSval('fieldH'),      code=CUSsto('fieldH')},
    WIDGET.newSelector{name='heightLimit', x=450,y=710,w=260,color='S',list=sList.heightLimit,disp=CUSval('heightLimit'), code=CUSsto('heightLimit')},
    WIDGET.newSelector{name='bufferLimit', x=450,y=790,w=260,color='B',list=sList.bufferLimit,disp=CUSval('bufferLimit'), code=CUSsto('bufferLimit')},

    WIDGET.newSelector{name='drop',        x=730,y=330,w=260,color='O',list=sList.drop,disp=CUSval('drop'),code=CUSsto('drop')},
    WIDGET.newSelector{name='lock',        x=730,y=410,w=260,color='O',list=sList.lock,disp=CUSval('lock'),code=CUSsto('lock')},
    WIDGET.newSelector{name='wait',        x=730,y=520,w=260,color='G',list=sList.wait,disp=CUSval('wait'),code=CUSsto('wait')},
    WIDGET.newSelector{name='fall',        x=730,y=600,w=260,color='G',list=sList.fall,disp=CUSval('fall'),code=CUSsto('fall')},
    WIDGET.newSelector{name='hurry',       x=730,y=680,w=260,color='G',list=sList.hurry,disp=CUSval('hurry'),code=CUSsto('hurry')},
    WIDGET.newSelector{name='hang',        x=730,y=760,w=260,color='G',list=sList.hang,disp=CUSval('hang'),code=CUSsto('hang')},

    -- Copy / Paste / Start
    WIDGET.newButton{name='copy',          x=1070,y=300,w=310,h=70,color='lR',font=25,code=pressKey'cC'},
    WIDGET.newButton{name='paste',         x=1070,y=380,w=310,h=70,color='lB',font=25,code=pressKey'cV'},
    WIDGET.newButton{name='play_clear',    x=1070,y=460,w=310,h=70,color='lY',font=35,code=pressKey'play1'},
    WIDGET.newButton{name='play_puzzle',   x=1070,y=540,w=310,h=70,color='lM',font=35,code=pressKey'play2',hideF=function() return #CUSTOMGAME_LOCAL.FIELD[1]==0 end},
    WIDGET.newButton{name='back',          x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},

    -- Rule set
    WIDGET.newSelector{name='eventSet',    x=1050,y=760,w=340,color='H',list=sList.eventSet,disp=CUSval('eventSet'),code=CUSsto('eventSet')},

    -- Special rules
    WIDGET.newSwitch{name='ospin',         x=850, y=850, lim=210,disp=CUSval('ospin'),    code=CUSrev('ospin')},
    WIDGET.newSwitch{name='fineKill',      x=850, y=910, lim=210,disp=CUSval('fineKill'), code=CUSrev('fineKill')},
    WIDGET.newSwitch{name='b2bKill',       x=850, y=970, lim=210,disp=CUSval('b2bKill'),  code=CUSrev('b2bKill')},
    WIDGET.newSwitch{name='lockout',       x=850, y=1030,lim=210,disp=CUSval('lockout'),  code=CUSrev('lockout')},
    WIDGET.newSwitch{name='easyFresh',     x=1170,y=850, lim=250,disp=CUSval('easyFresh'),code=CUSrev('easyFresh')},
    WIDGET.newSwitch{name='deepDrop',      x=1170,y=910, lim=250,disp=CUSval('deepDrop'), code=CUSrev('deepDrop')},
    WIDGET.newSwitch{name='bone',          x=1170,y=970, lim=250,disp=CUSval('bone'),     code=CUSrev('bone')},

    -- Next & Hold
    WIDGET.newSelector{name='holdMode',    x=310, y=890, w=300,color='lY',list=sList.holdMode,disp=CUSval('holdMode'),code=CUSsto('holdMode'),hideF=function() return CUSTOMGAME_LOCAL.CUSTOMENV.holdCount==0 end},
    WIDGET.newSlider{name='nextCount',     x=140, y=960, lim=130,w=180,axis={0,6,1},disp=CUSval('nextCount'),code=CUSsto('nextCount')},
    WIDGET.newSlider{name='holdCount',     x=140, y=1030,lim=130,w=180,axis={0,6,1},disp=CUSval('holdCount'),code=CUSsto('holdCount')},
    WIDGET.newSwitch{name='infHold',       x=560, y=960, lim=200,                   disp=CUSval('infHold'),code=CUSrev('infHold'),hideF=function() return CUSTOMGAME_LOCAL.CUSTOMENV.holdCount==0 end},
    WIDGET.newSwitch{name='phyHold',       x=560, y=1030,lim=200,                   disp=CUSval('phyHold'),code=CUSrev('phyHold'),hideF=function() return CUSTOMGAME_LOCAL.CUSTOMENV.holdCount==0 end},

    -- BG & BGM
    WIDGET.newSelector{name='bg',          x=840, y=1100,w=250,color='Y',list=BG.getList(),disp=CUSval('bg'),code=function(i) CUSTOMGAME_LOCAL.CUSTOMENV.bg=i BG.set(i) end},
    WIDGET.newSelector{name='bgm',         x=1120,y=1100,w=250,color='Y',list=BGM.getList(),disp=CUSval('bgm'),code=function(i) CUSTOMGAME_LOCAL.CUSTOMENV.bgm=i BGM.play(i) end},
}

return scene
