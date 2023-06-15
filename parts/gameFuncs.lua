local gc_push,gc_pop=GC.push,GC.pop
local gc_origin,gc_replaceTransform=GC.origin,GC.replaceTransform
local gc_setLineWidth,gc_setColor=GC.setLineWidth,GC.setColor
local gc_setShader=GC.setShader
local gc_draw,gc_rectangle,gc_printf=GC.draw,GC.rectangle,GC.printf

local ins,rem=table.insert,table.remove
local int,rnd=math.floor,math.random
local approach=MATH.expApproach

local SETTING,GAME,SCR=SETTING,GAME,SCR
local PLAYERS=PLAYERS



-- System
do-- function tryBack()
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
do-- function tryReset()
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
do-- function tryDelete()
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
do-- function loadFile(name,args), function saveFile(data,name,args)
    local t=setmetatable({},{__index=function() return "'$1' loading failed: $2" end})
    function loadFile(name,args)
        local text=text or t
        if not args then args='' end
        local res,mes=pcall(FILE.load,name,args)
        if res then
            return mes
        else
            if mes:find'open error' then
                MES.new('error',text.loadError_open:repD(name,""))
            elseif mes:find'unknown mode' then
                MES.new('error',text.loadError_errorMode:repD(name,args))
            elseif mes:find'no file' then
                if not args:sArg'-canSkip' then
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
                mes:find'duplicate' and
                    text.saveError_duplicate:repD(name) or
                mes:find'encode error' and
                    text.saveError_encode:repD(name) or
                mes and
                    text.saveError_other:repD(name,mes) or
                text.saveError_unknown:repD(name)
            )
        end
    end
end
function saveStats()
    return saveFile(STAT,'conf/data')
end
function saveProgress()
    return saveFile(RANKS,'conf/unlock')
end
function saveSettings()
    if WS.status('game')=='running' then
        NET.player_updateConf()
    end
    return saveFile(SETTING,'conf/settings')
end
function saveUser()
    return saveFile(USER.__data,'conf/user')
end
do-- function applySettings()
    local saturateValues={
        normal={0,1},
        soft={.2,.7},
        gray={.4,.4},
        light={.2,.8},
        color={-.2,1.2},
    }
    function applySettings()
        -- Apply language
        text=LANG.get(SETTING.locale)
        WIDGET.setLang(text.WidgetText)
        for k,v in next,TEXTOBJ do
            if rawget(text,k) then
                v:set(text[k])
            end
        end

        -- Apply cursor
        love.mouse.setVisible(SETTING.sysCursor)

        -- Apply fullscreen
        love.window.setFullscreen(SETTING.fullscreen)
        love.resize(GC.getWidth(),GC.getHeight())

        -- Apply Zframework setting
        Z.setClickFX(SETTING.clickFX)
        Z.setFrameMul(SETTING.frameMul)
        Z.setPowerInfo(SETTING.powerInfo)
        Z.setCleanCanvas(SETTING.cleanCanvas)

        -- Apply VK shape
        VK.setShape(SETTING.VKSkin)

        -- Apply sound
        love.audio.setVolume(SETTING.mainVol)
        BGM.setVol(SETTING.bgm)
        SFX.setVol(SETTING.sfx)
        VOC.setVol(SETTING.voc)

        -- Apply saturs
        local m
        m=saturateValues[SETTING.blockSatur] or saturateValues.normal
        SHADER.blockSatur:send('b',m[1])
        SHADER.blockSatur:send('k',m[2])
        m=saturateValues[SETTING.fieldSatur] or saturateValues.normal
        SHADER.fieldSatur:send('b',m[1])
        SHADER.fieldSatur:send('k',m[2])

        -- Apply BG
        if SETTING.bg=='on' then
            BG.unlock()
            BG.set()
        elseif SETTING.bg=='off' then
            BG.unlock()
            BG.set('fixColor',SETTING.bgAlpha,SETTING.bgAlpha,SETTING.bgAlpha)
            BG.lock()
        elseif SETTING.bg=='custom' then
            if love.filesystem.getInfo('conf/customBG') then
                local res,image=pcall(GC.newImage,love.filesystem.newFile('conf/customBG'))
                if res then
                    BG.unlock()
                    GC.setDefaultFilter('linear','linear')
                    BG.set('custom',SETTING.bgAlpha,image)
                    GC.setDefaultFilter('nearest','nearest')
                    BG.lock()
                else
                    MES.new('error',text.customBGloadFailed)
                end
            else-- Switch off when custom BG not found
                SETTING.bg='off'
                BG.unlock()
                BG.set('fixColor',SETTING.bgAlpha,SETTING.bgAlpha,SETTING.bgAlpha)
                BG.lock()
            end
        end
    end
end

-- Royale mode
function randomTarget(P)-- Return a random opponent for P
    local l=TABLE.shift(PLY_ALIVE,0)
    local count=0
    for i=1,#l do
        if P.group==0 and l[i]~=P or P.group~=l[i].group then
            count=count+1
        end
    end
    if count==0 then return end
    count=rnd(count)
    for i=1,#l do
        if P.group==0 and l[i]~=P or P.group~=l[i].group then
            count=count-1
            if count==0 then
                return l[i]
            end
        end
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
    TEXT.show(text.royale_remain:repD(#PLY_ALIVE),640,200,40,'beat',.3)
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
    if GAME.curMode.name:find("_u") then
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

-- Sound shortcuts
function playClearSFX(cc)
    if cc<=0 or cc%1~=0 then return end
    if cc<=4 then
        SFX.play('clear_'..cc)
    elseif cc<=6 then
        SFX.play('clear_4')
    elseif cc<=12 then
        SFX.play('clear_4',.8)
        if cc<=9 then
            Snd('bass','A3','E4')
        else
            Snd('bass','A3','E4','A4')
        end
    elseif cc<=16 then
        SFX.play('clear_5',.7)
        if cc<=14 then
            Snd('bass',.8,'A3','E4')Snd('lead','A4','E5')
        else
            Snd('bass',.8,'A3','G4')Snd('lead','B4','G5')
        end
    else
        SFX.play('clear_6',.6)
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


-- Game
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
        if notEmptyLine(F[y]) then
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
        if not args:find'q' then
            MES.new('info',text.newDay)
        end
        saveStats()
        return true
    end
end
function legalGameTime()-- Check if today's playtime is legal
    if
        SETTING.locale:find'zh' and
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
do-- function trySettingWarn()
    local lastWarnTime=0
    function trySettingWarn()
        if TIME()-lastWarnTime>2.6 then
            MES.new('warn',text.settingWarn,5)
        end
        lastWarnTime=TIME()
    end
end

function mergeStat(stat,delta)-- Merge delta stat. to global stat.
    for k,v in next,delta do
        if type(v)=='table' then
            if type(stat[k])=='table' then
                mergeStat(stat[k],v)
            end
        else
            if stat[k] then
                stat[k]=stat[k]+v
            end
        end
    end
end
function scoreValid()-- Check if any unranked mods are activated
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
function destroyPlayers()-- Destroy all player objects, restore freerows and free CCs
    for i=#PLAYERS,1,-1 do
        local P=PLAYERS[i]
        if P.canvas then
            P.canvas:release()
        end
        while P.field[1] do
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
                    if l[j] then
                        PLAYERS[i]:releaseKey(j)
                    end
                end
            end
        end
        for i=1,20 do
            VK.release(i)
        end
        if not (GAME.result or GAME.replaying) then
            GAME.pauseCount=GAME.pauseCount+1
        end
        SCN.swapTo('pause','none')
    end
end
function applyCustomGame()-- Apply CUSTOMENV, BAG, MISSION
    for k,v in next,CUSTOMENV do
        GAME.modeEnv[k]=v
    end
    if BAG[1] then
        GAME.modeEnv.seqData=BAG
    else
        GAME.modeEnv.seqData=nil
    end
    if MISSION[1] then
        GAME.modeEnv.mission=MISSION
    else
        GAME.modeEnv.mission=nil
    end
end
function loadGame(mode,ifQuickPlay,ifNet)-- Load a mode and go to game scene
    freshDate()
    if legalGameTime() then
        if not MODES[mode] and FILE.isSafe('parts/modes/'..mode) then
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
            local modeText=text.modes[mode] or{"["..MODES[mode].name.."]",""}
            TEXTOBJ.modeName:set(modeText[1].."   "..modeText[2])
            SCN.go('game',ifQuickPlay and 'swipeD' or 'fade_togame')
            SFX.play('enter')
        end
    end
end
function gameOver()-- Save record
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
        R=R(P)-- New rank
        if R then
            if R>0 then
                GAME.rank=R
            end
            if not GAME.replaying and M.score and scoreValid() then
                if RANKS[M.name] then-- Old rank exist
                    local needSave
                    if R>RANKS[M.name] then
                        RANKS[M.name]=R
                        needSave=true
                    end
                    if R>0 then
                        if M.unlock then
                            for i=1,#M.unlock do
                                local m=M.unlock[i]
                                local n=MODES[m].name
                                if not RANKS[n] then
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
                local p=#L-- Rank-1
                if p>0 then
                    while M.comp(D,L[p]) do-- If higher rank
                        p=p-1
                        if p==0 then break end
                    end
                end
                if p<10 then
                    if p==0 then
                        P:_showText(text.newRecord,0,-100,100,'beat',.5)
                        if SETTING.autoSave and DATA.saveReplay() then
                            GAME.saved=true
                            SFX.play('connected')
                            MES.new('check',text.saveDone)
                        end
                    end
                    D.date=os.date("%Y/%m/%d %H:%M")
                    ins(L,p+1,D)
                    if L[11] then L[11]=nil end
                    saveFile(L,('record/%s.rec'):format(M.name),'-luaon')
                end
            end
        end
    end
end
function trySave()
    if not GAME.statSaved and PLAYERS[1] and PLAYERS[1].type=='human' and (PLAYERS[1].frameRun>300 or GAME.result) then
        GAME.statSaved=true
        STAT.game=STAT.game+1
        mergeStat(STAT,PLAYERS[1].stat)
        STAT.todayTime=STAT.todayTime+PLAYERS[1].stat.time
        saveStats()
    end
end
do-- function freshPlayerPosition(sudden)
    local posLists=setmetatable({
        alive={
            [1]={main={340,75,1}},
            [3]={main={340,75,1},
                {25,210,.5},
                {955,210,.5},
            },
            [4]={main={340,75,1},
                {25,210,.5},
                {970,90,.45},{970,410,.45},
            },
            [5]={main={340,75,1},
                {40,90,.45},{40,410,.45},
                {970,90,.45},{970,410,.45},
            },
            [6]={main={340,75,1},
                {40,90,.45},{40,410,.45},
                {1010,80,.305},{1010,290,.305},{1010,500,.305},
            },
            [7]={main={340,75,1},
                {100,80,.305},{100,290,.305},{100,500,.305},
                {1010,80,.305},{1010,290,.305},{1010,500,.305},
            },
            [10]={main={340,75,1},
                {100,80,.305},{100,290,.305},{100,500,.305},
                {935,90,.275},{935,300,.275},{935,510,.275},
                {1105,90,.275},{1105,300,.275},{1105,510,.275},
            },
            [13]={main={340,75,1},
                {10,90,.275},{10,300,.275},{10,510,.275},
                {180,90,.275},{180,300,.275},{180,510,.275},
                {935,90,.275},{935,300,.275},{935,510,.275},
                {1105,90,.275},{1105,300,.275},{1105,510,.275},
            },
            [14]={main={340,75,1},
                {10,90,.275},{10,300,.275},{10,510,.275},
                {180,90,.275},{180,300,.275},{180,510,.275},
                {935,90,.275},{935,300,.275},{935,510,.275},
                {1120,80,.225},{1120,240,.225},{1120,400,.225},{1120,560,.225},
            },
            [15]={main={340,75,1},
                {10,90,.275},{10,300,.275},{10,510,.275},
                {180,90,.275},{180,300,.275},{180,510,.275},
                {960,80,.225},{960,240,.225},{960,400,.225},{960,560,.225},
                {1120,80,.225},{1120,240,.225},{1120,400,.225},{1120,560,.225},
            },
            [16]={main={340,75,1},
                {10,90,.275},{10,300,.275},{10,510,.275},
                {190,80,.225},{190,240,.225},{190,400,.225},{190,560,.225},
                {960,80,.225},{960,240,.225},{960,400,.225},{960,560,.225},
                {1120,80,.225},{1120,240,.225},{1120,400,.225},{1120,560,.225},
            },
            [17]={main={340,75,1},
                {30,80,.225},{30,240,.225},{30,400,.225},{30,560,.225},
                {190,80,.225},{190,240,.225},{190,400,.225},{190,560,.225},
                {960,80,.225},{960,240,.225},{960,400,.225},{960,560,.225},
                {1120,80,.225},{1120,240,.225},{1120,400,.225},{1120,560,.225},
            },
            [24]={main={340,75,1},
                {30,80,.225},{30,240,.225},{30,400,.225},{30,560,.225},
                {190,80,.225},{190,240,.225},{190,400,.225},{190,560,.225},
                {940,80,.175},{940,205,.175},{940,330,.175},{940,455,.175},{940,580,.175},
                {1050,80,.175},{1050,205,.175},{1050,330,.175},{1050,455,.175},{1050,580,.175},
                {1160,80,.175},{1160,205,.175},{1160,330,.175},{1160,455,.175},{1160,580,.175},
            },
            [31]={main={340,75,1},
                {10,80,.175},{10,205,.175},{10,330,.175},{10,455,.175},{10,580,.175},
                {120,80,.175},{120,205,.175},{120,330,.175},{120,455,.175},{120,580,.175},
                {230,80,.175},{230,205,.175},{230,330,.175},{230,455,.175},{230,580,.175},
                {940,80,.175},{940,205,.175},{940,330,.175},{940,455,.175},{940,580,.175},
                {1050,80,.175},{1050,205,.175},{1050,330,.175},{1050,455,.175},{1050,580,.175},
                {1160,80,.175},{1160,205,.175},{1160,330,.175},{1160,455,.175},{1160,580,.175},
            },
            [33]=(function()
                local l={main={340,75,1}}
                for y=-1.5,1.5 do for x=0,3 do
                    table.insert(l,{265-85*x,310+160*y,.125})
                    table.insert(l,{940+85*x,310+160*y,.125})
                end end
                return l
            end)(),
            [51]=(function()
                local l={main={340,75,1}}
                for y=-2,2 do for x=0,4 do
                    table.insert(l,{275-65*x,315+125*y,.1})
                    table.insert(l,{945+65*x,315+125*y,.1})
                end end
                return l
            end)(),
            [75]=(function()
                local l={main={340,75,1}}
                for y=-2,2 do for x=0,4 do
                    table.insert(l,{275-65*x,310+125*y,.1})
                end end
                for y=-3,3 do for x=0,6 do
                    table.insert(l,{940+47*x,340+92*y,.075})
                end end
                return l
            end)(),
            [99]=(function()
                local l={main={340,75,1}}
                for y=-3,3 do for x=0,6 do
                    table.insert(l,{290-47*x,340+92*y,.075})
                    table.insert(l,{940+47*x,340+92*y,.075})
                end end
                return l
            end)(),
            [MATH.inf]={main={340,75,1}},
        },
        dead={
            [1]={{340,75,1}},
            [2]={
                {50,130,.925},{670,130,.925},
            },
            [3]={
                {25,160,.675},{440,160,.675},{855,160,.675},
            },
            [4]={
                {13,200,.525},{328,200,.525},{643,200,.525},{948,200,.525},
            },
            [5]={
                {8,230,.425},{260,230,.425},{512,230,.425},{764,230,.425},{1016,230,.425},
            },
            [10]={
                {8,110,.425},{260,110,.425},{512,110,.425},{764,110,.425},{1016,110,.425},
                {8,410,.425},{260,410,.425},{512,410,.425},{764,410,.425},{1016,410,.425},
            },
            [12]={
                {10,120,.35},{220,120,.35},{430,120,.35},{640,120,.35},{850,120,.35},{1060,120,.35},
                {10,400,.35},{220,400,.35},{430,400,.35},{640,400,.35},{850,400,.35},{1060,400,.35},
            },
            [18]={
                {10,90,.305},{220,90,.305},{430,90,.305},{640,90,.305},{850,90,.305},{1060,90,.305},
                {10,300,.305},{220,300,.305},{430,300,.305},{640,300,.305},{850,300,.305},{1060,300,.305},
                {10,510,.305},{220,510,.305},{430,510,.305},{640,510,.305},{850,510,.305},{1060,510,.305},
            },
            [21]={
                {10,90,.295},{190,90,.295},{370,90,.295},{550,90,.295},{730,90,.295},{910,90,.295},{1090,90,.295},
                {10,300,.295},{190,300,.295},{370,300,.295},{550,300,.295},{730,300,.295},{910,300,.295},{1090,300,.295},
                {10,510,.295},{190,510,.295},{370,510,.295},{550,510,.295},{730,510,.295},{910,510,.295},{1090,510,.295},
            },
            [24]={
                {20,100,.25},{175,100,.25},{330,100,.25},{485,100,.25},{640,100,.25},{795,100,.25},{950,100,.25},{1105,100,.25},
                {20,300,.25},{175,300,.25},{330,300,.25},{485,300,.25},{640,300,.25},{795,300,.25},{950,300,.25},{1105,300,.25},
                {20,500,.25},{175,500,.25},{330,500,.25},{485,500,.25},{640,500,.25},{795,500,.25},{950,500,.25},{1105,500,.25},
            },
            [27]={
                {10,100,.225},{150,100,.225},{290,100,.225},{430,100,.225},{570,100,.225},{710,100,.225},{850,100,.225},{990,100,.225},{1130,100,.225},
                {10,300,.225},{150,300,.225},{290,300,.225},{430,300,.225},{570,300,.225},{710,300,.225},{850,300,.225},{990,300,.225},{1130,300,.225},
                {10,500,.225},{150,500,.225},{290,500,.225},{430,500,.225},{570,500,.225},{710,500,.225},{850,500,.225},{990,500,.225},{1130,500,.225},
            },
            [36]={
                {10,90,.225},{150,90,.225},{290,90,.225},{430,90,.225},{570,90,.225},{710,90,.225},{850,90,.225},{990,90,.225},{1130,90,.225},
                {10,245,.225},{150,245,.225},{290,245,.225},{430,245,.225},{570,245,.225},{710,245,.225},{850,245,.225},{990,245,.225},{1130,245,.225},
                {10,400,.225},{150,400,.225},{290,400,.225},{430,400,.225},{570,400,.225},{710,400,.225},{850,400,.225},{990,400,.225},{1130,400,.225},
                {10,555,.225},{150,555,.225},{290,555,.225},{430,555,.225},{570,555,.225},{710,555,.225},{850,555,.225},{990,555,.225},{1130,555,.225},
            },
            [39]=(function()
                local l={}
                for y=0,2 do for x=0,12 do
                    table.insert(l,{13+97*x,110+190*y,.15})
                end end
                return l
            end)(),
            [42]=(function()
                local l={}
                for y=0,2 do for x=0,13 do
                    table.insert(l,{15+90*x,120+190*y,.135})
                end  end
                return l
            end)(),
            [45]=(function()
                local l={}
                for y=0,2 do for x=0,14 do
                    table.insert(l,{8+85*x,120+190*y,.125})
                end end
                return l
            end)(),
            [60]=(function()
                local l={}
                for y=0,3 do for x=0,14 do
                    table.insert(l,{8+85*x,85+155*y,.125})
                end end
                return l
            end)(),
            [64]=(function()
                local l={}
                for y=0,3 do for x=0,15 do
                    table.insert(l,{13+79*x,85+155*y,.115})
                end end
                return l
            end)(),
            [68]=(function()
                local l={}
                for y=0,3 do for x=0,16 do
                    table.insert(l,{6+75*x,85+155*y,.115})
                end end
                return l
            end)(),
            [72]=(function()
                local l={}
                for y=0,3 do for x=0,17 do
                    table.insert(l,{15+70*x,95+155*y,.1})
                end end
                return l
            end)(),
            [90]=(function()
                local l={}
                for y=0,4 do for x=0,17 do
                    table.insert(l,{15+70*x,82+127*y,.1})
                end end
                return l
            end)(),
            [95]=(function()
                local l={}
                for y=0,4 do for x=0,18 do
                    table.insert(l,{15+66*x,82+127*y,.1})
                end end
                return l
            end)(),
            [100]=(function()
                local l={}
                for y=0,4 do for x=0,19 do
                    table.insert(l,{12+63*x,82+127*y,.1})
                end end
                return l
            end)(),
            [MATH.inf]={},
        },
    }, {
        __call=function(self,alive,count)
            local lastTested=MATH.inf
            for k in next,self[alive and 'alive' or 'dead'] do
                if k<lastTested and k>=count then
                    lastTested=k
                end
            end
            return self[alive and 'alive' or 'dead'][lastTested]
        end,
    })

    function freshPlayerPosition(mode)-- Set initial position for every player, mode: 'normal'|'quick'|'update'
        assert(mode=='normal' or mode=='quick' or mode=='update',"Wrong freshPlyPos mode")
        local L=PLY_ALIVE
        if mode~='update' then
            for i=1,#L do
                L[i]:setPosition(640,#L<=5 and 360 or -62,0)
            end
        end

        local alive=PLAYERS[1].alive

        if mode=='update' then
            if alive then
                if #L<=31 then
                    for i=2,#L do
                        L[i].miniMode=false
                        L[i].draw=require"parts.player.draw".norm
                    end
                end
            else
                if #L<=36 then
                    for i=1,#L do
                        L[i].miniMode=false
                        L[i].draw=require"parts.player.draw".norm
                    end
                end
            end
        end

        local posList=posLists(alive,#L)
        local method=mode=='normal' and 'setPosition' or 'movePosition'

        if alive then
            for i=1,#L do
                if i==1 then
                    if SETTING.portrait then-- WARNING: Brutly scaling up to 2x only for 1P, will cause many other visual issues.
                        L[i][method](L[i],36,-260,2)
                    else
                        L[i][method](L[i],unpack(posList['main']))
                    end
                else
                    L[i][method](L[i],unpack(posList[i-1]))
                end
            end
        else
            for i=1,#L do
                L[i][method](L[i],unpack(posList[i]))
            end
        end
    end
end
do-- function dumpBasicConfig()
    local gameSetting={
        -- Tuning
        'das','arr','dascut','dropcut','sddas','sdarr',
        'ihs','irs','ims','RS',

        -- System
        'skin','face',

        -- Graphic
        'ghostType','block','ghost','center','bagLine',
        'dropFX','moveFX','shakeFX',
        'text','highCam','nextPos',

        -- Unnecessary graphic
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
do-- function resetGameData(args)
    local function task_showMods()
        local time=0
        while true do
            coroutine.yield()
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
        -- Tuning
        'das','arr','dascut','dropcut','sddas','sdarr',
        'ihs','irs','ims','RS',

        -- System
        'skin','face',

        -- Graphic
        'block','ghost','center','smooth','grid','bagLine',
        'lockFX','dropFX','moveFX','clearFX','splashFX','shakeFX','atkFX',
        'text','score','warn','highCam','nextPos',
    }
    local function _copyGameSetting()
        local S={}
        for _,key in next,gameSetting do
            if type(SETTING[key])=='table' then
                S[key]=TABLE.shift(SETTING[key])
            else
                S[key]=SETTING[key]
            end
        end
        return S
    end
    function resetGameData(args,seed)
        if not args then args="" end
        trySave()

        GAME.result=false
        GAME.rank=0
        GAME.warnLVL0=0
        GAME.warnLVL=0
        if args:find'r' then
            GAME.frameStart=0
            GAME.recording=false
            GAME.replaying=true
        else
            GAME.frameStart=args:find'n' and 0 or 180-SETTING.reTime*60
            GAME.seed=seed or math.random(1046101471)
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
        freshPlayerPosition((args:find'q') and 'quick' or 'normal')
        VK.restore()

        local bg=GAME.modeEnv.bg
        BG.set(type(bg)=='string' and bg or type(bg)=='table' and bg[math.random(#bg)])
        local bgm=GAME.modeEnv.bgm
        BGM.play(type(bgm)=='string' and bgm or type(bgm)=='table' and bgm[math.random(#bgm)])

        TEXT.clear()
        if GAME.modeEnv.eventSet=='royale' then
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
do-- function checkWarning(P,dt)
    local max=math.max
    function checkWarning(P,dt)
        if P.alive then
            if P.frameRun%26==0 then
                local F=P.field
                local height=0-- Max height of row 4~7
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
                GAME.warnLVL0=math.log(height-(P.gameEnv.fieldH-5)+P.atkBufferSum*.8)
            end
            local _=GAME.warnLVL
            if _<GAME.warnLVL0 then
                _=approach(_,GAME.warnLVL0,dt*6)
            elseif _>0 then
                _=max(_-.026,0)
            end
            GAME.warnLVL=_
            if GAME.warnLVL>1.126 and P.frameRun%30==0 then
                SFX.fplay('warn_beep',SETTING.sfx_warn)
            end
        elseif GAME.warnLVL>0 then
            GAME.warnLVL=max(GAME.warnLVL-.026,0)
        end
    end
end



-- Game draw
do-- function drawSelfProfile()
    local name
    local textObj,scaleK,width,offY
    function drawSelfProfile()
        gc_push('transform')
        gc_replaceTransform(SCR.xOy_ur)

        -- Draw avatar
        gc_setLineWidth(2)
        gc_setColor(COLOR.X)gc_rectangle('fill',0,0,-300,80)
        gc_setColor(1,1,1)gc_rectangle('line',-300,0,300,80,5)
        gc_rectangle('line',-73,7,66,66,2)
        gc_draw(USERS.getAvatar(USER.uid),-72,8,nil,.5)

        -- Draw username
        if name~=USERS.getUsername(USER.uid) then
            name=USERS.getUsername(USER.uid)
            textObj=GC.newText(getFont(30),name)
            width=textObj:getWidth()
            scaleK=210/math.max(width,210)
            offY=textObj:getHeight()/2
        end
        gc_draw(textObj,-82,26,nil,scaleK,nil,width,offY)

        gc_pop()
    end
end
function drawOnlinePlayerCount()
    setFont(20)
    gc_setColor(1,1,1)
    gc_push('transform')
    gc_replaceTransform(SCR.xOy_ur)
    gc_printf(text.onlinePlayerCount:repD(NET.onlineCount),-600,80,594,'right')
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



-- Widget function shortcuts
function backScene() SCN.back() end
do-- function goScene(name,style)
    local cache={}
    function goScene(name,style)
        local hash=style and name..style or name
        if not cache[hash] then
            cache[hash]=function() SCN.go(name,style) end
        end
        return cache[hash]
    end
end
do-- function swapScene(name,style)
    local cache={}
    function swapScene(name,style)
        local hash=style and name..style or name
        if not cache[hash] then
            cache[hash]=function() SCN.swapTo(name,style) end
        end
        return cache[hash]
    end
end
do-- function pressKey(k)
    local cache={}
    function pressKey(k)
        if not cache[k] then
            cache[k]=function() love.keypressed(k) end
        end
        return cache[k]
    end
end
do-- CUS/SETXXX(k)
    local CUSTOMENV=CUSTOMENV
    local warnList={
        'das','arr','dascut','dropcut','sddas','sdarr',
        'ihs','irs','ims','RS',
        'frameMul','highCam',
        'VKSwitch','VKIcon','VKTrack','VKDodge',
        'simpMode',
    }
    function CUSval(k) return function()   return CUSTOMENV[k] end end
    function ROOMval(k) return function()  return ROOMENV[k] end end
    function SETval(k) return function()   return SETTING[k] end end
    function CUSrev(k) return function()   CUSTOMENV[k]=not CUSTOMENV[k] end end
    function ROOMrev(k) return function()  ROOMENV[k]=not ROOMENV[k] end end
    function SETrev(k) return function()   if TABLE.find(warnList,k) then trySettingWarn() end SETTING[k]=not SETTING[k] end end
    function CUSsto(k) return function(i)  CUSTOMENV[k]=i end end
    function ROOMsto(k) return function(i) ROOMENV[k]=i end end
    function SETsto(k) return function(i)  if TABLE.find(warnList,k) then trySettingWarn() end SETTING[k]=i end end
end
