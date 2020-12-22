--[[
	  ______             __                _
	 /_  __/___   _____ / /_   ____ ___   (_)____   ____
	  / /  / _ \ / ___// __ \ / __ `__ \ / // __ \ / __ \
	 / /  /  __// /__ / / / // / / / / // // / / // /_/ /
	/_/   \___/ \___//_/ /_//_/ /_/ /_//_//_/ /_/ \____/
	Techmino is my first "huge project"
	optimization is welcomed if you also love tetromino game
]]--

local fs=love.filesystem

--?
NONE={}function NULL()end
DBP=print--Use this in permanent code
TIME=love.timer.getTime
SYSTEM=love.system.getOS()
MOBILE=SYSTEM=="Android"or SYSTEM=="iOS"
SAVEDIR=fs.getSaveDirectory()

--Global Vars & Settings
MARKING=true
LOADED=false
NOGAME=false
LOGIN=false
EDITING=""
WSCONN=nil

math.randomseed(os.time()*626)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.mouse.setVisible(false)

--Create directories
for _,v in next,{"conf","record","replay"}do
	local info=fs.getInfo(v)
	if info then
		if info.type=="directory"then goto NEXT end
		fs.remove(v)
	end
	fs.createDirectory(v)
	::NEXT::
end

--Delete useless files
for _,v in next,{
	"cold_clear.dll",
	"CCloader.dll",
	"tech_ultimate.dat",
	"tech_ultimate+.dat",
	"sprintFix.dat",
	"sprintLock.dat",
	"marathon_ultimate.dat",
	"infinite.dat",
	"infinite_dig.dat",
	"conf/account",
}do
	if fs.getInfo(v)then fs.remove(v)end
end

--Collect files of old version
if fs.getInfo("data.dat")or fs.getInfo("key.dat")or fs.getInfo("settings.dat")then
	for k,v in next,{
		["settings.dat"]="conf/settings",
		["unlock.dat"]="conf/unlock",
		["data.dat"]="conf/data",
		["key.dat"]="conf/key",
		["virtualkey.dat"]="conf/virtualkey",
		["account.dat"]="conf/user",
	}do
		if fs.getInfo(k)then
			fs.write(v,fs.read(k))
			fs.remove(k)
		end
	end
	for _,name in next,fs.getDirectoryItems("")do
		if name:sub(-4)==".dat"then
			fs.write("record/"..name:sub(1,-4).."rec",fs.read(name))
			fs.remove(name)
		end
	end
end

--Load modules
require"Zframework"

require"parts/list"
require"parts/globalTables"
require"parts/gametoolfunc"
SCR.setSize(1280,720)--Initialize Screen size
FIELD[1]=newBoard()--Initialize field[1]

AIBUILDER=	require"parts/AITemplate"
FREEROW=	require"parts/freeRow"

TEXTURE=require"parts/texture"
SKIN=	require"parts/skin"
PLY=	require"parts/player"
AIFUNC=	require"parts/ai"
MODES=	require"parts/modes"
TICK=	require"parts/tick"

--First start for phones
if not fs.getInfo("conf/settings")and MOBILE then
	SETTING.VKSwitch=true
	SETTING.swap=false
	SETTING.vib=2
	SETTING.powerInfo=true
	SETTING.fullscreen=true
end
if SETTING.fullscreen then love.window.setFullscreen(true)end

--Initialize image libs
IMG.init{
	batteryImage="/mess/power.png",
	title="mess/title.png",
	title_color="mess/title_colored.png",
	dialCircle="mess/dialCircle.png",
	dialNeedle="mess/dialNeedle.png",
	lifeIcon="mess/life.png",
	badgeIcon="mess/badge.png",
	spinCenter="mess/spinCenter.png",
	ctrlSpeedLimit="mess/ctrlSpeedLimit.png",
	speedLimit="mess/speedLimit.png",
	pay1="mess/pay1.png",
	pay2="mess/pay2.png",

	miyaCH="miya/ch.png",
	miyaF1="miya/f1.png",
	miyaF2="miya/f2.png",
	miyaF3="miya/f3.png",
	miyaF4="miya/f4.png",

	electric="mess/electric.png",
	hbm="mess/hbm.png",
}
SKIN.init{
	"Normal(MrZ)",
	"Contrast(MrZ)",
	"PolkaDots(ScF)",
	"Smooth(MrZ)",
	"Glass(ScF)",
	"Penta(ScF)",
	"Pure(MrZ)",
	"Glow(MrZ)",
	"Plastic(MrZ)",
	"Paper(MrZ)",
	"CartoonCup(Earety)",
	"Jelly(Miya)",
	"Brick(Notypey)",
	"Gem(Notypey)",
	"Classic",
	"Ball(Shaw)",
	"Retro(Notypey)",
	"TextBone(MrZ)",
	"ColoredBone(MrZ)",
	"WTF",
}
--Initialize sound libs
SFX.init{
	--Stereo sfxs(cannot set position)
	"welcome_sfx",
	"click","enter",
	"finesseError","finesseError_long",

	--Mono sfxs
	"virtualKey",
	"button","swipe",
	"ready","start","win","fail","collect",
	"spawn_1","spawn_2","spawn_3","spawn_4","spawn_5","spawn_6","spawn_7",
	"move","rotate","rotatekick","hold",
	"prerotate","prehold",
	"lock","drop","fall",
	"reach",
	"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11","ren_mega",
	"clear_1","clear_2","clear_3","clear_4",
	"spin_0","spin_1","spin_2","spin_3",
	"emit","blip_1","blip_2",
	"clear",
	"error",
}
BGM.init{
	"blank",--menu
	"race",--sprint, solo
	"infinite",--infinite norm/dig, ultra, zen, tech-finesse
	"push",--marathon, round, tsd, blind-5/6
	"way",--dig sprint
	"reason",--drought, blind-1/2/3/4

	"secret8th",--master-1, survivor-2
	"secret7th",--master-2, survivor-3
	"waterfall",--sprint Penta/MPH
	"new era",--bigbang, survivor-1, tech-normal
	"oxygen",--c4w/pc train
	"truth",--pc challenge

	"distortion",--master-3
	"far",--GM
	"shining terminal",--attacker
	"storm",--defender, survivor-4/5
	"down",--dig, tech-hard/lunatic

	"sugar fairy","rockblock","magicblock",--classic, 49/99
	"cruelty","final","8-bit happiness","end","how feeling",--49/99
}
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
LANG.setLangList{
	require"parts/language/lang_zh",
	require"parts/language/lang_zh2",
	require"parts/language/lang_en",
	require"parts/language/lang_fr",
	require"parts/language/lang_sp",
	require"parts/language/lang_symbol",
	require"parts/language/lang_yygq",
	--1. Add language file to LANG folder;
	--2. Require it;
	--3. Add a button in parts/scenes/setting_lang.lua;
	--4. Set button name at LANG.setPublicWidgetText.lang beneath.
}
LANG.setPublicText{
	block={
		"Z","S","J","L","T","O","I",
		"Z5","S5","Q","P","F","E",
		"T5","U","V","W","X",
		"J5","L5","R","Y","N","H","I5",
		"I3","C","I2","O1"
	},
}
LANG.setPublicWidgetText{
	calculator={
		_1="1",_2="2",_3="3",
		_4="4",_5="5",_6="6",
		_7="7",_8="8",_9="9",
		_0="0",["."]=".",e="e",
		["+"]="+",["-"]="-",["*"]="*",["/"]="/",
		["<"]="<",["="]="=",
		play="-->",
	},
	setting_skin={
		prev="←",next="→",
		prev1="↑",next1="↓",
		prev2="↑",next2="↓",
		prev3="↑",next3="↓",
		prev4="↑",next4="↓",
		prev5="↑",next5="↓",
		prev6="↑",next6="↓",
		prev7="↑",next7="↓",
	},
	custom_field={
		b0="",b1="",b2="",b3="",b4="",b5="",b6="",b7="",
		b8="",b9="",b10="",b11="",b12="",b13="",b14="",b15="",b16="",
		b17="[  ]",b18="N",b19="B",b20="_",b21="_",b22="_",b23="_",b24="_",
	},
	lang={
		zh="中文",
		zh2="全中文",
		en="English",
		fr="Français",
		sp="Español",
		symbol="?????",
		yygq="就这?",
	},
	staff={},
	history={
		prev="↑",
		next="↓",
	},
	mg_cubefield={},
}
LANG.init()

--Load shader files from SOURCE ONLY
SHADER={}
for _,v in next,love.filesystem.getDirectoryItems("parts/shaders")do
	if love.filesystem.getRealDirectory("parts/shaders/"..v)~=SAVEDIR then
		local name=v:sub(1,-6)
		SHADER[name]=love.graphics.newShader("parts/shaders/"..name..".glsl")
	else
		LOG.print("Dangerous file : %SAVE%/parts/shaders/"..v)
	end
end

--Load background files from SOURCE ONLY
for _,v in next,love.filesystem.getDirectoryItems("parts/backgrounds")do
	if love.filesystem.getRealDirectory("parts/backgrounds/"..v)~=SAVEDIR then
		local name=v:sub(1,-5)
		BG.add(name,require("parts/backgrounds/"..name))
	else
		LOG.print("Dangerous file : %SAVE%/parts/backgrounds/"..v)
	end
end

--Load scene files from SOURCE ONLY
for _,v in next,fs.getDirectoryItems("parts/scenes")do
	if fs.getRealDirectory("parts/scenes/"..v)~=SAVEDIR then
		local sceneName=v:sub(1,-5)
		SCN.add(sceneName,require("parts/scenes/"..sceneName))
	else
		LOG.print("Dangerous file : %SAVE%/parts/scenes/"..v)
	end
end

LANG.set(SETTING.lang)

--Update data
do
	--Check Ranks
	local R=RANKS
	R.sprint_10=R.sprint_10 or 0
	if R.infinite and R.infinite~=6 then
		R.infinite=6
		R.infinite_dig=6
	end
	if not text.modes[STAT.lastPlay]then
		STAT.lastPlay="sprint_10"
	end

	--Check setting file
	local S=SETTING
	if
		type(S.block)~="boolean"or
		type(S.spawn)~="number"or
		type(S.ghost)~="number"or
		type(S.center)~="number"or
		type(S.grid)~="number"or
		S.bgm>1 or S.sfx>1 or S.voc>1 or
		S.stereo>1 or S.VKSFX>1 or S.VKAlpha>1
	then
		NOGAME=true
		fs.remove("conf/settings")
	end

	--Update data file
	S=STAT
	freshDate()
	if S.extraRate then
		S.finesseRate=5*(S.piece-S.extraRate)
	end
	if S.version~=VERSION_CODE then
		if type(S.version)~="number"then
			S.version=0
		end
		if S.version<1204 then
			STAT.frame=math.floor(STAT.time*60)
			STAT.lastPlay="sprint_10"
			RANKS.sprintFix=nil
			RANKS.sprintLock=nil
		end
		if S.version<1205 then
			SETTING.VKCurW=SETTING.VKCurW*.1
			SETTING.VKTchW=SETTING.VKTchW*.1
		end
		if S.version<1208 then
			SETTING.skinSet=1
		end
		newVersionLaunch=true

		S.version=VERSION_CODE
		FILE.save(RANKS,"conf/unlock","q")
		FILE.save(STAT,"conf/data")
	end
end