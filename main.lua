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
function NULL()end
DBP=print--use this if need debugging print
marking=true
NOGAME=false

--Global Setting & Vars
math.randomseed(os.time()*626)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.mouse.setVisible(false)

system=love.system.getOS()
scr={
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
preField={h=20}for i=1,20 do preField[i]={0,0,0,0,0,0,0,0,0,0}end--Field for custom game
preBag={}--Sequence for custom game
preMission={}--Clearing target for custom game

game={
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

	--Data for royale mode
	stage=nil,			--Game stage
	mostBadge=nil,		--Most badge owner
	secBadge=nil,		--Second badge owner
	mostDangerous=nil,	--Most dangerous player
	secDangerous=nil,	--Second dangerous player
}--Global game data
players={alive={}}--Players data
curMode=nil--Current mode object
--blockSkin,blockSkinMini={},{}--Redefined in SKIN.change

require("Zframework")--Load Zframework

--Load modules
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
	if system=="Android"or system=="iOS" then
		setting.VKSwitch=true
		setting.swap=false
		setting.vib=2
		setting.powerInfo=true
		setting.fullscreen=true
		love.window.setFullscreen(true)
		love.resize(love.graphics.getWidth(),love.graphics.getHeight())
	end
end
LANG.set(setting.lang)
if setting.fullscreen then love.window.setFullscreen(true)end

if fs.getInfo("unlock.dat")then FILE.loadUnlock()end
if fs.getInfo("data.dat")then FILE.loadData()end
if fs.getInfo("key.dat")then FILE.loadKeyMap()end
if fs.getInfo("virtualkey.dat")then FILE.loadVK()end

if fs.getInfo("tech_ultimate.dat")then fs.remove("tech_ultimate.dat")end
if fs.getInfo("tech_ultimate+.dat")then fs.remove("tech_ultimate+.dat")end

--Update data
do
	local R=modeRanks
	for k,v in next,R do
		if type(k)=="number"then
			if Modes[k]and not R[Modes[k].name]then
				R[Modes[k].name]=v
			end
			R[k]=nil
		end
	end
	if R.master_adavnce then
		R.master_advance,R.master_adavnce=R.master_adavnce
	end
	if not text.modes[stat.lastPlay]then
		stat.lastPlay="sprint_10"
	end

	--Update data file
	local S=setting
	if type(S.spawn)~="number"then S.spawn=0 end
	if type(S.ghost)~="number"then S.ghost=.3 end
	if type(S.center)~="number"then S.center=1 end
	if S.bgm>1 then S.bgm=S.bgm*.01 end
	if S.sfx>1 then S.sfx=S.sfx*.01 end
	if S.voc>1 then S.voc=S.voc*.01 end
	if S.stereo>1 then S.stereo=S.stereo*.1 end
	if S.VKSFX>1 then S.VKSFX=S.VKSFX*.25 end
	if S.VKAlpha>1 then S.VKAlpha=S.VKAlpha*.1 end
	S=stat
	if not S.spin[1][6]then
		for i=1,25 do
			S.spin[i][6]=0
		end
	end
	if S.version~=gameVersion then
		S.version=gameVersion
		newVersionLaunch=true
	end
	if system=="Android"and not setting.fullscreen then
		LOG.print("如果你的手机状态栏不会消失,请到设置界面开启全屏",300,color.yellow)
		LOG.print("Switch fullscreen on if titleBar don't disappear",300,color.yellow)
	end
end