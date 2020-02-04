local gc,tm=love.graphics,love.timer
local ms,kb=love.mouse,love.keyboard
local fs,sys=love.filesystem,love.system
int,ceil,abs,rnd,max,min,sin,cos,atan,pi=math.floor,math.ceil,math.abs,math.random,math.max,math.min,math.sin,math.cos,math.atan,math.pi
sub,gsub,find,format,byte,char=string.sub,string.gsub,string.find,string.format,string.byte,string.char
ins,rem,sort=table.insert,table.remove,table.sort
null=function()end

system=sys.getOS()
scr={x=0,y=0,w=gc.getWidth(),h=gc.getHeight(),k=1}
scene=""
bgmPlaying=nil
curBG="none"

kb.setKeyRepeat(false)
kb.setTextInput(false)
ms.setVisible(false)

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
	grid=false,swap=true,
	_20G=false,bone=false,
	drop=30,lock=45,
	wait=0,fall=0,
	next=6,hold=true,oncehold=true,

	keepVisible=true,visible="show",
	sequence="bag7",
	block=true,
	Fkey=false,
	ospin=true,
	freshLimit=1e99,
	target=1e99,
	reach=null,
	bg="none",
	bgm="race"
}
customSel={
	drop=20,
	lock=20,
	wait=1,
	fall=1,
	next=7,
	hold=1,
	sequence=1,
	visible=1,
	target=4,
	freshLimit=3,
	opponent=1,
}
preField={}for i=1,20 do preField[i]={0,0,0,0,0,0,0,0,0,0}end
freeRow={}
for i=1,40 do
	freeRow[i]={0,0,0,0,0,0,0,0,0,0}
end
--Game system Data
setting={
	ghost=true,center=true,
	grid=false,swap=true,
	fxs=true,

	das=10,arr=2,
	sddas=0,sdarr=2,
	
	sfx=true,bgm=true,vib=3,
	fullscreen=false,
	bgblock=true,
	lang=1,
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
	keyLib={
		{1},
		{2},
		{3},
		{4},
	},--Players' key setting(s)
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
	virtualkeySwitch=false,
	frameMul=100,
}
stat={
	run=0,
	game=0,
	gametime=0,
	piece=0,
	row=0,
	atk=0,
	key=0,
	hold=0,
	rotate=0,
	spin=0,
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
	{80,360,6400,80},--swap
	{80,80,6400,80},--restart
	--[[
	{x=0,y=0,r=0},--toLeft
	{x=0,y=0,r=0},--toRight
	{x=0,y=0,r=0},--toDown
	]]

}
virtualkeyDown={false,false,false,false,false,false,false,false,false,false,false,false,false}
virtualkeyPressTime={0,0,0,0,0,0,0,0,0,0,0,0,0}
--User Data&User Setting
require"toolfunc"
require"list"
require"class"
require"gamefunc"
require"ai"
require"timer"
require"paint"
require"call&sys"
require"dataList"
require"texture"

userData,userSetting=fs.newFile("userdata"),fs.newFile("usersetting")
if fs.getInfo("userdata")then
	loadData()
end
if fs.getInfo("usersetting")then
	loadSetting()
elseif system=="Android" or system=="iOS"then
	setting.virtualkeySwitch=true
	setting.swap=false
end
swapLanguage(setting.lang)