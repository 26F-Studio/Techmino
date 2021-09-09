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
SYSTEM=love.system.getOS()
MOBILE=SYSTEM=='Android'or SYSTEM=='iOS'
SAVEDIR=fs.getSaveDirectory()

--Global Vars & Settings
FIRSTLAUNCH=false
DAILYLAUNCH=false

--System setting
math.randomseed(os.time()*626)
love.setDeprecationOutput(false)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.mouse.setVisible(false)
if SYSTEM=='Android'or SYSTEM=='iOS'then
    local w,h,f=love.window.getMode()
    f.resizable=false
    love.window.setMode(w,h,f)
end

--Load modules
require'Zframework'
FONT.init('parts/fonts/puhui.ttf')
    setFont=FONT.set
    getFont=FONT.get
SCR.setSize(1280,720)--Initialize Screen size
BGM.setChange(function(name)MES.new('music',text.nowPlaying..name,5)end)

--Delete all naked files (from too old version)
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

--Load shader files from SOURCE ONLY
SHADER={}
for _,v in next,fs.getDirectoryItems('parts/shaders')do
    if fs.getRealDirectory('parts/shaders/'..v)~=SAVEDIR then
        local name=v:sub(1,-6)
        SHADER[name]=love.graphics.newShader('parts/shaders/'..name..'.glsl')
    end
end

require'parts.list'
require'parts.globalTables'
require'parts.gametoolfunc'

FREEROW=    require'parts.freeRow'
DATA=       require'parts.data'

TEXTURE=    require'parts.texture'
SKIN=       require'parts.skin'
USERS=      require'parts.users'
NET=        require'parts.net'
VK=         require'parts.virtualKey'
BOT=        require'parts.bot'
RSlist=     require'parts.RSlist'DSCP=RSlist.TRS.centerPos
PLY=        require'parts.player'
netPLY=     require'parts.netPlayer'
MODES=      require'parts.modes'

--Load settings and statistics
TABLE.cover (FILE.load('conf/user')or{},USER)
TABLE.cover (FILE.load('conf/unlock')or{},RANKS)
TABLE.update(FILE.load('conf/settings')or{},SETTING)
TABLE.update(FILE.load('conf/data')or{},STAT)
TABLE.cover (FILE.load('conf/key')or{},keyMap)
TABLE.cover (FILE.load('conf/virtualkey')or{},VK_org)

--Initialize fields, sequence, missions, gameEnv for cutsom game
local fieldData=FILE.load('conf/customBoards')
if fieldData then
    fieldData=STRING.split(fieldData,"!")
    for i=1,#fieldData do
        DATA.pasteBoard(fieldData[i],i)
    end
else
    FIELD[1]=DATA.newBoard()
end
local sequenceData=FILE.load('conf/customSequence')
if sequenceData then
    DATA.pasteSequence(sequenceData)
end
local missionData=FILE.load('conf/customMissions')
if missionData then
    DATA.pasteMission(missionData)
end
local customData=FILE.load('conf/customEnv')
if customData and customData.version==VERSION.code then
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

    miyaCH='media/image/characters/miya.png',
    miyaF1='media/image/characters/miya_f1.png',
    miyaF2='media/image/characters/miya_f2.png',
    miyaF3='media/image/characters/miya_f3.png',
    miyaF4='media/image/characters/miya_f4.png',
    nakiCH='media/image/characters/nakiharu.png',
    xiaoyaCH='media/image/characters/xiaoya.png',
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
SKIN.init{
    {name="crystal_scf",path='media/image/skin/crystal_scf.png'},
    {name="matte_mrz",path='media/image/skin/matte_mrz.png'},
    {name="shiny_cho",path='media/image/skin/shiny_cho.png'},
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
    {name="brick_notypey",path='media/image/skin/brick_notypey.png'},
    {name="gem_notypey",path='media/image/skin/gem_notypey.png'},
    {name="classic",path='media/image/skin/classic_unknown.png'},
    {name="ball_shaw",path='media/image/skin/ball_shaw.png'},
    {name="retro_notypey",path='media/image/skin/retro_notypey.png'},
    {name="textbone_mrz",path='media/image/skin/textbone_mrz.png'},
    {name="coloredbone_mrz",path='media/image/skin/coloredbone_mrz.png'},
    {name="wtf",path='media/image/skin/wtf_mrz.png'},
}

--Initialize sound libs
SFX.init((function()
    local L={}
    for _,v in next,fs.getDirectoryItems('media/SFX')do
        if fs.getRealDirectory('media/SFX/'..v)~=SAVEDIR then
            table.insert(L,v:sub(1,-5))
        else
            MES.new('warn',"Dangerous file : %SAVE%/media/SFX/"..v)
        end
    end
    return L
end)())
BGM.init((function()
    local L={}
    for _,v in next,fs.getDirectoryItems('media/BGM')do
        if fs.getRealDirectory('media/BGM/'..v)~=SAVEDIR then
            table.insert(L,{name=v:sub(1,-5),path='media/BGM/'..v})
        else
            MES.new('warn',"Dangerous file : %SAVE%/media/BGM/"..v)
        end
    end
    return L
end)())
VOC.init{
    'zspin','sspin','jspin','lspin','tspin','ospin','ispin','pspin','qspin','fspin','espin','uspin','vspin','wspin','xspin','rspin','yspin','nspin','hspin',
    'single','double','triple','techrash',
    'mini','b2b','b3b',
    'perfect_clear','half_clear',
    'win','lose','bye',
    'test','happy','doubt','sad','egg',
    'welcome_voc',
}

--Initialize language lib
LANG.init(
    {
        require'parts.language.lang_zh',
        require'parts.language.lang_zh2',
        require'parts.language.lang_yygq',
        require'parts.language.lang_en',
        require'parts.language.lang_fr',
        require'parts.language.lang_es',
        require'parts.language.lang_pt',
        require'parts.language.lang_symbol',
        --1. Add language file to LANG folder;
        --2. Require it;
        --3. Add a button in parts/scenes/setting_lang.lua;
    },
    {
        block={
            "Z","S","J","L","T","O","I",
            "Z5","S5","P","Q","F","E",
            "T5","U","V","W","X",
            "J5","L5","R","Y","N","H","I5",
            "I3","C","I2","O1"
        },
    }
)
--Load background files from SOURCE ONLY
for _,v in next,fs.getDirectoryItems('parts/backgrounds')do
    if fs.getRealDirectory('parts/backgrounds/'..v)~=SAVEDIR then
        if v:sub(-3)=='lua'then
            local name=v:sub(1,-5)
            BG.add(name,require('parts.backgrounds.'..name))
        end
    end
end
--Load scene files from SOURCE ONLY
for _,v in next,fs.getDirectoryItems('parts/scenes')do
    if fs.getRealDirectory('parts/scenes/'..v)~=SAVEDIR then
        local sceneName=v:sub(1,-5)
        SCN.add(sceneName,require('parts.scenes.'..sceneName))
        LANG.addScene(sceneName)
    end
end
--Load mode files
for i=1,#MODES do
    local m=MODES[i]--Mode template
    local M=require('parts.modes.'..m.name)--Mode file
    for k,v in next,m do M[k]=v end
    MODES[m.name],MODES[i]=M
end

--Update data
do
    local needSave

    if not fs.getInfo('conf/data')then
        FIRSTLAUNCH=true
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
        needSave=true
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
    if RANKS.stack_20l then
        RANKS.stack_20l=nil
        RANKS.stack_40l=nil
        RANKS.stack_100l=nil
        fs.remove('record/stack_20l.rec')
        fs.remove('record/stack_40l.rec')
        fs.remove('record/stack_100l.rec')
    end
    if STAT.version~=VERSION.code then
        STAT.version=VERSION.code
        needSave=true
        love.event.quit('restart')
    end
    SETTING.appLock=nil
    SETTING.dataSaving=nil
    if not SETTING.VKSkin then
        SETTING.VKSkin=1
    end
    for _,v in next,SETTING.skin do if v<1 or v>17 then v=17 end end
    if
        SETTING.RS=='ZRS'or SETTING.RS=='BRS'or
        SETTING.RS=='ASCplus'or SETTING.RS=='C2sym'
    then SETTING.RS='TRS'end
    if SETTING.ghostType=='greyCell'then
        SETTING.ghostType='grayCell'
    end
    if type(SETTING.skinSet)=='number'then
        SETTING.skinSet='crystal_scf'
    end
    if not TABLE.find({8,10,13,17,22,29,37,47,62,80,100},SETTING.frameMul)then
        SETTING.frameMul=100
    end

    for _,v in next,VK_org do v.color=nil end
    if RANKS.infinite then
        RANKS.infinite=0
    end
    if RANKS.infinite_dig then
        RANKS.infinite_dig=0
    end
    if not RANKS.sprint_10l then
        RANKS.sprint_10l=0
    end
    if RANKS.master_l then
        RANKS.master_n,RANKS.master_l=RANKS.master_l needSave=true
    end
    if RANKS.master_u then
        RANKS.master_h,RANKS.master_u=RANKS.master_u needSave=true
    end
    for k in next,RANKS do
        if type(k)=='number'then
            RANKS[k]=nil
            needSave=true
        end
    end
    for k,v in next,oldModeNameTable do
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

    if needSave then
        saveStats()
        saveProgress()
        saveSettings()
    end
end

--First start for phones
if FIRSTLAUNCH and MOBILE then
    SETTING.VKSwitch=true
    SETTING.swap=false
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
        mode,   fileData=STRING.readLine(fileData)mode=oldModeNameTable[mode]or mode
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
