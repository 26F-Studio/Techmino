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

--Initialize sound libs
SFX.set{
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
BGM.set{
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
VOC.set{
	"zspin","sspin","lspin","jspin","tspin","ospin","ispin",
	"single","double","triple","techrash",
	"mini","b2b","b3b",
	"perfect_clear","half_clear",
	"win","lose","bye",
	"test","happy","doubt","sad","egg",
	"welcome_voc",
}

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
		require("parts/scenes/"..v:sub(1,-5))
	else
		LOG.print("Dangerous file : %SAVE%/parts/scenes/"..v)
	end
end

--Load files
if fs.getInfo("settings.dat")then
	SETTING=FILE.load("settings")
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

if fs.getInfo("unlock.dat")then RANKS=FILE.load("unlock")end
if fs.getInfo("data.dat")then STAT=FILE.load("data")end
if fs.getInfo("key.dat")then keyMap=FILE.load("key")end
if fs.getInfo("virtualkey.dat")then VK_org=FILE.load("virtualkey")end

if fs.getInfo("tech_ultimate.dat")then fs.remove("tech_ultimate.dat")end
if fs.getInfo("tech_ultimate+.dat")then fs.remove("tech_ultimate+.dat")end

--Update data
do
	--Check Ranks
	local R=RANKS
	R.sprint_10=R.sprint_10 or 0
	if R.infinite and R.infinite~=6 then
		R.infinite=6
		R.infinite_dig=6
		fs.remove("infinite.dat")
		fs.remove("infinite_dig.dat")
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
		S.bgm>1 or S.sfx>1 or S.voc>1 or
		S.stereo>1 or S.VKSFX>1 or S.VKAlpha>1
	then
		NOGAME="delSetting"
		fs.remove("settings.dat")
	end

	--Update data file
	S=STAT
	if S.extraRate then
		S.finesseRate=5*(S.piece-S.extraRate)
	end
	if S.version~=VERSION_CODE then
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
		FILE.save(RANKS,"unlock","")
		FILE.save(STAT,"data","")
	end
	if MOBILE and not SETTING.fullscreen then
		LOG.print("如果手机上方状态栏不消失,请到设置界面开启全屏",300,COLOR.yellow)
		LOG.print("Switch fullscreen on if titleBar don't disappear",300,COLOR.yellow)
	end
end