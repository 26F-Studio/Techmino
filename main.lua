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

--Load modules
require"Zframework"

require"parts/list"
require"parts/globalTables"
require"parts/gametoolfunc"

SCR.setSize(1280,720)--Initialize Screen size
FIELD[1]=newBoard()--Initialize field[1]

BLOCKS=		require"parts/mino"
AIBUILDER=	require"parts/AITemplate"
FREEROW=	require"parts/freeRow"

TEXTURE=require"parts/texture"
SKIN=	require"parts/skin"
PLY=	require"parts/player"
AIFUNC=	require"parts/ai"
MODES=	require"parts/modes"
TICK=	require"parts/tick"

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
	"normal(mrz)",
	"smooth(mrz)",
	"contrast(mrz)",
	"glow(mrz)",
	"plastic(mrz)",
	"jelly(miya)",
	"steel(kulumi)",
	"pure(mrz)",
	"ball(shaw)",
	"paper(mrz)",
	"gem(notypey)",
	"classic(_)",
	"brick(notypey)",
	"brick_light(notypey)",
	"cartoon_cup(earety)",
	"crack(earety)",
	"retro(notypey)",
	"retro_grey(notypey)",
	"text_bone(mrz)",
	"colored_bone(mrz)",
	"white_bone(mrz)",
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
	"sugar fairy",--classic2

	"distortion",--master-3
	"far",--GM
	"shining terminal",--attacker
	"storm",--defender, survivor-4/5
	"down",--dig, tech-hard/lunatic

	"rockblock",--classic, 49/99
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
	--Add new language file to LANG folder. Attention, new language won't show in-game when you add language
}
LANG.setPublicText{
	block={
		"Z","S","J","L","T","O","I",
		"Z5","S5","Q","P","F","E",
		"T5","U","V","W","X",
		"J5","L5","R","Y","N","H","I5"
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

--Collect files
if fs.getInfo("data.dat")then
	for k,v in next,{
		["settings.dat"]="conf/settings",
		["unlock.dat"]="conf/unlock",
		["data.dat"]="conf/data",
		["key.dat"]="conf/key",
		["virtualkey.dat"]="conf/virtualkey",
		["account.dat"]="conf/user",
	}do
		fs.write(v,fs.read(k))
		fs.remove(k)
	end
	for _,name in next,fs.getDirectoryItems("")do
		if name:sub(-4)==".dat"then
			fs.write("record/"..name:sub(1,-4).."rec",fs.read(name))
			fs.remove(name)
		end
	end
end

--Load files
if fs.getInfo("conf/settings")then
	addToTable(FILE.load("conf/settings"),SETTING)
else
	if MOBILE then
		SETTING.VKSwitch=true
		SETTING.swap=false
		SETTING.vib=2
		SETTING.powerInfo=true
		SETTING.fullscreen=true
		love.window.setFullscreen(true)
		love.resize(love.graphics.getWidth(),love.graphics.getHeight())
	end
end
if SETTING.fullscreen then love.window.setFullscreen(true)end
LANG.set(SETTING.lang)

if fs.getInfo("conf/unlock")then RANKS=FILE.load("conf/unlock")end
if fs.getInfo("conf/data")then STAT=FILE.load("conf/data")end
if fs.getInfo("conf/key")then keyMap=FILE.load("conf/key")end
if fs.getInfo("conf/virtualkey")then VK_org=FILE.load("conf/virtualkey")end
if fs.getInfo("conf/user")then USER=FILE.load("conf/user")end
if fs.getInfo("conf/replay")then REPLAY=FILE.load("conf/replay")end

for _,v in next,{
	"tech_ultimate.dat",
	"tech_ultimate+.dat",
	"sprintFix.dat",
	"sprintLock.dat",
	"marathon_ultimate.dat",
	"infinite.dat",
	"infinite_dig.dat",
}do
	if fs.getInfo(v)then fs.remove(v)end
end

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
		fs.remove("settings.dat")
	end

	if fs.getInfo("cold_clear.dll")then
		NOGAME=true
		fs.remove("cold_clear.dll")
		fs.remove("CCloader.dll")
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
		newVersionLaunch=true

		--Try unlock modes which should be unlocked
		for name,rank in next,RANKS do
			if rank and rank>0 then
				for _,mode in next,MODES do
					if mode.name==name and mode.unlock then
						for _,unlockName in next,mode.unlock do
							if not RANKS[unlockName]then
								RANKS[unlockName]=0
							end
						end
					end
				end
			end
		end

		S.version=VERSION_CODE
		FILE.save(RANKS,"conf/unlock","q")
		FILE.save(STAT,"conf/data")
	end
end