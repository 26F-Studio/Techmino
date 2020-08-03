--[[
  ______             __                _
 /_  __/___   _____ / /_   ____ ___   (_)____   ____
  / /  / _ \ / ___// __ \ / __ `__ \ / // __ \ / __ \
 / /  /  __// /__ / / / // / / / / // // / / // /_/ /
/_/   \___/ \___//_/ /_//_/ /_/ /_//_//_/ /_/ \____/
Techmino is my first "huge project"
optimization is welcomed if you also love tetromino game
]]--

--Global Setting & Vars
math.randomseed(os.time()*626)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.mouse.setVisible(false)

function NULL()end
system=love.system.getOS()
game={}
mapCam={
	sel=nil,--Selected mode ID

	--Basic paragrams
	x=0,y=0,k=1,--Camera pos/k
	x1=0,y1=0,k1=1,--Camera pos/k shown

	--If controlling with key
	keyCtrl=false,

	--For auto zooming when enter/leave scene
	zoomMethod=nil,
	zoomK=nil,
}
scr={x=0,y=0,w=0,h=0,rad=0,k=1}--wid,hei,radius,scale K

customSel={1,22,1,1,7,3,1,1,8,4,1,1,1}
preField={h=20}for i=1,20 do preField[i]={0,0,0,0,0,0,0,0,0,0}end
preBag={}

game={
	frame=0,			--Frame count
	result=0,			--Game result
	pauseTime=0,		--Time paused
	pauseCount=0,		--Pausing count
	garbageSpeed=1,		--Garbage timing speed
	warnLVL0=0,			--Warning level
	warnLVL=0,			--Warning level (show)
	recording=false,	--If recording
	replaying=false,	--If replaying
	rec={},				--Recording list, key-time
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

--Update modeRanks
R=modeRanks
if R[1]then
	local L=R
	for i=1,#L do
		L[Modes[i].name],L[i]=L[i]
	end
elseif R.master_adavnce then
	R.master_advance,R.master_adavnce=R.master_adavnce
end

--Update data file
S=stat
if S.version=="Alpha V0.9.1"or type(setting.spawn)~="number"then
	setting.spawn=0
end
if S.version~=gameVersion then
	S.version=gameVersion
	TEXT.show(text.newBigVersion,640,200,30,"fly",.3)
	newVersionLaunch=true

	fs.remove("master_adavnce.dat")
	fs.remove("master_beginner.dat")
	for name,M in next,Modes do
		if M.score then
			if modeRanks[name]==6 then
				modeRanks[name]=0
			end
		else
			modeRanks[name]=6
		end
	end
end
R,S=nil