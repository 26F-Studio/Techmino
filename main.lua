--[[
	  ______             __                _
	 /_  __/___   _____ / /_   ____ ___   (_)____   ____
	  / /  / _ \ / ___// __ \ / __ `__ \ / // __ \ / __ \
	 / /  /  __// /__ / / / // / / / / // // / / // /_/ /
	/_/   \___/ \___//_/ /_//_/ /_/ /_//_//_/ /_/ \____/
	Techmino is my first "huge project"
	optimization is welcomed if you also love tetromino game
]]--


--Var leak check
-- setmetatable(_G,{__newindex=function(self,k,v)print('>>'..k)print(debug.traceback():match("\n.-\n\t(.-): "))rawset(self,k,v)end})

--Declaration
goto REM love=require"love"::REM::--Just tell IDE to load love-api, no actual usage
local fs=love.filesystem
TIME=love.timer.getTime
YIELD=coroutine.yield
SYSTEM=love.system.getOS()
MOBILE=SYSTEM=="Android"or SYSTEM=="iOS"
SAVEDIR=fs.getSaveDirectory()

--Global Vars & Settings
DAILYLAUNCH=false

--System setting
math.randomseed(os.time()*626)
love.setDeprecationOutput(false)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.mouse.setVisible(false)

--Delete all files from too old version
function CLEAR(root)
	for _,name in next,fs.getDirectoryItems(root or"")do
		if fs.getRealDirectory(name)==SAVEDIR and fs.getInfo(name).type~='directory'then
			fs.remove(name)
		end
	end
end CLEAR()

--Create directories
for _,v in next,{"conf","record","replay","cache","lib"}do
	local info=fs.getInfo(v)
	if not info then
		fs.createDirectory(v)
	elseif info.type~='directory'then
		fs.remove(v)
		fs.createDirectory(v)
	end
end

--Load modules
require"Zframework"
SCR.setSize(1280,720)--Initialize Screen size

require"parts.list"
require"parts.globalTables"
require"parts.gametoolfunc"

--Load shader files from SOURCE ONLY
SHADER={}
for _,v in next,fs.getDirectoryItems("parts/shaders")do
	if fs.getRealDirectory("parts/shaders/"..v)~=SAVEDIR then
		local name=v:sub(1,-6)
		SHADER[name]=love.graphics.newShader("parts/shaders/"..name..".glsl")
	end
end

FREEROW=	require"parts.freeRow"
DATA=		require"parts.data"

TEXTURE=	require"parts.texture"
SKIN=		require"parts.skin"
USERS=		require"parts.users"
NET=		require"parts.net"
VK=			require"parts.virtualKey"
PLY=		require"parts.player"
netPLY=		require"parts.netPlayer"
AIFUNC=		require"parts.ai"
AIBUILDER=	require"parts.AITemplate"
MODES=		require"parts.modes"

--Initialize field[1]
FIELD[1]=DATA.newBoard()

--First start for phones
if not fs.getInfo("conf/settings")and MOBILE then
	SETTING.VKSwitch=true
	SETTING.swap=false
	SETTING.powerInfo=true
	SETTING.cleanCanvas=true
end
if SETTING.fullscreen then love.window.setFullscreen(true)end

--Initialize image libs
IMG.init{
	batteryImage="mess/power.png",
	lock="mess/lock.png",
	dialCircle="mess/dialCircle.png",
	dialNeedle="mess/dialNeedle.png",
	lifeIcon="mess/life.png",
	badgeIcon="mess/badge.png",
	spinCenter="mess/spinCenter.png",
	ctrlSpeedLimit="mess/ctrlSpeedLimit.png",
	speedLimit="mess/speedLimit.png",
	pay1="mess/pay1.png",
	pay2="mess/pay2.png",

	nakiCH="characters/naki.png",
	miyaCH="characters/miya.png",
	miyaF1="characters/miya_f1.png",
	miyaF2="characters/miya_f2.png",
	miyaF3="characters/miya_f3.png",
	miyaF4="characters/miya_f4.png",
	electric="characters/electric.png",
	hbm="characters/hbm.png",

	lanterns={
		"lanterns/1.png",
		"lanterns/2.png",
		"lanterns/3.png",
		"lanterns/4.png",
		"lanterns/5.png",
		"lanterns/6.png",
	},
}
SKIN.init{
	"crystal_scf",
	"matte_mrz",
	"contrast_mrz",
	"polkadots_scf",
	"toy_scf",
	"smooth_mrz",
	"simple_scf",
	"glass_scf",
	"penta_scf",
	"bubble_scf",
	"minoes_scf",
	"pure_mrz",
	"bright_scf",
	"glow_mrz",
	"plastic_mrz",
	"paper_mrz",
	"yinyang_scf",
	"cartooncup_earety",
	"jelly_miya",
	"brick_notypey",
	"gem_notypey",
	"classic",
	"ball_shaw",
	"retro_notypey",
	"textbone_mrz",
	"coloredbone_mrz",
	"wtf",
}

--Initialize sound libs
SFX.init((function()
	local L={}
	for _,v in next,fs.getDirectoryItems("media/SFX")do
		if fs.getRealDirectory("media/SFX/"..v)~=SAVEDIR then
			L[#L+1]=v:sub(1,-5)
		else
			LOG.print("Dangerous file : %SAVE%/media/SFX/"..v)
		end
	end
	return L
end)())
BGM.init((function()
	local L={}
	for _,v in next,fs.getDirectoryItems("media/BGM")do
		if fs.getRealDirectory("media/BGM/"..v)~=SAVEDIR then
			L[#L+1]=v:sub(1,-5)
		else
			LOG.print("Dangerous file : %SAVE%/media/BGM/"..v)
		end
	end
	return L
end)())
VOC.init{
	"zspin","sspin","lspin","jspin","tspin","ospin","ispin",
	"single","double","triple","techrash",
	"mini","b2b","b3b",
	"perfect_clear","half_clear",
	"win","lose","bye",
	"test","happy","doubt","sad","egg",
	"welcome_voc",
}

--Initialize language lib
LANG.init(
	{
		require"parts.language.lang_zh",
		require"parts.language.lang_zh2",
		require"parts.language.lang_yygq",
		require"parts.language.lang_en",
		require"parts.language.lang_fr",
		require"parts.language.lang_sp",
		require"parts.language.lang_pt",
		require"parts.language.lang_symbol",
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
for _,v in next,fs.getDirectoryItems("parts/backgrounds")do
	if fs.getRealDirectory("parts/backgrounds/"..v)~=SAVEDIR then
		if v:sub(-3)=="lua"then
			local name=v:sub(1,-5)
			BG.add(name,require("parts.backgrounds."..name))
		end
	end
end

--Load scene files from SOURCE ONLY
for _,v in next,fs.getDirectoryItems("parts/scenes")do
	if fs.getRealDirectory("parts/scenes/"..v)~=SAVEDIR then
		local sceneName=v:sub(1,-5)
		SCN.add(sceneName,require("parts.scenes."..sceneName))
		LANG.addScene(sceneName)
	end
end
LANG.set(SETTING.lang)

--Update data
do
	local needSave
	local autoRestart

	if type(STAT.version)~='number'then
		STAT.version=0
		needSave=true
	end
	if STAT.version<1300 then
		STAT.frame=math.floor(STAT.time*60)
		STAT.lastPlay='sprint_10l'
		RANKS.sprintFix=nil
		RANKS.sprintLock=nil
		needSave=true
		for _,name in next,fs.getDirectoryItems("replay")do
			fs.remove("replay/"..name)
		end
	end
	if STAT.version<1302 then
		if RANKS.pctrain_n then RANKS.pctrain_n=0 end
		if RANKS.pctrain_l then RANKS.pctrain_l=0 end
		fs.remove("conf/settings")
		needSave=true
		autoRestart=true
	end
	if STAT.version<1400 then
		fs.remove("conf/user")
		fs.remove("conf/key")
		needSave=true
		autoRestart=true
	end
	if STAT.version<1405 then
		fs.remove("conf/user")
		autoRestart=true
	end
	SETTING.appLock=nil

	for _,v in next,VK_org do
		if not v.color then
			fs.remove("conf/virtualkey")
			autoRestart=true
			break
		end
	end

	if STAT.version~=VERSION.code then
		newVersionLaunch=true
		STAT.version=VERSION.code
		CLEAR("lib")
		needSave=true
		autoRestart=true
	end

	if RANKS.GM then RANKS.GM=0 end
	if RANKS.infinite then RANKS.infinite=6 end
	if RANKS.infinite_dig then RANKS.infinite_dig=6 end
	for k in next,RANKS do
		if type(k)=='number'then
			RANKS[k]=nil
			needSave=true
		end
	end
	local modeTable={attacker_h="attacker_hard",attacker_u="attacker_ultimate",blind_e="blind_easy",blind_h="blind_hard",blind_l="blind_lunatic",blind_n="blind_normal",blind_u="blind_ultimate",c4wtrain_l="c4wtrain_lunatic",c4wtrain_n="c4wtrain_normal",defender_l="defender_lunatic",defender_n="defender_normal",dig_100l="dig_100",dig_10l="dig_10",dig_400l="dig_400",dig_40l="dig_40",dig_h="dig_hard",dig_u="dig_ultimate",drought_l="drought_lunatic",drought_n="drought_normal",marathon_h="marathon_hard",marathon_n="marathon_normal",pc_h="pcchallenge_hard",pc_l="pcchallenge_lunatic",pc_n="pcchallenge_normal",pctrain_l="pctrain_lunatic",pctrain_n="pctrain_normal",round_e="round_1",round_h="round_2",round_l="round_3",round_n="round_4",round_u="round_5",solo_e="solo_1",solo_h="solo_2",solo_l="solo_3",solo_n="solo_4",solo_u="solo_5",sprint_10l="sprint_10",sprint_20l="sprint_20",sprint_40l="sprint_40",sprint_400l="sprint_400",sprint_100l="sprint_100",sprint_1000l="sprint_1000",survivor_e="survivor_easy",survivor_h="survivor_hard",survivor_l="survivor_lunatic",survivor_n="survivor_normal",survivor_u="survivor_ultimate",tech_finesse_f="tech_finesse2",tech_h_plus="tech_hard2",tech_h="tech_hard",tech_l_plus="tech_lunatic2",tech_l="tech_lunatic",tech_n_plus="tech_normal2",tech_n="tech_normal",techmino49_e="techmino49_easy",techmino49_h="techmino49_hard",techmino49_u="techmino49_ultimate",techmino99_e="techmino99_easy",techmino99_h="techmino99_hard",techmino99_u="techmino99_ultimate",tsd_e="tsd_easy",tsd_h="tsd_hard",tsd_u="tsd_ultimate",master_extra="GM"}
	for k,v in next,modeTable do
		if RANKS[v]then
			RANKS[k]=RANKS[v]
			RANKS[v]=nil
		end
		v="record/"..v
		if fs.getInfo(v..".dat")then
			fs.write("record/"..k..".rec",fs.read(v..".dat"))
			fs.remove(v..".dat")
		end
		if fs.getInfo(v..".rec")then
			fs.write("record/"..k..".rec",fs.read(v..".rec"))
			fs.remove(v..".rec")
		end
	end
	if not RANKS.sprint_10l then
		RANKS.sprint_10l=0
		needSave=true
	end

	if needSave then
		FILE.save(SETTING,'conf/settings','q')
		FILE.save(RANKS,'conf/unlock','q')
		FILE.save(STAT,'conf/data','q')
	end
	if autoRestart then
		love.event.quit('restart')
	end
end