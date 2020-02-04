local gc=love.graphics
local tc,kb=love.touch,love.keyboard
local sys=love.system
local fs=love.filesystem
local mobile=system=="Android"or system=="iOS"

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
	survivor={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE","EXTRA"},
	defender={"NORMAL","LUNATIC"},
	attacker={"HARD","ULTIMATE"},
	tech={"NORMAL","NORMAL+","HARD","HARD+","LUNATIC","LUNATIC+",},
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
	{1,11,8,11,4,1,2,1,8,3,1,4,9},
}
local function useDefaultSet(n)
	for i=1,#customSet[n]do
		customSel[i]=customSet[n][i]
	end
	curBG=customRange.bg[customSel[12]]
	BGM(customRange.bgm[customSel[13]])
end
Widget={
	load={},
	intro={},
	main={
		qplay=	newButton(160,	300,150,150,color.lightRed,	40,function()loadGame(modeSel,levelSel)end,	nil,"play"),
		play=	newButton(380,	300,240,240,color.red,		70,function()gotoScene("mode")end,			nil,"setting"),
		setting=newButton(640,	300,240,240,color.lightBlue,55,function()gotoScene("setting")end,		nil,"music"),
		music=	newButton(900,	300,240,240,color.lightCyan,42,function()gotoScene("music")end,			nil,"stat"),
		stat=	newButton(640,	560,240,240,color.cyan,		55,function()gotoScene("stat")end,			nil,"help"),
		help=	newButton(900,	560,240,240,color.yellow,	55,function()gotoScene("help")end,			nil,"quit"),
		quit=	newButton(1180,620,120,120,color.lightGrey,50,function()gotoScene("quit")end,			nil,"qplay"),
	},
	mode={
		up=		newButton(1000,210,200,140,color.white,	80,function()love.keypressed("up")end,function()return modeSel==1 end),
		down=	newButton(1000,430,200,140,color.white,	80,function()love.keypressed("down")end,function()return modeSel==#modeID end),
		left=	newButton(190,	160,100,80,	color.white,	40,function()love.keypressed("left")end,function()return levelSel==1 end),
		right=	newButton(350,	160,100,80,	color.white,	40,function()love.keypressed("right")end,function()return levelSel==#modeLevel[modeID[modeSel]]end),
		start=	newButton(1000,600,250,100,color.green,	50,function()loadGame(modeSel,levelSel)end),
		custom=	newButton(275,	420,200,90,	color.yellow,	40,function()gotoScene("custom")end),
		back=	newButton(640,	630,230,90,	color.white,	45,back),
	},
	music={
		bgm=	newSlider(760,80,400,8,40,nil,function()return setting.bgm end,function(i)setting.bgm=i;BGM(bgmPlaying)end),
		up=		newButton(1100,200,120,120,color.white,60,function()love.keypressed("up")end),
		play=	newButton(1100,340,120,120,color.white,40,function()love.keypressed("space")end,function()return setting.bgm==0 end),
		down=	newButton(1100,480,120,120,color.white,60,function()love.keypressed("down")end),
		back=	newButton(640,	630,230,90,	color.white,45,back),
	},
	custom={
		up=		newButton(1000,220,100,100,color.white,		50,function()sel=(sel-2)%#customID+1 end),
		down=	newButton(1000,460,100,100,color.white,		50,function()sel=sel%#customID+1 end),
		left=	newButton(880,	340,100,100,color.white,		50,function()love.keypressed("left")end),
		right=	newButton(1120,340,100,100,color.white,		50,function()love.keypressed("right")end),
		start1=	newButton(880,	580,220,70,	color.green,		40,function()loadGame(0,1)end),
		start2=	newButton(1120,580,220,70,	color.lightPurple,	40,function()loadGame(0,2)end),
		draw=	newButton(1000,90,	190,85,	color.cyan,			40,function()gotoScene("draw")end),
		set1=	newButton(640,	160,240,75,	color.lightRed,		40,function()useDefaultSet(1)end),
		set2=	newButton(640,	250,240,75,	color.lightRed,		40,function()useDefaultSet(2)end),
		set3=	newButton(640,	340,240,75,	color.lightRed,		40,function()useDefaultSet(3)end),
		set4=	newButton(640,	430,240,75,	color.lightRed,		40,function()useDefaultSet(4)end),
		set5=	newButton(640,	520,240,75,	color.lightRed,		40,function()useDefaultSet(5)end),
		back=	newButton(640,	630,180,60,	color.white,		40,back),
	},
	draw={
		any=	newButton(700,	80,	120,120,color.lightGrey,	45,function()pen=0 end),
		block1=	newButton(840,	80,	120,120,color.red,			65,function()pen=1 end),
		block2=	newButton(980,	80,	120,120,color.green,		65,function()pen=2 end),
		block3=	newButton(1120,80,	120,120,color.orange,		65,function()pen=3 end),
		block4=	newButton(840,	220,120,120,color.blue,			65,function()pen=4 end),
		block5=	newButton(980,	220,120,120,color.magenta,		65,function()pen=5 end),
		block6=	newButton(1120,220,120,120,color.yellow,		65,function()pen=6 end),
		block7=	newButton(840,	360,120,120,color.cyan,			65,function()pen=7 end),
		gb1=	newButton(980,	360,120,120,color.darkGrey,		65,function()pen=9 end),
		gb2=	newButton(1120,360,120,120,color.grey,			65,function()pen=10 end),
		gb3=	newButton(840,	500,120,120,color.darkPurple,	65,function()pen=11 end),
		gb4=	newButton(980,	500,120,120,color.darkRed,		65,function()pen=12 end),
		gb5=	newButton(1120,500,120,120,color.darkGreen,	65,function()pen=13 end),
		space=	newButton(840,	640,120,120,color.grey,			70,function()pen=-1 end),
		clear=	newButton(1120,640,120,120,color.white,		45,function()love.keypressed("delete")end),
		back=	newButton(1235,45,	80,	80,	color.white,		35,back),
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
			gotoScene("play","none")
			end),
		quit=	newButton(640,600,240,100,color.white,50,back),
	},
	setting={
		game=	newButton(640,100,320,70,color.white,40,function()gotoScene("setting_game")	end,nil,"graphic"),
		graphic=newButton(640,180,320,70,color.white,40,function()gotoScene("setting_graphic")	end,nil,"sound"),
		sound=	newButton(640,260,320,70,color.white,40,function()gotoScene("setting_sound")	end,nil,"ctrl"),
		ctrl=	newButton(640,340,320,70,color.white,40,function()gotoScene("setting_control")	end,nil,"touch"),
		touch=	newButton(640,420,320,70,color.white,40,function()gotoScene("setting_touch")	end,nil,"lang"),
		lang=	newButton(640,500,320,70,color.red,40,function()
			setting.lang=setting.lang%#langName+1
			swapLanguage(setting.lang)
			end,nil,"back"),
		back=	newButton(640,620,300,70,color.white,40,back,										nil,"game"),
	},
	setting_game={
		dasD=	newButton(150,120,50,50,color.white,40,function()setting.das=(setting.das-1)%31 end,		nil,"dasU"),
		dasU=	newButton(370,120,50,50,color.white,40,function()setting.das=(setting.das+1)%31 end,		nil,"arrD"),
		arrD=	newButton(450,120,50,50,color.white,40,function()
			setting.arr=(setting.arr-1)%16
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.dasU:FX()
				SFX("blip_1",.4)
			end
			end,nil,"arrU"),
		arrU=	newButton(670,120,50,50,color.white,40,function()
			setting.arr=(setting.arr+1)%16
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.dasU:FX()
				SFX("blip_1",.4)
			end
			end,nil,"sddasD"),
		sddasD=	newButton(150,230,50,50,color.white,40,function()setting.sddas=(setting.sddas-1)%11 end,				nil,"sddasU"),
		sddasU=	newButton(370,230,50,50,color.white,40,function()setting.sddas=(setting.sddas+1)%11 end,				nil,"sdarrD"),
		sdarrD=	newButton(450,230,50,50,color.white,40,function()setting.sdarr=(setting.sdarr-1)%4 end,				nil,"sdarrU"),
		sdarrU=	newButton(670,230,50,50,color.white,40,function()setting.sdarr=(setting.sdarr+1)%4 end,				nil,"holdR"),
		holdR=	newSwitch(510,330,40,function()return setting.holdR end,function()setting.holdR=not setting.holdR end,	nil,"swap"),
		swap=	newSwitch(510,420,25,function()return setting.swap end,function()setting.swap=not setting.swap end,	nil,"back"),
		back=	newButton(640,620,300,70,color.white,40,back,nil,"dasD"),
	},
	setting_graphic={
		ghost=	newSwitch(310,90,40,			function()return setting.ghost end,		function()setting.ghost=	not setting.ghost end,	nil,"center"),
		center=	newSwitch(580,90,40,			function()return setting.center end,	function()setting.center=	not setting.center end,	nil,"smo"),
		smo=	newSwitch(310,170,25,			function()return setting.smo end,		function()setting.smo=		not setting.smo end,	nil,"grid"),
		grid=	newSwitch(580,170,40,			function()return setting.grid end,		function()setting.grid=		not setting.grid end,	nil,"dropFX"),
		dropFX=	newSlider(310,260,373,3,40,nil,function()return setting.dropFX end,	function(i)setting.dropFX=i end,					nil,"shakeFX"),
		shakeFX=newSlider(310,340,373,3,40,nil,function()return setting.shakeFX end,	function(i)setting.shakeFX=i end,					nil,"atkFX"),
		atkFX=	newSlider(310,420,373,3,40,nil,function()return setting.atkFX end,		function(i)setting.atkFX=i end,						nil,"frame"),
		frame=	newSlider(310,500,373,10,40,nil,function()return setting.frameMul>35 and setting.frameMul/10 or setting.frameMul/5-4 end,function(i)setting.frameMul=i<5 and 5*i+20 or 10*i end,nil,"fullscreen"),
		fullscreen=newSwitch(990,90,40,function()return setting.fullscreen end,function()
			setting.fullscreen=not setting.fullscreen
			love.window.setFullscreen(setting.fullscreen)
			if not setting.fullscreen then
			love.resize(gc.getWidth(),gc.getHeight())
			end
			end,nil,"bg"),
		bg=		newSwitch(990,170,40,function()return setting.bg end,function()setting.bg=not setting.bg end,	nil,"bgblock"),
		bgblock=newSwitch(990,250,40,function()return setting.bgblock end,function()
			setting.bgblock=not setting.bgblock--if not setting.bgblock then for i=1,16 do FX_BGblock.list[i].v=3*FX_BGblock.list[i].v end end
			end,nil,"skin"),
		skin=	newButton(950,450,120,60,color.white,40,function()
			setting.skin=setting.skin%6+1
			changeBlockSkin(setting.skin)
			end,nil,"back"),
		back=	newButton(600,620,300,70,color.white,40,back,nil,"ghost"),
	},
	setting_sound={
		sfx=newSlider(180,150,400,8,40,function()SFX("blip_1")end,				function()return setting.sfx end,function(i)setting.sfx=i end,nil,"bgm"),
		bgm=newSlider(750,150,400,8,40,function()BGM(bgmPlaying or"blank")end,	function()return setting.bgm end,function(i)setting.bgm=i end,nil,"vib"),
		vib=newSlider(180,340,400,5,40,function()VIB(1)end,						function()return setting.vib end,function(i)setting.vib=i end,nil,"voc"),
		voc=newSlider(750,340,400,8,40,function()VOICE("nya")end,				function()return setting.voc end,function(i)setting.voc=i end,nil,"back"),
		back=newButton(640,620,300,70,color.white,40,back,nil,"sfx"),
	},
	setting_control={
		back=newButton(840,630,180,60,color.white,40,back),
	},
	setting_touch={
		hide=	newButton(640,210,500,80,color.white,45,function()
			setting.virtualkeySwitch=not setting.virtualkeySwitch
			end),
		default=newButton(450,310,170,80,color.white,40,function()
			for K=1,#virtualkey do
				local b,b0=virtualkey[K],virtualkeySet[defaultSel][K]
				b[1],b[2],b[3],b[4]=b0[1],b0[2],b0[3],b0[4]
			end--Default virtualkey
			defaultSel=defaultSel%5+1
			end),
		snap=	newButton(640,310,170,80,color.white,40,function()
			snapLevel=snapLevel%6+1
			end),
		alpha=	newButton(830,310,170,80,color.white,45,function()
			setting.virtualkeyAlpha=(setting.virtualkeyAlpha+1)%11
			--Adjust virtualkey alpha
			end),
		icon=	newButton(450,410,170,80,color.white,45,function()
			setting.virtualkeyIcon=not setting.virtualkeyIcon
			--Switch virtualkey icon
			end),
		size=	newButton(830,410,170,80,color.white,45,function()
			if sel then
				local b=virtualkey[sel]
				b[4]=b[4]+10
				if b[4]==150 then b[4]=40 end
				b[3]=b[4]^2
			end
			end),
		back=	newButton(640,410,170,80,color.white,45,back),
	},
	help={
		his=	newButton(1050,520,230,60,color.white,40,function()gotoScene("history")end,nil,"back"),
		qq=		newButton(1050,600,230,60,color.white,40,function()sys.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,	function()return mobile end,"his"),
		back=	newButton(640,	600,180,60,color.white,40,back,nil,"qq"),
	},
	history={
		prev=	newButton(1155,170,180,180,color.white,70,function()love.keypressed("up")end,function()return sel==1 end),
		next=	newButton(1155,400,180,180,color.white,70,function()love.keypressed("down")end,function()return sel==#updateLog-22 end),
		back=	newButton(1155,600,180,90,color.white,40,back),
	},
	stat={
		path=	newButton(980,590,250,60,color.white,30,function()sys.openURL(fs.getSaveDirectory())end,function()return mobile end,"back"),
		back=	newButton(640,590,180,60,color.white,40,back,nil,"path"),
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