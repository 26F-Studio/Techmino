--[[
第一次搞这么大的工程,参考价值也许不是很大
如果你有时间并且也热爱俄罗斯方块的话,来看代码或者帮助优化的话欢迎!
]]
math.randomseed(os.time()*626)
--Global vars
system=love.system.getOS()
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
--[[
blockSkin,blockSkinMini={},{}--redefined in SKIN.change
widget_sel=nil--selected widget obj
]]

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

require("parts/light")
require("parts/modes")
require("default_data")
require("parts/widget")
require("parts/ai")
require("player")
Widget=require("widgetList")
require("callback")

--load files & settings
local fs=love.filesystem
if fs.getInfo("keymap.dat")then fs.remove("keymap.dat")end

if fs.getInfo("setting.dat")then FILE.loadSetting()
else
	-- firstRun=true
	if system=="Android"or system=="iOS" then
		setting.VKSwitch=true
		setting.swap=false
		setting.vib=2
	end
end
LANG.set(setting.lang)
if setting.fullscreen then love.window.setFullscreen(true)end

if fs.getInfo("unlock.dat")then FILE.loadUnlock()end
if fs.getInfo("data.dat")then FILE.loadData()end
if fs.getInfo("key.dat")then FILE.loadKeyMap()end
if fs.getInfo("virtualkey.dat")then FILE.loadVK()end