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
DBP=print--use this if need debugging print
SYSTEM=love.system.getOS()
MOBILE=SYSTEM=="Android"or SYSTEM=="iOS"
SAVEDIR=fs.getSaveDirectory()

MARKING=true
LOADED=false
NOGAME=false
LOGIN=false
EDITING=""

--Global Setting & Vars
math.randomseed(os.time()*626)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.mouse.setVisible(false)

SCR={
	w0=1280,h0=720,--Default Screen Size
	x=0,y=0,--Up-left Coord on screen
	w=0,h=0,--Fullscreen w/h in gc
	W=0,H=0,--Fullscreen w/h in shader
	rad=0,--Radius
	k=1,--Scale size
	dpi=1,--DPI from gc.getDPIScale()
	xOy=love.math.newTransform(),--Screen transformation object
}

CUSTOMENV={
	--Basic
	drop=60,
	lock=60,
	wait=0,
	fall=0,

	next=6,
	hold=true,
	oncehold=true,

	--Visual
	block=true,
	ghost=.3,
	center=1,
	bagLine=false,
	highCam=false,
	nextPos=false,
	bone=false,

	--Rule
	mindas=0,
	minarr=0,
	minsdarr=0,
	sequence="bag",
	ospin=false,
	noTele=false,
	fineKill=false,
	missionKill=false,
	easyFresh=true,
	visible="show",
	target=1e99,
	freshLimit=1e99,
	opponent=0,
	life=0,
	pushSpeed=3,

	--Else
	bg="none",
	bgm="race"
}
FIELD={}--Field(s) for custom game
BAG={}--Sequence for custom game
MISSION={}--Clearing mission for custom game

GAME={
	frame=0,			--Frame count
	result=false,		--Game result (string)
	pauseTime=0,		--Time paused
	pauseCount=0,		--Pausing count
	garbageSpeed=1,		--Garbage timing speed
	warnLVL0=0,			--Warning level
	warnLVL=0,			--Warning level (show)
	recording=false,	--If recording
	replaying=false,	--If replaying
	seed=math.random(2e6),--Game seed
	setting={},			--Game settings
	rec={},				--Recording list, key,time,key,time...
	rank=nil,			--Rank reached

	prevBG=nil,			--Previous background, for restore BG when quit setting page

	--Data for royale mode
	stage=nil,			--Game stage
	mostBadge=nil,		--Most badge owner
	secBadge=nil,		--Second badge owner
	mostDangerous=nil,	--Most dangerous player
	secDangerous=nil,	--Second dangerous player
}--Global game data
PLAYERS={alive={}}--Players data
CURMODE=nil--Current mode object
RANKS={sprint_10=0}


--Load modules
require("Zframework")

require("parts/list")
require("parts/default_data")
require("parts/gametoolfunc")

FIELD[1]=newBoard()--Initialize field[1]

BLOCKS=		require("parts/mino")
AIBUILDER=	require("parts/AITemplate")
FREEROW=	require("parts/freeRow")

TEXTURE=require("parts/texture")
SKIN=	require("parts/skin")
PLY=	require("parts/player")
AIFUNC=	require("parts/ai")
MODES=	require("parts/modes")
TICK=	require("parts/tick")

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

--Load files & settings
if fs.getInfo("settings.dat")then
	FILE.loadSetting()
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
LANG.set(SETTING.lang)
if SETTING.fullscreen then love.window.setFullscreen(true)end

if fs.getInfo("unlock.dat")then FILE.loadUnlock()end
if fs.getInfo("data.dat")then FILE.loadData()end
if fs.getInfo("key.dat")then FILE.loadKeyMap()end
if fs.getInfo("virtualkey.dat")then FILE.loadVK()end

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
	if S.version~=VERSION then
		S.version=VERSION
		newVersionLaunch=true

		local function delRecord(n)
			if R[n]then
				R[n]=0
				fs.remove(n..".dat")
			end
		end
		delRecord("solo_1")delRecord("solo_2")delRecord("solo_3")delRecord("solo_4")delRecord("solo_5")
		delRecord("dig_10")delRecord("dig_40")delRecord("dig_100")delRecord("dig_400")
		delRecord("classic_fast")

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
		FILE.saveUnlock()
		FILE.saveData()
	end
	if MOBILE and not SETTING.fullscreen then
		LOG.print("如果手机上方状态栏不消失,请到设置界面开启全屏",300,COLOR.yellow)
		LOG.print("Switch fullscreen on if titleBar don't disappear",300,COLOR.yellow)
	end
end