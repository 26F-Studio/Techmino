--[[
	  ______             __                _
	 /_  __/___   _____ / /_   ____ ___   (_)____   ____
	  / /  / _ \ / ___// __ \ / __ `__ \ / // __ \ / __ \
	 / /  /  __// /__ / / / // / / / / // // / / // /_/ /
	/_/   \___/ \___//_/ /_//_/ /_/ /_//_//_/ /_/ \____/
	Techmino is my first "huge project"
	optimization is welcomed if you also love tetromino stacking game

	Instructions:
	1. I made a framework called Zframework, most code in Zframework are not directly relevant to game;
	2. "xxx" are texts for reading, 'xxx' are string values just in program;
	3. Some goto statement are used for better performance. All goto-labes have detailed names so don't afraid;
	4. Except "gcinfo" function of lua itself, other "gc" are short for "graphics";
]]--


--Var leak check
-- setmetatable(_G,{__newindex=function(self,k,v)print('>>'..k)print(debug.traceback():match("\n.-\n\t(.-): "))rawset(self,k,v)end})

--Declaration
goto REM love=require"love"::REM::--Just tell IDE to load love-api, no actual usage
local fs=love.filesystem
TIME=love.timer.getTime
YIELD=coroutine.yield
SYSTEM=love.system.getOS()
MOBILE=SYSTEM=='Android'or SYSTEM=='iOS'
SAVEDIR=fs.getSaveDirectory()

--Global Vars & Settings
DAILYLAUNCH=false

--System setting
math.randomseed(os.time()*626)
love.setDeprecationOutput(false)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.mouse.setVisible(false)

--Load modules
require'Zframework'
SCR.setSize(1280,720)--Initialize Screen size

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

FREEROW=	require'parts.freeRow'
DATA=		require'parts.data'

TEXTURE=	require'parts.texture'
SKIN=		require'parts.skin'
USERS=		require'parts.users'
NET=		require'parts.net'
VK=			require'parts.virtualKey'
AIFUNC=		require'parts.ai'
AIBUILDER=	require'parts.AITemplate'
PLY=		require'parts.player'
netPLY=		require'parts.netPlayer'
MODES=		require'parts.modes'

--Initialize field[1]
FIELD[1]=DATA.newBoard()

--First start for phones
if not fs.getInfo('conf/settings')and MOBILE then
	SETTING.VKSwitch=true
	SETTING.swap=false
	SETTING.powerInfo=true
	SETTING.cleanCanvas=true
end
if SETTING.fullscreen then love.window.setFullscreen(true)end

--Initialize image libs
IMG.init{
	lock='mess/lock.png',
	dialCircle='mess/dialCircle.png',
	dialNeedle='mess/dialNeedle.png',
	lifeIcon='mess/life.png',
	badgeIcon='mess/badge.png',
	ctrlSpeedLimit='mess/ctrlSpeedLimit.png',
	speedLimit='mess/speedLimit.png',--Not used, for future C2-mode
	pay1='mess/pay1.png',
	pay2='mess/pay2.png',

	nakiCH='characters/nakiharu.png',
	miyaCH='characters/miya.png',
	miyaF1='characters/miya_f1.png',
	miyaF2='characters/miya_f2.png',
	miyaF3='characters/miya_f3.png',
	miyaF4='characters/miya_f4.png',
	electric='characters/electric.png',
	hbm='characters/hbm.png',

	lanterns={
		'lanterns/1.png',
		'lanterns/2.png',
		'lanterns/3.png',
		'lanterns/4.png',
		'lanterns/5.png',
		'lanterns/6.png',
	},
}
SKIN.init{
	'crystal_scf',
	'matte_mrz',
	'contrast_mrz',
	'polkadots_scf',
	'toy_scf',
	'smooth_mrz',
	'simple_scf',
	'glass_scf',
	'penta_scf',
	'bubble_scf',
	'minoes_scf',
	'pure_mrz',
	'bright_scf',
	'glow_mrz',
	'plastic_mrz',
	'paper_mrz',
	'yinyang_scf',
	'cartooncup_earety',
	'jelly_miya',
	'brick_notypey',
	'gem_notypey',
	'classic',
	'ball_shaw',
	'retro_notypey',
	'textbone_mrz',
	'coloredbone_mrz',
	'wtf',
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
			table.insert(L,v:sub(1,-5))
		else
			MES.new('warn',"Dangerous file : %SAVE%/media/BGM/"..v)
		end
	end
	return L
end)())
VOC.init{
	'zspin','sspin','lspin','jspin','tspin','ospin','ispin',
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
			"Z5","S5","Q","P","F","E",
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

	if type(STAT.version)~='number'then
		STAT.version=0
		needSave=true
	end
	if STAT.version<1302 then
		FILE.clear_s('')
	end
	if STAT.version<1405 then
		fs.remove('conf/user')
		fs.remove('conf/key')
	end
	if STAT.version<1505 then
		fs.remove('record/bigbang.rec')
		fs.remove('conf/replay')
	end
	if STAT.version~=VERSION.code then
		STAT.version=VERSION.code
		needSave=true
		love.event.quit('restart')
	end
	if SETTING.ghostType=='greyCell'then
		SETTING.ghostType='grayCell'
		needSave=true
	end
	if not SETTING.VKSkin then SETTING.VKSkin=1 end
	if not TABLE.find({8,10,13,17,22,29,37,47,62,80,100},SETTING.frameMul)then
		SETTING.frameMul=100
	end
	SETTING.appLock=nil
	SETTING.dataSaving=nil
	for _,v in next,VK_org do v.color=nil end
	if RANKS.infinite then RANKS.infinite=0 end
	if RANKS.infinite_dig then RANKS.infinite_dig=0 end
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
	if not RANKS.sprint_10l then
		RANKS.sprint_10l=0
		needSave=true
	end

	if needSave then
		FILE.save(SETTING,'conf/settings')
		FILE.save(RANKS,'conf/unlock')
		FILE.save(STAT,'conf/data')
	end
end

--Apply system setting
LANG.set(SETTING.lang)
VK.setShape(SETTING.VKSkin)
applyBlockSatur(SETTING.blockSatur)
applyFieldSatur(SETTING.fieldSatur)

--Load replays
for _,fileName in next,fs.getDirectoryItems('replay')do
	if fileName:sub(12,12):match("[a-zA-Z]")then
		local date,mode,version,player,seed,setting,mod
		local fileData=fs.read('replay/'..fileName)
		date,	fileData=STRING.readLine(fileData)date=date:gsub("[a-zA-Z]","")
		mode,	fileData=STRING.readLine(fileData)mode=oldModeNameTable[mode]or mode
		version,fileData=STRING.readLine(fileData)
		player,	fileData=STRING.readLine(fileData)if player=="Local Player"then player="Stacker"end
		local success
		success,fileData=pcall(love.data.decompress,'string','zlib',fileData)
		if not success then goto BREAK_cannotParse end
		seed,	fileData=STRING.readLine(fileData)
		setting,fileData=STRING.readLine(fileData)setting=JSON.decode(setting)
		mod,	fileData=STRING.readLine(fileData)mod=JSON.decode(mod)
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