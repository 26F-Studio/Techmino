local rnd=math.random
local mobileHide,mobileShow
if MOBILE then
	function mobileHide()return true end
else
	function mobileShow()return true end
end
local function BACK()SCN.back()end
local virtualkeySet={
	{
		{1,	80,			720-200,	80},--moveLeft
		{2,	320,		720-200,	80},--moveRight
		{3,	1280-80,	720-200,	80},--rotRight
		{4,	1280-200,	720-80,		80},--rotLeft
		{5,	1280-200,	720-320,	80},--rot180
		{6,	200,		720-320,	80},--hardDrop
		{7,	200,		720-80,		80},--softDrop
		{8,	1280-320,	720-200,	80},--hold
		{9,	1280-80,	280,		80},--func
		{10,80,			280,		80},--restart
	},--Farter's set,thanks
	{
		{1,	1280-320,	720-200,	80},--moveLeft
		{2,	1280-80,	720-200,	80},--moveRight
		{3,	200,		720-80,		80},--rotRight
		{4,	80,			720-200,	80},--rotLeft
		{5,	200,		720-320,	80},--rot180
		{6,	1280-200,	720-320,	80},--hardDrop
		{7,	1280-200,	720-80,		80},--softDrop
		{8,	320,		720-200,	80},--hold
		{9,	80,			280,		80},--func
		{10,1280-80,	280,		80},--restart
	},--Mirrored farter's set,sknaht
	{
		{1,	80,			720-80,		80},--moveLeft
		{2,	240,		720-80,		80},--moveRight
		{3,	1280-240,	720-80,		80},--rotRight
		{4,	1280-400,	720-80,		80},--rotLeft
		{5,	1280-240,	720-240,	80},--rot180
		{6,	1280-80,	720-80,		80},--hardDrop
		{7,	1280-80,	720-240,	80},--softDrop
		{8,	1280-80,	720-400,	80},--hold
		{9,	80,			360,		80},--func
		{10,80,			80,			80},--restart
	},--Author's set,not recommend
	{
		{1,	1280-400,	720-80,		80},--moveLeft
		{2,	1280-80,	720-80,		80},--moveRight
		{3,	240,		720-80,		80},--rotRight
		{4,	80,			720-80,		80},--rotLeft
		{5,	240,		720-240,	80},--rot180
		{6,	1280-240,	720-240,	80},--hardDrop
		{7,	1280-240,	720-80,		80},--softDrop
		{8,	1280-80,	720-240,	80},--hold
		{9,	80,			720-240,	80},--func
		{10,80,			320,		80},--restart
	},--Keyboard set
	{
		{10,70,		50,30},--restart
		{9,	130,	50,30},--func
		{4,	190,	50,30},--rotLeft
		{3,	250,	50,30},--rotRight
		{5,	310,	50,30},--rot180
		{1,	370,	50,30},--moveLeft
		{2,	430,	50,30},--moveRight
		{8,	490,	50,30},--hold
		{7,	550,	50,30},--softDrop1
		{6,	610,	50,30},--hardDrop
		{11,670,	50,30},--insLeft
		{12,730,	50,30},--insRight
		{13,790,	50,30},--insDown
		{14,850,	50,30},--down1
		{15,910,	50,30},--down4
		{16,970,	50,30},--down10
		{17,1030,	50,30},--dropLeft
		{18,1090,	50,30},--dropRight
		{19,1150,	50,30},--zangiLeft
		{20,1210,	50,30},--zangiRight
	},--PC key feedback(top&in a row)
}
local SLClist={
	snap={1,10,20,40,60,80},

	drop={0,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
	lock={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
	wait={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
	fall={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
	sequence={"bag","his4","rnd","reverb","loop","fixed"},
	target={10,20,40,100,200,500,1000,1e99},
	visible={"show","time","fast","none"},
	freshLimit={0,8,15,1e99},
	opponent={0,1,2,3,4,5,6,7,8,9,10},
	life={0,1,2,3,5,10,15,26,42,87,500},
	pushSpeed={1,2,3,5,15},
	bg={"none","grey","glow","rgb","flink","wing","fan","badapple","welcome","aura","bg1","bg2","rainbow","rainbow2","lightning","lightning2","matrix","space"},
	bgm=BGM.list,
}

--Lambda Funcs for widgets,delete at file end
local function CUSval(k)	return function()	return customEnv[k]				end end
local function CUSrev(k)	return function()	customEnv[k]=not customEnv[k]	end end
local function CUSsto(k)	return function(i)	customEnv[k]=i					end end

local function SETval(k)	return function()	return SETTING[k]				end end
local function SETrev(k)	return function()	SETTING[k]=not SETTING[k]		end end
local function SETsto(k)	return function(i)	SETTING[k]=i					end end

local function STPval(k)	return function()	return sceneTemp[k]				end end
local function STPrev(k)	return function()	sceneTemp[k]=not sceneTemp[k]	end end
local function STPsto(k)	return function(i)	sceneTemp[k]=i					end end
local function STPeq(k,v)	return function()	return sceneTemp[k]==v			end end

local function prevSkin(n)	return function()	SKIN.prev(n)					end end
local function nextSkin(n)	return function()	SKIN.next(n)					end end
local function nextDir(n)	return function()	SKIN.rotate(n)					end end

local function VKAdisp(n)	return function()	return VK_org[n].ava			end end
local function VKAcode(n)	return function()	VK_org[n].ava=not VK_org[n].ava	end end

local function pressKey(k)	return function()	love.keypressed(k)				end end
local function setPen(i)	return function()	sceneTemp.pen=i					end end
local function setLang(n)	return function()	LANG.set(n)SETTING.lang=n		end end
local function goScene(t,s)	return function()	SCN.go(t,s)						end end
local function swapScene(t,s)return function()	SCN.swapTo(t,s)					end end

--NewXXX
local newText=		WIDGET.newText
local newImage=		WIDGET.newImage
local newButton=	WIDGET.newButton
local newKey=		WIDGET.newKey
local newSwitch=	WIDGET.newSwitch
local newSlider=	WIDGET.newSlider
local newSelector=	WIDGET.newSelector
local newTextBox=	WIDGET.newTextBox

--All widgets
local Widgets={
	load={},intro={},quit={},
	calculator={
		newKey({name="_1",			x=150,y=300,w=90,						font=50,code=pressKey("1")}),
		newKey({name="_2",			x=250,y=300,w=90,						font=50,code=pressKey("2")}),
		newKey({name="_3",			x=350,y=300,w=90,						font=50,code=pressKey("3")}),
		newKey({name="_4",			x=150,y=400,w=90,						font=50,code=pressKey("4")}),
		newKey({name="_5",			x=250,y=400,w=90,						font=50,code=pressKey("5")}),
		newKey({name="_6",			x=350,y=400,w=90,						font=50,code=pressKey("6")}),
		newKey({name="_7",			x=150,y=500,w=90,						font=50,code=pressKey("7")}),
		newKey({name="_8",			x=250,y=500,w=90,						font=50,code=pressKey("8")}),
		newKey({name="_9",			x=350,y=500,w=90,						font=50,code=pressKey("9")}),
		newKey({name="_0",			x=150,y=600,w=90,						font=50,code=pressKey("0")}),
		newKey({name=".",			x=250,y=600,w=90,		color="lPurple",font=50,code=pressKey(".")}),
		newKey({name="e",			x=350,y=600,w=90,		color="lPurple",font=50,code=pressKey("e")}),
		newKey({name="+",			x=450,y=300,w=90,		color="lBlue",	font=50,code=pressKey("+")}),
		newKey({name="-",			x=450,y=400,w=90,		color="lBlue",	font=50,code=pressKey("-")}),
		newKey({name="*",			x=450,y=500,w=90,		color="lBlue",	font=50,code=pressKey("*")}),
		newKey({name="/",			x=450,y=600,w=90,		color="lBlue",	font=50,code=pressKey("/")}),
		newKey({name="<",			x=550,y=300,w=90,		color="lRed",	font=50,code=pressKey("backspace")}),
		newKey({name="=",			x=550,y=400,w=90,		color="lYellow",font=50,code=pressKey("return")}),
		newButton({name="play",		x=640,y=600,w=180,h=90,	color="lGreen",	font=40,code=pressKey("space"),hide=function()return not sceneTemp.pass end}),
	},
	main={
		newButton({name="play",		x=150,y=220,w=200,h=140,color="lRed",	font=55,code=goScene("mode")}),
		newButton({name="setting",	x=370,y=220,w=200,h=140,color="sky",	font=45,code=goScene("setting_game")}),
		newButton({name="custom",	x=590,y=220,w=200,h=140,color="lPurple",font=45,code=goScene("customGame"),hide=function()return not modeRanks.marathon_normal end}),
		newButton({name="help",		x=150,y=380,w=200,h=140,color="lYellow",font=50,code=goScene("help")}),
		newButton({name="stat",		x=370,y=380,w=200,h=140,color="lGreen",	font=40,code=goScene("stat")}),
		newButton({name="qplay",	x=590,y=380,w=200,h=140,color="white",	font=45,code=function()SCN.push()loadGame(STAT.lastPlay,true)end}),
		newButton({name="lang",		x=150,y=515,w=200,h=90,color="dYellow",	font=45,code=goScene("lang")}),
		newButton({name="music",	x=370,y=515,w=200,h=90,color="dGreen",	font=30,code=goScene("music")}),
		newButton({name="quit",		x=590,y=515,w=200,h=90,color="grey",	font=45,code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end}),
		newKey({name="account",		x=150,y=610,w=200,h=60,color="red",				code=function()SCN.go(LOGIN and"account"or"login")end}),
		newKey({name="sound",		x=370,y=610,w=200,h=60,color="green",			code=goScene("sound")}),
		newKey({name="minigame",	x=590,y=610,w=200,h=60,color="blue",			code=goScene("minigame")}),
	},
	mode={
		newButton({name="start",	x=1040,	y=655,w=180,h=80,	font=40,code=pressKey("return"),hide=function()return not mapCam.sel end}),
		newButton({name="back",		x=1200,	y=655,w=120,h=80,	font=40,code=BACK}),
	},
	play={
		newButton({name="pause",	x=1235,	y=45,	w=80,		font=25,code=function()pauseGame()end}),
	},
	pause={
		newButton({name="setting",	x=1120,	y=70,	w=240,h=90,	color="lBlue",	font=35,code=pressKey("s")}),
		newButton({name="replay",	x=640,	y=250,	w=240,h=100,color="lYellow",font=30,code=pressKey("p"),hide=function()return not(GAME.result or GAME.replaying)or #PLAYERS>1 end}),
		newButton({name="resume",	x=640,	y=367,	w=240,h=100,color="lGreen",	font=30,code=pressKey("escape")}),
		newButton({name="restart",	x=640,	y=483,	w=240,h=100,color="lRed",	font=35,code=pressKey("r")}),
		newButton({name="quit",		x=640,	y=600,	w=240,h=100,font=35,code=BACK}),
	},
	setting_game={
		newText({name="title",		x=640,y=15,font=80}),

		newButton({name="graphic",	x=200,	y=80,	w=240,h=80,	color="lCyan",	font=35,code=swapScene("setting_video","swipeR")}),
		newButton({name="sound",	x=1080,	y=80,	w=240,h=80,	color="lCyan",	font=35,code=swapScene("setting_sound","swipeL")}),

		newButton({name="ctrl",		x=290,	y=220,	w=320,h=80,	color="lYellow",font=35,code=goScene("setting_control")}),
		newButton({name="key",		x=640,	y=220,	w=320,h=80,	color="lGreen",	font=35,code=goScene("setting_key")}),
		newButton({name="touch",	x=990,	y=220,	w=320,h=80,	color="lBlue",	font=35,code=goScene("setting_touch")}),
		newSlider({name="reTime",	x=350,	y=340,	w=300,unit=10,				font=30,disp=SETval("reTime"),	code=SETsto("reTime"),show=function(S)return(.5+S.disp()*.25).."s"end}),
		newSlider({name="maxNext",	x=350,	y=440,	w=300,unit=6,				font=30,disp=SETval("maxNext"),	code=SETsto("maxNext")}),
		newButton({name="layout",	x=460,	y=540,	w=140,h=70,					font=35,code=goScene("setting_skin")}),
		newSwitch({name="autoPause",x=1080,	y=320,	font=20,disp=SETval("autoPause"),	code=SETrev("autoPause")}),
		newSwitch({name="swap",		x=1080,	y=380,	font=20,disp=SETval("swap"),		code=SETrev("swap")}),
		newSwitch({name="fine",		x=1080,	y=440,	font=20,disp=SETval("fine"),		code=function()SETTING.fine=not SETTING.fine if SETTING.fine then SFX.play("finesseError",.6) end end}),
		newSwitch({name="appLock",	x=1080,	y=500,	font=20,disp=SETval("appLock"),		code=SETrev("appLock")}),
		newButton({name="calc",		x=970,	y=550,	w=150,h=60,color="dGrey",	font=25,code=goScene("calculator"),hide=function()return not SETTING.appLock end}),
		newButton({name="back",		x=1140,	y=640,	w=170,h=80,					font=40,code=BACK}),
	},
	setting_video={
		newText({name="title",		x=640,y=15,font=80}),

		newButton({name="sound",	x=200,	y=80,w=240,h=80,color="lCyan",font=35,code=swapScene("setting_sound","swipeR")}),
		newButton({name="game",		x=1080,	y=80,w=240,h=80,color="lCyan",font=35,code=swapScene("setting_game","swipeL")}),

		newSwitch({name="block",	x=360,	y=180,					disp=SETval("block"),				code=SETrev("block")}),
		newSlider({name="ghost",	x=260,	y=250,w=200,unit=.6,	disp=SETval("ghost"),show="percent",code=SETsto("ghost")}),
		newSlider({name="center",	x=260,	y=300,w=200,unit=1,		disp=SETval("center"),				code=SETsto("center")}),

		newSwitch({name="smooth",	x=700,	y=180,					disp=SETval("smooth"),	code=SETrev("smooth")}),
		newSwitch({name="grid",		x=700,	y=240,					disp=SETval("grid"),	code=SETrev("grid")}),
		newSwitch({name="bagLine",	x=700,	y=300,					disp=SETval("bagLine"),	code=SETrev("bagLine")}),

		newSlider({name="lockFX",	x=350,	y=350,w=373,unit=5,		disp=SETval("lockFX"),	code=SETsto("lockFX")}),
		newSlider({name="dropFX",	x=350,	y=400,w=373,unit=5,		disp=SETval("dropFX"),	code=SETsto("dropFX")}),
		newSlider({name="moveFX",	x=350,	y=450,w=373,unit=5,		disp=SETval("moveFX"),	code=SETsto("moveFX")}),
		newSlider({name="clearFX",	x=350,	y=500,w=373,unit=5,		disp=SETval("clearFX"),	code=SETsto("clearFX")}),
		newSlider({name="shakeFX",	x=350,	y=550,w=373,unit=5,		disp=SETval("shakeFX"),	code=SETsto("shakeFX")}),
		newSlider({name="atkFX",	x=350,	y=600,w=373,unit=5,		disp=SETval("atkFX"),	code=SETsto("atkFX")}),
		newSlider({name="frame",	x=350,	y=650,w=373,unit=10,
			disp=function()
				return SETTING.frameMul>35 and SETTING.frameMul/10 or SETTING.frameMul/5-4
			end,
			code=function(i)
				SETTING.frameMul=i<5 and 5*i+20 or 10*i
			end}),

		newSwitch({name="text",		x=1100,	y=180,font=35,disp=SETval("text"),code=SETrev("text")}),
		newSwitch({name="score",	x=1100,	y=240,font=35,disp=SETval("score"),code=SETrev("score")}),
		newSwitch({name="warn",		x=1100,	y=300,font=35,disp=SETval("warn"),code=SETrev("warn")}),
		newSwitch({name="highCam",	x=1100,	y=360,font=35,disp=SETval("highCam"),code=SETrev("highCam")}),
		newSwitch({name="nextPos",	x=1100,	y=420,font=35,disp=SETval("nextPos"),code=SETrev("nextPos")}),
		newSwitch({name="fullscreen",x=1100,y=480,disp=SETval("fullscreen"),
			code=function()
				SETTING.fullscreen=not SETTING.fullscreen
				love.window.setFullscreen(SETTING.fullscreen)
				love.resize(love.graphics.getWidth(),love.graphics.getHeight())
			end}),
		newSwitch({name="bg",		x=1100,	y=540,font=35,disp=SETval("bg"),
			code=function()
				BG.set("none")
				SETTING.bg=not SETTING.bg
				BG.set("space")
			end}),
		newSwitch({name="power",	x=990,	y=640,font=35,disp=SETval("powerInfo"),
			code=function()
				SETTING.powerInfo=not SETTING.powerInfo
			end}),
		newButton({name="back",		x=1140,	y=640,w=170,h=80,				font=40,code=BACK}),
	},
	setting_sound={
		newText({name="title",		x=640,y=15,font=80}),

		newButton({name="game",		x=200,	y=80,w=240,h=80,color="lCyan",	font=35,code=swapScene("setting_game","swipeR")}),
		newButton({name="graphic",	x=1080,	y=80,w=240,h=80,color="lCyan",	font=35,code=swapScene("setting_video","swipeL")}),

		newSlider({name="sfx",		x=180,	y=200,w=400,					font=35,change=function()SFX.play("blip_1")end,						disp=SETval("sfx"),		code=SETsto("sfx")}),
		newSlider({name="stereo",	x=180,	y=500,w=400,					font=35,change=function()SFX.play("move",1,-1)SFX.play("lock",1,1)end,disp=SETval("stereo"),code=SETsto("stereo"),hide=function()return SETTING.sfx==0 end}),
		newSlider({name="spawn",	x=180,	y=300,w=400,					font=30,change=function()SFX.fplay("spawn_"..rnd(7),SETTING.spawn)end,disp=SETval("spawn"),	code=SETsto("spawn")}),
		newSlider({name="bgm",		x=180,	y=400,w=400,					font=35,change=function()BGM.freshVolume()end,						disp=SETval("bgm"),		code=SETsto("bgm")}),
		newSlider({name="vib",		x=750,	y=200,w=400,	unit=5,			font=25,change=function()VIB(2)end,									disp=SETval("vib"),		code=SETsto("vib")}),
		newSlider({name="voc",		x=750,	y=300,w=400,					font=35,change=function()VOC.play("test")end,						disp=SETval("voc"),		code=SETsto("voc")}),
		newButton({name="back",		x=1140,	y=640,w=170,h=80,				font=40,code=BACK}),
	},
	setting_control={
		newText({name="title",		x=80,y=50,font=70,align="L"}),
		newText({name="preview",	x=520,y=540,font=40,align="R"}),

		newSlider({name="das",		x=250,	y=200,w=910,	unit=26,	disp=SETval("das"),		show="frame_time",code=SETsto("das")}),
		newSlider({name="arr",		x=250,	y=290,w=525,	unit=15,	disp=SETval("arr"),		show="frame_time",code=SETsto("arr")}),
		newSlider({name="sddas",	x=250,	y=380,w=350,	unit=10,	disp=SETval("sddas"),	show="frame_time",code=SETsto("sddas")}),
		newSlider({name="sdarr",	x=250,	y=470,w=140,	unit=4,		disp=SETval("sdarr"),	show="frame_time",code=SETsto("sdarr")}),
		newSwitch({name="ihs",		x=1100,	y=290,						disp=SETval("ihs"),		code=SETrev("ihs")}),
		newSwitch({name="irs",		x=1100,	y=380,						disp=SETval("irs"),		code=SETrev("irs")}),
		newSwitch({name="ims",		x=1100,	y=470,						disp=SETval("ims"),		code=SETrev("ims")}),
		newButton({name="reset",	x=160,	y=580,w=200,h=100,color="lRed",font=40,
			code=function()
				local _=SETTING
				_.das,_.arr=10,2
				_.sddas,_.sdarr=0,2
				_.ihs,_.irs,_.ims=false,false,false
			end}),
		newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=BACK}),
	},
	setting_key={
		newText({name="keyboard",	x=340,y=30,font=25,color="lRed"}),
		newText({name="keyboard",	x=940,y=30,font=25,color="lRed"}),
		newText({name="joystick",	x=540,y=30,font=25,color="lBlue"}),
		newText({name="joystick",	x=1140,y=30,font=25,color="lBlue"}),
		newText({name="help",		x=50,y=650,font=30,align="L"}),
		newButton({name="back",		x=1140,y=640,w=170,h=80,font=40,code=BACK}),
	},
	setting_skin={
		newText({name="title",		x=80,y=50,font=70}),

		newButton({name="prev",		x=700,y=100,w=140,h=100,font=50,code=function()SKIN.prevSet()end}),
		newButton({name="next",		x=860,y=100,w=140,h=100,font=50,code=function()SKIN.nextSet()end}),
		newButton({name="prev1",	x=130,y=230,w=90,h=65,code=prevSkin(1)}),
		newButton({name="prev2",	x=270,y=230,w=90,h=65,code=prevSkin(2)}),
		newButton({name="prev3",	x=410,y=230,w=90,h=65,code=prevSkin(3)}),
		newButton({name="prev4",	x=550,y=230,w=90,h=65,code=prevSkin(4)}),
		newButton({name="prev5",	x=690,y=230,w=90,h=65,code=prevSkin(5)}),
		newButton({name="prev6",	x=830,y=230,w=90,h=65,code=prevSkin(6)}),
		newButton({name="prev7",	x=970,y=230,w=90,h=65,code=prevSkin(7)}),

		newButton({name="next1",	x=130,y=450,w=90,h=65,code=nextSkin(1)}),
		newButton({name="next2",	x=270,y=450,w=90,h=65,code=nextSkin(2)}),
		newButton({name="next3",	x=410,y=450,w=90,h=65,code=nextSkin(3)}),
		newButton({name="next4",	x=550,y=450,w=90,h=65,code=nextSkin(4)}),
		newButton({name="next5",	x=690,y=450,w=90,h=65,code=nextSkin(5)}),
		newButton({name="next6",	x=830,y=450,w=90,h=65,code=nextSkin(6)}),
		newButton({name="next7",	x=970,y=450,w=90,h=65,code=nextSkin(7)}),

		newButton({name="spin1",	x=130,y=540,w=90,h=65,code=nextDir(1)}),
		newButton({name="spin2",	x=270,y=540,w=90,h=65,code=nextDir(2)}),
		newButton({name="spin3",	x=410,y=540,w=90,h=65,code=nextDir(3)}),
		newButton({name="spin4",	x=550,y=540,w=90,h=65,code=nextDir(4)}),
		newButton({name="spin5",	x=690,y=540,w=90,h=65,code=nextDir(5)}),
		--newButton({name="spin6",x=825,y=540,w=90,h=65,code=nextDir(6)}),--Cannot rotate O
		newButton({name="spin7",	x=970,y=540,w=90,h=65,code=nextDir(7)}),

		newButton({name="skinR",	x=200,y=640,w=220,h=80,color="lPurple",font=35,
			code=function()
				SETTING.skin={1,7,11,3,14,4,9,1,7,1,7,11,3,14,4,9,14,9,11,3,11,3,1,7,4}
				SFX.play("rotate")
			end}),
		newButton({name="faceR",	x=480,y=640,w=220,h=80,color="lRed",font=35,
			code=function()
				for i=1,25 do
					SETTING.face[i]=0
				end
				SFX.play("hold")
			end}),
		newButton({name="back",		x=1140,y=640,w=170,h=80,font=40,code=BACK}),
	},
	setting_touch={
		newButton({name="default",	x=520,y=90,w=200,h=80,font=35,
			code=function()
				local D=virtualkeySet[sceneTemp.default]
				for i=1,#VK_org do
					VK_org[i].ava=false
				end

				--Replace keys
				for n=1,#D do
					local T=D[n]
					if T[1]then
						local B=VK_org[n]
						B.ava=true
						B.x,B.y,B.r=T[2],T[3],T[4]
					end
				end
				sceneTemp.default=sceneTemp.default%5+1
				sceneTemp.sel=nil
				LOG.print("[ "..sceneTemp.default.." ]")
			end}),
		newSelector({name="snap",	x=760,y=90,w=200,h=80,color="yellow",list=SLClist.snap,disp=STPval("snap"),code=STPsto("snap")}),
		newButton({name="option",	x=520,y=190,w=200,h=80,font=40,
			code=function()
				SCN.go("setting_touchSwitch")
			end}),
		newButton({name="back",		x=760,y=190,w=200,h=80,font=35,code=BACK}),
		newSlider({name="size",		x=450,y=270,w=460,unit=19,font=40,show="vkSize",
			disp=function()
				return VK_org[sceneTemp.sel].r/10-1
			end,
			code=function(v)
				if sceneTemp.sel then
					VK_org[sceneTemp.sel].r=(v+1)*10
				end
			end,
			hide=function()
				return not sceneTemp.sel
			end}),
	},
	setting_touchSwitch={
		newSwitch({name="b1",		x=280,	y=80,	font=35,disp=VKAdisp(1),code=VKAcode(1)}),
		newSwitch({name="b2",		x=280,	y=140,	font=35,disp=VKAdisp(2),code=VKAcode(2)}),
		newSwitch({name="b3",		x=280,	y=200,	font=35,disp=VKAdisp(3),code=VKAcode(3)}),
		newSwitch({name="b4",		x=280,	y=260,	font=35,disp=VKAdisp(4),code=VKAcode(4)}),
		newSwitch({name="b5",		x=280,	y=320,	font=35,disp=VKAdisp(5),code=VKAcode(5)}),
		newSwitch({name="b6",		x=280,	y=380,	font=35,disp=VKAdisp(6),code=VKAcode(6)}),
		newSwitch({name="b7",		x=280,	y=440,	font=35,disp=VKAdisp(7),code=VKAcode(7)}),
		newSwitch({name="b8",		x=280,	y=500,	font=35,disp=VKAdisp(8),code=VKAcode(8)}),
		newSwitch({name="b9",		x=280,	y=560,	font=35,disp=VKAdisp(9),code=VKAcode(9)}),
		newSwitch({name="b10",		x=280,	y=620,	font=35,disp=VKAdisp(10),code=VKAcode(10)}),
		newSwitch({name="b11",		x=580,	y=80,	font=35,disp=VKAdisp(11),code=VKAcode(11)}),
		newSwitch({name="b12",		x=580,	y=140,	font=35,disp=VKAdisp(12),code=VKAcode(12)}),
		newSwitch({name="b13",		x=580,	y=200,	font=35,disp=VKAdisp(13),code=VKAcode(13)}),
		newSwitch({name="b14",		x=580,	y=260,	font=35,disp=VKAdisp(14),code=VKAcode(14)}),
		newSwitch({name="b15",		x=580,	y=320,	font=35,disp=VKAdisp(15),code=VKAcode(15)}),
		newSwitch({name="b16",		x=580,	y=380,	font=35,disp=VKAdisp(16),code=VKAcode(16)}),
		newSwitch({name="b17",		x=580,	y=440,	font=35,disp=VKAdisp(17),code=VKAcode(17)}),
		newSwitch({name="b18",		x=580,	y=500,	font=35,disp=VKAdisp(18),code=VKAcode(18)}),
		newSwitch({name="b19",		x=580,	y=560,	font=35,disp=VKAdisp(19),code=VKAcode(19)}),
		newSwitch({name="b20",		x=580,	y=620,	font=35,disp=VKAdisp(20),code=VKAcode(20)}),
		newButton({name="norm",		x=840,	y=100,	w=240,h=80,		font=35,code=function()for i=1,20 do VK_org[i].ava=i<11 end end}),
		newButton({name="pro",		x=1120,	y=100,	w=240,h=80,		font=35,code=function()for i=1,20 do VK_org[i].ava=true end end}),
		newSwitch({name="hide",		x=1170,	y=200,					font=40,disp=SETval("VKSwitch"),code=SETrev("VKSwitch")}),
		newSwitch({name="track",	x=1170,	y=300,					font=35,disp=SETval("VKTrack"),code=SETrev("VKTrack")}),
		newSlider({name="sfx",		x=800,	y=380,	w=180,			font=35,change=function()SFX.play("virtualKey",SETTING.VKSFX)end,disp=SETval("VKSFX"),code=SETsto("VKSFX")}),
		newSlider({name="vib",		x=800,	y=460,	w=180,unit=2,	font=35,change=function()VIB(SETTING.VKVIB)end,disp=SETval("VKVIB"),code=SETsto("VKVIB")}),
		newSwitch({name="icon",		x=850,	y=300,	font=40,disp=SETval("VKIcon"),code=SETrev("VKIcon")}),
		newButton({name="tkset",	x=1120,	y=420,	w=240,h=80,
			code=function()
				SCN.go("setting_trackSetting")
			end,
			hide=function()
				return not SETTING.VKTrack
			end}),
		newSlider({name="alpha",	x=840,	y=540,	w=400,font=40,disp=SETval("VKAlpha"),code=SETsto("VKAlpha")}),
		newButton({name="back",		x=1140,	y=640,	w=170,h=80,font=40,code=BACK}),
	},
	setting_trackSetting={
		newSwitch({name="VKDodge",	x=400,	y=200,	font=35,				disp=SETval("VKDodge"),code=SETrev("VKDodge")}),
		newSlider({name="VKTchW",	x=140,	y=310,	w=1000,	unit=10,font=35,disp=SETval("VKTchW"),code=function(i)SETTING.VKTchW=i SETTING.VKCurW=math.max(SETTING.VKCurW,i)end}),
		newSlider({name="VKCurW",	x=140,	y=370,	w=1000,	unit=10,font=35,disp=SETval("VKCurW"),code=function(i)SETTING.VKCurW=i SETTING.VKTchW=math.min(SETTING.VKTchW,i)end}),
		newButton({name="back",		x=1140,	y=640,	w=170,h=80,font=40,code=BACK}),
	},
	customGame={
		newText({name="title",		x=520,y=5,font=70,align="R"}),
		newText({name="subTitle",	x=530,y=50,font=35,align="L",color="grey"}),
		newText({name="defSeq",		x=330,y=550,align="L",color="grey",hide=function()return BAG[1]end}),
		newText({name="noMsn",		x=610,y=550,align="L",color="grey",hide=function()return MISSION[1]end}),

		--Basic
		newSelector({name="drop",	x=170,	y=150,w=220,color="orange",		list=SLClist.drop,	disp=CUSval("drop"),code=CUSsto("drop")}),
		newSelector({name="lock",	x=170,	y=230,w=220,color="red",		list=SLClist.lock,	disp=CUSval("lock"),code=CUSsto("lock")}),
		newSelector({name="wait",	x=410,	y=150,w=220,color="green",		list=SLClist.wait,	disp=CUSval("wait"),code=CUSsto("wait")}),
		newSelector({name="fall",	x=410,	y=230,w=220,color="yellow",		list=SLClist.fall,	disp=CUSval("fall"),code=CUSsto("fall")}),

		--Else
		newSelector({name="bg",		x=1070,	y=150,w=250,color="yellow",		list=SLClist.bg,	disp=CUSval("bg"),	code=function(i)customEnv.bg=i BG.set(i)end}),
		newSelector({name="bgm",	x=1070,	y=230,w=250,color="yellow",		list=SLClist.bgm,	disp=CUSval("bgm"),	code=function(i)customEnv.bgm=i BGM.play(i)end}),

		--Copy/Paste/Start
		newButton({name="copy",		x=1070,	y=310,w=310,h=70,color="lRed",	font=25,code=pressKey("cC")}),
		newButton({name="paste",	x=1070,	y=390,w=310,h=70,color="lBlue",	font=25,code=pressKey("cV")}),
		newButton({name="clear",	x=1070,	y=470,w=310,h=70,color="lYellow",font=35,code=pressKey("return")}),
		newButton({name="puzzle",	x=1070,	y=550,w=310,h=70,color="lMagenta",font=35,code=pressKey("return2")}),

		--More
		newKey({name="advance",		x=730,	y=190,w=220,h=90,color="red",	font=35,code=goScene("custom_advance")}),
		newKey({name="field",		x=170,	y=640,w=240,h=80,color="water",	font=25,code=goScene("custom_field")}),
		newKey({name="sequence",	x=450,	y=640,w=240,h=80,color="pink",	font=25,code=goScene("custom_sequence")}),
		newKey({name="mission",		x=730,	y=640,w=240,h=80,color="sky",	font=25,code=goScene("custom_mission")}),

		newButton({name="back",		x=1140,	y=640,	w=170,h=80,font=40,code=BACK}),
	},
	custom_advance={
		newText({name="title",		x=520,y=5,font=70,align="R"}),
		newText({name="subTitle",	x=530,y=50,font=35,align="L",color="grey"}),

		--Visual
		newSwitch({name="block",	x=620,	y=430,				font=25,	disp=CUSval("block"),	code=CUSrev("block")}),
		newSlider({name="ghost",	x=490,	y=500,w=200,unit=.6,font=25,	disp=CUSval("ghost"),	code=CUSsto("ghost")}),
		newSlider({name="center",	x=490,	y=560,w=200,unit=1,	font=25,	disp=CUSval("center"),	code=CUSsto("center")}),

		newSwitch({name="bagLine",	x=1190,	y=340,				disp=CUSval("bagLine"),	code=CUSrev("bagLine")}),
		newSwitch({name="highCam",	x=1190,	y=410,				disp=CUSval("highCam"),	code=CUSrev("highCam")}),
		newSwitch({name="nextPos",	x=1190,	y=480,				disp=CUSval("nextPos"),	code=CUSrev("nextPos")}),
		newSwitch({name="bone",		x=1190,	y=550,				disp=CUSval("bone"),	code=CUSrev("bone")}),

		--Control
		newSlider({name="next",		x=130,	y=410,w=200,unit=6,	disp=CUSval("next"),	code=CUSsto("next")}),
		newSwitch({name="hold",		x=260,	y=480,				disp=CUSval("hold"),	code=CUSrev("hold")}),
		newSwitch({name="oncehold",	x=260,	y=560,				disp=CUSval("oncehold"),code=CUSrev("oncehold"),hide=function()return not customEnv.hold end}),

		newSlider({name="mindas",	x=180,	y=150,w=400,unit=15,font=25,	disp=CUSval("mindas"),	code=CUSsto("mindas")}),
		newSlider({name="minarr",	x=180,	y=220,w=400,unit=10,font=25,	disp=CUSval("minarr"),	code=CUSsto("minarr")}),
		newSlider({name="minsdarr",	x=180,	y=290,w=200,unit=4,	font=20,	disp=CUSval("minsdarr"),code=CUSsto("minsdarr")}),

		--Rule
		newSwitch({name="ospin",	x=910,	y=340,				font=30,	disp=CUSval("ospin"),	code=CUSrev("ospin")}),
		newSwitch({name="noTele",	x=910,	y=420,				font=25,	disp=CUSval("noTele"),	code=CUSrev("noTele")}),
		newSwitch({name="fineKill",	x=910,	y=490,				font=20,	disp=CUSval("fineKill"),code=CUSrev("fineKill")}),
		newSwitch({name="easyFresh",x=910,	y=560,				font=20,	disp=CUSval("easyFresh"),code=CUSrev("easyFresh")}),
		newSelector({name="visible",	x=840,	y=60,w=260,color="lBlue",	list=SLClist.visible,	disp=CUSval("visible"),	code=CUSsto("visible")}),
		newSelector({name="target",		x=840,	y=160,w=260,color="green",	list=SLClist.target,	disp=CUSval("target"),	code=CUSsto("target")}),
		newSelector({name="freshLimit",	x=840,	y=260,w=260,color="purple",	list=SLClist.freshLimit,disp=CUSval("freshLimit"),code=CUSsto("freshLimit")}),
		newSelector({name="opponent",	x=1120,	y=60,w=260,color="red",		list=SLClist.opponent,	disp=CUSval("opponent"),code=CUSsto("opponent")}),
		newSelector({name="life",		x=1120,	y=160,w=260,color="red",	list=SLClist.life,		disp=CUSval("life"),	code=CUSsto("life")}),
		newSelector({name="pushSpeed",	x=1120,	y=260,w=260,color="red",	list=SLClist.pushSpeed,	disp=CUSval("pushSpeed"),code=CUSsto("pushSpeed")}),

		newButton({name="back",			x=1140,	y=640,	w=170,h=80,	font=40,code=BACK}),
	},
	custom_field={
		newText({name="title",		x=1020,y=5,font=70,align="R"}),
		newText({name="subTitle",	x=1030,y=50,font=35,align="L",color="grey"}),

		newButton({name="b1",		x=580,	y=130,w=75,color={color.rainbow( 1.471)},code=setPen(1)}),--B1
		newButton({name="b2",		x=660,	y=130,w=75,color={color.rainbow( 1.078)},code=setPen(2)}),--B2
		newButton({name="b3",		x=740,	y=130,w=75,color={color.rainbow( 0.685)},code=setPen(3)}),--B3
		newButton({name="b4",		x=820,	y=130,w=75,color={color.rainbow( 0.293)},code=setPen(4)}),--B4
		newButton({name="b5",		x=900,	y=130,w=75,color={color.rainbow(-0.100)},code=setPen(5)}),--B5
		newButton({name="b6",		x=980,	y=130,w=75,color={color.rainbow(-0.493)},code=setPen(6)}),--B6
		newButton({name="b7",		x=1060,	y=130,w=75,color={color.rainbow(-0.885)},code=setPen(7)}),--B7
		newButton({name="b8",		x=1140,	y=130,w=75,color={color.rainbow(-1.278)},code=setPen(8)}),--B8

		newButton({name="b9",		x=580,	y=210,w=75,color={color.rainbow(-1.671)},code=setPen(9)}),--B9
		newButton({name="b10",		x=660,	y=210,w=75,color={color.rainbow(-2.063)},code=setPen(10)}),--B10
		newButton({name="b11",		x=740,	y=210,w=75,color={color.rainbow(-2.456)},code=setPen(11)}),--B11
		newButton({name="b12",		x=820,	y=210,w=75,color={color.rainbow(-2.849)},code=setPen(12)}),--B12
		newButton({name="b13",		x=900,	y=210,w=75,color={color.rainbow(-3.242)},code=setPen(13)}),--B13
		newButton({name="b14",		x=980,	y=210,w=75,color={color.rainbow(-3.634)},code=setPen(14)}),--B14
		newButton({name="b15",		x=1060,	y=210,w=75,color={color.rainbow(-4.027)},code=setPen(15)}),--B15
		newButton({name="b16",		x=1140,	y=210,w=75,color={color.rainbow(-4.412)},code=setPen(16)}),--B16

		newButton({name="b17",		x=580,	y=290,w=75,color="dGrey",	code=setPen(17)}),--BONE
		newButton({name="b18",		x=660,	y=290,w=75,color="black",	code=setPen(18)}),--HIDE
		newButton({name="b19",		x=740,	y=290,w=75,color="lYellow",	code=setPen(19)}),--BOMB
		newButton({name="b20",		x=820,	y=290,w=75,color="grey",	code=setPen(20)}),--GB1
		newButton({name="b21",		x=900,	y=290,w=75,color="lGrey",	code=setPen(21)}),--GB2
		newButton({name="b22",		x=980,	y=290,w=75,color="dPurple",	code=setPen(22)}),--GB3
		newButton({name="b23",		x=1060,	y=290,w=75,color="dRed",	code=setPen(23)}),--GB4
		newButton({name="b24",		x=1140,	y=290,w=75,color="dGreen",	code=setPen(24)}),--GB5

		newButton({name="any",		x=600,	y=400,	w=120,	color="lGrey",	font=40,code=setPen(0)}),
		newButton({name="space",	x=730,	y=400,	w=120,	color="grey",	font=65,code=setPen(-1)}),
		newButton({name="copy",		x=905,	y=400,	w=120,	color="lRed",	font=35,code=pressKey("cC")}),
		newButton({name="paste",	x=1035,	y=400,	w=120,	color="lBlue",	font=35,code=pressKey("cV")}),
		newButton({name="clear",	x=1165,	y=400,	w=120,	color="white",	font=40,code=pressKey("delete")}),
		newButton({name="pushLine",	x=1035,	y=530,	w=120,	color="lYellow",font=20,code=pressKey("k")}),
		newButton({name="delLine",	x=1165,	y=530,	w=120,	color="lYellow",font=20,code=pressKey("l")}),
		newSwitch({name="demo",		x=755,	y=640,	disp=STPval("demo"),code=STPrev("demo")}),

		newButton({name="back",		x=1140,	y=640,	w=170,h=80,font=40,code=BACK}),
	},
	custom_sequence={
		newText({name="title",		x=520,y=5,font=70,align="R"}),
		newText({name="subTitle",	x=530,y=50,font=35,align="L",color="grey"}),

		newSelector({name="sequence",x=1080,y=60,	w=200,		color="yellow",list=SLClist.sequence,disp=CUSval("sequence"),code=CUSsto("sequence")}),

		newKey({name="Z",			x=100,	y=440,	w=90,						font=50,code=pressKey(1)}),
		newKey({name="S",			x=200,	y=440,	w=90,						font=50,code=pressKey(2)}),
		newKey({name="J",			x=300,	y=440,	w=90,						font=50,code=pressKey(3)}),
		newKey({name="L",			x=400,	y=440,	w=90,						font=50,code=pressKey(4)}),
		newKey({name="T",			x=500,	y=440,	w=90,						font=50,code=pressKey(5)}),
		newKey({name="O",			x=600,	y=440,	w=90,						font=50,code=pressKey(6)}),
		newKey({name="I",			x=700,	y=440,	w=90,						font=50,code=pressKey(7)}),

		newKey({name="Z5",			x=100,	y=540,	w=90,		color="grey",	font=50,code=pressKey(8)}),
		newKey({name="S5",			x=200,	y=540,	w=90,		color="grey",	font=50,code=pressKey(9)}),
		newKey({name="P",			x=300,	y=540,	w=90,		color="grey",	font=50,code=pressKey(10)}),
		newKey({name="Q",			x=400,	y=540,	w=90,		color="grey",	font=50,code=pressKey(11)}),
		newKey({name="F",			x=500,	y=540,	w=90,		color="grey",	font=50,code=pressKey(12)}),
		newKey({name="E",			x=600,	y=540,	w=90,		color="grey",	font=50,code=pressKey(13)}),
		newKey({name="T5",			x=700,	y=540,	w=90,		color="grey",	font=50,code=pressKey(14)}),
		newKey({name="U",			x=800,	y=540,	w=90,		color="grey",	font=50,code=pressKey(15)}),
		newKey({name="V",			x=900,	y=540,	w=90,		color="grey",	font=50,code=pressKey(16)}),
		newKey({name="W",			x=100,	y=640,	w=90,		color="grey",	font=50,code=pressKey(17)}),
		newKey({name="X",			x=200,	y=640,	w=90,		color="grey",	font=50,code=pressKey(18)}),
		newKey({name="J5",			x=300,	y=640,	w=90,		color="grey",	font=50,code=pressKey(19)}),
		newKey({name="L5",			x=400,	y=640,	w=90,		color="grey",	font=50,code=pressKey(20)}),
		newKey({name="R",			x=500,	y=640,	w=90,		color="grey",	font=50,code=pressKey(21)}),
		newKey({name="Y",			x=600,	y=640,	w=90,		color="grey",	font=50,code=pressKey(22)}),
		newKey({name="N",			x=700,	y=640,	w=90,		color="grey",	font=50,code=pressKey(23)}),
		newKey({name="H",			x=800,	y=640,	w=90,		color="grey",	font=50,code=pressKey(24)}),
		newKey({name="I5",			x=900,	y=640,	w=90,		color="grey",	font=50,code=pressKey(25)}),

		newKey({name="left",		x=800,	y=440,	w=90,		color="lGreen",	font=55,code=pressKey("left")}),
		newKey({name="right",		x=900,	y=440,	w=90,		color="lGreen",	font=55,code=pressKey("right")}),
		newKey({name="ten",			x=1000,	y=440,	w=90,		color="lGreen",	font=40,code=pressKey("ten")}),
		newKey({name="backsp",		x=1000,	y=540,	w=90,		color="lYellow",font=50,code=pressKey("backspace")}),
		newKey({name="reset",		x=1000,	y=640,	w=90,		color="lYellow",font=50,code=pressKey("delete")}),
		newButton({name="copy",		x=1140,	y=440,	w=170,h=80,	color="lRed",	font=40,code=pressKey("cC"),hide=function()return #BAG==0 end}),
		newButton({name="paste",	x=1140,	y=540,	w=170,h=80,	color="lBlue",	font=40,code=pressKey("cV")}),

		newButton({name="back",		x=1140,	y=640,	w=170,h=80,	font=40,code=BACK}),
	},
	custom_mission={
		newText({name="title",		x=520,y=5,font=70,align="R"}),
		newText({name="subTitle",	x=530,y=50,font=35,align="L",color="grey"}),

		newKey({name="_1",			x=800,	y=540,	w=90,	font=50,code=pressKey(01)}),
		newKey({name="_2",			x=900,	y=540,	w=90,	font=50,code=pressKey(02)}),
		newKey({name="_3",			x=800,	y=640,	w=90,	font=50,code=pressKey(03)}),
		newKey({name="_4",			x=900,	y=640,	w=90,	font=50,code=pressKey(04)}),
		newKey({name="any1",		x=100,	y=640,	w=90,			code=pressKey(05)}),
		newKey({name="any2",		x=200,	y=640,	w=90,			code=pressKey(06)}),
		newKey({name="any3",		x=300,	y=640,	w=90,			code=pressKey(07)}),
		newKey({name="any4",		x=400,	y=640,	w=90,			code=pressKey(08)}),
		newKey({name="PC",			x=500,	y=640,	w=90,	font=50,code=pressKey(09)}),

		newKey({name="Z1",			x=100,	y=340,	w=90,	font=50,code=pressKey(11)}),
		newKey({name="S1",			x=200,	y=340,	w=90,	font=50,code=pressKey(21)}),
		newKey({name="J1",			x=300,	y=340,	w=90,	font=50,code=pressKey(31)}),
		newKey({name="L1",			x=400,	y=340,	w=90,	font=50,code=pressKey(41)}),
		newKey({name="T1",			x=500,	y=340,	w=90,	font=50,code=pressKey(51)}),
		newKey({name="O1",			x=600,	y=340,	w=90,	font=50,code=pressKey(61)}),
		newKey({name="I1",			x=700,	y=340,	w=90,	font=50,code=pressKey(71)}),

		newKey({name="Z2",			x=100,	y=440,	w=90,	font=50,code=pressKey(12)}),
		newKey({name="S2",			x=200,	y=440,	w=90,	font=50,code=pressKey(22)}),
		newKey({name="J2",			x=300,	y=440,	w=90,	font=50,code=pressKey(32)}),
		newKey({name="L2",			x=400,	y=440,	w=90,	font=50,code=pressKey(42)}),
		newKey({name="T2",			x=500,	y=440,	w=90,	font=50,code=pressKey(52)}),
		newKey({name="O2",			x=600,	y=440,	w=90,	font=50,code=pressKey(62)}),
		newKey({name="I2",			x=700,	y=440,	w=90,	font=50,code=pressKey(72)}),

		newKey({name="Z3",			x=100,	y=540,	w=90,	font=50,code=pressKey(13)}),
		newKey({name="S3",			x=200,	y=540,	w=90,	font=50,code=pressKey(23)}),
		newKey({name="J3",			x=300,	y=540,	w=90,	font=50,code=pressKey(33)}),
		newKey({name="L3",			x=400,	y=540,	w=90,	font=50,code=pressKey(43)}),
		newKey({name="T3",			x=500,	y=540,	w=90,	font=50,code=pressKey(53)}),
		newKey({name="O3",			x=600,	y=540,	w=90,	font=50,code=pressKey(63)}),
		newKey({name="I3",			x=700,	y=540,	w=90,	font=50,code=pressKey(73)}),

		newKey({name="O4",			x=600,	y=640,	w=90,	font=50,code=pressKey(64)}),
		newKey({name="I4",			x=700,	y=640,	w=90,	font=50,code=pressKey(74)}),

		newKey({name="left",		x=800,	y=440,	w=90,		color="lGreen",	font=55,code=pressKey("left")}),
		newKey({name="right",		x=900,	y=440,	w=90,		color="lGreen",	font=55,code=pressKey("right")}),
		newKey({name="ten",			x=1000,	y=440,	w=90,		color="lGreen",	font=40,code=pressKey("ten")}),
		newKey({name="backsp",		x=1000,	y=540,	w=90,		color="lYellow",font=50,code=pressKey("backspace")}),
		newKey({name="reset",		x=1000,	y=640,	w=90,		color="lYellow",font=50,code=pressKey("delete")}),
		newButton({name="copy",		x=1140,	y=440,	w=170,h=80,	color="lRed",	font=40,code=pressKey("cC"),hide=function()return #MISSION==0 end}),
		newButton({name="paste",	x=1140,	y=540,	w=170,h=80,	color="lBlue",	font=40,code=pressKey("cV")}),
		newSwitch({name="mission",	x=1150, y=350,		disp=CUSval("missionKill"),		code=CUSrev("missionKill")}),

		newButton({name="back",		x=1140,	y=640,	w=170,h=80,	font=40,code=BACK}),
	},
	help={
		newImage({name="pay1",		x=20,	y=20}),
		newImage({name="pay2",		x=1014,	y=20}),
		newButton({name="dict",		x=1140,	y=410,w=220,h=70,font=35,code=goScene("dict")}),
		newButton({name="staff",	x=1140,	y=490,w=220,h=70,font=35,code=goScene("staff")}),
		newButton({name="his",		x=1140,	y=570,w=220,h=70,font=35,code=goScene("history")}),
		newButton({name="qq",		x=1140,	y=650,w=220,h=70,font=35,code=function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,hide=mobileHide}),
		newButton({name="back",		x=640,	y=600,w=170,h=80,font=35,code=BACK}),
	},
	dict={
		newText({name="title",		x=20,	y=5,font=70,align="L"}),
		newKey({name="keyboard",	x=960,	y=60,w=200,h=80,font=35,code=function()love.keyboard.setTextInput(true,0,0,1,1)end,hide=mobileShow}),
		newKey({name="link",		x=1140,	y=650,w=200,h=80,font=35,code=pressKey("link"),hide=function()return not sceneTemp.url end}),
		newKey({name="up",			x=1190,	y=440,w=100,h=100,font=35,code=pressKey("up"),hide=mobileShow}),
		newKey({name="down",		x=1190,	y=550,w=100,h=100,font=35,code=pressKey("down"),hide=mobileShow}),
		newButton({name="back",		x=1165,	y=60,w=170,h=80,font=40,code=BACK}),
	},
	staff={
		newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=BACK}),
	},
	history={
		newKey({name="prev",		x=1155,	y=170,w=180,font=65,code=pressKey("up"),hide=STPeq("pos",1)}),
		newKey({name="next",		x=1155,	y=400,w=180,font=65,code=pressKey("down"),hide=function()return sceneTemp.pos==#sceneTemp.text end}),
		newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=BACK}),
	},
	stat={
		newButton({name="path",		x=980,	y=620,w=250,h=80,font=25,code=function()love.system.openURL(love.filesystem.getSaveDirectory())end,hide=mobileHide}),
		newButton({name="back",		x=640,	y=620,w=200,h=80,font=35,code=BACK}),
	},
	lang={
		newButton({name="zh",		x=160,	y=100,w=200,h=120,font=45,code=setLang(1)}),
		newButton({name="zh2",		x=380,	y=100,w=200,h=120,font=45,code=setLang(2)}),
		newButton({name="en",		x=600,	y=100,w=200,h=120,font=45,code=setLang(3)}),
		newButton({name="symbol",	x=820,	y=100,w=200,h=120,font=45,code=setLang(4)}),
		newButton({name="yygq",		x=1040,	y=100,w=200,h=120,font=45,code=setLang(5)}),
		newButton({name="back",		x=640,	y=600,w=200,h=80,font=35,code=BACK}),
	},
	music={
		newText({name="title",		x=30,	y=30,font=80,align="L"}),
		newText({name="arrow",		x=270,	y=360,font=45,align="L"}),
		newText({name="now",		x=700,	y=500,font=50,align="R",hide=function()return not BGM.nowPlay end}),
		newSlider({name="bgm",		x=760,	y=80,w=400,			font=35,disp=SETval("bgm"),code=function(v)SETTING.bgm=v BGM.freshVolume()end}),
		newButton({name="up",		x=200,	y=250,w=120,		font=55,code=pressKey("up"),hide=function()return sceneTemp==1 end}),
		newButton({name="play",		x=200,	y=390,w=120,		font=35,code=pressKey("space"),hide=function()return SETTING.bgm==0 end}),
		newButton({name="down",		x=200,	y=530,w=120,		font=55,code=pressKey("down"),hide=function()return sceneTemp==BGM.len end}),
		newButton({name="back",		x=1140,	y=640,w=170,h=80,	font=40,code=BACK}),
	},
	login={
		newText({name="title",		x=80,	y=50,font=70,align="L"}),
		newTextBox({name="username",x=380,	y=160,w=500,h=60,regex="[0-9A-Za-z_]"}),
		newTextBox({name="email",	x=380,	y=260,w=626,h=60,regex="[0-9A-Za-z@-._]"}),
		newTextBox({name="code",	x=380,	y=360,w=626,h=60,regex="[0-9A-Za-z]"}),
		newTextBox({name="password",x=380,	y=460,w=626,h=60,secret=true,regex="[ -~]"}),
		newTextBox({name="password2",x=380,	y=560,w=626,h=60,secret=true,regex="[ -~]"}),
		newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=BACK}),
	},
	account={
		newText({name="title",		x=80,	y=50,font=70,align="L"}),
		newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=BACK}),
	},
	sound={
		newText({name="title",		x=30,	y=15,font=70,align="L"}),

		newKey({name="move",		x=100,	y=140,w=140,h=50,code=function()SFX.play("move")end}),
		newKey({name="lock",		x=100,	y=205,w=140,h=50,code=function()SFX.play("lock")end}),
		newKey({name="drop",		x=100,	y=270,w=140,h=50,code=function()SFX.play("drop")end}),
		newKey({name="fall",		x=100,	y=335,w=140,h=50,code=function()SFX.play("fall")end}),
		newKey({name="rotate",		x=100,	y=400,w=140,h=50,code=function()SFX.play("rotate")end}),
		newKey({name="rotatekick",	x=100,	y=465,w=140,h=50,code=function()SFX.play("rotatekick")end}),
		newKey({name="hold",		x=100,	y=530,w=140,h=50,code=function()SFX.play("hold")end}),
		newKey({name="prerotate",	x=100,	y=595,w=140,h=50,code=function()SFX.play("prerotate")end}),
		newKey({name="prehold",		x=100,	y=660,w=140,h=50,code=function()SFX.play("prehold")end}),

		newKey({name="_1",			x=260,	y=140,w=140,h=50,code=function()SFX.play("clear_1")end}),
		newKey({name="_2",			x=260,	y=205,w=140,h=50,code=function()SFX.play("clear_2")end}),
		newKey({name="_3",			x=260,	y=270,w=140,h=50,code=function()SFX.play("clear_3")end}),
		newKey({name="_4",			x=260,	y=335,w=140,h=50,code=function()SFX.play("clear_4")end}),
		newKey({name="spin0",		x=260,	y=400,w=140,h=50,code=function()SFX.play("spin_0")end}),
		newKey({name="spin1",		x=260,	y=465,w=140,h=50,code=function()SFX.play("spin_1")end}),
		newKey({name="spin2",		x=260,	y=530,w=140,h=50,code=function()SFX.play("spin_2")end}),
		newKey({name="spin3",		x=260,	y=595,w=140,h=50,code=function()SFX.play("spin_3")end}),

		newKey({name="z0",			x=660,	y=80,w=140,h=50,code=pressKey(10)}),
		newKey({name="z1",			x=660,	y=145,w=140,h=50,code=pressKey(11)}),
		newKey({name="z2",			x=660,	y=210,w=140,h=50,code=pressKey(12)}),
		newKey({name="z3",			x=660,	y=275,w=140,h=50,code=pressKey(13)}),
		newKey({name="t0",			x=660,	y=340,w=140,h=50,code=pressKey(50)}),
		newKey({name="t1",			x=660,	y=405,w=140,h=50,code=pressKey(51)}),
		newKey({name="t2",			x=660,	y=470,w=140,h=50,code=pressKey(52)}),
		newKey({name="t3",			x=660,	y=535,w=140,h=50,code=pressKey(53)}),

		newKey({name="s0",			x=820,	y=80,w=140,h=50,code=pressKey(20)}),
		newKey({name="s1",			x=820,	y=145,w=140,h=50,code=pressKey(21)}),
		newKey({name="s2",			x=820,	y=210,w=140,h=50,code=pressKey(22)}),
		newKey({name="s3",			x=820,	y=275,w=140,h=50,code=pressKey(23)}),
		newKey({name="o0",			x=820,	y=340,w=140,h=50,code=pressKey(60)}),
		newKey({name="o1",			x=820,	y=405,w=140,h=50,code=pressKey(61)}),
		newKey({name="o2",			x=820,	y=470,w=140,h=50,code=pressKey(62)}),
		newKey({name="o3",			x=820,	y=535,w=140,h=50,code=pressKey(63)}),

		newKey({name="j0",			x=980,	y=80,w=140,h=50,code=pressKey(30)}),
		newKey({name="j1",			x=980,	y=145,w=140,h=50,code=pressKey(31)}),
		newKey({name="j2",			x=980,	y=210,w=140,h=50,code=pressKey(32)}),
		newKey({name="j3",			x=980,	y=275,w=140,h=50,code=pressKey(33)}),
		newKey({name="i0",			x=980,	y=340,w=140,h=50,code=pressKey(70)}),
		newKey({name="i1",			x=980,	y=405,w=140,h=50,code=pressKey(71)}),
		newKey({name="i2",			x=980,	y=470,w=140,h=50,code=pressKey(72)}),
		newKey({name="i3",			x=980,	y=535,w=140,h=50,code=pressKey(73)}),

		newKey({name="l0",			x=1140,	y=80,w=140,h=50,code=pressKey(40)}),
		newKey({name="l1",			x=1140,	y=145,w=140,h=50,code=pressKey(41)}),
		newKey({name="l2",			x=1140,	y=210,w=140,h=50,code=pressKey(42)}),
		newKey({name="l3",			x=1140,	y=275,w=140,h=50,code=pressKey(43)}),

		newSwitch({name="mini",		x=380,	y=660,disp=STPval("mini"),code=pressKey("1")}),
		newSwitch({name="b2b",		x=560,	y=660,disp=STPval("b2b"),code=pressKey("2")}),
		newSwitch({name="b3b",		x=740,	y=660,disp=STPval("b3b"),code=pressKey("3")}),
		newSwitch({name="pc",		x=940,	y=660,disp=STPval("pc"),code=pressKey("4")}),

		newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=BACK}),
	},
	minigame={
		newButton({name="p15",		x=240,	y=250,w=350,h=120,font=40,code=goScene("p15")}),
		newButton({name="schulte_G",x=640,	y=250,w=350,h=120,font=40,code=goScene("schulte_G")}),
		newButton({name="pong",		x=1040,	y=250,w=350,h=120,font=40,code=goScene("pong")}),
		newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=BACK}),
	},
	p15={
		newButton({name="reset",	x=160,y=100,w=180,h=100,color="lGreen",	font=40,code=pressKey("space")}),
		newSlider({name="color",	x=110,y=250,w=170,unit=4,show=false,font=30,disp=STPval("color"),	code=function(v)if sceneTemp.state~=1 then sceneTemp.color=v end end,hide=STPeq("state",1)}),
		newSwitch({name="blind",	x=240,y=330,w=60,					font=40,disp=STPval("blind"),	code=pressKey("w"),	hide=STPeq("state",1)}),
		newSwitch({name="slide",	x=240,y=420,w=60,					font=40,disp=STPval("slide"),	code=pressKey("e"),	hide=STPeq("state",1)}),
		newSwitch({name="pathVis",	x=240,y=510,w=60,					font=40,disp=STPval("pathVis"),	code=pressKey("r"),	hide=function()return sceneTemp.state==1 or not sceneTemp.slide end}),
		newSwitch({name="revKB",	x=240,y=600,w=60,					font=40,disp=STPval("revKB"),	code=pressKey("t"),	hide=STPeq("state",1)}),
		newButton({name="back",		x=1140,y=640,w=170,h=80,			font=40,code=BACK}),
	},
	schulte_G={
		newButton({name="reset",	x=160,y=100,w=180,h=100,color="lGreen",font=40,code=pressKey("space"),hide=function()return sceneTemp.state==0 end}),
		newSlider({name="rank",		x=130,y=250,w=150,unit=3,show=false,font=40,disp=function()return sceneTemp.rank-3 end,code=function(v)sceneTemp.rank=v+3 end,hide=function()return sceneTemp.state>0 end}),
		newSwitch({name="blind",	x=240,y=330,w=60,					font=40,disp=STPval("blind"),	code=pressKey("q"),hide=STPeq("state",1)}),
		newSwitch({name="disappear",x=240,y=420,w=60,					font=40,disp=STPval("disappear"),code=pressKey("w"),hide=STPeq("state",1)}),
		newSwitch({name="tapFX",	x=240,y=510,w=60,					font=40,disp=STPval("tapFX"),	code=pressKey("e"),hide=STPeq("state",1)}),
		newButton({name="back",		x=1140,y=640,w=170,h=80,			font=40,code=BACK}),
	},
	pong={
		newKey({name="reset",		x=640,y=45,w=150,h=50,		font=35,code=pressKey("r")}),
		newKey({name="back",		x=640,y=675,w=150,h=50,		font=35,code=BACK}),
	},
	debug={
		newButton({name="scrInfo",	x=300,y=120,w=300,h=100,color="green",code=function()
			LOG.print("Screen Info:")
			LOG.print("x y: "..SCR.x.." "..SCR.y)
			LOG.print("w h: "..SCR.w.." "..SCR.h)
			LOG.print("W H: "..SCR.W.." "..SCR.H)
			LOG.print("k: "..math.floor(SCR.k*100)*.01)
			LOG.print("rad: "..math.floor(SCR.rad*100)*.01)
			LOG.print("dpi: "..SCR.dpi)
		end}),
		newButton({name="reset",x=640,y=380,w=240,h=100,color="orange",font=40,
			code=function()sceneTemp.reset=true end,
			hide=STPval("reset")}),
		newButton({name="reset1",x=340,y=480,w=240,h=100,color="red",font=35,
			code=function()
				love.filesystem.remove("unlock.dat")
				SFX.play("finesseError_long")
				TEXT.show("rank resetted",640,300,60,"stretch",.4)
				TEXT.show("effected after restart game",640,360,60,"stretch",.4)
				TEXT.show("play one game if you regret",640,390,40,"stretch",.4)
			end,
			hide=function()return not sceneTemp.reset end}),
		newButton({name="reset2",x=640,y=480,w=260,h=100,color="red",font=35,
			code=function()
				love.filesystem.remove("data.dat")
				SFX.play("finesseError_long")
				TEXT.show("game data resetted",640,300,60,"stretch",.4)
				TEXT.show("effected after restart game",640,360,60,"stretch",.4)
				TEXT.show("play one game if you regret",640,390,40,"stretch",.4)
			end,
			hide=function()return not sceneTemp.reset end}),
		newButton({name="reset3",x=940,y=480,w=260,h=100,color="red",font=35,
			code=function()
				local L=love.filesystem.getDirectoryItems("")
				for i=1,#L do
					local s=L[i]
					if s:sub(-4)==".dat"then
						love.filesystem.remove(s)
					end
				end
				SFX.play("clear_4")SFX.play("finesseError_long")
				TEXT.show("all file deleted",640,330,60,"stretch",.4)
				TEXT.show("effected after restart game",640,390,60,"stretch",.4)
				SCN.back()
			end,
			hide=function()return not sceneTemp.reset end}),
		newButton({name="back",x=640,y=620,w=200,h=80,font=40,code=BACK}),
	},
}
local indexWithName={
	__index=function(L,k)
		for i=1,#L do
			if L[i].name==k then
				return L[i]
			end
		end
	end
}
for _,v in next,Widgets do
	setmetatable(v,indexWithName)
end
return Widgets