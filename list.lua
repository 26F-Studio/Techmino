local gc=love.graphics
local tc,kb=love.touch,love.keyboard
local sys=love.system
local fs=love.filesystem
local mobile=mobile

actName={"moveLeft","moveRight","rotRight","rotLeft","rotFlip","hardDrop","softDrop","hold","func","restart","insLeft","insRight","insDown"}
color={
	red={1,0,0},
	green={0,1,0},
	blue={.2,.2,1},
	yellow={1,1,0},
	magenta={1,0,1},
	cyan={0,1,1},
	grey={.6,.6,.6},

	lightRed={1,.5,.5},
	lightGreen={.5,1,.5},
	lightBlue={.6,.6,1},
	lightYellow={1,1,.5},
	lightMagenta={1,.5,1},
	lightCyan={.5,1,1},
	lightGrey={.8,.8,.8},

	darkRed={.6,0,0},
	darkGreen={0,.6,0},
	darkBlue={0,0,.6},
	darkYellow={.6,.6,0},
	darkMagenta={.6,0,.6},
	darkCyan={0,.6,.6},
	darkGrey={.3,.3,.3},

	white={1,1,1},
	orange={1,.6,0},
	lightOrange={1,.7,.3},
	purple={.5,0,1},
	lightPurple={.8,.4,1},
	darkPurple={.3,0,.6},
}
blockColor={
	color.red,
	color.green,
	color.orange,
	color.blue,
	color.magenta,
	color.yellow,
	color.cyan,
	color.darkGreen,
	color.grey,
	color.lightGrey,
	color.darkPurple,
	color.darkRed,
	color.darkGreen,
}
sfx={
	"button","swipe",
	"ready","start","win","fail","collect",
	"move","rotate","rotatekick","hold",
	"prerotate","prehold",
	"lock","drop","fall",
	"reach",
	"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11","ren_mega",
	"clear_1","clear_2","clear_3","clear_4",
	"spin_0","spin_1","spin_2","spin_3",
	"emit","blip_1","blip_2",
	"perfectclear",
}
bgm={
	"blank",
	"way",
	"race",
	"newera",
	"push",
	"reason",
	"infinite",
	"cruelty",
	"final",
	"secret7th",
	"secret8th",
	"rockblock",
	"8-bit happiness",
	"end",
}
voiceList={
	"Z","S","L","J","T","O","I",
	"single","double","triple","tts",
	"spin","spin_","mini","b2b","b3b","pc",
	"win","lose","voc_nya","nya",
}
voiceBank={}
voice={
	Z={"Z_1","Z_2"},
	S={"S_1","S_2"},
	J={"J_1","J_2"},
	L={"L_1","L_2"},
	T={"T_1","T_2"},
	O={"O_1","O_2"},
	I={"I_1","I_2"},
	single={"single_1","single_2","single_3"},
	double={"double_1","double_2","double_3"},
	triple={"triple_1","triple_2"},
	tts={"tts_1"},
	spin={"spin_1","spin_2","spin_3","spin_4","spin_5"},
	spin_={"spin-_1","spin-_2"},
	mini={"mini_1"},
	b2b={"b2b_1","b2b_2"},
	b3b={"b3b_1"},
	pc={"PC_1"},
	win={"win_1","win_2"},
	lose={"lose_1","lose_2","lose_3"},
	voc_nya={"nya_11","nya_12","nya_13","nya_21","nya_22"},
	nya={"nya_1","nya_2","nya_3","nya_4"},
}

musicID={
	"blank",
	"way",
	"race",
	"newera",
	"push",
	"reason",
	"infinite",
	"cruelty",
	"final",
	"secret7th",
	"secret8th",
	"rockblock",
	"8-bit happiness",
	"end",
}
customID={
	"drop","lock",
	"wait","fall",
	"next","hold",
	"sequence","visible",
	"target",
	"freshLimit",
	"opponent",
	"bg","bgm",
}
customRange={
	drop={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99,-1},
	lock={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
	wait={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
	fall={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
	next={0,1,2,3,4,5,6},
	hold={true,false,true},
	sequence={"bag7","his4","rnd"},
	visible={"show","time","fast","none"},
	target={10,20,40,100,200,500,1000,1e99},
	freshLimit={0,8,15,1e99},
	opponent={0,60,30,20,15,10,7,5,4,3,2,1},
	bg={"none","game1","game2","game3","strap","rgb","glow","matrix"},
	bgm={"blank","way","race","newera","push","reason","infinite","secret7th","secret8th","rockblock"},
}

RCPB={10,33,200,33,105,5,105,60}
snapLevelValue={1,10,20,40,60,80}
up0to4={[0]="000%UP","025%UP","050%UP","075%UP","100%UP",}

modeID={
	[0]="custom",
	"sprint","marathon","master","classic","zen","infinite","solo","tsd","blind","dig","survivor","tech",
	"c4wtrain","pctrain","pcchallenge","techmino49","techmino99","drought","hotseat",
}
modeLevel={
	sprint={"10L","20L","40L","100L","400L","1000L"},
	marathon={"EASY","NORMAL","HARD"},
	master={"LUNATIC","ULTIMATE"},
	classic={"CTWC"},
	zen={"NORMAL"},
	infinite={"NORMAL","EXTRA"},
	solo={"EASY","NORMAL","HARD","LUNATIC"},
	tsd={"NORMAL","HARD"},
	blind={"EASY","HARD","HARD+","LUNATIC","ULTIMATE","GM"},
	dig={"NORMAL","LUNATIC"},
	survivor={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE","EXTRA"},
	tech={"NORMAL","NORMAL+","HARD","HARD+","LUNATIC","LUNATIC+",},
	c4wtrain={"NORMAL","LUNATIC"},
	pctrain={"NORMAL","EXTRA"},
	pcchallenge={"NORMAL","HARD","LUNATIC"},
	techmino49={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	techmino99={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	drought={"NORMAL","MESS"},
	hotseat={"2P","3P","4P",},
	custom={"Normal","Puzzle"},
}
local O,_=true,false
blocks={
	{[0]={{_,O,O},{O,O,_}},{{O,_},{O,O},{_,O}}},
	{[0]={{O,O,_},{_,O,O}},{{_,O},{O,O},{O,_}}},
	{[0]={{O,O,O},{_,_,O}},{{O,O},{O,_},{O,_}},{{O,_,_},{O,O,O}},{{_,O},{_,O},{O,O}}},
	{[0]={{O,O,O},{O,_,_}},{{O,_},{O,_},{O,O}},{{_,_,O},{O,O,O}},{{O,O},{_,O},{_,O}}},
	{[0]={{O,O,O},{_,O,_}},{{O,_},{O,O},{O,_}},{{_,O,_},{O,O,O}},{{_,O},{O,O},{_,O}}},
	{[0]={{O,O},{O,O}},{{O,O},{O,O}}},
	{[0]={{O,O,O,O}},{{O},{O},{O},{O}}},
}
local l={1,2,6,7}for i=1,4 do blocks[l[i]][2],blocks[l[i]][3]=blocks[l[i]][0],blocks[l[i]][1]end
for i=1,7 do blocks[i+7]=blocks[i]end

local virtualkeySet={
	{
		{80,720-200,6400,80},--moveLeft
		{320,720-200,6400,80},--moveRight
		{1280-80,720-200,6400,80},--rotRight
		{1280-200,720-80,6400,80},--rotLeft
		{1280-200,720-320,6400,80},--rotFlip
		{200,720-320,6400,80},--hardDrop
		{200,720-80,6400,80},--softDrop
		{1280-320,720-200,6400,80},--hold
		{1280-80,280,6400,80},--func
		{80,280,6400,80},--restart
	},--Farter's set 3
	{
		{1280-320,720-200,6400,80},--moveLeft
		{1280-80,720-200,6400,80},--moveRight
		{200,720-80,6400,80},--rotRight
		{80,720-200,6400,80},--rotLeft
		{200,720-320,6400,80},--rotFlip
		{1280-200,720-320,6400,80},--hardDrop
		{1280-200,720-80,6400,80},--softDrop
		{320,720-200,6400,80},--hold
		{80,280,6400,80},--func
		{1280-80,280,6400,80},--restart
	},--Mirrored farter's set 3
	{
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
	},--Author's set
	{
		{1280-400,720-80,6400,80},--moveLeft
		{1280-80,720-80,6400,80},--moveRight
		{240,720-80,6400,80},--rotRight
		{80,720-80,6400,80},--rotLeft
		{240,720-240,6400,80},--rotFlip
		{1280-240,720-240,6400,80},--hardDrop
		{1280-240,720-80,6400,80},--softDrop
		{1280-80,720-240,6400,80},--hold
		{80,720-240,6400,80},--func
		{80,320,6400,80},--restart
	},--Keyboard set
	{
		{1200-370,40,1600,40},--moveLeft
		{1200-280,40,1600,40},--moveRight
		{1200-530,40,1600,40},--rotRight
		{1200-610,40,1600,40},--rotLeft
		{1200-450,40,1600,40},--rotFlip
		{1200-50,40,1600,40},--hardDrop
		{1200-130,40,1600,40},--softDrop
		{1200-210,40,1600,40},--hold
		{1200-690,40,1600,40},--func
		{1200-770,40,1600,40},--restart
	},--PC key feedback
}
local customSet={
	{20,20,1,1,7,1,1,1,3,4,1,2,3},
	{18,20,1,1,7,1,1,1,8,3,8,3,3},
	{22,22,1,1,7,3,1,1,8,4,1,7,7},
	{20,20,1,1,7,1,1,3,8,3,1,7,8},
	{23,11,8,11,4,1,2,1,8,3,1,4,9},
}
local function useDefaultSet(n)
	for i=1,#customSet[n]do
		customSel[i]=customSet[n][i]
	end
	curBG=customRange.bg[customSel[12]]
	BGM(customRange.bgm[customSel[13]])
end
Buttons={
	load={},
	intro={},
	main={
		qplay=	{x=160,y=300,w=150,	h=150,	rgb=color.lightRed,	f=40,code=function()loadGame(modeSel,levelSel)end,down="stat",right="play"},
		play=	{x=380,y=300,w=240,	h=240,	rgb=color.red,		f=70,code=function()gotoScene("mode")end,down="stat",left="qplay",right="setting"},
		setting={x=640,y=300,w=240,	h=240,	rgb=color.lightBlue,f=55,code=function()gotoScene("setting")end,down="stat",left="play",right="music"},
		music=	{x=900,y=300,w=240,	h=240,	rgb=color.lightCyan,f=42,code=function()gotoScene("music")end,down="help",left="setting",right="quit"},
		stat=	{x=640,y=560,w=240,	h=240,	rgb=color.cyan,		f=55,code=function()gotoScene("stat")end,up="setting",left="play",right="help"},
		help=	{x=900,y=560,w=240,	h=240,	rgb=color.yellow,	f=55,code=function()gotoScene("help")end,up="music",left="stat",right="quit"},
		quit=	{x=1180,y=620,w=120,h=120,	rgb=color.lightGrey,f=50,code=function()gotoScene("quit")end,up="setting",left="help"},
	},
	mode={
		up=		{x=1000,y=210,w=200,h=140,	rgb=color.white,	f=80,	code=function()love.keypressed("up")end,	hide=function()return modeSel==1 end,},
		down=	{x=1000,y=430,w=200,h=140,	rgb=color.white,	f=80,	code=function()love.keypressed("down")end,	hide=function()return modeSel==#modeID end,},
		left=	{x=190,	y=160,w=100,h=80,	rgb=color.white,			code=function()love.keypressed("left")end,	hide=function()return levelSel==1 end,},
		right=	{x=350,	y=160,w=100,h=80,	rgb=color.white,			code=function()love.keypressed("right")end,	hide=function()return levelSel==#modeLevel[modeID[modeSel]]end,},
		start=	{x=1000,y=600,w=250,h=100,	rgb=color.green,	f=50,	code=function()loadGame(modeSel,levelSel)end},
		custom=	{x=275,	y=420,w=200,h=90,	rgb=color.yellow,			code=function()gotoScene("custom")end},
		back=	{x=640,	y=630,w=230,h=90,	rgb=color.white,	f=45,	code=back},
	},
	music={
		bgm=	{x=1100,y=80,	w=160,	h=80,	rgb=color.white,code=function()BGM()setting.bgm=not setting.bgm end},
		up=		{x=1100,y=200,	w=120,	h=120,	rgb=color.white,f=40,hide=function()return not setting.bgm end,code=function()sel=(sel-2)%#musicID+1 end},
		play=	{x=1100,y=340,	w=120,	h=120,	rgb=color.white,f=40,hide=function()return not setting.bgm end,code=function()BGM(musicID[sel])end},
		down=	{x=1100,y=480,	w=120,	h=120,	rgb=color.white,f=50,hide=function()return not setting.bgm end,code=function()sel=sel%#musicID+1 end},
		back=	{x=640,	y=630,	w=230,	h=90,	rgb=color.white,f=45,code=back},
	},
	custom={
		up=		{x=1000,y=220,	w=100,h=100,	rgb=color.white,f=50,	code=function()sel=(sel-2)%#customID+1 end},
		down=	{x=1000,y=460,	w=100,h=100,	rgb=color.white,f=50,	code=function()sel=sel%#customID+1 end},
		left=	{x=880,	y=340,	w=100,h=100,	rgb=color.white,f=50,	code=function()
			customSel[sel]=(customSel[sel]-2)%#customRange[customID[sel]]+1
			if sel==12 then
				curBG=customRange.bg[customSel[12]]
			elseif sel==13 then
				BGM(customRange.bgm[customSel[13]])
			end
			end},
		right=	{x=1120,y=340,	w=100,h=100,	rgb=color.white,f=50,	code=function()
			customSel[sel]=customSel[sel]%#customRange[customID[sel]]+1
			if sel==12 then
				curBG=customRange.bg[customSel[12]]
			elseif sel==13 then
				BGM(customRange.bgm[customSel[13]])
			end
			end},
		start1=	{x=880,	y=580,	w=220,h=70,	rgb=color.green,		code=function()loadGame(0,1)end},
		start2=	{x=1120,y=580,	w=220,h=70,	rgb=color.lightPurple,	code=function()loadGame(0,2)end},
		draw=	{x=1000,y=90,	w=190,h=85,	rgb=color.cyan,			code=function()gotoScene("draw")end},
		set1=	{x=640,	y=160,	w=240,h=75,	rgb=color.lightRed,		code=function()useDefaultSet(1)end},
		set2=	{x=640,	y=250,	w=240,h=75,	rgb=color.lightRed,		code=function()useDefaultSet(2)end},
		set3=	{x=640,	y=340,	w=240,h=75,	rgb=color.lightRed,		code=function()useDefaultSet(3)end},
		set4=	{x=640,	y=430,	w=240,h=75,	rgb=color.lightRed,		code=function()useDefaultSet(4)end},
		set5=	{x=640,	y=520,	w=240,h=75,	rgb=color.lightRed,		code=function()useDefaultSet(5)end},
		back=	{x=640,	y=630,	w=180,h=60,	rgb=color.white,		code=back},
	},
	draw={
		any=	{x=700,	y=80,w=120,h=120,	f=45,	rgb=color.lightGrey,code=function()pen=-1 end},
		block1=	{x=840,	y=80,w=120,h=120,	f=65,	rgb=color.red,		code=function()pen=1 end},
		block2=	{x=980,	y=80,w=120,h=120,	f=65,	rgb=color.green,	code=function()pen=2 end},
		block3=	{x=1120,y=80,w=120,h=120,	f=65,	rgb=color.orange,	code=function()pen=3 end},
		block4=	{x=840,	y=220,w=120,h=120,	f=65,	rgb=color.blue,		code=function()pen=4 end},
		block5=	{x=980,	y=220,w=120,h=120,	f=65,	rgb=color.magenta,	code=function()pen=5 end},
		block6=	{x=1120,y=220,w=120,h=120,	f=65,	rgb=color.yellow,	code=function()pen=6 end},
		block7=	{x=840,	y=360,w=120,h=120,	f=65,	rgb=color.cyan,		code=function()pen=7 end},
		gb1=	{x=980,	y=360,w=120,h=120,	f=65,	rgb=color.darkGrey,	code=function()pen=9 end},
		gb2=	{x=1120,y=360,w=120,h=120,	f=65,	rgb=color.grey,		code=function()pen=10 end},
		gb3=	{x=840,	y=500,w=120,h=120,	f=65,	rgb=color.darkPurple,code=function()pen=11 end},
		gb4=	{x=980,	y=500,w=120,h=120,	f=65,	rgb=color.darkRed,	code=function()pen=12 end},
		gb5=	{x=1120,y=500,w=120,h=120,	f=65,	rgb=color.darkGreen,code=function()pen=13 end},
		space=	{x=840,	y=640,w=120,h=120,	f=70,	rgb=color.grey,		code=function()pen=0 end},
		clear=	{x=1120,y=640,w=120,h=120,	f=45,	rgb=color.white,	code=function()
			if clearSureTime>15 then
				for y=1,20 do for x=1,10 do preField[y][x]=-1 end end
				clearSureTime=0
			else
				clearSureTime=50
			end
			end},
		back=	{x=1235,y=45,w=80,h=80,		f=35,	rgb=color.white,	code=back},
	},
	play={
		pause={x=1235,y=45,w=80,h=80,rgb=color.white,f=30,code=pauseGame},
	},
	pause={
		resume=	{x=640,y=400,w=240,h=100,	rgb=color.white,f=50,code=resumeGame},
		quit=	{x=640,y=550,w=240,h=100,	rgb=color.white,f=50,code=back},
	},
	setting={--Normal setting
		ghost=	{x=290,	y=90,	w=210,	h=60,		rgb=color.white,code=function()setting.ghost=not setting.ghost end,down="grid",right="center"},
		center=	{x=505,	y=90,	w=210,	h=60,		rgb=color.white,code=function()setting.center=not setting.center end,down="swap",left="ghost",right="sfx"},
		grid=	{x=290,	y=160,	w=210,	h=60,		rgb=color.white,code=function()setting.grid=not setting.grid end,up="ghost",down="fxs",right="swap"},
		swap=	{x=505,	y=160,	w=210,	h=60,f=28,	rgb=color.white,code=function()setting.swap=not setting.swap end,up="center",down="bg",left="grid",right="vib"},
		fxs=	{x=290,	y=230,	w=210,	h=60,		rgb=color.white,code=function()setting.fxs=(setting.fxs+1)%4 end,up="grid",down="dasU",right="bg"},
		bg=		{x=505,	y=230,	w=210,	h=60,		rgb=color.white,code=function()setting.bg=not setting.bg end,up="swap",down="arrD",left="fxs",right="fullscreen"},
		dasD=	{x=210,	y=300,	w=50,	h=50,		rgb=color.white,code=function()setting.das=(setting.das-1)%31 end,up="fxs",down="sddasD",right="dasU"},
		dasU=	{x=370,	y=300,	w=50,	h=50,		rgb=color.white,code=function()setting.das=(setting.das+1)%31 end,up="fxs",down="sddasU",left="dasD",right="arrD"},
		arrD=	{x=425,	y=300,	w=50,	h=50,		rgb=color.white,code=function()setting.arr=(setting.arr-1)%16 end,up="bg",down="sdarrD",left="dasU",right="arrU"},
		arrU=	{x=585,	y=300,	w=50,	h=50,		rgb=color.white,code=function()setting.arr=(setting.arr+1)%16 end,up="bg",down="sdarrU",left="arrD",right="bgblock"},--3~6
		sddasD=	{x=210,	y=370,	w=50,	h=50,		rgb=color.white,code=function()setting.sddas=(setting.sddas-1)%11 end,up="dasD",down="ctrl",right="sddasU"},
		sddasU=	{x=370,	y=370,	w=50,	h=50,		rgb=color.white,code=function()setting.sddas=(setting.sddas+1)%11 end,up="dasU",down="ctrl",left="sddasD",right="sdarrD"},
		sdarrD=	{x=425,	y=370,	w=50,	h=50,		rgb=color.white,code=function()setting.sdarr=(setting.sdarr-1)%4 end,up="arrD",down="ctrl",left="sddasU",right="sdarrU"},
		sdarrU=	{x=585,	y=370,	w=50,	h=50,		rgb=color.white,code=function()setting.sdarr=(setting.sdarr+1)%4 end,up="arrU",down="ctrl",left="sdarrD",right="frame"},

		ctrl=	{x=340,y=440,	w=310,	h=60,rgb=color.green,	code=function()gotoScene("setting2")end,up="sddasU",down="touch",left="lang",right="skin"},
		touch=	{x=340,y=510,	w=310,	h=60,rgb=color.yellow,code=function()gotoScene("setting3")end,up="ctrl",down="back",right="lang"},
		lang=	{x=580,y=510,	w=150,	h=60,rgb=color.red,	code=function()
			setting.lang=setting.lang%#langName+1
			swapLanguage(setting.lang)
			end,up="sdarrU",down="back",left="touch",right="skin"},

		sfx=	{x=760,y=90,	w=160,	h=60,		rgb=color.white,code=function()setting.sfx=not setting.sfx end,down="vib",left="center",right="bgm"},
		bgm=	{x=940,y=90,	w=160,	h=60,		rgb=color.white,code=function()BGM()setting.bgm=not setting.bgm BGM("blank")end,down="voc",left="sfx"},
		vib=	{x=760,y=160,	w=160,	h=60,rgb=color.white,	code=function()setting.vib=(setting.vib+1)%6 VIB(1)end,up="sfx",down="fullscreen",left="swap",right="voc"},
		voc=	{x=940,y=160,	w=160,	h=60,rgb=color.white,code=function()setting.voc=not setting.voc end,up="sfx",down="fullscreen",left="vib"},
		fullscreen=	{x=850,y=230,w=340,	h=60,rgb=color.white,	code=function()
			setting.fullscreen=not setting.fullscreen
			love.window.setFullscreen(setting.fullscreen)
			if not setting.fullscreen then
				love.resize(gc.getWidth(),gc.getHeight())
			end
			end,up="vib",down="bgblock",left="bg"},
		bgblock={x=850,y=300,	w=340,	h=60,rgb=color.white,	code=function()
			setting.bgblock=not setting.bgblock
			--if not setting.bgblock then for i=1,16 do BGblockList[i].v=3*BGblockList[i].v end end
			end,up="fullscreen",down="frame",left="arrU"},
		frame=	{x=850,y=370,	w=340,	h=60,rgb=color.white,	code=function()
			setting.frameMul=setting.frameMul+(setting.frameMul<50 and 5 or 10)
			if setting.frameMul>100 then setting.frameMul=25 end
			end,up="bgblock",down="skin",left="sdarrU"},
		skin=	{x=740,y=440,	w=120,	h=60,rgb=color.white,	code=function()
			setting.skin=setting.skin%6+1
			changeBlockSkin(setting.skin)
			end,up="frame",down="back",left="ctrl",right="smo"},
		smo=	{x=920,y=440,	w=200,	h=60,f=27,rgb=color.white,	code=function()
			setting.smo=not setting.smo
			end,up="frame",down="back",left="skin"},
		back=	{x=640,y=620,	w=300,h=70,rgb=color.white,	code=back,up="lang"},
	},
	setting2={--Control setting
		back={x=840,y=630,w=180,h=60,rgb=color.white,code=back},
	},
	setting3={--Touch setting
		back={x=640,y=410,w=170,h=80,f=45,code=back},
		hide={x=640,y=210,w=500,h=80,f=45,code=function()
			setting.virtualkeySwitch=not setting.virtualkeySwitch
			end},
		default={x=450,y=310,w=170,h=80,code=function()
			for K=1,#virtualkey do
				local b,b0=virtualkey[K],virtualkeySet[defaultSel][K]
				b[1],b[2],b[3],b[4]=b0[1],b0[2],b0[3],b0[4]
			end--Default virtualkey
			defaultSel=defaultSel%5+1
			end},
		snap={x=640,y=310,w=170,h=80,code=function()
			snapLevel=snapLevel%6+1
			end},
		alpha={x=830,y=310,w=170,h=80,f=45,code=function()
			setting.virtualkeyAlpha=(setting.virtualkeyAlpha+1)%11
			--Adjust virtualkey alpha
			end},
		icon={x=450,y=410,w=170,h=80,f=45,code=function()
			setting.virtualkeyIcon=not setting.virtualkeyIcon
			--Switch virtualkey icon
			end},
		size={x=830,y=410,w=170,h=80,f=45,code=function()
			if sel then
				local b=virtualkey[sel]
				b[4]=b[4]+10
				if b[4]==150 then b[4]=40 end
				b[3]=b[4]^2
			end
			end},
	},
	help={
		his={x=1050,y=520,w=230,h=60,rgb=color.white,code=function()gotoScene("history")end,down="qq",left="back"},
		qq={x=1050,y=600,w=230,h=60,hide=function()return mobile end,rgb=color.white,code=function()sys.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,up="his",left="back"},
		back={x=640,y=600,w=180,h=60,rgb=color.white,code=back,up="his",right="qq"},
	},
	history={
		prev=	{x=75,	y=320,w=100,	h=300,	rgb=color.white,hide=function()return sel==1 end,code=function()sel=sel-1 end},
		next=	{x=1205,y=320,w=100,	h=300,	rgb=color.white,hide=function()return sel==#updateLog end,code=function()sel=sel+1 end},
		back=	{x=640,	y=640,w=200,h=70,	rgb=color.white,code=back},
	},
	stat={
		path={x=980,y=590,w=250,h=60,f=30,rgb=color.white,hide=function()return mobile end,code=function()sys.openURL(fs.getSaveDirectory())end,left="back"},
		back={x=640,y=590,w=180,h=60,rgb=color.white,code=back,right="path"},
	},
	sel=nil,--selected button id(integer)
}