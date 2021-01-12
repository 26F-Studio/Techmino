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
WSCONN=false
FESTIVAL=
	os.date"%m"=="12"and math.abs(os.date"%d"-25)<4 and"Xmas"or
	os.date"%m"<"03"and math.abs(({--Spring festival dates, 1.2=2, 2.1=32, etc.
		24,43,32,22,40,29,49,38,26,45,
		34,23,41,31,50,39,28,47,36,25,
		43,32,22,41,29,48,37,26,44,34,
		23,42,31,50,39,28,46,35,24,43,
		32,22,41,30,48,37,26,45,33,23,
		42,32,50,39,28,46,35,24,43,33,
		21,40,
	})[0+os.date"%y"]-((os.date"%m"=="01"and 0 or 31)+os.date"%d"))<8 and"sprFes"

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

--First start for phones
if not fs.getInfo("conf/settings")and MOBILE then
	SETTING.VKSwitch=true
	SETTING.swap=false
	SETTING.powerInfo=true
	SETTING.fullscreen=true
end
if SETTING.fullscreen then love.window.setFullscreen(true)end

--Initialize image libs
IMG.init{
	batteryImage="mess/power.png",
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
	"Crystal(ScF)",
	"Contrast(MrZ)",
	"PolkaDots(ScF)",
	"Toy(ScF)",
	"Smooth(MrZ)",
	"Simple(ScF)",
	"Glass(ScF)",
	"Penta(ScF)",
	"Bubble(ScF)",
	"Shape(ScF)",
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
SFX.init((function()
	local L={}
	for _,v in next,love.filesystem.getDirectoryItems("media/SFX")do
		if love.filesystem.getRealDirectory("media/SFX/"..v)~=SAVEDIR then
			L[#L+1]=v:sub(1,-5)
		else
			LOG.print("Dangerous file : %SAVE%/media/SFX/"..v)
		end
	end
	return L
end)())
BGM.init((function()
	local L={}
	for _,v in next,love.filesystem.getDirectoryItems("media/BGM")do
		if love.filesystem.getRealDirectory("media/BGM/"..v)~=SAVEDIR then
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
LANG.setLangList{
	require"parts/language/lang_zh",
	require"parts/language/lang_zh2",
	require"parts/language/lang_en",
	require"parts/language/lang_fr",
	require"parts/language/lang_sp",
	require"parts/language/lang_pt",
	require"parts/language/lang_symbol",
	require"parts/language/lang_yygq",
	--1. Add language file to LANG folder;
	--2. Require it;
	--3. Add a button in parts/scenes/setting_lang.lua;
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
		if v:sub(-3)=="lua"then
			local name=v:sub(1,-5)
			BG.add(name,require("parts/backgrounds/"..name))
		end
	else
		LOG.print("Dangerous file : %SAVE%/parts/backgrounds/"..v)
	end
end

--Load scene files from SOURCE ONLY
for _,v in next,fs.getDirectoryItems("parts/scenes")do
	if fs.getRealDirectory("parts/scenes/"..v)~=SAVEDIR then
		local sceneName=v:sub(1,-5)
		SCN.add(sceneName,require("parts/scenes/"..sceneName))
		LANG.addScene(sceneName)
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
		if S.version<1225 then
			SETTING.skin={1,7,11,3,14,4,9,1,7,2,6,10,2,13,5,9,15,10,11,3,12,2,16,8,4,10,13,2,8}
		end
		newVersionLaunch=true

		S.version=VERSION_CODE
		FILE.save(STAT,"conf/data")
	end
end

if FESTIVAL=="Xmas"then
	BG.setDefault("snow")
	BGM.setDefault("mXmas")
elseif FESTIVAL=="sprFes"then
	BG.setDefault("firework")
	BGM.setDefault("spring festival")
else
	BG.setDefault("space")
	BGM.setDefault("blank")
end