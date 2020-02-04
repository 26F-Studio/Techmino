local gc,tm=love.graphics,love.timer
local ms,kb=love.mouse,love.keyboard
local fs,sys=love.filesystem,love.system
int,ceil,abs,rnd,max,min,sin,cos,atan=math.floor,math.ceil,math.abs,math.random,math.max,math.min,math.sin,math.cos,math.atan
sub,gsub,find,format,byte,char=string.sub,string.gsub,string.find,string.format,string.byte,string.char
ins,rem,concat=table.insert,table.remove,table.concat
-- sort=table.sort
math.randomseed(os.time()*626)
null=function()end

system=sys.getOS()
scr={x=0,y=0,w=gc.getWidth(),h=gc.getHeight(),k=1}
scene=""
bgmPlaying=nil
curBG="none"
voicePlaying={}

local F=false
kb.setKeyRepeat(F)
kb.setTextInput(F)
ms.setVisible(F)

local Fonts={}
function setFont(s)
	if s~=currentFont then
		if Fonts[s]then
			gc.setFont(Fonts[s])
		else
			local t=gc.setNewFont("font.ttf",s-5)
			Fonts[s]=t
			gc.setFont(t)
		end
		currentFont=s
	end
	return Fonts[s]
end

gameEnv0={
	das=10,arr=2,
	sddas=0,sdarr=2,
	ghost=true,center=true,
	grid=F,swap=true,
	_20G=F,bone=F,
	drop=30,lock=45,
	wait=0,fall=0,
	next=6,hold=true,oncehold=true,
	sequence="bag7",

	block=true,
	keepVisible=true,visible="show",
	Fkey=F,puzzle=F,ospin=true,
	freshLimit=1e99,target=1e99,reach=null,
	bg="none",bgm="race"
}
customSel={22,22,1,1,7,3,1,1,8,4,1,1,1}
preField={h=20}
for i=1,18 do preField[i]={0,0,0,0,0,0,0,0,0,0}end
for i=19,20 do preField[i]={-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}end
freeRow={}
for i=1,40 do
	freeRow[i]={0,0,0,0,0,0,0,0,0,0}
end
--Game system Data
setting={
	ghost=true,center=true,
	grid=F,swap=true,
	fxs=true,bg=true,
	das=10,arr=2,
	sddas=0,sdarr=2,
	lang=1,
	
	sfx=true,bgm=true,
	vib=3,voc=false,
	fullscreen=F,
	bgblock=true,
	skin=1,
	keyMap={
		{"left","right","x","z","c","up","down","space","tab","r","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","x","leftshoulder","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
	},--keyboard & joystick
	virtualkey={
		{80,720-80,6400,80},--moveLeft
		{240,720-80,6400,80},--moveRight
		{1280-240,720-80,6400,80},--rotRight
		{1280-400,720-80,6400,80},--rotLeft
		{1280-240,720-240,6400,80},--rotFlip
		{1280-80,720-80,6400,80},--hardDrop
		{1280-80,720-240,6400,80},--softDrop
		{1280-80,720-400,6400,80},--hold
		{80,80,6400,80},--restart
	},
	virtualkeyAlpha=3,
	virtualkeyIcon=true,
	virtualkeySwitch=F,
	frameMul=100,
}
stat={
	run=0,game=0,time=0,
	key=0,rotate=0,hold=0,piece=0,row=0,
	atk=0,send=0,recv=0,pend=0,
	clear_1=0,clear_2=0,clear_3=0,clear_4=0,
	spin_0=0,spin_1=0,spin_2=0,spin_3=0,
	b2b=0,b3b=0,pc=0,
}
virtualkey={
	{80,720-80,6400,80},--moveLeft
	{240,720-80,6400,80},--moveRight
	{1280-240,720-80,6400,80},--rotRight
	{1280-400,720-80,6400,80},--rotLeft
	{1280-240,720-240,6400,80},--rotFlip
	{1280-80,720-80,6400,80},--hardDrop
	{1280-80,720-240,6400,80},--softDrop
	{1280-80,720-400,6400,80},--hold
	{80,360,6400,80},--func
	{80,80,6400,80},--restart
	--[[
	{x=0,y=0,r=0},--toLeft
	{x=0,y=0,r=0},--toRight
	{x=0,y=0,r=0},--toDown
	]]

}
virtualkeyDown={F,F,F,F,F,F,F,F,F,F,F,F,F}
virtualkeyPressTime={0,0,0,0,0,0,0,0,0,0,0,0,0}
--User Data&User Setting
require("toolfunc")
require("list")
require("class")
require("gamefunc")
require("ai")
require("timer")
require("paint")
require("call&sys")
require("dataList")
require("texture")

userData,userSetting=fs.newFile("userdata"),fs.newFile("usersetting")
if fs.getInfo("userdata")then
	loadData()
end
if fs.getInfo("usersetting")then
	loadSetting()
elseif system=="Android" or system=="iOS"then
	setting.virtualkeySwitch=true
	setting.swap=F
end

swapLanguage(setting.lang)
changeBlockSkin(setting.skin)