local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_origin,gc_replaceTransform=gc.origin,gc.replaceTransform
local gc_setLineWidth,gc_setColor=gc.setLineWidth,gc.setColor
local gc_setShader=gc.setShader
local gc_draw,gc_rectangle,gc_line,gc_printf=gc.draw,gc.rectangle,gc.line,gc.printf

local ins,rem=table.insert,table.remove
local int,rnd=math.floor,math.random
local approach=MATH.expApproach

local SETTING,GAME,SCR=SETTING,GAME,SCR
local PLAYERS=PLAYERS
local playSFX=SFX.play



--System
do--function tryBack()
    local sureTime=-1e99
    function tryBack()
        if TIME()-sureTime<1 then
            sureTime=-1e99
            return true
        else
            sureTime=TIME()
            MES.new('warn',text.sureQuit)
        end
    end
end
do--function tryReset()
    local sureTime=-1e99
    function tryReset()
        if TIME()-sureTime<1 then
            sureTime=-1e99
            return true
        else
            sureTime=TIME()
            MES.new('warn',text.sureReset)
        end
    end
end
do--function tryDelete()
    local sureTime=-1e99
    function tryDelete()
        if TIME()-sureTime<1 then
            sureTime=-1e99
            return true
        else
            sureTime=TIME()
            MES.new('warn',text.sureDelete)
        end
    end
end
do--function loadFile(name,args), function saveFile(data,name,args)
    local t=setmetatable({},{__index=function()return"'$1' loading failed: $2"end})
    function loadFile(name,args)
        local text=text or t
        if not args then args=''end
        local res,mes=pcall(FILE.load,name,args)
        if res then
            return mes
        else
            if mes:find'open error'then
                MES.new('error',text.loadError_open:repD(name,""))
            elseif mes:find'unknown mode'then
                MES.new('error',text.loadError_errorMode:repD(name,args))
            elseif mes:find'no file'then
                if not args:sArg'-canSkip'then
                    MES.new('error',text.loadError_noFile:repD(name,""))
                end
            elseif mes then
                MES.new('error',text.loadError_other:repD(name,mes))
            else
                MES.new('error',text.loadError_unknown:repD(name,""))
            end
        end
    end
    function saveFile(data,name,args)
        local text=text or t
        local res,mes=pcall(FILE.save,data,name,args)
        if res then
            return true
        else
            MES.new('error',
                mes:find'duplicate'and
                    text.saveError_duplicate:repD(name)or
                mes:find'encode error'and
                    text.saveError_encode:repD(name)or
                mes and
                    text.saveError_other:repD(name,mes)or
                text.saveError_unknown:repD(name)
            )
        end
    end
end
function isSafeFile(file,mes)
    if love.filesystem.getRealDirectory(file)~=SAVEDIR then
        return true
    elseif mes then
        MES.new('warn',mes)
    end
end
function saveStats()
    return saveFile(STAT,'conf/data')
end
function saveProgress()
    return saveFile(RANKS,'conf/unlock')
end
function saveSettings()
    return saveFile(SETTING,'conf/settings')
end
do--function applySettings()
    local saturateValues={
        normal={0,1},
        soft={.2,.7},
        gray={.4,.4},
        light={.2,.8},
        color={-.2,1.2},
    }
    function applySettings()
        --Apply language
        text=LANG.get(SETTING.locale)
        WIDGET.setLang(text.WidgetText)
        for k,v in next,TEXTOBJ do
            if rawget(text,k)then
                v:set(text[k])
            end
        end

        --Apply cursor
        love.mouse.setVisible(SETTING.sysCursor)

        --Apply fullscreen
        love.window.setFullscreen(SETTING.fullscreen)
        love.resize(gc.getWidth(),gc.getHeight())

        --Apply Zframework setting
        Z.setClickFX(SETTING.clickFX)
        Z.setFrameMul(SETTING.frameMul)
        Z.setPowerInfo(SETTING.powerInfo)
        Z.setCleanCanvas(SETTING.cleanCanvas)

        --Apply VK shape
        VK.setShape(SETTING.VKSkin)

        --Apply sound
        love.audio.setVolume(SETTING.mainVol)
        BGM.setVol(SETTING.bgm)
        SFX.setVol(SETTING.sfx)
        VOC.setVol(SETTING.voc)

        --Apply saturs
        local m
        m=saturateValues[SETTING.blockSatur]or saturateValues.normal
        SHADER.blockSatur:send('b',m[1])
        SHADER.blockSatur:send('k',m[2])
        m=saturateValues[SETTING.fieldSatur]or saturateValues.normal
        SHADER.fieldSatur:send('b',m[1])
        SHADER.fieldSatur:send('k',m[2])

        --Apply BG
        if SETTING.bg=='on'then
            BG.unlock()
            BG.set()
        elseif SETTING.bg=='off'then
            BG.unlock()
            BG.set('fixColor')
            BG.send(SETTING.bgAlpha,SETTING.bgAlpha,SETTING.bgAlpha)
            BG.lock()
        elseif SETTING.bg=='custom'then
            if love.filesystem.getInfo('conf/customBG')then
                local res,image=pcall(gc.newImage,love.filesystem.newFile('conf/customBG'))
                if res then
                    BG.unlock()
                    BG.set('custom')
                    gc.setDefaultFilter('linear','linear')
                    BG.send(SETTING.bgAlpha,image)
                    gc.setDefaultFilter('nearest','nearest')
                    BG.lock()
                else
                    MES.new('error',text.customBGloadFailed)
                end
            else--Switch off when custom BG not found
                SETTING.bg='off'
                BG.unlock()
                BG.set('fixColor')
                BG.send(SETTING.bgAlpha,SETTING.bgAlpha,SETTING.bgAlpha)
                BG.lock()
            end
        end
    end
end

--Royale mode
function randomTarget(P)--Return a random opponent for P
    if #PLY_ALIVE>1 then
        local R
        repeat
            R=PLY_ALIVE[rnd(#PLY_ALIVE)]
        until R~=P
        return R
    end
end
function freshMostDangerous()
    GAME.mostDangerous,GAME.secDangerous=false,false
    local m,m2=0,0
    for i=1,#PLY_ALIVE do
        local h=#PLY_ALIVE[i].field
        if h>=m then
            GAME.mostDangerous,GAME.secDangerous=PLY_ALIVE[i],GAME.mostDangerous
            m,m2=h,m
        elseif h>=m2 then
            GAME.secDangerous=PLY_ALIVE[i]
            m2=h
        end
    end

    for i=1,#PLY_ALIVE do
        if PLY_ALIVE[i].atkMode==3 then
            PLY_ALIVE[i]:freshTarget()
        end
    end
end
function freshMostBadge()
    GAME.mostBadge,GAME.secBadge=false,false
    local m,m2=0,0
    for i=1,#PLY_ALIVE do
        local P=PLY_ALIVE[i]
        local b=P.badge
        if b>=m then
            GAME.mostBadge,GAME.secBadge=P,GAME.mostBadge
            m,m2=b,m
        elseif b>=m2 then
            GAME.secBadge=P
            m2=b
        end
    end

    for i=1,#PLY_ALIVE do
        if PLY_ALIVE[i].atkMode==4 then
            PLY_ALIVE[i]:freshTarget()
        end
    end
end
function royaleLevelup()
    GAME.stage=GAME.stage+1
    local spd
    TEXT.show(text.royale_remain:gsub("$1",#PLY_ALIVE),640,200,40,'beat',.3)
    if GAME.stage==2 then
        spd=30
    elseif GAME.stage==3 then
        spd=15
        for _,P in next,PLY_ALIVE do
            P.gameEnv.garbageSpeed=.6
        end
        if PLAYERS[1].alive then
            BGM.play('cruelty')
        end
    elseif GAME.stage==4 then
        spd=8
        for _,P in next,PLY_ALIVE do
            P.gameEnv.pushSpeed=3
        end
    elseif GAME.stage==5 then
        spd=4
        for _,P in next,PLY_ALIVE do
            P.gameEnv.garbageSpeed=1
        end
    elseif GAME.stage==6 then
        spd=2
        if PLAYERS[1].alive then
            BGM.play('final')
        end
    end
    for _,P in next,PLY_ALIVE do
        P.gameEnv.drop=spd
    end
    if GAME.curMode.name:find("_u")then
        for i=1,#PLY_ALIVE do
            local P=PLY_ALIVE[i]
            P.gameEnv.drop=int(P.gameEnv.drop*.4)
            if P.gameEnv.drop==0 then
                P.curY=P.ghoY
                P:set20G(true)
            end
        end
    end
end

--Sound shortcuts
function playClearSFX(cc)
    if cc<=0 or cc%1~=0 then return end
    if cc<=4 then
        playSFX('clear_'..cc)
    elseif cc<=6 then
        playSFX('clear_4')
    elseif cc<=12 then
        playSFX('clear_4',.8)
        if cc<=9 then
            Snd('bass','A3','E4')
        else
            Snd('bass','A3','E4','A4')
        end
    elseif cc<=16 then
        playSFX('clear_5',.7)
        if cc<=14 then
            Snd('bass',.8,'A3','E4')Snd('lead','A4','E5')
        else
            Snd('bass',.8,'A3','G4')Snd('lead','B4','G5')
        end
    else
        playSFX('clear_6',.6)
        if cc==17 then Snd('bass',.8,'A3','A4')Snd('lead','E5','G5')
        elseif cc==18 then Snd('bass',.7,'A4')Snd('lead',.8,'C4','G5')Snd('bell','D5')
        elseif cc==19 then Snd('bass',.7,'A4')Snd('lead',.8,'A4','E5')Snd('bell','B5')
        elseif cc==20 then Snd('bass',.7,'A4')Snd('lead',.8,'A4','E4')Snd('bell','D5','B5','G6')
        else               Snd('bass',.7,'A4')Snd('lead',.8,'A4','E4')Snd('bell','B5','E6','A6')
        end
    end
end
function playReadySFX(i,vol)
    if i==3 then
        Snd('bass','A3',vol)
        Snd('lead','A4',vol)
    elseif i==2 then
        Snd('bass','F3',vol)
        Snd('lead','A4',vol)
        Snd('lead','D5',vol)
    elseif i==1 then
        Snd('bass','G3',vol)
        Snd('lead','B4',vol)
        Snd('lead','E5',vol)
    elseif i==0 then
        Snd('bass','A3',vol)
        Snd('lead','A4',vol)
        Snd('lead','E5',vol)
        Snd('lead','A5',vol)
    end
end


--Game
function getItem(itemName,amount)
    STAT.item[itemName]=STAT.item[itemName]+(amount or 1)
end
function generateLine(hole)
    return 1023-2^(hole-1)
end
function notEmptyLine(L)
    for i=1,10 do
        if L[i]>0 then
            return true
        end
    end
end
function setField(P,page)
    local F=FIELD[page]
    local height=0
    for y=#F,1,-1 do
        if notEmptyLine(F[y])then
            height=y
            break
        end
    end
    local t=P.showTime*3
    for y=1,height do
        local notEmpty=notEmptyLine(F[y])
        P.field[y]=LINE.new(0,notEmpty)
        P.visTime[y]=LINE.new(t)
        if notEmpty then
            for x=1,10 do
                P.field[y][x]=F[y][x]
            end
            P.garbageBeneath=P.garbageBeneath+1
        end
    end
end
function freshDate(args)
    if not args then
        args=""
    end
    local date=os.date("%Y/%m/%d")
    if STAT.date~=date then
        STAT.date=date
        STAT.todayTime=0
        getItem('zTicket',1)
        if not args:find'q'then
            MES.new('info',text.newDay)
        end
        saveStats()
        return true
    end
end
function legalGameTime()--Check if today's playtime is legal
    if
        SETTING.locale:find'zh'and
        RANKS.sprint_10l<4 and
        (not RANKS.sprint_40l or RANKS.sprint_40l<3)
    then
        if STAT.todayTime<7200 then
            return true
        elseif STAT.todayTime<14400 then
            MES.new('warn',text.playedLong)
            return true
        else
            MES.new('error',text.playedTooMuch)
            return false
        end
    end
    return true
end
do--function trySettingWarn()
    local lastWarnTime=0
    function trySettingWarn()
        if TIME()-lastWarnTime>2.6 then
            MES.new('warn',text.settingWarn,5)
        end
        lastWarnTime=TIME()
    end
end

function mergeStat(stat,delta)--Merge delta stat. to global stat.
    for k,v in next,delta do
        if type(v)=='table'then
            if type(stat[k])=='table'then
                mergeStat(stat[k],v)
            end
        else
            if stat[k]then
                stat[k]=stat[k]+v
            end
        end
    end
end
function scoreValid()--Check if any unranked mods are activated
    for _,M in next,GAME.mod do
        if M.unranked then
            return false
        end
    end
    if GAME.playing and GAME.tasUsed then
        return false
    end
    return true
end
function destroyPlayers()--Destroy all player objects, restore freerows and free CCs
    for i=#PLAYERS,1,-1 do
        local P=PLAYERS[i]
        if P.canvas then
            P.canvas:release()
        end
        while P.field[1]do
            rem(P.field)
            rem(P.visTime)
        end
    end
    TABLE.cut(PLAYERS)
    TABLE.cut(PLY_ALIVE)
end
function pauseGame()
    if not SCN.swapping then
        if not GAME.replaying then
            for i=1,#PLAYERS do
                local l=PLAYERS[i].keyPressing
                for j=1,#l do
                    if l[j]then
                        PLAYERS[i]:releaseKey(j)
                    end
                end
            end
        end
        for i=1,20 do
            VK.release(i)
        end
        if not(GAME.result or GAME.replaying)then
            GAME.pauseCount=GAME.pauseCount+1
        end
        SCN.swapTo('pause','none')
    end
end
function applyCustomGame()--Apply CUSTOMENV, BAG, MISSION
    for k,v in next,CUSTOMENV do
        GAME.modeEnv[k]=v
    end
    if BAG[1]then
        GAME.modeEnv.seqData=BAG
    else
        GAME.modeEnv.seqData=nil
    end
    if MISSION[1]then
        GAME.modeEnv.mission=MISSION
    else
        GAME.modeEnv.mission=nil
    end
end
function loadGame(mode,ifQuickPlay,ifNet)--Load a mode and go to game scene
    freshDate()
    if legalGameTime()then
        if not MODES[mode]and love.filesystem.getRealDirectory('parts/modes/'..mode)~=SAVEDIR then
            MODES[mode]=require('parts.modes.'..mode)
            MODES[mode].name=mode
        end
        if MODES[mode].score then
            STAT.lastPlay=mode
        end
        GAME.playing=true
        GAME.init=true
        GAME.fromRepMenu=false
        GAME.curModeName=mode
        GAME.curMode=MODES[mode]
        GAME.modeEnv=GAME.curMode.env
        GAME.net=ifNet
        if ifNet then
            SCN.go('net_game','swipeD')
        else
            local modeText=text.modes[mode]or{"["..MODES[mode].name.."]",""}
            TEXTOBJ.modeName:set(modeText[1].."   "..modeText[2])
            SCN.go('game',ifQuickPlay and'swipeD'or'fade_togame')
            playSFX('enter')
        end
    end
end
function gameOver()--Save record
    if GAME.replaying then
        local R=GAME.curMode.getRank
        if R then
            R=R(PLAYERS[1])
            if R and R>0 then
                GAME.rank=R
            end
        end
    end
    trySave()

    local M=GAME.curMode
    local R=M.getRank
    if R then
        local P=PLAYERS[1]
        R=R(P)--New rank
        if R then
            if R>0 then
                GAME.rank=R
            end
            if not GAME.replaying and M.score and scoreValid()then
                if RANKS[M.name]then--Old rank exist
                    local needSave
                    if R>RANKS[M.name]then
                        RANKS[M.name]=R
                        needSave=true
                    end
                    if R>0 then
                        if M.unlock then
                            for i=1,#M.unlock do
                                local m=M.unlock[i]
                                local n=MODES[m].name
                                if not RANKS[n]then
                                    if MODES[m].x then
                                        RANKS[n]=0
                                    end
                                    needSave=true
                                end
                            end
                        end
                    end
                    if needSave then
                        saveProgress()
                    end
                end
                local D=M.score(P)
                local L=M.records
                local p=#L--Rank-1
                if p>0 then
                    while M.comp(D,L[p])do--If higher rank
                        p=p-1
                        if p==0 then break end
                    end
                end
                if p<10 then
                    if p==0 then
                        P:_showText(text.newRecord,0,-100,100,'beat',.5)
                        if SETTING.autoSave and DATA.saveReplay()then
                            GAME.saved=true
                            playSFX('connected')
                            MES.new('check',text.saveDone)
                        end
                    end
                    D.date=os.date("%Y/%m/%d %H:%M")
                    ins(L,p+1,D)
                    if L[11]then L[11]=nil end
                    saveFile(L,('record/%s.rec'):format(M.name),'-luaon')
                end
            end
        end
    end
end
function trySave()
    if not GAME.statSaved and PLAYERS[1]and PLAYERS[1].type=='human'and(PLAYERS[1].frameRun>300 or GAME.result)then
        GAME.statSaved=true
        STAT.game=STAT.game+1
        mergeStat(STAT,PLAYERS[1].stat)
        STAT.todayTime=STAT.todayTime+PLAYERS[1].stat.time
        saveStats()
    end
end
do--function freshPlayerPosition(sudden)
    local posLists={
        --1~5
        {
            {340,75,1},
            {965,390,.5},
            {965,30,.5},
            {20,390,.5},
            {20,30,.5},
        },
        --6~17
        (function()
            local L={{340,75,1}}
            for i=1,4 do ins(L,{15,-160+180*i,.25})end
            for i=1,4 do ins(L,{180,-160+180*i,.25})end
            for i=1,4 do ins(L,{950,-160+180*i,.25})end
            for i=1,4 do ins(L,{1120,-160+180*i,.25})end
            return L
        end)(),
        --18~31
        (function()
            local L={{340,75,1}}
            for i=1,5 do ins(L,{10,  -100+135*i,.18})end
            for i=1,5 do ins(L,{120, -100+135*i,.18})end
            for i=1,5 do ins(L,{230, -100+135*i,.18})end
            for i=1,5 do ins(L,{940, -100+135*i,.18})end
            for i=1,5 do ins(L,{1050,-100+135*i,.18})end
            for i=1,5 do ins(L,{1160,-100+135*i,.18})end
            return L
        end)(),
        --32~49
        (function()
            local L={{340,75,1}}
            for i=1,4 do for j=1,6 do ins(L,{78*i-54,115*j-98,.09})end end
            for i=9,12 do for j=1,6 do ins(L,{78*i+267,115*j-98,.09})end end
            return L
        end)(),
        --50~99
        (function()
            local L={{340,75,1}}
            for i=1,7 do for j=1,7 do ins(L,{46*i-36,97*j-72,.068})end end
            for i=15,21 do for j=1,7 do ins(L,{46*i+264,97*j-72,.068})end end
            return L
        end)(),
    }
    function freshPlayerPosition(sudden)--Set initial position for every player
        local L=PLY_ALIVE
        if not sudden then
            for i=1,#L do
                L[i]:setPosition(640,#L<=5 and 360 or -62,0)
            end
        end

        local posList
        if #L<=5 then posList=posLists[1]
        elseif #L<=17 then posList=posLists[2]
        elseif #L<=31 then posList=posLists[3]
        elseif #L<=49 then posList=posLists[4]
        elseif #L<=99 then posList=posLists[5]
        else error("TOO MANY PLAYERS!")
        end
        local method=sudden and'setPosition'or'movePosition'
        for i=1,#L do L[i][method](L[i],unpack(posList[i]))end
    end
end
do--function dumpBasicConfig()
    local gameSetting={
        --Tuning
        'das','arr','dascut','dropcut','sddas','sdarr',
        'ihs','irs','ims','RS',

        --System
        'skin','face',

        --Graphic
        'ghostType','block','ghost','center','bagLine',
        'dropFX','moveFX','shakeFX',
        'text','highCam','nextPos',

        --Unnecessary graphic
        -- 'grid','smooth',
        -- 'lockFX','clearFX','splashFX','atkFX',
        -- 'score',
    }
    function dumpBasicConfig()
        local S={}
        for _,key in next,gameSetting do
            S[key]=SETTING[key]
        end
        return JSON.encode(S)
    end
end
do--function resetGameData(args)
    local function task_showMods()
        local time=0
        while true do
            YIELD()
            time=time+1
            if time%20==0 then
                local M=GAME.mod[time/20]
                if M then
                    TEXT.show(M.id,700+(time-20)%120*4,36,45,'spin',.5)
                else
                    return
                end
            end
        end
    end
    local gameSetting={
        --Tuning
        'das','arr','dascut','dropcut','sddas','sdarr',
        'ihs','irs','ims','RS',

        --System
        'skin','face',

        --Graphic
        'block','ghost','center','smooth','grid','bagLine',
        'lockFX','dropFX','moveFX','clearFX','splashFX','shakeFX','atkFX',
        'text','score','warn','highCam','nextPos',
    }
    local function _copyGameSetting()
        local S={}
        for _,key in next,gameSetting do
            if type(SETTING[key])=='table'then
                S[key]=TABLE.shift(SETTING[key])
            else
                S[key]=SETTING[key]
            end
        end
        return S
    end
    function resetGameData(args,seed)
        if not args then args=""end
        trySave()

        GAME.result=false
        GAME.rank=0
        GAME.warnLVL0=0
        GAME.warnLVL=0
        if args:find'r'then
            GAME.frameStart=0
            GAME.recording=false
            GAME.replaying=true
        else
            GAME.frameStart=args:find'n'and 0 or 180-SETTING.reTime*60
            GAME.seed=seed or math.random(1046101471,2662622626)
            GAME.pauseTime=0
            GAME.pauseCount=0
            GAME.saved=false
            GAME.setting=_copyGameSetting()
            GAME.tasUsed=false
            GAME.rep={}
            GAME.recording=true
            GAME.statSaved=false
            GAME.replaying=false
            math.randomseed(TIME())
        end

        destroyPlayers()
        if GAME.curMode.load then
            GAME.curMode.load()
        else
            PLY.newPlayer(1)
        end
        freshPlayerPosition(args:find'q')
        VK.restore()

        local bg=GAME.modeEnv.bg
        BG.set(type(bg)=='string'and bg or type(bg)=='table'and bg[math.random(#bg)])
        local bgm=GAME.modeEnv.bgm
        BGM.play(type(bgm)=='string'and bgm or type(bgm)=='table'and bgm[math.random(#bgm)])

        TEXT.clear()
        if GAME.modeEnv.eventSet=='royale'then
            for i=1,#PLAYERS do
                PLAYERS[i]:changeAtk(randomTarget(PLAYERS[i]))
            end
            GAME.stage=false
            GAME.mostBadge=false
            GAME.secBadge=false
            GAME.mostDangerous=false
            GAME.secDangerous=false
            GAME.stage=1
        end
        TASK.removeTask_code(task_showMods)
        if GAME.setting.allowMod then
            TASK.new(task_showMods)
        end
        playReadySFX(3)
        collectgarbage()
    end
end
do--function checkWarning()
    local max=math.max
    function checkWarning(dt)
        local P1=PLAYERS[1]
        if P1.alive then
            if P1.frameRun%26==0 then
                local F=P1.field
                local height=0--Max height of row 4~7
                for x=4,7 do
                    for y=#F,1,-1 do
                        if F[y][x]>0 then
                            if y>height then
                                height=y
                            end
                            break
                        end
                    end
                end
                GAME.warnLVL0=math.log(height-(P1.gameEnv.fieldH-5)+P1.atkBufferSum*.8)
            end
            local _=GAME.warnLVL
            if _<GAME.warnLVL0 then
                _=approach(_,GAME.warnLVL0,dt*6)
            elseif _>0 then
                _=max(_-.026,0)
            end
            GAME.warnLVL=_
            if GAME.warnLVL>1.126 and P1.frameRun%30==0 then
                SFX.fplay('warn_beep',SETTING.sfx_warn)
            end
        elseif GAME.warnLVL>0 then
            GAME.warnLVL=max(GAME.warnLVL-.026,0)
        end
    end
end



--Game draw
do--function drawSelfProfile()
    local lvColor={COLOR.J,COLOR.A,COLOR.C,COLOR.N,COLOR.S,COLOR.V,COLOR.P,COLOR.M,COLOR.W,COLOR.R,COLOR.O,COLOR.Y}
    local lvIcon=setmetatable({},{__index=function(self,lv)
        local c=lvColor[int((lv-1)/26)+1]or COLOR.Z

        local img=GC.DO{25,25,
            {"clear",0,0,0,0},
            {"setLW",2},
            {"setCL",c[1],c[2],c[3],.6},
            {"fRect",2,2,21,21,2},
            {"setCL",c},
            {"dRect",2,2,21,21,2},
            {"setCL",COLOR.Z},
            {"mText",(lv-1)%26+1,13,-1},
        }
        rawset(self,lv,img)
        return img
    end})
    local name
    local textObj,scaleK,width,offY
    function drawSelfProfile()
        local selfAvatar=USERS.getAvatar(USER.uid)
        gc_push('transform')
        gc_replaceTransform(SCR.xOy_ur)

        --Draw avatar
        gc_setLineWidth(2)
        gc_setColor(COLOR.X)gc_rectangle('fill',0,0,-300,80)
        gc_setColor(1,1,1)gc_rectangle('line',-300,0,300,80,5)
        gc_rectangle('line',-73,7,66,66,2)
        gc_draw(selfAvatar,-72,8,nil,.5)

        --Draw username
        if name~=USERS.getUsername(USER.uid)then
            name=USERS.getUsername(USER.uid)
            textObj=gc.newText(getFont(30),name)
            width=textObj:getWidth()
            scaleK=210/math.max(width,210)
            offY=textObj:getHeight()/2
        end
        gc_draw(textObj,-82,26,nil,scaleK,nil,width,offY)

        --Draw lv. & xp.
        gc_draw(lvIcon[USER.lv],-295,50)
        gc_line(-270,55,-80,55,-80,70,-270,70)
        gc_rectangle('fill',-210,55,150*USER.xp/USER.lv/USER.lv,15)

        gc_pop()
    end
end
function drawOnlinePlayerCount()
    setFont(20)
    gc_setColor(1,1,1)
    gc_push('transform')
    gc_replaceTransform(SCR.xOy_ur)
    gc_printf(("%s: %s/%s/%s"):format(text.onlinePlayerCount,NET.UserCount,NET.PlayCount,NET.StreamCount),-600,80,594,'right')
    gc_pop()
end
function drawWarning()
    if SETTING.warn and GAME.warnLVL>0 then
        gc_push('transform')
        gc_origin()
        SHADER.warning:send('level',GAME.warnLVL)
        gc_setShader(SHADER.warning)
        gc_rectangle('fill',0,0,SCR.w,SCR.h)
        gc_setShader()
        gc_pop()
    end
end



--Widget function shortcuts
function backScene()SCN.back()end
do--function goScene(name,style)
    local cache={}
    function goScene(name,style)
        local hash=style and name..style or name
        if not cache[hash]then
            cache[hash]=function()SCN.go(name,style)end
        end
        return cache[hash]
    end
end
do--function swapScene(name,style)
    local cache={}
    function swapScene(name,style)
        local hash=style and name..style or name
        if not cache[hash]then
            cache[hash]=function()SCN.swapTo(name,style)end
        end
        return cache[hash]
    end
end
do--function pressKey(k)
    local cache={}
    function pressKey(k)
        if not cache[k]then
            cache[k]=function()love.keypressed(k)end
        end
        return cache[k]
    end
end
do--CUS/SETXXX(k)
    local CUSTOMENV=CUSTOMENV
    local warnList={
        'das','arr','dascut','dropcut','sddas','sdarr',
        'ihs','irs','ims','RS',
        'frameMul','highCam',
        'VKSwitch','VKIcon','VKTrack','VKDodge',
        'simpMode',
    }
    function CUSval(k)return function()return CUSTOMENV[k]end end
    function ROOMval(k)return function()return ROOMENV[k]end end
    function SETval(k)return function()return SETTING[k]end end
    function CUSrev(k)return function()CUSTOMENV[k]=not CUSTOMENV[k]end end
    function ROOMrev(k)return function()ROOMENV[k]=not ROOMENV[k]end end
    function SETrev(k)return function()if TABLE.find(warnList,k)then trySettingWarn()end SETTING[k]=not SETTING[k]end end
    function CUSsto(k)return function(i)CUSTOMENV[k]=i end end
    function ROOMsto(k)return function(i)ROOMENV[k]=i end end
    function SETsto(k)return function(i)if TABLE.find(warnList,k)then trySettingWarn()end SETTING[k]=i end end
end
