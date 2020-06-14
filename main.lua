--[[
	Techmino is my first "huge project"
	optimization is welcomed if you also love tetromino game
]]
math.randomseed(os.time()*626)
--Global vars
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
function NULL()end
--blockSkin,blockSkinMini={},{}--redefined in SKIN.change

--Load modules
setFont=require("parts/setfont")
color=require("parts/color")
blocks=require("parts/mino")
SHADER=require("parts/shader")
AITemplate=require("parts/AITemplate")
freeRow=require("parts/freeRow")
tickEvent=require("parts/tickEvent")

require("parts/list")
require("toolfunc")
require("texture")

SCN=require("scene")
VIB=require("parts/vib")
SFX=require("parts/sfx")
sysFX=require("parts/sysFX")
BGM=require("parts/bgm")
VOC=require("parts/voice")
SKIN=require("parts/skin")
LANG=require("parts/languages")
FILE=require("parts/file")
TEXT=require("parts/text")
TASK=require("parts/task")
BG=require("parts/bg")
IMG=require("parts/img")
WIDGET=require("parts/widget")
LIGHT=require("parts/light")

require("parts/modes")
require("parts/default_data")
require("parts/ai")
PLY=require("player")
widgetList=require("widgetList")
require("callback")

--load files & settings
local fs=love.filesystem
if fs.getInfo("keymap.dat")then fs.remove("keymap.dat")end
if fs.getInfo("setting.dat")then fs.remove("setting.dat")end

if fs.getInfo("settings.dat")then FILE.loadSetting()
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
if not S.version or S.version=="Alpha V0.8.15"then
	S.clear_S={S.clear_1,S.clear_2,S.clear_3,S.clear_4}
	S.clear={{},{},{},{},{},{},{}}
	local A,B,C,D=int(S.clear_1/7),int(S.clear_2/7),int(S.clear_3/7),S.clear_4
	for i=1,7 do
		S.clear[i][1]=A
		S.clear[i][2]=B
		S.clear[i][3]=C
		S.clear[i][4]=0
	end
	S.clear[7][4]=D
	for i=1,S.clear_1%7 do S.clear[i][1]=S.clear[i][1]+1 end
	for i=1,S.clear_2%7 do S.clear[i][2]=S.clear[i][2]+1 end
	for i=1,S.clear_3%7 do S.clear[i][3]=S.clear[i][3]+1 end
	S.clear_B={}
	for i=1,7 do
		S.clear_B[i]=S.clear[i][1]+S.clear[i][2]+S.clear[i][3]+S.clear[i][4]
	end

	S.spin_S={S.spin_0,S.spin_1,S.spin_2,S.spin_3}
	S.spin={{},{},{},{},{},{},{}}
	A,B,C,D=int(S.spin_0/7),int(S.spin_1/7),int(S.spin_2/7),int(S.spin_3/7)
	for i=1,7 do
		S.spin[i][1]=A
		S.spin[i][2]=B
		S.spin[i][3]=C
		S.spin[i][4]=D
	end
	for i=1,S.spin_0%7 do S.spin[i][1]=S.spin[i][1]+1 end
	for i=1,S.spin_1%7 do S.spin[i][2]=S.spin[i][2]+1 end
	for i=1,S.spin_2%7 do S.spin[i][3]=S.spin[i][3]+1 end
	for i=1,S.spin_3%7 do S.spin[i][4]=S.spin[i][4]+1 end
	S.spin_B={}
	for i=1,7 do
		S.spin_B[i]=S.spin[i][1]+S.spin[i][2]+S.spin[i][3]+S.spin[i][4]
	end

	S.hpc=S.c
elseif S.version=="Alpha V0.8.16"then
	for i=1,6 do
		S.clear[7][4]=S.clear[7][4]+S.clear[i][4]
		S.clear[i][4]=0
	end
end
if not S.clear_B[8]then
	for i=1,7 do
		S.clear[i][5]=0
		S.spin[i][5]=0
	end
	for i=8,25 do
		S.clear[i]={0,0,0,0,0}
		S.spin[i]={0,0,0,0,0}
		S.spin_B[i]=0
		S.clear_B[i]=0
	end
	S.spin_S[5]=0
	S.clear_S[5]=0
end
if S.version=="Alpha V0.8.18"or S.version=="Alpha V0.8.19"then
	S.clear[3],S.clear[4]=S.clear[4],S.clear[3]
	S.spin[3],S.spin[4]=S.spin[4],S.spin[3]
	S.clear_B[3],S.clear_B[4]=S.clear_B[4],S.clear_B[3]
	S.spin_B[3],S.spin_B[4]=S.spin_B[4],S.spin_B[3]
end
if S.version=="Alpha V0.8.22"then
	S.off=S.recv-S.pend
end
while #modeRanks>73 do
	table.remove(modeRanks)
end
if modeRanks[73]==6 then modeRanks[73]=0 end
if setting.skin[10]==5 then
	setting.skin[10],setting.skin[11]=1,5
end
if S.version~=gameVersion then
	S.version=gameVersion
	TEXT.show(text.newVersion,640,200,30,"fly",.3)
end
S=nil