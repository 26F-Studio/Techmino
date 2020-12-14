--[[
	  ______             __                _
	 /_  __/___   _____ / /_   ____ ___   (_)____   ____
	  / /  / _ \ / ___// __ \ / __ `__ \ / // __ \ / __ \
	 / /  /  __// /__ / / / // / / / / // // / / // /_/ /
	/_/   \___/ \___//_/ /_//_/ /_/ /_//_//_/ /_/ \____/
	Techmino is my first "huge project"
	optimization is welcomed if you also love tetromino game
]]--

--?
NULL=function()end
DBP=print--use this if need debugging print
SYSTEM=love.system.getOS()
MOBILE=SYSTEM=="Android"or SYSTEM=="iOS"
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
	x=0,y=0,--Up-left Coord on screen
	w=0,h=0,--Fullscreen w/h in gc
	W=0,H=0,--Fullscreen w/h in shader
	rad=0,--Radius
	k=1,--Scale size
	dpi=1--DPI from gc.getDPIScale()
}--1280:720-Rect Screen Info

customEnv={
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
FIELD={h=20}for i=1,20 do FIELD[i]={0,0,0,0,0,0,0,0,0,0}end--Field for custom game
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

	--Data for royale mode
	stage=nil,			--Game stage
	mostBadge=nil,		--Most badge owner
	secBadge=nil,		--Second badge owner
	mostDangerous=nil,	--Most dangerous player
	secDangerous=nil,	--Second dangerous player
}--Global game data
PLAYERS={alive={}}--Players data
CURMODE=nil--Current mode object
--blockSkin,blockSkinMini={},{}--Redefined in SKIN.change


--Load modules
require("Zframework")--Load Zframework
blocks=		require("parts/mino")
AITemplate=	require("parts/AITemplate")
freeRow=	require("parts/freeRow")

require("parts/list")
require("parts/gametoolfunc")
require("parts/default_data")

TEXTURE=require("parts/texture")
SKIN=	require("parts/skin")
PLY=	require("parts/player")
AIfunc=	require("parts/ai")
Modes=	require("parts/modes")
TICK=	require("parts/tick")

require("parts/scenes")

--Load files & settings
modeRanks={sprint_10=0}

local fs=love.filesystem
if fs.getInfo("keymap.dat")then fs.remove("keymap.dat")end
if fs.getInfo("setting.dat")then fs.remove("setting.dat")end

if fs.getInfo("settings.dat")then
	FILE.loadSetting()
else
	-- firstRun=true
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
	local R=modeRanks
	R.sprint_10=R.sprint_10 or 0
	for k,_ in next,R do
		if type(k)=="number"then
			R[k]=nil
		end
	end
	if R.master_adavnce then
		R.master_advance,R.master_adavnce=R.master_adavnce
	end
	if R["tech_normal+"]then
		R.tech_normal2=R["tech_normal+"]
		R.tech_hard2=R["tech_hard+"]
		R.tech_lunatic2=R["tech_lunatic+"]
		R.tech_finesse2=R["tech_finesse+"]
		R["tech_normal+"],R["tech_hard+"],R["tech_lunatic+"],R["tech_finesse+"]=nil
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
	if not S.spin[1][6]then
		for i=1,25 do
			S.spin[i][6]=0
		end
	end
	if S.extraRate then
		S.finesseRate=5*(S.piece-S.extraRate)
	end
	if fs.getInfo("bigbang.dat")then fs.remove("bigbang.dat")end
	if S.version~=gameVersion then
		S.version=gameVersion
		newVersionLaunch=true
		if S.finesseRate<.5*S.piece then
			S.finesseRate=10*S.finesseRate
		end
		SETTING.skin={1,7,11,3,14,4,9,1,7,1,7,11,3,14,4,9,14,9,11,3,11,3,1,7,4}
		FILE.saveData()
		FILE.saveSetting()
	end
	if MOBILE and not SETTING.fullscreen then
		LOG.print("如果手机上方状态栏不消失,请到设置界面开启全屏",300,color.yellow)
		LOG.print("Switch fullscreen on if titleBar don't disappear",300,color.yellow)
	end
end