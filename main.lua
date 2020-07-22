--[[
  ______             __                _
 /_  __/___   _____ / /_   ____ ___   (_)____   ____
  / /  / _ \ / ___// __ \ / __ `__ \ / // __ \ / __ \
 / /  /  __// /__ / / / // / / / / // // / / // /_/ /
/_/   \___/ \___//_/ /_//_/ /_/ /_//_//_/ /_/ \____/
Techmino is my first "huge project"
optimization is welcomed if you also love tetromino game
]]

--Global Setting & Vars
math.randomseed(os.time()*626)
love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.mouse.setVisible(false)

function NULL()end
system=love.system.getOS()
game={}
mapCam={
	sel=nil,--selected mode ID

	x=0,y=0,k=1,--camera pos/k
	x1=0,y1=0,k1=1,--camera pos/k shown
	--basic paras

	keyCtrl=false,--if controlling with key

	zoomMethod=nil,
	zoomK=nil,
	--for auto zooming when enter/leave scene
}
scr={x=0,y=0,w=0,h=0,rad=0,k=1}--wid,hei,radius,scale K

customSel={1,22,1,1,7,3,1,1,8,4,1,1,1}
preField={h=20}for i=1,20 do preField[i]={0,0,0,0,0,0,0,0,0,0}end
preBag={}

players={alive={},human=0}
--blockSkin,blockSkinMini={},{}--redefined in SKIN.change

require("Zframework")--load Zframework

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


--load files & settings
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

--update data file
S=stat
if S.version=="Alpha V0.9.1"then
	setting.spawn=0
end
if S.version~=gameVersion then
	S.version=gameVersion
	TEXT.show(text.newVersion,640,200,30,"fly",.3)
end
S=nil