local rnd=math.random
local ins,rem=table.insert,table.remove
local mobileHide=(system=="Android"or system=="iOS")and function()return true end
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

--Lambda Funcs for widgets,delete at file end
function SETval(k)	return function()return setting[k]					end end
function SETsto(k)	return function(i)setting[k]=i						end end
function SETrev(k)	return function()setting[k]=not setting[k]			end end
function pressKey(k)return function()love.keypressed(k)					end end
function setPen(i)	return function()sceneTemp.pen=i					end end
function prevSkin(n)return function()SKIN.prev(n)						end end
function nextSkin(n)return function()SKIN.next(n)						end end
function nextDir(n)	return function()SKIN.rotate(n)						end end
function VKAdisp(n)	return function()return VK_org[n].ava				end end
function VKAcode(n)	return function()VK_org[n].ava=not VK_org[n].ava	end end
function setLang(n)	return function()LANG.set(n)setting.lang=n			end end
function goScene(s)	return function()SCN.go(s)							end end

--NewXXX
newText=WIDGET.newText
newImage=WIDGET.newImage
newButton=WIDGET.newButton
newKey=WIDGET.newKey
newSwitch=WIDGET.newSwitch
newSlider=WIDGET.newSlider

--All widgets
local Widgets={
	load={},intro={},quit={},
	calculator={
		newKey({name="_1",			x=150,y=300,w=90,		color="white",	font=50,code=pressKey("1")}),
		newKey({name="_2",			x=250,y=300,w=90,		color="white",	font=50,code=pressKey("2")}),
		newKey({name="_3",			x=350,y=300,w=90,		color="white",	font=50,code=pressKey("3")}),
		newKey({name="_4",			x=150,y=400,w=90,		color="white",	font=50,code=pressKey("4")}),
		newKey({name="_5",			x=250,y=400,w=90,		color="white",	font=50,code=pressKey("5")}),
		newKey({name="_6",			x=350,y=400,w=90,		color="white",	font=50,code=pressKey("6")}),
		newKey({name="_7",			x=150,y=500,w=90,		color="white",	font=50,code=pressKey("7")}),
		newKey({name="_8",			x=250,y=500,w=90,		color="white",	font=50,code=pressKey("8")}),
		newKey({name="_9",			x=350,y=500,w=90,		color="white",	font=50,code=pressKey("9")}),
		newKey({name="_0",			x=150,y=600,w=90,		color="white",	font=50,code=pressKey("0")}),
		newKey({name="<",			x=250,y=600,w=90,		color="lRed",	font=50,code=pressKey("backspace")}),
		newKey({name="=",			x=350,y=600,w=90,		color="lYellow",font=50,code=pressKey("return")}),
		newKey({name="+",			x=450,y=300,w=90,		color="lBlue",	font=50,code=pressKey("+")}),
		newKey({name="-",			x=450,y=400,w=90,		color="lBlue",	font=50,code=pressKey("-")}),
		newKey({name="*",			x=450,y=500,w=90,		color="lBlue",	font=50,code=pressKey("*")}),
		newKey({name="/",			x=450,y=600,w=90,		color="lBlue",	font=50,code=pressKey("/")}),
		newButton({name="play",		x=640,y=600,w=180,h=90,	color="lGreen",	font=40,code=pressKey("space"),hide=function()return not sceneTemp.pass end}),
	},
	main={
		newButton({name="play",		x=150,y=280,w=200,h=160,color="lRed",	font=55,code=goScene("mode")}),
		newButton({name="setting",	x=370,y=280,w=200,h=160,color="lBlue",	font=45,code=goScene("setting_game")}),
		newButton({name="music",	x=590,y=280,w=200,h=160,color="lPurple",font=32,code=goScene("music")}),
		newButton({name="help",		x=150,y=460,w=200,h=160,color="lYellow",font=50,code=goScene("help")}),
		newButton({name="stat",		x=370,y=460,w=200,h=160,color="lCyan",	font=43,code=goScene("stat")}),
		newButton({name="qplay",	x=590,y=460,w=200,h=160,color="lOrange",font=43,code=function()SCN.push()loadGame(stat.lastPlay,true)end}),
		newButton({name="lang",		x=150,y=610,w=160,h=100,color="lGreen",	font=45,code=goScene("setting_lang")}),
		newButton({name="minigame",	x=370,y=610,w=80,		color="black",			code=goScene("minigame")}),
		newButton({name="quit",		x=590,y=610,w=160,h=100,color="lGrey",	font=45,code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end}),
	},
	mode={
		newButton({name="setting",	x=1100,y=540,w=240,h=90,color="lGreen",	font=40,code=function()
				SCN.go("custom")
			end,
			hide=function()
				return mapCam.sel~="custom_clear" and mapCam.sel~="custom_puzzle"
			end}),
		newButton({name="start",	x=1040,y=655,w=180,h=80,color="white",	font=40,code=pressKey("return"),hide=function()return not mapCam.sel end}),
		newButton({name="back",		x=1200,y=655,w=120,h=80,color="white",	font=40,code=BACK}),
	},
	music={
		newSlider({name="bgm",		x=760,	y=80,	w=400,							font=35,disp=SETval("bgm"),code=function(v)setting.bgm=v;BGM.freshVolume()end}),
		newButton({name="up",		x=1100,	y=200,	w=120,			color="white",	font=55,code=pressKey("up")}),
		newButton({name="play",		x=1100,	y=340,	w=120,			color="white",	font=35,code=pressKey("space"),hide=function()return setting.bgm==0 end}),
		newButton({name="down",		x=1100,	y=480,	w=120,			color="white",	font=55,code=pressKey("down")}),
		newButton({name="back",		x=1140,	y=640,	w=180,h=80,		color="white",	font=35,code=BACK}),
	},
	custom={
		newKey({name="up",			x=1140,	y=100,	w=100,			color="white",	font=45,code=function()sceneTemp=(sceneTemp-2)%#customID+1 end}),
		newKey({name="down",		x=1140,	y=340,	w=100,			color="white",	font=45,code=function()sceneTemp=sceneTemp%#customID+1 end}),
		newKey({name="left",		x=1080,	y=220,	w=100,			color="white",	font=45,code=pressKey("left")}),
		newKey({name="right",		x=1200,	y=220,	w=100,			color="white",	font=45,code=pressKey("right")}),

		newButton({name="set1",		x=900,	y=320,	w=210,h=70,		color="lYellow",font=32,code=pressKey("1")}),
		newButton({name="set2",		x=900,	y=400,	w=210,h=70,		color="lYellow",font=32,code=pressKey("2")}),
		newButton({name="set3",		x=900,	y=480,	w=210,h=70,		color="lYellow",font=32,code=pressKey("3")}),
		newButton({name="set4",		x=900,	y=560,	w=210,h=70,		color="lYellow",font=32,code=pressKey("4")}),
		newButton({name="set5",		x=900,	y=640,	w=210,h=70,		color="lYellow",font=32,code=pressKey("5")}),

		newButton({name="seq",		x=665,	y=415,	w=200,h=40,		color="lGreen",	font=30,code=pressKey("q")}),
		newButton({name="draw",		x=150,	y=80,	w=220,h=80,		color="white",	font=35,code=pressKey("e")}),
		newButton({name="back",		x=1140,	y=640,	w=180,h=80,		color="white",	font=35,code=BACK}),
	},
	sequence={
		newKey({name="Z",			x=100,	y=440,	w=90,			color="white",	font=50,code=pressKey(1)}),
		newKey({name="S",			x=200,	y=440,	w=90,			color="white",	font=50,code=pressKey(2)}),
		newKey({name="J",			x=300,	y=440,	w=90,			color="white",	font=50,code=pressKey(3)}),
		newKey({name="L",			x=400,	y=440,	w=90,			color="white",	font=50,code=pressKey(4)}),
		newKey({name="T",			x=500,	y=440,	w=90,			color="white",	font=50,code=pressKey(5)}),
		newKey({name="O",			x=600,	y=440,	w=90,			color="white",	font=50,code=pressKey(6)}),
		newKey({name="I",			x=700,	y=440,	w=90,			color="white",	font=50,code=pressKey(7)}),

		newKey({name="Z5",			x=100,	y=540,	w=90,			color="grey",	font=50,code=pressKey(8)}),
		newKey({name="S5",			x=200,	y=540,	w=90,			color="grey",	font=50,code=pressKey(9)}),
		newKey({name="P",			x=300,	y=540,	w=90,			color="grey",	font=50,code=pressKey(10)}),
		newKey({name="Q",			x=400,	y=540,	w=90,			color="grey",	font=50,code=pressKey(11)}),
		newKey({name="F",			x=500,	y=540,	w=90,			color="grey",	font=50,code=pressKey(12)}),
		newKey({name="E",			x=600,	y=540,	w=90,			color="grey",	font=50,code=pressKey(13)}),
		newKey({name="T5",			x=700,	y=540,	w=90,			color="grey",	font=50,code=pressKey(14)}),
		newKey({name="U",			x=800,	y=540,	w=90,			color="grey",	font=50,code=pressKey(15)}),
		newKey({name="V",			x=900,	y=540,	w=90,			color="grey",	font=50,code=pressKey(16)}),
		newKey({name="W",			x=100,	y=640,	w=90,			color="grey",	font=50,code=pressKey(17)}),
		newKey({name="X",			x=200,	y=640,	w=90,			color="grey",	font=50,code=pressKey(18)}),
		newKey({name="J5",			x=300,	y=640,	w=90,			color="grey",	font=50,code=pressKey(19)}),
		newKey({name="L5",			x=400,	y=640,	w=90,			color="grey",	font=50,code=pressKey(20)}),
		newKey({name="R",			x=500,	y=640,	w=90,			color="grey",	font=50,code=pressKey(21)}),
		newKey({name="Y",			x=600,	y=640,	w=90,			color="grey",	font=50,code=pressKey(22)}),
		newKey({name="N",			x=700,	y=640,	w=90,			color="grey",	font=50,code=pressKey(23)}),
		newKey({name="H",			x=800,	y=640,	w=90,			color="grey",	font=50,code=pressKey(24)}),
		newKey({name="I5",			x=900,	y=640,	w=90,			color="grey",	font=50,code=pressKey(25)}),

		newKey({name="left",		x=800,	y=440,	w=90,			color="lGreen",	font=55,code=pressKey("left")}),
		newKey({name="right",		x=900,	y=440,	w=90,			color="lGreen",	font=55,code=pressKey("right")}),
		newKey({name="backsp",		x=1000,	y=440,	w=90,			color="lYellow",font=50,code=pressKey("backspace")}),
		newKey({name="reset",		x=1000,	y=540,	w=90,			color="lYellow",font=50,code=pressKey("delete")}),
		newButton({name="copy",		x=1140,	y=440,	w=170,h=90,		color="lRed",	font=40,code=pressKey("cC"),hide=function()return #preBag==0 end}),
		newButton({name="paste",	x=1140,	y=540,	w=170,h=90,		color="lBlue",	font=40,code=pressKey("cV")}),
		newButton({name="back",		x=1140,	y=640,	w=180,h=80,		color="white",	font=35,code=BACK}),
	},
	draw={
		newButton({name="b1",		x=500+65*1,	y=150,	w=58,		color="red",	font=30,code=setPen(1)}),--B1
		newButton({name="b2",		x=500+65*2,	y=150,	w=58,		color="orange",	font=30,code=setPen(2)}),--B2
		newButton({name="b3",		x=500+65*3,	y=150,	w=58,		color="yellow",	font=30,code=setPen(3)}),--B3
		newButton({name="b4",		x=500+65*4,	y=150,	w=58,		color="grass",	font=30,code=setPen(4)}),--B4
		newButton({name="b5",		x=500+65*5,	y=150,	w=58,		color="green",	font=30,code=setPen(5)}),--B5
		newButton({name="b6",		x=500+65*6,	y=150,	w=58,		color="water",	font=30,code=setPen(6)}),--B6
		newButton({name="b7",		x=500+65*7,	y=150,	w=58,		color="cyan",	font=30,code=setPen(7)}),--B7
		newButton({name="b8",		x=500+65*8,	y=150,	w=58,		color="blue",	font=30,code=setPen(8)}),--B8
		newButton({name="b9",		x=500+65*9,	y=150,	w=58,		color="purple",	font=30,code=setPen(9)}),--B9
		newButton({name="b10",		x=500+65*10,y=150,	w=58,		color="magenta",font=30,code=setPen(10)}),--B10
		newButton({name="b11",		x=500+65*11,y=150,	w=58,		color="pink",	font=30,code=setPen(11)}),--B11

		newButton({name="b12",		x=500+65*1,	y=230,	w=58,		color="dGrey",	font=30,code=setPen(12)}),--Bone
		newButton({name="b13",		x=500+65*2,	y=230,	w=58,		color="grey",	font=30,code=setPen(13)}),--GB1
		newButton({name="b14",		x=500+65*3,	y=230,	w=58,		color="lGrey",	font=30,code=setPen(14)}),--GB2
		newButton({name="b15",		x=500+65*4,	y=230,	w=58,		color="dPurple",font=30,code=setPen(15)}),--GB3
		newButton({name="b16",		x=500+65*5,	y=230,	w=58,		color="dRed",	font=30,code=setPen(16)}),--GB4
		newButton({name="b17",		x=500+65*6,	y=230,	w=58,		color="dGreen",	font=30,code=setPen(17)}),--GB5

		newButton({name="any",		x=600,		y=360,	w=120,		color="lGrey",	font=40,code=setPen(0)}),
		newButton({name="space",	x=730,		y=360,	w=120,		color="grey",	font=65,code=setPen(-1)}),
		newButton({name="copy",		x=920,		y=500,	w=120,		color="lRed",	font=35,code=pressKey("cC")}),
		newButton({name="paste",	x=1060,		y=500,	w=120,		color="lBlue",	font=35,code=pressKey("cV")}),
		newButton({name="clear",	x=1200,		y=500,	w=120,		color="white",	font=40,code=pressKey("delete")}),
		newSwitch({name="demo",		x=755,		y=640,									font=30,disp=function()return sceneTemp.demo end,code=function()sceneTemp.demo=not sceneTemp.demo end}),
		newButton({name="custom",	x=110,		y=80,	w=140,h=80,	color="white",	font=35,code=pressKey("e")}),
		newButton({name="back",		x=1140,		y=640,	w=180,h=80,	color="white",	font=35,code=BACK}),
	},
	play={
		newButton({name="pause",	x=1235,	y=45,	w=80,			color="white",	font=25,code=function()pauseGame()end}),
	},
	pause={
		newButton({name="setting",	x=1120,	y=70,	w=240,h=90,	color="lBlue",	font=35,code=pressKey("s")}),
		newButton({name="replay",	x=640,	y=250,	w=240,h=100,color="lYellow",font=30,code=pressKey("p"),hide=function()return not(game.result or game.replaying)end}),
		newButton({name="resume",	x=640,	y=367,	w=240,h=100,color="lGreen",	font=30,code=pressKey("escape")}),
		newButton({name="restart",	x=640,	y=483,	w=240,h=100,color="lRed",	font=33,code=pressKey("r")}),
		newButton({name="quit",		x=640,	y=600,	w=240,h=100,color="white",	font=35,code=BACK}),
	},
	setting_game={
		newButton({name="graphic",	x=200,	y=80,	w=240,h=80,	color="lCyan",	font=35,code=function()SCN.swapTo("setting_video","swipe")end}),
		newButton({name="sound",	x=1080,	y=80,	w=240,h=80,	color="lCyan",	font=35,code=function()SCN.swapTo("setting_sound","swipe")end}),
		newButton({name="ctrl",		x=290,	y=220,	w=320,h=80,	color="lYellow",font=35,code=goScene("setting_control")}),
		newButton({name="key",		x=640,	y=220,	w=320,h=80,	color="lGreen",	font=35,code=goScene("setting_key")}),
		newButton({name="touch",	x=990,	y=220,	w=320,h=80,	color="lBlue",	font=35,code=goScene("setting_touch")}),
		newSlider({name="reTime",	x=350,	y=340,	w=300,unit=10,				font=30,disp=SETval("reTime"),	code=SETsto("reTime"),show=function(S)return(.5+S.disp()*.25).."s"end}),
		newSlider({name="maxNext",	x=350,	y=440,	w=300,unit=6,				font=30,disp=SETval("maxNext"),	code=SETsto("maxNext")}),
		newButton({name="layout",	x=460,	y=540,	w=140,h=70,color="white",	font=35,code=function()
			SCN.go("setting_skin")
			end}),
		newSwitch({name="autoPause",x=1080,	y=320,	font=20,disp=SETval("autoPause"),	code=SETrev("autoPause")}),
		newSwitch({name="swap",		x=1080,	y=380,	font=20,disp=SETval("swap"),		code=SETrev("swap")}),
		newSwitch({name="fine",		x=1080,	y=440,	font=20,disp=SETval("fine"),		code=SETrev("fine")}),
		newSwitch({name="appLock",	x=1080,	y=500,	font=20,disp=SETval("appLock"),		code=SETrev("appLock")}),
		newButton({name="back",		x=1140,	y=640,	w=180,h=80,color="white",	font=35,code=BACK}),
	},
	setting_video={
		newButton({name="sound",	x=200,	y=80,w=240,h=80,color="lCyan",font=35,code=function()SCN.swapTo("setting_sound","swipe")end}),
		newButton({name="game",		x=1080,	y=80,w=240,h=80,color="lCyan",font=35,code=function()SCN.swapTo("setting_game","swipe")end}),
		newSlider({name="ghost",	x=250,	y=180,w=200,unit=.6,font=35,disp=SETval("ghost"),show="percent",code=SETsto("ghost")}),
		newSlider({name="center",	x=620,	y=180,w=200,unit=1,	font=35,disp=SETval("center"),	code=SETsto("center")}),
		newSwitch({name="smooth",	x=260,	y=260,				font=25,disp=SETval("smooth"),	code=SETrev("smooth")}),
		newSwitch({name="grid",		x=480,	y=260,				font=35,disp=SETval("grid"),	code=SETrev("grid")}),
		newSwitch({name="bagLine",	x=700,	y=260,				font=30,disp=SETval("bagLine"),	code=SETrev("bagLine")}),
		newSlider({name="lockFX",	x=350,	y=340,w=373,unit=5,	font=32,disp=SETval("lockFX"),	code=SETsto("lockFX")}),
		newSlider({name="dropFX",	x=350,	y=390,w=373,unit=5,	font=32,disp=SETval("dropFX"),	code=SETsto("dropFX")}),
		newSlider({name="moveFX",	x=350,	y=440,w=373,unit=5,	font=32,disp=SETval("moveFX"),	code=SETsto("moveFX")}),
		newSlider({name="clearFX",	x=350,	y=490,w=373,unit=5,	font=32,disp=SETval("clearFX"),	code=SETsto("clearFX")}),
		newSlider({name="shakeFX",	x=350,	y=540,w=373,unit=5,	font=32,disp=SETval("shakeFX"),	code=SETsto("shakeFX")}),
		newSlider({name="atkFX",	x=350,	y=590,w=373,unit=5,	font=32,disp=SETval("atkFX"),	code=SETsto("atkFX")}),
		newSlider({name="frame",	x=350,	y=640,w=373,unit=10,font=30,
			disp=function()
				return setting.frameMul>35 and setting.frameMul/10 or setting.frameMul/5-4
			end,
			code=function(i)
				setting.frameMul=i<5 and 5*i+20 or 10*i
			end}),
		newSwitch({name="text",		x=1050,	y=180,font=35,disp=SETval("text"),code=SETrev("text")}),
		newSwitch({name="warn",		x=1050,	y=260,font=35,disp=SETval("warn"),code=SETrev("warn")}),
		newSwitch({name="fullscreen",x=1050,y=340,font=35,disp=SETval("fullscreen"),
			code=function()
				setting.fullscreen=not setting.fullscreen
				love.window.setFullscreen(setting.fullscreen)
				love.resize(love.graphics.getWidth(),love.graphics.getHeight())
			end}),
		newSwitch({name="bg",		x=1050,	y=420,font=35,disp=SETval("bg"),
			code=function()
				BG.set("none")
				setting.bg=not setting.bg
				BG.set("space")
			end}),
		newSwitch({name="power",	x=1050,	y=500,font=35,disp=SETval("powerInfo"),
			code=function()
				setting.powerInfo=not setting.powerInfo
			end}),
		newButton({name="back",		x=1140,	y=640,w=180,h=80,color="white",	font=35,code=BACK}),
	},
	setting_sound={
		newButton({name="game",		x=200,	y=80,w=240,h=80,color="lCyan",	font=35,code=function()SCN.swapTo("setting_game","swipe")end}),
		newButton({name="graphic",	x=1080,	y=80,w=240,h=80,color="lCyan",	font=35,code=function()SCN.swapTo("setting_video","swipe")end}),
		newSlider({name="sfx",		x=180,	y=200,w=400,					font=35,change=function()SFX.play("blip_1")end,						disp=SETval("sfx"),		code=SETsto("sfx")}),
		newSlider({name="stereo",	x=180,	y=500,w=400,					font=35,change=function()SFX.play("move",1,-1)SFX.play("lock",1,1)end,disp=SETval("stereo"),code=SETsto("stereo"),hide=function()return setting.sfx==0 end}),
		newSlider({name="spawn",	x=180,	y=300,w=400,					font=30,change=function()SFX.fplay("spawn_"..rnd(7),setting.spawn)end,disp=SETval("spawn"),	code=SETsto("spawn")}),
		newSlider({name="bgm",		x=180,	y=400,w=400,					font=35,change=function()BGM.freshVolume()end,						disp=SETval("bgm"),		code=SETsto("bgm")}),
		newSlider({name="vib",		x=750,	y=200,w=400,	unit=5,			font=28,change=function()VIB(2)end,									disp=SETval("vib"),		code=SETsto("vib")}),
		newSlider({name="voc",		x=750,	y=300,w=400,					font=32,change=function()VOC.play("nya")end,						disp=SETval("voc"),		code=SETsto("voc")}),
		newButton({name="back",		x=1140,	y=640,w=180,h=80,color="white",	font=35,code=BACK}),
	},
	setting_control={
		newSlider({name="das",		x=250,	y=200,w=910,	unit=26,	font=30,disp=SETval("das"),		show="frame_time",code=SETsto("das")}),
		newSlider({name="arr",		x=250,	y=290,w=525,	unit=15,	font=30,disp=SETval("arr"),		show="frame_time",code=SETsto("arr")}),
		newSlider({name="sddas",	x=250,	y=380,w=350,	unit=10,	font=30,disp=SETval("sddas"),	show="frame_time",code=SETsto("sddas")}),
		newSlider({name="sdarr",	x=250,	y=470,w=140,	unit=4,		font=30,disp=SETval("sdarr"),	show="frame_time",code=SETsto("sdarr")}),
		newSwitch({name="ihs",		x=1100,	y=290,font=30,				disp=SETval("ihs"),				code=SETrev("ihs")}),
		newSwitch({name="irs",		x=1100,	y=380,font=30,				disp=SETval("irs"),				code=SETrev("irs")}),
		newSwitch({name="ims",		x=1100,	y=470,font=30,				disp=SETval("ims"),				code=SETrev("ims")}),
		newButton({name="reset",	x=160,	y=580,w=200,h=100,color="lRed",font=40,
			code=function()
				local _=setting
				_.das,_.arr=10,2
				_.sddas,_.sdarr=0,2
				_.ihs,_.irs,_.ims=false,false,false
			end}),
		newButton({name="back",		x=1140,	y=640,w=180,h=80,color="white",font=35,code=BACK}),
	},
	setting_key={
		newButton({name="back",		x=1140,y=640,w=180,h=80,color="white",font=35,code=BACK}),
	},
	setting_skin={
		newButton({name="prev",		x=700,y=100,w=140,h=100,color="white",font=50,code=function()SKIN.prevSet()end}),
		newButton({name="next",		x=860,y=100,w=140,h=100,color="white",font=50,code=function()SKIN.nextSet()end}),
		newButton({name="prev1",	x=130,y=230,w=90,h=65,color="white",font=30,code=prevSkin(1)}),
		newButton({name="prev2",	x=270,y=230,w=90,h=65,color="white",font=30,code=prevSkin(2)}),
		newButton({name="prev3",	x=410,y=230,w=90,h=65,color="white",font=30,code=prevSkin(3)}),
		newButton({name="prev4",	x=550,y=230,w=90,h=65,color="white",font=30,code=prevSkin(4)}),
		newButton({name="prev5",	x=690,y=230,w=90,h=65,color="white",font=30,code=prevSkin(5)}),
		newButton({name="prev6",	x=830,y=230,w=90,h=65,color="white",font=30,code=prevSkin(6)}),
		newButton({name="prev7",	x=970,y=230,w=90,h=65,color="white",font=30,code=prevSkin(7)}),

		newButton({name="next1",	x=130,y=450,w=90,h=65,color="white",font=30,code=nextSkin(1)}),
		newButton({name="next2",	x=270,y=450,w=90,h=65,color="white",font=30,code=nextSkin(2)}),
		newButton({name="next3",	x=410,y=450,w=90,h=65,color="white",font=30,code=nextSkin(3)}),
		newButton({name="next4",	x=550,y=450,w=90,h=65,color="white",font=30,code=nextSkin(4)}),
		newButton({name="next5",	x=690,y=450,w=90,h=65,color="white",font=30,code=nextSkin(5)}),
		newButton({name="next6",	x=830,y=450,w=90,h=65,color="white",font=30,code=nextSkin(6)}),
		newButton({name="next7",	x=970,y=450,w=90,h=65,color="white",font=30,code=nextSkin(7)}),

		newButton({name="spin1",	x=130,y=540,w=90,h=65,color="white",font=30,code=nextDir(1)}),
		newButton({name="spin2",	x=270,y=540,w=90,h=65,color="white",font=30,code=nextDir(2)}),
		newButton({name="spin3",	x=410,y=540,w=90,h=65,color="white",font=30,code=nextDir(3)}),
		newButton({name="spin4",	x=550,y=540,w=90,h=65,color="white",font=30,code=nextDir(4)}),
		newButton({name="spin5",	x=690,y=540,w=90,h=65,color="white",font=30,code=nextDir(5)}),
		--newButton({name="spin6",x=825,y=540,w=90,h=65,color="white",font=30,code=nextDir(6)}),--Cannot rotate O
		newButton({name="spin7",	x=970,y=540,w=90,h=65,color="white",font=30,code=nextDir(7)}),

		newButton({name="skinR",	x=200,y=640,w=220,h=80,color="lPurple",font=35,
			code=function()
				setting.skin={1,5,8,2,10,3,7,1,5,5,1,8,2,10,3,7,10,7,8,2,8,2,1,5,3}
				SFX.play("rotate")
			end}),
		newButton({name="faceR",	x=480,y=640,w=220,h=80,color="lRed",font=35,
			code=function()
				for i=1,25 do
					setting.face[i]=0
				end
				SFX.play("hold")
			end}),
		newButton({name="back",		x=1140,y=640,w=180,h=80,color="white",font=35,code=BACK}),
	},
	setting_touch={
		newButton({name="default",	x=520,y=80,w=200,h=80,color="white",font=35,
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
			end}),
		newButton({name="snap",		x=760,y=80,w=200,h=80,color="white",font=35,
			code=function()
				sceneTemp.snap=sceneTemp.snap%6+1
			end}),
		newButton({name="option",	x=520,y=180,w=200,h=80,color="white",font=40,
			code=function()
				SCN.go("setting_touchSwitch")
			end}),
		newButton({name="back",		x=760,y=180,w=200,h=80,color="white",font=35,code=BACK}),
		newSlider({name="size",		x=450,y=265,w=460,unit=14,font=40,show="vkSize",
			disp=function()
				return VK_org[sceneTemp.sel].r/10-1
			end,
			code=function(v)
				if sceneTemp.sel then
					VK_org[sceneTemp.sel].r=10+v*10
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
		newSwitch({name="b11",		x=620,	y=80,	font=35,disp=VKAdisp(11),code=VKAcode(11)}),
		newSwitch({name="b12",		x=620,	y=140,	font=35,disp=VKAdisp(12),code=VKAcode(12)}),
		newSwitch({name="b13",		x=620,	y=200,	font=35,disp=VKAdisp(13),code=VKAcode(13)}),
		newSwitch({name="b14",		x=620,	y=260,	font=35,disp=VKAdisp(14),code=VKAcode(14)}),
		newSwitch({name="b15",		x=620,	y=320,	font=35,disp=VKAdisp(15),code=VKAcode(15)}),
		newSwitch({name="b16",		x=620,	y=380,	font=35,disp=VKAdisp(16),code=VKAcode(16)}),
		newSwitch({name="b17",		x=620,	y=440,	font=35,disp=VKAdisp(17),code=VKAcode(17)}),
		newSwitch({name="b18",		x=620,	y=500,	font=35,disp=VKAdisp(18),code=VKAcode(18)}),
		newSwitch({name="b19",		x=620,	y=560,	font=35,disp=VKAdisp(19),code=VKAcode(19)}),
		newSwitch({name="b20",		x=620,	y=620,	font=35,disp=VKAdisp(20),code=VKAcode(20)}),
		newButton({name="norm",		x=840,	y=100,	w=240,h=80,color="white",font=35,code=function()for i=1,20 do VK_org[i].ava=i<11 end end}),
		newButton({name="pro",		x=1120,	y=100,	w=240,h=80,color="white",font=35,code=function()for i=1,20 do VK_org[i].ava=true end end}),
		newSwitch({name="hide",		x=1170,	y=200,	font=40,disp=SETval("VKSwitch"),code=SETrev("VKSwitch")}),
		newSwitch({name="track",	x=1170,	y=300,	font=35,disp=SETval("VKTrack"),code=SETrev("VKTrack")}),
		newSlider({name="sfx",		x=800,	y=380,	w=180,			font=40,change=function()SFX.play("virtualKey",setting.VKSFX)end,disp=SETval("VKSFX"),code=SETsto("VKSFX")}),
		newSlider({name="vib",		x=800,	y=460,	w=180,unit=2,	font=40,change=function()VIB(setting.VKVIB)end,disp=SETval("VKVIB"),code=SETsto("VKVIB")}),
		newSwitch({name="icon",		x=850,	y=300,	font=40,disp=SETval("VKIcon"),code=SETrev("VKIcon")}),
		newButton({name="tkset",	x=1120,	y=420,	w=240,h=80,color="white",font=32,
			code=function()
				SCN.go("setting_trackSetting")
			end,
			hide=function()
				return not setting.VKTrack
			end}),
		newSlider({name="alpha",	x=840,	y=540,	w=400,font=40,disp=SETval("VKAlpha"),code=SETsto("VKAlpha")}),
		newButton({name="back",		x=1140,	y=640,	w=180,h=80,color="white",font=35,code=BACK}),
	},
	setting_trackSetting={
		newSwitch({name="VKDodge",	x=400,	y=200,	font=35,				disp=SETval("VKDodge"),code=SETrev("VKDodge")}),
		newSlider({name="VKTchW",	x=140,	y=310,	w=1000,	unit=10,font=35,disp=SETval("VKTchW"),code=function(i)setting.VKTchW=i;setting.VKCurW=math.max(setting.VKCurW,i)end}),
		newSlider({name="VKCurW",	x=140,	y=370,	w=1000,	unit=10,font=35,disp=SETval("VKCurW"),code=function(i)setting.VKCurW=i;setting.VKTchW=math.min(setting.VKTchW,i)end}),
		newButton({name="back",		x=1140,	y=640,	w=180,h=80,color="white",font=35,code=BACK}),
	},
	setting_lang={
		newButton({name="chi",		x=160,	y=100,w=200,h=120,color="white",font=45,code=setLang(1)}),
		newButton({name="chi2",		x=380,	y=100,w=200,h=120,color="white",font=45,code=setLang(2)}),
		newButton({name="eng",		x=600,	y=100,w=200,h=120,color="white",font=45,code=setLang(3)}),
		newButton({name="str",		x=820,	y=100,w=200,h=120,color="white",font=45,code=setLang(4)}),
		newButton({name="yygq",		x=1040,	y=100,w=200,h=120,color="white",font=45,code=setLang(5)}),
		newButton({name="back",		x=640,	y=600,w=200,h=80,color="white",	font=35,code=BACK}),
	},
	minigame={
		newButton({name="p15",		x=640,	y=100,w=350,h=120,color="white",font=40,code=goScene("p15")}),
		newButton({name="back",		x=1140,	y=640,w=180,h=80,color="white",	font=35,code=BACK}),
	},
	p15={
		newButton({name="reset",	x=160,y=100,w=180,h=100,color="lGreen",	font=40,code=pressKey("space")}),
		newSlider({name="color",	x=110,y=250,w=170,unit=4,show=false,	font=30,disp=function()return sceneTemp.color end,code=function(v)sceneTemp.color=v end,hide=function()return sceneTemp.state<2 end}),
		newSwitch({name="blind",	x=200,y=350,w=60,						font=40,disp=function()return sceneTemp.blind end,code=pressKey("b"),hide=function()return sceneTemp.state>0 end}),
		newSwitch({name="slide",	x=200,y=450,w=60,						font=40,disp=function()return sceneTemp.slide end,code=pressKey("s"),hide=function()return sceneTemp.state>0 end}),
		newSwitch({name="revKB",	x=200,y=550,w=60,						font=40,disp=function()return sceneTemp.revKB end,code=pressKey("r"),hide=function()return sceneTemp.state>0 end}),
		newButton({name="back",		x=1140,y=640,w=180,h=80,color="white",	font=35,code=BACK}),
	},
	help={
		newButton({name="staff",	x=980,	y=500,w=150,h=80,color="white",font=32,code=goScene("staff")}),
		newButton({name="his",		x=1160,	y=500,w=150,h=80,color="white",font=32,code=goScene("history")}),
		newButton({name="qq",		x=1070,	y=600,w=200,h=80,color="white",font=32,code=function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,hide=mobileHide}),
		newButton({name="back",		x=640,	y=600,w=200,h=80,color="white",font=35,code=BACK}),
	},
	staff={
		newButton({name="back",		x=1140,	y=640,w=180,h=80,color="white",font=35,code=BACK}),
	},
	history={
		newKey({name="prev",		x=1155,	y=170,w=180,	color="white",font=65,code=pressKey("up"),hide=function()return sceneTemp.pos==1 end}),
		newKey({name="next",		x=1155,	y=400,w=180,	color="white",font=65,code=pressKey("down"),hide=function()return sceneTemp.pos==#sceneTemp.text end}),
		newButton({name="back",		x=1140,	y=640,w=180,h=80,color="white",font=35,code=BACK}),
	},
	stat={
		newButton({name="path",		x=980,	y=620,w=250,h=80,color="white",font=25,code=function()love.system.openURL(love.filesystem.getSaveDirectory())end,hide=mobileHide}),
		newButton({name="back",		x=640,	y=620,w=200,h=80,color="white",font=35,code=BACK}),
	},
	debug={
		newButton({name="reset",	x=640,y=200,w=260,h=100,color="yellow",font=40,
			code=function()
				sceneTemp.reset=true
			end,
			hide=function()
				return sceneTemp.reset
			end}),
		newButton({name="reset1",	x=340,y=400,w=260,h=100,color="red",font=40,
			code=function()
				love.filesystem.remove("unlock.dat")
				SFX.play("finesseError_long")
				TEXT.show("rank resetted",640,300,60,"stretch",.4)
				TEXT.show("effected after restart game",640,360,60,"stretch",.4)
				TEXT.show("play one game if you regret",640,390,40,"stretch",.4)
			end,
			hide=function()
				return not sceneTemp.reset
			end}),
		newButton({name="reset2",	x=640,y=400,w=260,h=100,color="red",font=40,
			code=function()
				love.filesystem.remove("data.dat")
				SFX.play("finesseError_long")
				TEXT.show("game data resetted",640,300,60,"stretch",.4)
				TEXT.show("effected after restart game",640,360,60,"stretch",.4)
				TEXT.show("play one game if you regret",640,390,40,"stretch",.4)
			end,
			hide=function()
				return not sceneTemp.reset
			end}),
		newButton({name="reset3",	x=940,y=400,w=260,h=100,color="red",font=40,
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
			hide=function()
				return not sceneTemp.reset
			end}),
		newButton({name="back",		x=640,y=620,w=200,h=80,color="white",font=35,code=BACK}),
	},
}

--Remove temp vars
mobileHide,SETval,SETsto,SETrev=nil
pressKey,setPen,prevSkin,nextSkin=nil
nextDir,VKAdisp,VKAcode,setLang=nil
goScene=nil
newText,newImage,newButton,newSwitch,newSlider=nil
return Widgets