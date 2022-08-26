--[[
    #   ______             __                _              #
    #  /_  __/___   _____ / /_   ____ ___   (_)____   ____  #
    #   / /  / _ \ / ___// __ \ / __ `__ \ / // __ \ / __ \ #
    #  / /  /  __// /__ / / / // / / / / // // / / // /_/ / #
    # /_/   \___/ \___//_/ /_//_/ /_/ /_//_//_/ /_/ \____/  #
    Techmino is my first "huge project"
    optimization is welcomed if you also love tetromino stacking game

    Instructions:
    1. I made a framework called Zframework, *most* code in Zframework are not directly relevant to game;
    2. "xxx" are texts for reading by player, 'xxx' are string values just used in program;
    3. Some goto statement are used for better performance. All goto-labes have detailed names so don't be afraid;
    4. Except "gcinfo" function of lua itself, other "gc" are short for "graphics";
]]--


--Var leak check
-- setmetatable(_G,{__newindex=function(self,k,v)print('>>'..k)print(debug.traceback():match("\n.-\n\t(.-): "))rawset(self,k,v)end})

--System Global Vars Declaration
local fs=love.filesystem
VERSION=require"version"
TIME=love.timer.getTime
YIELD=coroutine.yield
SYSTEM=love.system.getOS()if SYSTEM=='OS X'then SYSTEM='macOS'end
FNNS=SYSTEM:find'\79\83'--What does FNSF stand for? IDK so don't ask me lol
MOBILE=SYSTEM=='Android'or SYSTEM=='iOS'
SAVEDIR=fs.getSaveDirectory()

--Global Vars & Settings
SFXPACKS={'chiptune'}
VOCPACKS={'miya','mono','xiaoya','miku','rin'}
FIRSTLAUNCH=false
DAILYLAUNCH=false

--System setting
math.randomseed(os.time()*626)
love.setDeprecationOutput(false)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
if MOBILE then
    local w,h,f=love.window.getMode()
    f.resizable=false
    love.window.setMode(w,h,f)
end

local _LOADTIMELIST_={}
local _LOADTIME_=TIME()

--Load modules
Z=require'Zframework'
FONT.load{
    norm='parts/fonts/proportional.otf',
    mono='parts/fonts/monospaced.otf',
}
FONT.setDefault('norm')
FONT.setFallback('norm')

SCR.setSize(1280,720)--Initialize Screen size
BGM.setMaxSources(5)
BGM.setChange(function(name)MES.new('music',text.nowPlaying..name,5)end)
VOC.setDiversion(.62)

WIDGET.setOnChange(function()
    if SCN.cur~='custom_field'then
        local colorList=THEME.getThemeColor()
        if not colorList then return end
        local rnd=math.random
        for _,W in next,SCN.scenes[SCN.cur].widgetList do
            if W.color then
                W.color=colorList[rnd(#colorList)]
            end
        end
    end
end)

table.insert(_LOADTIMELIST_,("Load Zframework: %.3fs"):format(TIME()-_LOADTIME_))

--Create shortcuts
setFont=FONT.set
getFont=FONT.get
mStr=GC.mStr
mText=GC.simpX
mDraw=GC.draw
Snd=SFX.playSample
string.repD=STRING.repD
string.sArg=STRING.sArg
string.split=STRING.split

--Delete all naked files (from ancient versions)
FILE.clear('')

--Create directories
for _,v in next,{'conf','record','replay','cache','lib'}do
    local info=fs.getInfo(v)
    if not info then
        fs.createDirectory(v)
    elseif info.type~='directory'then
        fs.remove(v)
        fs.createDirectory(v)
    end
end

CHAR=require'parts.char'
require'parts.gameTables'
require'parts.gameFuncs'

--Load shader files from SOURCE ONLY
SHADER={}
for _,v in next,fs.getDirectoryItems('parts/shaders')do
    if isSafeFile('parts/shaders/'..v)then
        local name=v:sub(1,-6)
        SHADER[name]=love.graphics.newShader('parts/shaders/'..name..'.glsl')
    end
end

THEME=      require'parts.theme'
LINE=       require'parts.line'
DATA=       require'parts.data'

TEXTURE=    require'parts.texture'
SKIN=       require'parts.skin'
USERS=      require'parts.users'
NET=        require'parts.net'
VK=         require'parts.virtualKey'
BOT=        require'parts.bot'
RSlist=     require'parts.RSlist'DSCP=RSlist.TRS.centerPos
PLY=        require'parts.player'
NETPLY=     require'parts.netPlayer'
MODES=      require'parts.modes'

setmetatable(TEXTURE,{__index=function(self,k)
    MES.new('warn',"No texture called: "..k)
    self[k]=PAPER
    return self[k]
end})

table.insert(_LOADTIMELIST_,("Load Parts: %.3fs"):format(TIME()-_LOADTIME_))

--Init Zframework
do--Z.setCursor
    local normImg=GC.DO{16,16,
        {'fCirc',8,8,4},
        {'setCL',1,1,1,.7},
        {'fCirc',8,8,6},
    }
    local holdImg=GC.DO{16,16,
        {'setLW',2},
        {'dCirc',8,8,7},
        {'fCirc',8,8,3},
    }
    local min,int,abs=math.min,math.floor,math.abs
    local gc_setColor,gc_draw=love.graphics.setColor,love.graphics.draw
    local ms=love.mouse
    Z.setCursor(function(time,x,y)
        if not SETTING.sysCursor then
            local R=int((time+1)/2)%7+1
            _=BLOCK_COLORS[SETTING.skin[R]]
            gc_setColor(_[1],_[2],_[3],min(abs(1-time%2),.3))
            _=DSCP[R][0]
            gc_draw(TEXTURE.miniBlock[R],x,y,time%3.14159265359*4,8,8,2*_[2]+1,2*(#BLOCKS[R][0]-_[1])-1)
            gc_setColor(1,1,1)
            gc_draw(ms.isDown(1)and holdImg or normImg,x,y,nil,nil,nil,8,8)
        end
    end)
end
Z.setOnFnKeys({
    function()MES.new('check',PROFILE.switch()and"profile start!"or"profile report copied!")end,
    function()MES.new('info',("System:%s[%s]\nluaVer:%s\njitVer:%s\njitVerNum:%s"):format(SYSTEM,jit.arch,_VERSION,jit.version,jit.version_num))end,
    function()MES.new('error',"挂了")end,
    function()
        if GAME.playing and not GAME.net then
            for _=1,8 do
                if #PLY_ALIVE>1 then
                    local P=PLY_ALIVE[math.random(2,#PLY_ALIVE)]
                    P.lastRecv=PLAYERS[1]
                    P:lose()
                end
            end
        end
    end,
    function()print(BG.locked)end,
    function()for k,v in next,_G do print(k,v)end end,
    function()if love['_openConsole']then love['_openConsole']()end end,
})
Z.setDebugInfo{
    {"Cache",gcinfo},
    {"Tasks",TASK.getCount},
    {"Voices",VOC.getQueueCount},
    {"Audios",love.audio.getSourceCount},
}
do--Z.setOnFocus
    local function task_autoSoundOff()
        while true do
            coroutine.yield()
            local v=love.audio.getVolume()
            love.audio.setVolume(math.max(v-.05,0))
            if v==0 then return end
        end
    end
    local function task_autoSoundOn()
        while true do
            coroutine.yield()
            local v=love.audio.getVolume()
            if v<SETTING.mainVol then
                love.audio.setVolume(math.min(v+.05,SETTING.mainVol,1))
            else
                return
            end
        end
    end
    Z.setOnFocus(function(f)
        if f then
            love.timer.step()
            if SETTING.autoMute then
                TASK.removeTask_code(task_autoSoundOff)
                TASK.new(task_autoSoundOn)
            end
        else
            if SCN.cur=='game'and SETTING.autoPause then
                pauseGame()
            end
            if SETTING.autoMute and SCN.cur~='music' then
                TASK.removeTask_code(task_autoSoundOn)
                TASK.new(task_autoSoundOff)
            end
        end
    end)
end
Z.setOnQuit(destroyPlayers)

--Load settings and statistics
if
    not(
        pcall(TABLE.cover, loadFile('conf/user',      '-json -canSkip')or loadFile('conf/user',      '-luaon -canSkip')or{},USER) and
        pcall(TABLE.cover, loadFile('conf/unlock',    '-json -canSkip')or loadFile('conf/unlock',    '-luaon -canSkip')or{},RANKS) and
        pcall(TABLE.update,loadFile('conf/settings',  '-json -canSkip')or loadFile('conf/settings',  '-luaon -canSkip')or{},SETTING) and
        pcall(TABLE.coverR,loadFile('conf/data',      '-json -canSkip')or loadFile('conf/data',      '-luaon -canSkip')or{},STAT) and
        pcall(TABLE.cover, loadFile('conf/key',       '-json -canSkip')or loadFile('conf/key',       '-luaon -canSkip')or{},KEY_MAP) and
        pcall(TABLE.cover, loadFile('conf/virtualkey','-json -canSkip')or loadFile('conf/virtualkey','-luaon -canSkip')or{},VK_ORG)
    )
then
    MES.new('error',"An error occured during loading, and some data was lost.")
end

--Initialize fields, sequence, missions, gameEnv for cutsom game
local fieldData=loadFile('conf/customBoards','-string -canSkip')
if fieldData then
    fieldData=STRING.split(fieldData,"!")
    for i=1,#fieldData do
        DATA.pasteBoard(fieldData[i],i)
    end
else
    FIELD[1]=DATA.newBoard()
end
local sequenceData=loadFile('conf/customSequence','-string -canSkip')
if sequenceData then
    DATA.pasteSequence(sequenceData)
end
local missionData=loadFile('conf/customMissions','-string -canSkip')
if missionData then
    DATA.pasteMission(missionData)
end
local customData=loadFile('conf/customEnv','-canSkip')
if customData and customData['version']==VERSION.code then
    TABLE.complete(customData,CUSTOMENV)
end
TABLE.complete(require"parts.customEnv0",CUSTOMENV)


--Initialize image libs
IMG.init{
    lock='media/image/mess/lock.png',
    dialCircle='media/image/mess/dialCircle.png',
    dialNeedle='media/image/mess/dialNeedle.png',
    lifeIcon='media/image/mess/life.png',
    badgeIcon='media/image/mess/badge.png',
    ctrlSpeedLimit='media/image/mess/ctrlSpeedLimit.png',
    speedLimit='media/image/mess/speedLimit.png',--Not used, for future C2-mode
    pay1='media/image/mess/pay1.png',
    pay2='media/image/mess/pay2.png',

    miyaCH1='media/image/characters/miya1.png',
    miyaCH2='media/image/characters/miya2.png',
    miyaCH3='media/image/characters/miya3.png',
    miyaCH4='media/image/characters/miya4.png',
    miyaHeart='media/image/characters/miya_heart.png',
    miyaGlow='media/image/characters/miya_glow.png',
    monoCH='media/image/characters/mono.png',
    xiaoyaCH='media/image/characters/xiaoya.png',
    xiaoyaOmino='media/image/characters/xiaoya_Omino.png',
    mikuCH='media/image/characters/miku.png',
    rinCH='media/image/characters/rin.png',
    z={
        character='media/image/characters/z_character.png',
        screen1='media/image/characters/z_screen1.png',
        screen2='media/image/characters/z_screen2.png',
        particle1='media/image/characters/z_particle1.png',
        particle2='media/image/characters/z_particle2.png',
        particle3='media/image/characters/z_particle3.png',
        particle4='media/image/characters/z_particle4.png',
    },
    electric='media/image/characters/electric.png',
    hbm='media/image/characters/hbm.png',

    lanterns={
        'media/image/lanterns/1.png',
        'media/image/lanterns/2.png',
        'media/image/lanterns/3.png',
        'media/image/lanterns/4.png',
        'media/image/lanterns/5.png',
        'media/image/lanterns/6.png',
    },
}
SKIN.load{
    {name="crystal_scf",path='media/image/skin/crystal_scf.png'},
    {name="matte_mrz",path='media/image/skin/matte_mrz.png'},
    {name="shiny_chno",path='media/image/skin/shiny_chno.png'},
    {name="contrast_mrz",path='media/image/skin/contrast_mrz.png'},
    {name="polkadots_scf",path='media/image/skin/polkadots_scf.png'},
    {name="toy_scf",path='media/image/skin/toy_scf.png'},
    {name="smooth_mrz",path='media/image/skin/smooth_mrz.png'},
    {name="simple_scf",path='media/image/skin/simple_scf.png'},
    {name="glass_scf",path='media/image/skin/glass_scf.png'},
    {name="penta_scf",path='media/image/skin/penta_scf.png'},
    {name="bubble_scf",path='media/image/skin/bubble_scf.png'},
    {name="minoes_scf",path='media/image/skin/minoes_scf.png'},
    {name="pure_mrz",path='media/image/skin/pure_mrz.png'},
    {name="bright_scf",path='media/image/skin/bright_scf.png'},
    {name="glow_mrz",path='media/image/skin/glow_mrz.png'},
    {name="plastic_mrz",path='media/image/skin/plastic_mrz.png'},
    {name="paper_mrz",path='media/image/skin/paper_mrz.png'},
    {name="yinyang_scf",path='media/image/skin/yinyang_scf.png'},
    {name="cartooncup_earety",path='media/image/skin/cartooncup_earety.png'},
    {name="jelly_miya",path='media/image/skin/jelly_miya.png'},
    {name="guidetris_xmiao_lusisi",path='media/image/skin/guidetris_xmiao_lusisi.png'},
    {name="brick_notypey",path='media/image/skin/brick_notypey.png'},
    {name="gem_notypey",path='media/image/skin/gem_notypey.png'},
    {name="classic",path='media/image/skin/classic_unknown.png'},
    {name="ball_shaw",path='media/image/skin/ball_shaw.png'},
    {name="retro_notypey",path='media/image/skin/retro_notypey.png'},
    {name="pixel_chno",path='media/image/skin/pixel_chno.png'},
    {name="pastel_chno",path='media/image/skin/pastel_chno.png'},
    {name="letters_chno",path='media/image/skin/letters_chno.png'},
    {name="kanji_chno",path='media/image/skin/kanji_chno.png'},
    {name="textbone_mrz",path='media/image/skin/textbone_mrz.png'},
    {name="coloredbone_mrz",path='media/image/skin/coloredbone_mrz.png'},
    {name="wtf",path='media/image/skin/wtf_mrz.png'},
}

--Initialize sound libs
SFX.init((function()--[Warning] Not loading files here, just get the list of sound needed
    local L={}
    for _,v in next,fs.getDirectoryItems('media/effect/chiptune/')do
        if isSafeFile('media/effect/chiptune/'..v,"Dangerous file : %SAVE%/media/effect/chiptune/"..v)then
            table.insert(L,v:sub(1,-5))
        end
    end
    return L
end)())
BGM.load((function()
    local L={}
    for _,v in next,fs.getDirectoryItems('media/music')do
        if isSafeFile('media/music/'..v,"Dangerous file : %SAVE%/media/music/"..v)then
            L[v:sub(1,-5)]='media/music/'..v
        end
    end
    return L
end)())
VOC.init{
    'zspin','sspin','jspin','lspin','tspin','ospin','ispin','pspin','qspin','fspin','espin','uspin','vspin','wspin','xspin','rspin','yspin','nspin','hspin','cspin',
    'single','double','triple','techrash','pentacrash','hexacrash',
    'mini','b2b','b3b',
    'perfect_clear','half_clear',
    'win','lose','bye',
    'test','happy','doubt',
    'welcome',
}

--Initialize language lib
LANG.init('zh',
    {
        zh=require'parts.language.lang_zh',
        zh_trad=require'parts.language.lang_zh_trad',
        en=require'parts.language.lang_en',
        fr=require'parts.language.lang_fr',
        es=require'parts.language.lang_es',
        pt=require'parts.language.lang_pt',
        id=require'parts.language.lang_id',
        ja=require'parts.language.lang_ja',
        symbol=require'parts.language.lang_symbol',
        zh_code=require'parts.language.lang_zh_code',
        --1. Add language file to LANG folder;
        --2. Require it;
        --3. Add a button in parts/scenes/lang.lua;
    },
    {
        block=BLOCK_NAMES
    },
    (function()
        local tipMeta={__call=function(L)return L[math.random(#L)]end}
        return function(L)
            if type(rawget(L,'getTip'))=='table'then setmetatable(L.getTip,tipMeta)end
            setmetatable(L,{__index=function(self,k)
                local mes="No Text ("..SETTING.locale.."): "..k
                LOG(mes)
                MES.new('warn',mes)
                self[k]=CHAR.zChan.thinking
                return self[k]
            end})
        end
    end)()
)

table.insert(_LOADTIMELIST_,("Initialize Parts: %.3fs"):format(TIME()-_LOADTIME_))

--Load background files from SOURCE ONLY
for _,v in next,fs.getDirectoryItems('parts/backgrounds')do
    if isSafeFile('parts/backgrounds/'..v)and v:sub(-3)=='lua'then
        local name=v:sub(1,-5)
        BG.add(name,require('parts.backgrounds.'..name))
    end
end
BG.remList('none')BG.remList('gray')BG.remList('custom')
--Load scene files from SOURCE ONLY
for _,v in next,fs.getDirectoryItems('parts/scenes')do
    if isSafeFile('parts/scenes/'..v)then
        local sceneName=v:sub(1,-5)
        SCN.add(sceneName,require('parts.scenes.'..sceneName))
        LANG.addScene(sceneName)
    end
end
--Load mode files
for i=1,#MODES do
    local m=MODES[i]--Mode template
    if isSafeFile('parts/modes/'..m.name)then
        TABLE.complete(require('parts.modes.'..m.name),MODES[i])
        MODES[m.name],MODES[i]=MODES[i]
    end
end
for _,v in next,fs.getDirectoryItems('parts/modes')do
    if isSafeFile('parts/modes/'..v)and not MODES[v:sub(1,-5)]then
        local M={name=v:sub(1,-5)}
        local modeData=require('parts.modes.'..M.name)
        if modeData.env then
            TABLE.complete(modeData,M)
            MODES[M.name]=M
        end
    end
end

table.insert(_LOADTIMELIST_,("Load Files: %.3fs"):format(TIME()-_LOADTIME_))

--Update data
do
    local needSave

    if not fs.getInfo('conf/data')then
        needSave=true
    end
    if type(STAT.version)~='number'then
        STAT.version=0
        needSave=true
    end
    if STAT.version<1500 then
        FILE.clear_s('')
    end
    if STAT.version<1505 then
        fs.remove('record/bigbang.rec')
        fs.remove('conf/replay')
    end
    if STAT.version==1506 then
        local temp1,temp2
        if fs.getInfo('record/master_l.rec')then
            temp1=fs.read('record/master_l.rec')
        end
        if fs.getInfo('record/master_u.rec')then
            temp2=fs.read('record/master_u.rec')
        end
        if temp1 then
            fs.write('record/master_u.rec',temp1)
        end
        if temp2 then
            fs.write('record/master_l.rec',temp2)
        end
        RANKS.master_l,RANKS.master_u=RANKS.master_u,RANKS.master_l
        if RANKS.tsd_u then
            RANKS.tsd_u=0
        end
    end
    if STAT.version==1601 then
        RANKS.round_e=nil
        RANKS.round_n=nil
        RANKS.round_h=nil
        RANKS.round_l=nil
        RANKS.round_u=nil
        fs.remove('record/round_e.rec')
        fs.remove('record/round_n.rec')
        fs.remove('record/round_h.rec')
        fs.remove('record/round_l.rec')
        fs.remove('record/round_u.rec')
    end
    if STAT.version<1700 and SETTING.dascut<5 then
        SETTING.dascut=SETTING.dascut+1
        needSave=true
    end
    if RANKS.stack_e then
        RANKS.stack_e=nil
        RANKS.stack_h=nil
        RANKS.stack_u=nil
        fs.remove('record/stack_e.rec')
        fs.remove('record/stack_h.rec')
        fs.remove('record/stack_u.rec')
    end
    if RANKS.stack_20l then
        RANKS.stack_20l=nil
        RANKS.stack_40l=nil
        RANKS.stack_100l=nil
        fs.remove('record/stack_20l.rec')
        fs.remove('record/stack_40l.rec')
        fs.remove('record/stack_100l.rec')
    end
    if RANKS.rhythm_e then
        RANKS.rhythm_e=nil
        RANKS.rhythm_h=nil
        RANKS.rhythm_u=nil
        fs.remove('record/rhythm_e.rec')
        fs.remove('record/rhythm_h.rec')
        fs.remove('record/rhythm_u.rec')
    end
    if RANKS.bigbang or RANKS.clearRush then
        fs.remove('record/clearRush.rec')
        fs.remove('record/bigbang.rec')
    end
    if STAT.version~=VERSION.code then
        for k,v in next,MODE_UPDATE_MAP do
            if RANKS[k]then
                RANKS[v]=RANKS[k]
                RANKS[k]=nil
            end
            k='record/'..k
            if fs.getInfo(k..'.dat')then
                fs.write('record/'..v..'.rec',fs.read(k..'.dat'))
                fs.remove(k..'.dat')
            end
            if fs.getInfo(k..'.rec')then
                fs.write('record/'..v..'.rec',fs.read(k..'.rec'))
                fs.remove(k..'.rec')
            end
        end
        STAT.version=VERSION.code
        needSave=true
    end
    SETTING.appLock,SETTING.dataSaving,SETTING.swap=nil
    if not SETTING.VKSkin then SETTING.VKSkin=1 end
    for _,v in next,SETTING.skin do if v<1 or v>17 then v=17 end end
    if not RSlist[SETTING.RS]then SETTING.RS='TRS'end
    if SETTING.ghostType=='greyCell'then SETTING.ghostType='grayCell'end
    if type(SETTING.skinSet)=='number'then SETTING.skinSet='crystal_scf'end
    if not TABLE.find({8,10,13,17,22,29,37,47,62,80,100},SETTING.frameMul)then SETTING.frameMul=100 end
    if SETTING.cv then SETTING.vocPack,SETTING.cv=SETTING.cv end
    if type(SETTING.bg)~='string'then SETTING.bg='on'end
    if SETTING.skin[18]==10 then SETTING.skin[18]=4 end
    if SETTING.reTime>3 or SETTING.reTime<.5 then SETTING.reTime=2 end
    if SETTING.locale=='zh_full' then SETTING.locale='zh' end
    if RANKS.infinite then RANKS.infinite=0 end
    if RANKS.infinite_dig then RANKS.infinite_dig=0 end
    if not RANKS.sprint_10l then RANKS.sprint_10l=0 end
    if RANKS.master_l then RANKS.master_n,RANKS.master_l=RANKS.master_l needSave=true end
    if RANKS.master_u then RANKS.master_h,RANKS.master_u=RANKS.master_u needSave=true end
    for _,v in next,VK_ORG do v.color=nil end
    for name,rank in next,RANKS do
        if type(name)=='number'or type(rank)~='number'then
            RANKS[name]=nil
            needSave=true
        else
            local M=MODES[name]
            if M and M.unlock and rank>0 then
                for _,unlockName in next,M.unlock do
                    if not RANKS[unlockName]then
                        RANKS[unlockName]=0
                        needSave=true
                    end
                end
            end
            if not(M and M.x)then
                RANKS[name]=nil
                needSave=true
            end
        end
    end
    if not MODES[STAT.lastPlay]then
        STAT.lastPlay='sprint_10l'
        needSave=true
    end

    if needSave then
        saveStats()
        saveProgress()
        saveSettings()
        love.event.quit('restart')
    end
end

--First start
FIRSTLAUNCH=STAT.run==0
if FIRSTLAUNCH and MOBILE then
    SETTING.VKSwitch=true
    SETTING.powerInfo=true
    SETTING.cleanCanvas=true
end

--Apply system setting
applySettings()

--Load replays
for _,fileName in next,fs.getDirectoryItems('replay')do
    if fileName:sub(12,12):match("[a-zA-Z]")then
        local date,mode,version,player,seed,setting,mod
        local fileData=fs.read('replay/'..fileName)
        date,   fileData=STRING.readLine(fileData)date=date:gsub("[a-zA-Z]","")
        mode,   fileData=STRING.readLine(fileData)mode=MODE_UPDATE_MAP[mode]or mode
        version,fileData=STRING.readLine(fileData)
        player, fileData=STRING.readLine(fileData)if player=="Local Player"then player="Stacker"end
        local success
        success,fileData=pcall(love.data.decompress,'string','zlib',fileData)
        if not success then goto BREAK_cannotParse end
        seed,   fileData=STRING.readLine(fileData)
        setting,fileData=STRING.readLine(fileData)setting=JSON.decode(setting)
        mod,    fileData=STRING.readLine(fileData)mod=JSON.decode(mod)
        if
            not setting or
            not mod or
            not mode or
            #mode==0
        then goto BREAK_cannotParse end

        fs.remove('replay/'..fileName)
        local newName=fileName:sub(1,10)..fileName:sub(15)
        fs.write('replay/'..newName,
            love.data.compress('string','zlib',
                JSON.encode{
                    date=date,
                    mode=mode,
                    version=version,
                    player=player,
                    seed=seed,
                    setting=setting,
                    mod=mod,
                }.."\n"..
                fileData
            )
        )
        fileName=newName
    end
    ::BREAK_cannotParse::
    local rep=DATA.parseReplay('replay/'..fileName)
    table.insert(REPLAY,rep)
end
table.sort(REPLAY,function(a,b)return a.fileName>b.fileName end)

table.insert(_LOADTIMELIST_,("Initialize Data: %.3fs"):format(TIME()-_LOADTIME_))

for i=1,#_LOADTIMELIST_ do LOG(_LOADTIMELIST_[i])end

--Launch testing task if launch param received
if TABLE.find(arg,'--test')then
    TASK.new(function()
        while not LOADED do YIELD()end

        LOG("\27[92m\27[1mAutomatic Test Started\27[0m")
        BGM.setVol(0)SFX.setVol(0)
        love.keypressed('space')
        TEST.yieldUntilNextScene()

        for k,mode in next,MODES do
            if k~='netBattle'then
                LOG("Scanning mode: "..mode.name)
                loadGame(mode.name,true)
                TEST.yieldUntilNextScene()
                SCN.back()
                TEST.yieldUntilNextScene()
            end
        end
        LOG("\27[92m\27[1mAutomatic Test Passed :)\27[0m")
        TEST.yieldN(60)
        love.event.quit(0)
    end)
    TASK.new(function()
        while true do
            YIELD()
            if Z.getErr(1)then break end
        end
        LOG("\27[91m\27[1mAutomatic Test Failed :(\27[0m\nThe error message is:\n"..table.concat(Z.getErr(1).mes,"\n").."\27[91m\nAborting\27[0m")
        TEST.yieldN(60)
        love.event.quit(1)
    end)
end
WS.switchHost('101.43.110.22','10026','/tech/socket/v1')
