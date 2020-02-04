local mobile=system=="Android"or system=="iOS"
actName={
	"moveLeft","moveRight",
	"rotRight","rotLeft","rotFlip",
	"hardDrop","softDrop",
	"hold","func",
	"restart",
	"insLeft","insRight","insDown","down1","down4","down10",
	"dropLeft","dropRight","addLeft","addRight",--Super contorl system
}
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
	"welcome",
	"button","swipe",
	"ready","start","win","fail","collect",
	"move","rotate","rotatekick","hold",
	"prerotate","prehold",
	"lock","drop","fall",
	"error","error_long","reach",
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
	"shining terminal",
	"end",
}
voiceBank={}
voiceName={
	"Z","S","L","J","T","O","I",
	"single","double","triple","tts",
	"spin","spin_","mini","b2b","b3b","pc",
	"win","lose","voc_nya","nya",
}
voiceList={
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
	"secret7th",
	"secret8th",
	"shining terminal",
	"rockblock",
	"8-bit happiness",
	"cruelty",
	"final",
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
	drop={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
	lock={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
	wait={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
	fall={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
	next={0,1,2,3,4,5,6},
	hold={true,false,true},
	sequence={"bag7","his4","rnd"},
	visible={"show","time","fast","none"},
	target={10,20,40,100,200,500,1000,1e99},
	freshLimit={0,8,15,1e99},
	opponent={0,1,2,3,4,5,11,12,13,14,15,16},
	bg={"none","game1","game2","game3","strap","rgb","glow","matrix"},
	bgm={"blank","way","race","newera","push","reason","infinite","secret7th","secret8th","rockblock"},
}

RCPB={10,33,200,33,105,5,105,60}
snapLevelValue={1,10,20,40,60,80}
up0to4={[0]="000%UP","025%UP","050%UP","075%UP","100%UP",}

modeID={
	[0]="custom",
	"sprint","marathon","master","classic","zen","infinite","solo","round","tsd","blind",
	"dig","survivor","defender","attacker","tech",
	"c4wtrain","pctrain","pcchallenge","techmino49","techmino99","drought","hotseat",
}
modeLevel={
	sprint={"10L","20L","40L","100L","400L","1000L"},
	marathon={"EASY","NORMAL","HARD"},
	master={"LUNATIC","ULTIMATE","FINAL"},
	classic={"CTWC"},
	zen={"NORMAL"},
	infinite={"NORMAL","EXTRA"},
	solo={"EASY","EASY+","NORMAL","NORMAL+","HARD","HARD+","LUNATIC","LUNATIC+","ULTIMATE"},
	round={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	tsd={"NORMAL","HARD"},
	blind={"EASY","HARD","HARD+","LUNATIC","ULTIMATE","GM"},
	dig={"NORMAL","LUNATIC"},
	survivor={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	defender={"NORMAL","LUNATIC"},
	attacker={"HARD","ULTIMATE"},
	tech={"NORMAL","NORMAL+","HARD","HARD+","LUNATIC","LUNATIC+","ULTIMATE","ULTIMATE+",},
	c4wtrain={"NORMAL","LUNATIC"},
	pctrain={"NORMAL","EXTRA"},
	pcchallenge={"NORMAL","HARD","LUNATIC"},
	techmino49={"EASY","HARD","ULTIMATE"},
	techmino99={"EASY","HARD","ULTIMATE"},
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
		{1,	80,			720-200,	80},--moveLeft
		{2,	320,		720-200,	80},--moveRight
		{3,	1280-80,	720-200,	80},--rotRight
		{4,	1280-200,	720-80,		80},--rotLeft
		{5,	1280-200,	720-320,	80},--rotFlip
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
		{5,	200,		720-320,	80},--rotFlip
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
		{5,	1280-240,	720-240,	80},--rotFlip
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
		{5,	240,		720-240,	80},--rotFlip
		{6,	1280-240,	720-240,	80},--hardDrop
		{7,	1280-240,	720-80,		80},--softDrop
		{8,	1280-80,	720-240,	80},--hold
		{9,	80,			720-240,	80},--func
		{10,80,			320,		80},--restart
	},--Keyboard set
	{
		{10,70,		50,27},--restart
		{9,	130,	50,27},--func
		{4,	190,	50,27},--rotLeft
		{3,	250,	50,27},--rotRight
		{5,	310,	50,27},--rotFlip
		{1,	370,	50,27},--moveLeft
		{2,	430,	50,27},--moveRight
		{8,	490,	50,27},--hold
		{7,	550,	50,27},--softDrop1
		{6,	610,	50,27},--hardDrop
		{11,670,	50,27},--insLeft
		{12,730,	50,27},--insRight
		{13,790,	50,27},--insDown
		{14,850,	50,27},--down1
		{15,910,	50,27},--down4
		{16,970,	50,27},--down10
		{17,1030,	50,27},--dropLeft
		{18,1090,	50,27},--dropRight
		{19,1150,	50,27},--addLeft
		{20,1210,	50,27},--addRight
	},--PC key feedback(top&in a row)
}
local customSet={
	{20,20,1,1,7,1,1,1,3,4,1,2,3},
	{18,20,1,1,7,1,1,1,8,3,8,3,3},
	{22,22,1,1,7,3,1,1,8,4,1,7,7},
	{20,20,1,1,7,1,1,3,8,3,1,7,8},
	{1,11,8,11,4,1,2,1,8,3,1,4,9},
}
local function useDefaultSet(n)
	for i=1,#customSet[n]do
		customSel[i]=customSet[n][i]
	end
	curBG=customRange.bg[customSel[12]]
	BGM(customRange.bgm[customSel[13]])
end
local function VKAdisp(n)
	return function()
		return VK_org[n].ava
	end
end
local function VKAcode(n)
	return function()
		VK_org[n].ava=not VK_org[n].ava
	end
end
Widget={
	load={},intro={},quit={},
	main={
		play=	newButton(150,280,200,160,color.red,		60,function()scene.push()scene.swapTo("mode")end,			nil,"setting"),
		setting=newButton(370,280,200,160,color.lightBlue,	50,function()scene.push()scene.swapTo("setting_game")end,	nil,"music"),
		music=	newButton(590,280,200,160,color.lightPurple,37,function()scene.push()scene.swapTo("music")end,			nil,"help"),
		help=	newButton(150,460,200,160,color.yellow,		55,function()scene.push()scene.swapTo("help")end,			nil,"stat"),
		stat=	newButton(370,460,200,160,color.cyan,		48,function()scene.push()scene.swapTo("stat")end,			nil,"qplay"),
		qplay=	newButton(540,415,100,70,color.lightGreen,	28,function()scene.push()loadGame(modeSel,levelSel)end,	nil,"lang"),
		lang=	newButton(590,505,200,70,color.lightRed,	50,function()
			setting.lang=setting.lang%#langName+1
			swapLanguage(setting.lang)
			end,nil,"quit"),
		quit=	newButton(370,620,280,100,color.lightGrey,	60,function()scene.swapTo("quit")end,						nil,"play"),
	},
	mode={
		up=		newButton(1000,	210,200,140,color.white,	80,function()love.keypressed("up")end,function()return modeSel==1 end),
		down=	newButton(1000,	430,200,140,color.white,	80,function()love.keypressed("down")end,function()return modeSel==#modeID end),
		left=	newButton(190,	160,100,80,	color.white,	40,function()love.keypressed("left")end,function()return levelSel==1 end),
		right=	newButton(350,	160,100,80,	color.white,	40,function()love.keypressed("right")end,function()return levelSel==#modeLevel[modeID[modeSel]]end),
		start=	newButton(1000,	600,250,100,color.green,	50,function()scene.push()loadGame(modeSel,levelSel)end),
		custom=	newButton(275,	420,200,90,	color.yellow,	40,function()scene.push()scene.swapTo("custom")end),
		back=	newButton(640,	630,230,90,	color.white,	45,scene.back),
	},
	music={
		bgm=	newSlider(760,	80,400,8,40,nil,function()return setting.bgm end,function(i)setting.bgm=i;BGM(bgmPlaying)end),
		up=		newButton(1100,	200,120,120,color.white,60,function()love.keypressed("up")end),
		play=	newButton(1100,	340,120,120,color.white,40,function()love.keypressed("space")end,function()return setting.bgm==0 end),
		down=	newButton(1100,	480,120,120,color.white,60,function()love.keypressed("down")end),
		back=	newButton(640,	630,230,90,	color.white,45,scene.back),
	},
	custom={
		up=		newButton(1000,	220,100,100,color.white,		50,function()sel=(sel-2)%#customID+1 end),
		down=	newButton(1000,	460,100,100,color.white,		50,function()sel=sel%#customID+1 end),
		left=	newButton(880,	340,100,100,color.white,		50,function()love.keypressed("left")end),
		right=	newButton(1120,	340,100,100,color.white,		50,function()love.keypressed("right")end),
		start1=	newButton(880,	580,220,70,	color.green,		40,function()scene.push()loadGame(0,1)end),
		start2=	newButton(1120,	580,220,70,	color.lightPurple,	40,function()scene.push()loadGame(0,2)end),
		draw=	newButton(1000,	90,	190,85,	color.cyan,			40,function()scene.push()scene.swapTo("draw")end),
		set1=	newButton(640,	160,240,75,	color.lightRed,		40,function()useDefaultSet(1)end),
		set2=	newButton(640,	250,240,75,	color.lightRed,		40,function()useDefaultSet(2)end),
		set3=	newButton(640,	340,240,75,	color.lightRed,		40,function()useDefaultSet(3)end),
		set4=	newButton(640,	430,240,75,	color.lightRed,		40,function()useDefaultSet(4)end),
		set5=	newButton(640,	520,240,75,	color.lightRed,		40,function()useDefaultSet(5)end),
		back=	newButton(640,	630,180,60,	color.white,		40,scene.back),
	},
	draw={
		block1=	newButton(920,	80,	120,120,color.red,			65,function()pen=1 end),
		block2=	newButton(1060,	80,	120,120,color.green,		65,function()pen=2 end),
		block3=	newButton(1200,	80,	120,120,color.orange,		65,function()pen=3 end),
		block4=	newButton(920,	220,120,120,color.blue,			65,function()pen=4 end),
		block5=	newButton(1060,	220,120,120,color.magenta,		65,function()pen=5 end),
		block6=	newButton(1200,	220,120,120,color.yellow,		65,function()pen=6 end),
		block7=	newButton(920,	360,120,120,color.cyan,			65,function()pen=7 end),
		gb1=	newButton(1060,	360,120,120,color.darkGrey,		65,function()pen=9 end),
		gb2=	newButton(1200,	360,120,120,color.grey,			65,function()pen=10 end),
		gb3=	newButton(920,	500,120,120,color.darkPurple,	65,function()pen=11 end),
		gb4=	newButton(1060,	500,120,120,color.darkRed,		65,function()pen=12 end),
		gb5=	newButton(1200,	500,120,120,color.darkGreen,	65,function()pen=13 end),
		clear=	newButton(780,	80,	120,120,color.white,		45,function()love.keypressed("delete")end),
		any=	newButton(780,	220,120,120,color.lightGrey,	45,function()pen=0 end),
		space=	newButton(780,	360,120,120,color.grey,			70,function()pen=-1 end),
		back=	newButton(1200,	640,120,120,color.white,		40,scene.back),
	},
	play={
		pause=	newButton(1235,45,80,80,color.white,30,pauseGame),
	},
	pause={
		resume=	newButton(640,290,240,100,color.white,50,resumeGame),
		restart=newButton(640,445,240,100,color.white,50,function()
			clearTask("play")
			updateStat()
			resetGameData()
			scene.swapTo("play","none")
			end),
		quit=	newButton(640,600,240,100,color.white,50,scene.back),
	},
	setting_game={
		graphic=newButton(200,80,240,80,color.lightGreen,40,function()scene.swapTo("setting_graphic")end,	nil,"sound"),
		sound=	newButton(1080,80,240,80,color.lightGreen,40,function()scene.swapTo("setting_sound")end,	nil,"dasD"),
		dasD=	newButton(180,230,50,50,color.white,40,function()setting.das=(setting.das-1)%31 end,	nil,"dasU"),
		dasU=	newButton(400,230,50,50,color.white,40,function()setting.das=(setting.das+1)%31 end,	nil,"arrD"),
		arrD=	newButton(500,230,50,50,color.white,40,function()
			setting.arr=(setting.arr-1)%16
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.dasU:FX()
				SFX("blip_1",.4)
			end
			end,nil,"arrU"),
		arrU=	newButton(720,230,50,50,color.white,40,function()
			setting.arr=(setting.arr+1)%16
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.dasU:FX()
				SFX("blip_1",.4)
			end
			end,nil,"sddasD"),
		sddasD=	newButton(180,340,50,50,color.white,40,function()setting.sddas=(setting.sddas-1)%11 end,	nil,"sddasU"),
		sddasU=	newButton(400,340,50,50,color.white,40,function()setting.sddas=(setting.sddas+1)%11 end,	nil,"sdarrD"),
		sdarrD=	newButton(500,340,50,50,color.white,40,function()setting.sdarr=(setting.sdarr-1)%4 end,		nil,"sdarrU"),
		sdarrU=	newButton(720,340,50,50,color.white,40,function()setting.sdarr=(setting.sdarr+1)%4 end,		nil,"quickR"),
		quickR=	newSwitch(560,430,40,function()return setting.quickR end,function()setting.quickR=not setting.quickR end,	nil,"swap"),
		swap=	newSwitch(560,510,25,function()return setting.swap end,function()setting.swap=not setting.swap end,			nil,"fine"),
		fine=	newSwitch(560,590,25,function()return setting.fine end,function()setting.fine=not setting.fine end,			nil,"ctrl"),
		ctrl=	newButton(1020,230,320,80,color.white,40,function()scene.push()scene.swapTo("setting_key")end,			nil,"touch"),
		touch=	newButton(1020,340,320,80,color.white,40,function()scene.push()scene.swapTo("setting_touch")end,			nil,"back"),
		back=	newButton(1160,600,160,160,color.white,55,scene.back,nil,"graphic"),
	},
	setting_graphic={
		sound=	newButton(200,80,240,80,color.lightGreen,40,function()scene.swapTo("setting_sound")end,	nil,"game"),
		game=	newButton(1080,80,240,80,color.lightGreen,40,function()scene.swapTo("setting_game")end,	nil,"ghost"),
		ghost=	newSwitch(310,180,40,function()return setting.ghost end,	function()setting.ghost=	not setting.ghost end,	nil,"center"),
		center=	newSwitch(580,180,40,function()return setting.center end,	function()setting.center=	not setting.center end,	nil,"smo"),
		smo=	newSwitch(310,260,25,function()return setting.smo end,		function()setting.smo=		not setting.smo end,	nil,"grid"),
		grid=	newSwitch(580,260,40,function()return setting.grid end,		function()setting.grid=		not setting.grid end,	nil,"dropFX"),
		dropFX=	newSlider(310,350,373,3,40,nil,function()return setting.dropFX end,		function(i)setting.dropFX=i end,		nil,"shakeFX"),
		shakeFX=newSlider(310,430,373,3,40,nil,function()return setting.shakeFX end,	function(i)setting.shakeFX=i end,		nil,"atkFX"),
		atkFX=	newSlider(310,510,373,3,40,nil,function()return setting.atkFX end,		function(i)setting.atkFX=i end,			nil,"frame"),
		frame=	newSlider(310,590,373,10,40,nil,function()return setting.frameMul>35 and setting.frameMul/10 or setting.frameMul/5-4 end,function(i)setting.frameMul=i<5 and 5*i+20 or 10*i end,nil,"fullscreen"),
		fullscreen=newSwitch(990,180,40,function()return setting.fullscreen end,function()
			setting.fullscreen=not setting.fullscreen
			love.window.setFullscreen(setting.fullscreen)
			if not setting.fullscreen then
			love.resize(love.graphics.getWidth(),love.graphics.getHeight())
			end
			end,nil,"bg"),
		bg=		newSwitch(990,250,40,function()return setting.bg end,function()setting.bg=not setting.bg end,	nil,"bgblock"),
		bgblock=newSwitch(990,330,40,function()return setting.bgblock end,function()
			setting.bgblock=not setting.bgblock--if not setting.bgblock then for i=1,16 do FX_BGblock.list[i].v=3*FX_BGblock.list[i].v end end
			end,nil,"skin"),
		skin=	newButton(860,470,120,60,color.white,40,function()
			setting.skin=setting.skin%8+1
			changeBlockSkin(setting.skin)
			end,nil,"back"),
		back=	newButton(1160,600,160,160,color.white,55,scene.back,nil,"sound"),
		},
	setting_sound={
		game=	newButton(200,80,240,80,color.lightGreen,40,function()scene.swapTo("setting_game")end,	nil,"graphic"),
		graphic=newButton(1080,80,240,80,color.lightGreen,40,function()scene.swapTo("setting_graphic")end,	nil,"sfx"),
		sfx=newSlider(180,250,400,8,40,function()SFX("blip_1")end,				function()return setting.sfx end,function(i)setting.sfx=i end,nil,"bgm"),
		bgm=newSlider(750,250,400,8,40,function()BGM(bgmPlaying or"blank")end,	function()return setting.bgm end,function(i)setting.bgm=i end,nil,"vib"),
		vib=newSlider(180,440,400,5,40,function()VIB(1)end,						function()return setting.vib end,function(i)setting.vib=i end,nil,"voc"),
		voc=newSlider(750,440,400,8,40,function()VOICE("nya")end,				function()return setting.voc end,function(i)setting.voc=i end,nil,"back"),
		back=newButton(1160,600,160,160,color.white,55,scene.back,nil,"game"),
	},
	setting_key={
		back=newButton(1140,650,200,80,color.white,50,scene.back),
	},
	setting_touch={
		hide=	newSwitch(810,140,45,function()return setting.VKSwitch end,function()setting.VKSwitch=not setting.VKSwitch end),
		track=	newSwitch(810,220,45,function()return setting.VKTrack end,function()setting.VKTrack=not setting.VKTrack end),
		tkset=	newButton(450,220,170,80,color.white,30,function()
			scene.push()
			scene.swapTo("setting_trackSetting")
			end,function()return not setting.VKTrack end),
		default=newButton(450,320,170,80,color.white,40,function()
				local D=virtualkeySet[defaultSel]
				for i=1,#VK_org do
					VK_org[i].ava=false
				end
				for n=1,#D do
					local T=D[n]
					if T[1]then
						local B=VK_org[n]
						B.ava=true
						B.x,B.y,B.r=T[2],T[3],T[4]
					end
				end--Replace keys
			defaultSel=defaultSel%5+1
			end),
		snap=	newButton(640,320,170,80,color.white,40,function()
			snapLevel=snapLevel%6+1
			end),
			--VK=T,70,50,27/T,130,50,27/T,190,50,27/T,250,50,27/T,310,50,27/T,370,50,27/T,430,50,27/T,490,50,27/T,550,50,27/T,610,50,27/T,670,50,27/T,730,50,27/T,790,50,27/T,850,50,27/T,910,50,27/T,970,50,27/T,739,789,897/T,1090,50,27/T,1150,50,27/T,1210,50,27
		alpha=	newButton(830,320,170,80,color.white,45,function()
			setting.VKAlpha=(setting.VKAlpha+1)%11
			--Adjust virtualkey alpha
			end),
		icon=	newButton(495,420,260,80,color.white,45,function()
			setting.VKIcon=not setting.VKIcon
			--Switch virtualkey icon
			end),
		size=	newButton(785,420,260,80,color.white,45,function()
			if sel then
				local B=VK_org[sel]
				B.r=B.r+10
				if B.r>=150 then B.r=B.r-110 end
			end
			end),
		toggle=	newButton(495,520,260,80,color.white,45,function()
			scene.push()
			scene.swapTo("setting_touchSwitch")
			end),
		back=	newButton(785,520,260,80,color.white,45,scene.back),
	},
	setting_touchSwitch={
		b1=		newSwitch(300,80,	40,VKAdisp(1),VKAcode(1)),
		b2=		newSwitch(300,140,	40,VKAdisp(2),VKAcode(2)),
		b3=		newSwitch(300,200,	40,VKAdisp(3),VKAcode(3)),
		b4=		newSwitch(300,260,	40,VKAdisp(4),VKAcode(4)),
		b5=		newSwitch(300,320,	40,VKAdisp(5),VKAcode(5)),
		b6=		newSwitch(300,380,	40,VKAdisp(6),VKAcode(6)),
		b7=		newSwitch(300,440,	40,VKAdisp(7),VKAcode(7)),
		b8=		newSwitch(300,500,	40,VKAdisp(8),VKAcode(8)),
		b9=		newSwitch(300,560,	40,VKAdisp(9),VKAcode(9)),
		b10=	newSwitch(300,620,	40,VKAdisp(10),VKAcode(10)),
		b11=	newSwitch(760,80,	40,VKAdisp(11),VKAcode(11)),
		b12=	newSwitch(760,140,	40,VKAdisp(12),VKAcode(12)),
		b13=	newSwitch(760,200,	40,VKAdisp(13),VKAcode(13)),
		b14=	newSwitch(760,260,	40,VKAdisp(14),VKAcode(14)),
		b15=	newSwitch(760,320,	40,VKAdisp(15),VKAcode(15)),
		b16=	newSwitch(760,380,	40,VKAdisp(16),VKAcode(16)),
		b17=	newSwitch(760,440,	40,VKAdisp(17),VKAcode(17)),
		b18=	newSwitch(760,500,	40,VKAdisp(18),VKAcode(18)),
		b19=	newSwitch(760,560,	40,VKAdisp(19),VKAcode(19)),
		b20=	newSwitch(760,620,	40,VKAdisp(20),VKAcode(20)),
		norm=	newButton(1080,150,240,80,color.white,50,function()for i=1,20 do VK_org[i].ava=i<11 end end),
		pro=	newButton(1080,300,240,80,color.white,40,function()for i=1,20 do VK_org[i].ava=true end end),
		back=	newButton(1080,600,240,80,color.white,50,scene.back),
	},
	setting_trackSetting={
		VKTchW=	newSlider(140,310,1000,10,40,nil,function()return setting.VKTchW end,function(i)setting.VKTchW=i;setting.VKCurW=math.max(setting.VKCurW,i)end),
		VKCurW=	newSlider(140,370,1000,10,40,nil,function()return setting.VKCurW end,function(i)setting.VKCurW=i;setting.VKTchW=math.min(setting.VKTchW,i)end),
		back=	newButton(1080,600,240,80,color.white,50,scene.back),
	},
	help={
		his=	newButton(1050,520,230,60,color.white,40,function()scene.push()scene.swapTo("history")end,nil,"back"),
		qq=		newButton(1050,600,230,60,color.white,40,function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,	function()return mobile end,"his"),
		back=	newButton(640,	600,180,60,color.white,40,scene.back,nil,"qq"),
	},
	history={
		prev=	newButton(1155,170,180,180,color.white,70,function()love.keypressed("up")end,function()return sel==1 end),
		next=	newButton(1155,400,180,180,color.white,70,function()love.keypressed("down")end,function()return sel==#updateLog-22 end),
		back=	newButton(1155,600,180,90,color.white,40,scene.back),
	},
	stat={
		path=	newButton(980,620,250,60,color.white,30,function()love.system.openURL(love.filesystem.getSaveDirectory())end,function()return mobile end,"back"),
		back=	newButton(640,620,180,60,color.white,40,scene.back,nil,"path"),
	},
}
for S,L in next,Widget do
	for N,W in next,L do
		if W.next then
			W.next,L[W.next].prev=L[W.next],W
		end
	end
end
widget_sel=nil--selected widget object