--[[
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
require("parts/texture")
require("parts/default_data")

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
S.clear_B,S.clear_S=nil
if not S.clear[1][5]then
	for i=1,7 do
		S.clear[i][5]=0
		S.spin[i][5]=0
	end
	for i=8,25 do
		S.clear[i]={0,0,0,0,0}
		S.spin[i]={0,0,0,0,0}
	end
end
if not S.off then
	S.off=S.recv-S.pend
end
if S.clear[1][4]>0 then
	for i=1,6 do
		S.clear[7][4]=S.clear[7][4]+S.clear[i][4]
		S.clear[i][4]=0
	end
end
while #modeRanks>73 do
	table.remove(modeRanks)
end
if modeRanks[73]==6 then modeRanks[73]=0 end
if modeRanks[1]then--rename key of modeRanks
	local L=modeRanks
	for i=1,#L do
		L[Modes[i].name],L[i]=L[i]
	end
end
if setting.skin[10]==5 then
	setting.skin[10],setting.skin[11]=1,5
end
if S.version~=gameVersion then
	if S.version then
		setting.spawn=true
	end
	S.version=gameVersion
	TEXT.show(text.newVersion,640,200,30,"fly",.3)
end
S=nil