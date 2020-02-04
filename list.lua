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
	"error","error_long",
	--Stereo sfxs(cannot set position)
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
	--Mono sfxs
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
	"zspin","sspin","lspin","jspin","tspin","ospin","ispin",
	"single","double","triple","techrash",
	"mini","b2b","b3b","pc",
	"win","lose",
	"bye",
	"nya","voc_nya",
	"egg",
}
voiceList={
	zspin={"zspin_1","zspin_2","zspin_3"},
	sspin={"sspin_1","sspin_2","sspin_3","sspin_4","sspin_5","sspin_6"},
	lspin={"lspin_1","lspin_2"},
	jspin={"jspin_1","jspin_2","jspin_3","jspin_4"},
	tspin={"tspin_1","tspin_2","tspin_3","tspin_4","tspin_5","tspin_6"},
	ospin={"ospin_1","ospin_2","ospin_3"},
	ispin={"ispin_1","ispin_2","ispin_3"},

	single={"single_1","single_2","single_3","single_4","single_5","single_6","single_7"},
	double={"double_1","double_2","double_3","double_4","double_5"},
	triple={"triple_1","triple_2","triple_3","triple_4","triple_5","triple_6","triple_7"},
	techrash={"techrash_1","techrash_2","techrash_3","techrash_4"},

	mini={"mini_1","mini_2","mini_3"},
	b2b={"b2b_1","b2b_2","b2b_3"},
	b3b={"b3b_1","b3b_2"},
	pc={"pc_1","pc_2"},
	win={"win_1","win_2","win_3","win_4","win_5","win_6","win_6","win_7"},
	lose={"lose_1","lose_2","lose_3"},
	bye={"bye_1","bye_2"},
	nya={"nya_1","nya_2","nya_3","nya_4"},
	voc_nya={"nya_11","nya_12","nya_13","nya_21","nya_22"},
	egg={"egg_1","egg_2"},
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
modeID={
	[0]="custom",
	"sprint","marathon","master","classic","zen","infinite","solo","round","tsd","blind",
	"dig","survivor","defender","attacker","tech",
	"c4wtrain","pctrain","pcchallenge","techmino49","techmino99","drought","hotseat",
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

--λFuncs for widgets
local function SETdisp(k)
	return function()
		return setting[k]
	end
end
local function SETsto(k)
	return function(i)setting[k]=i end
end
local function SETrev(k)
	return function()
		setting[k]=not setting[k]
	end
end
local function pressKey(k)
	return function()
		love.keypressed(k)
	end
end
local function setPen(i)
	return function()
		pen=i
	end
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
local C=color
local skinName={
	"Normal(MrZ)",
	"Jelly(Miya)",
	"Plastic(MrZ)",
	"Glow(MrZ)",
	"Pure(MrZ)",
	"Text Bone(MrZ)",
	"Colored Bone(MrZ)",
	"white Bone(MrZ)",
}
-- T1,T2=0,0
Widget={
	load={},intro={},quit={},
	main={
		play=	newButton(150,280,200,160,C.lightRed,		55,function()scene.push()scene.swapTo("mode")end,			nil,"setting"),
		setting=newButton(370,280,200,160,C.lightBlue,	45,function()scene.push()scene.swapTo("setting_game")end,	nil,"music"),
		music=	newButton(590,280,200,160,C.lightPurple,32,function()scene.push()scene.swapTo("music")end,			nil,"help"),
		help=	newButton(150,460,200,160,C.lightYellow,		50,function()scene.push()scene.swapTo("help")end,			nil,"stat"),
		stat=	newButton(370,460,200,160,C.lightCyan,		43,function()scene.push()scene.swapTo("stat")end,			nil,"qplay"),
		qplay=	newButton(540,415,100,70,C.lightOrange,	23,function()scene.push()loadGame(modeSel,levelSel)end,	nil,"lang"),
		lang=	newButton(590,505,200,70,C.lightRed,	45,function()
			setting.lang=setting.lang%#langName+1
			swapLanguage(setting.lang)
			TEXT(text.lang,795,500,50,"appear",1.6)
			end,nil,"quit"),
		-- S1= newSlider(520,550,380,10,10,nil,function()return T1 end,function(i)T1=i end),
		-- S2= newSlider(520,590,380,10,10,nil,function()return T2 end,function(i)T2=i end),
		quit=	newButton(370,620,280,100,C.lightGrey,	55,function()VOICE("bye")scene.swapTo("quit","slowFade")end,nil,"play"),
	},
	mode={
		up=		newButton(1000,	210,200,140,C.white,		75,pressKey("up"),		function()return modeSel==1 end),
		down=	newButton(1000,	430,200,140,C.white,		75,pressKey("down"),	function()return modeSel==#modeID end),
		left=	newButton(190,	150,100,80,	C.white,		35,pressKey("left"),	function()return levelSel==1 end),
		right=	newButton(350,	150,100,80,	C.white,		35,pressKey("right"),	function()return levelSel==#modes[modeID[modeSel]].level end),
		start=	newButton(1000,	600,250,100,C.lightGreen,	45,function()scene.push()loadGame(modeSel,levelSel)end),
		custom=	newButton(275,	460,200,90,	C.lightYellow,	35,function()scene.push()scene.swapTo("custom")end),
		back=	newButton(640,	630,230,90,	C.white,		40,scene.back),
	},
	music={
		bgm=	newSlider(760,	80,400,10,35,nil,SETdisp("bgm"),function(i)setting.bgm=i;BGM(bgmPlaying)end),
		up=		newButton(1100,	200,120,120,C.white,55,pressKey("up")),
		play=	newButton(1100,	340,120,120,C.white,35,pressKey("space"),function()return setting.bgm==0 end),
		down=	newButton(1100,	480,120,120,C.white,55,pressKey("down")),
		back=	newButton(640,	630,230,90,	C.white,40,scene.back),
	},
	custom={
		up=		newButton(1000,	220,100,100,C.white,		45,function()sel=(sel-2)%#customID+1 end),
		down=	newButton(1000,	460,100,100,C.white,		45,function()sel=sel%#customID+1 end),
		left=	newButton(880,	340,100,100,C.white,		45,pressKey("left")),
		right=	newButton(1120,	340,100,100,C.white,		45,pressKey("right")),
		start1=	newButton(880,	580,220,70,	C.lightGreen,	35,function()scene.push()loadGame(0,1)end),
		start2=	newButton(1120,	580,220,70,	C.lightPurple,	35,function()scene.push()loadGame(0,2)end),
		draw=	newButton(1000,	90,	190,85,	C.lightCyan,			35,function()scene.push()scene.swapTo("draw")end),
		set1=	newButton(640,	160,240,75,	C.lightYellow,	35,function()useDefaultSet(1)end),
		set2=	newButton(640,	250,240,75,	C.lightYellow,	35,function()useDefaultSet(2)end),
		set3=	newButton(640,	340,240,75,	C.lightYellow,	35,function()useDefaultSet(3)end),
		set4=	newButton(640,	430,240,75,	C.lightYellow,	35,function()useDefaultSet(4)end),
		set5=	newButton(640,	520,240,75,	C.lightYellow,	35,function()useDefaultSet(5)end),
		back=	newButton(640,	630,180,60,	C.white,		35,scene.back),
	},
	draw={
		block1=	newButton(920,	80,	120,120,C.red,			60,setPen(1)),
		block2=	newButton(1060,	80,	120,120,C.green,		60,setPen(2)),
		block3=	newButton(1200,	80,	120,120,C.orange,		60,setPen(3)),
		block4=	newButton(920,	220,120,120,C.blue,			60,setPen(4)),
		block5=	newButton(1060,	220,120,120,C.magenta,		60,setPen(5)),
		block6=	newButton(1200,	220,120,120,C.yellow,		60,setPen(6)),
		block7=	newButton(920,	360,120,120,C.cyan,			60,setPen(7)),
		gb1=	newButton(1060,	360,120,120,C.darkGrey,		60,setPen(9)),
		gb2=	newButton(1200,	360,120,120,C.grey,			60,setPen(10)),
		gb3=	newButton(920,	500,120,120,C.darkPurple,	60,setPen(11)),
		gb4=	newButton(1060,	500,120,120,C.darkRed,		60,setPen(12)),
		gb5=	newButton(1200,	500,120,120,C.darkGreen,	60,setPen(13)),
		clear=	newButton(780,	80,	120,120,C.white,		40,pressKey("delete")),
		any=	newButton(780,	220,120,120,C.lightGrey,	40,setPen(0)),
		space=	newButton(780,	360,120,120,C.grey,			65,setPen(-1)),
		back=	newButton(1200,	640,120,120,C.white,		35,scene.back),
	},
	play={
		pause=	newButton(1235,45,80,80,C.white,25,pauseGame),
	},
	pause={
		resume=	newButton(640,290,240,100,C.white,45,resumeGame),
		restart=newButton(640,445,240,100,C.white,45,function()
			clearTask("play")
			updateStat()
			resetGameData()
			scene.swapTo("play","none")
			end),
		setting=newButton(1150,80,200,100,C.yellow,40,function()
			scene.push()
			scene.swapTo("setting_sound")
		end),
		quit=	newButton(640,600,240,100,C.white,45,scene.back),
	},
	setting_game={
		graphic=newButton(200,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_graphic")end,	nil,"sound"),
		sound=	newButton(1080,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_sound")end,	nil,"dasD"),
		dasD=	newButton(180,230,50,50,C.white,40,function()
			setting.das=(setting.das-1)%31
			if setting.arr>setting.das then
				setting.arr=setting.das
				Widget.setting_game.arrD:FX()
				SFX("blip_1",.4)
			end
			end,nil,"dasU"),
		dasU=	newButton(400,230,50,50,C.white,40,function()
			setting.das=(setting.das+1)%31
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.arrD:FX()
				SFX("blip_1",.4)
			end
			end,nil,"arrD"),
		arrD=	newButton(500,230,50,50,C.white,40,function()
			setting.arr=(setting.arr-1)%16
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.dasU:FX()
				SFX("blip_1",.4)
			end
			end,nil,"arrU"),
		arrU=	newButton(720,230,50,50,C.white,40,function()
			setting.arr=(setting.arr+1)%16
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.dasU:FX()
				SFX("blip_1",.4)
			end
			end,nil,"sddasD"),
		sddasD=	newButton(180,340,50,50,C.white,40,	function()setting.sddas=(setting.sddas-1)%11 end,	nil,"sddasU"),
		sddasU=	newButton(400,340,50,50,C.white,40,	function()setting.sddas=(setting.sddas+1)%11 end,	nil,"sdarrD"),
		sdarrD=	newButton(500,340,50,50,C.white,40,	function()setting.sdarr=(setting.sdarr-1)%4 end,	nil,"sdarrU"),
		sdarrU=	newButton(720,340,50,50,C.white,40,	function()setting.sdarr=(setting.sdarr+1)%4 end,	nil,"quickR"),
		quickR=	newSwitch(580,430,35,SETdisp("quickR"),	SETrev("quickR"),									nil,"swap"),
		swap=	newSwitch(580,510,20,SETdisp("swap"),	SETrev("swap"),										nil,"fine"),
		fine=	newSwitch(580,590,20,SETdisp("fine"),	SETrev("fine"),										nil,"ctrl"),
		ctrl=	newButton(1020,230,320,80,C.white,35,function()scene.push()scene.swapTo("setting_key")end,	nil,"touch"),
		touch=	newButton(1020,340,320,80,C.white,35,function()scene.push()scene.swapTo("setting_touch")end,nil,"back"),
		back=	newButton(1160,600,160,160,C.white,50,scene.back,nil,"graphic"),
	},
	setting_graphic={
		sound=	newButton(200,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_sound")end,	nil,"game"),
		game=	newButton(1080,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_game")end,	nil,"ghost"),
		ghost=	newSwitch(310,180,35,SETdisp("ghost"),						SETrev("ghost"),		nil,"center"),
		center=	newSwitch(580,180,35,SETdisp("center"),						SETrev("center"),		nil,"smo"),
		smo=	newSwitch(310,260,25,SETdisp("smo"),						SETrev("smo"),			nil,"grid"),
		grid=	newSwitch(580,260,30,SETdisp("grid"),						SETrev("grid"),			nil,"dropFX"),
		dropFX=	newSlider(310,350,373,5,35,nil,SETdisp("dropFX"),			SETsto("dropFX"),		nil,"shakeFX"),
		shakeFX=newSlider(310,430,373,5,35,nil,SETdisp("shakeFX"),			SETsto("shakeFX"),		nil,"atkFX"),
		atkFX=	newSlider(310,510,373,5,35,nil,SETdisp("atkFX"),			SETsto("atkFX"),		nil,"frame"),
		frame=	newSlider(310,590,373,10,35,nil,function()return setting.frameMul>35 and setting.frameMul/10 or setting.frameMul/5-4 end,function(i)setting.frameMul=i<5 and 5*i+20 or 10*i end,nil,"fullscreen"),
		fullscreen=newSwitch(990,180,40,SETdisp("fullscreen"),function()
			setting.fullscreen=not setting.fullscreen
			love.window.setFullscreen(setting.fullscreen)
			if not setting.fullscreen then
			love.resize(love.graphics.getWidth(),love.graphics.getHeight())
			end
			end,nil,"bg"),
		bg=		newSwitch(990,250,35,SETdisp("bg"),SETrev("bg"),nil,"bgblock"),
		bgblock=newSwitch(990,330,35,SETdisp("bgblock"),SETrev("bgblock"),nil,"skin"),--if not setting.bgblock then for i=1,16 do FX_BGblock.list[i].v=3*FX_BGblock.list[i].v end end
		skin=	newButton(810,420,120,60,C.white,35,function()
			local _=setting.skin%8+1
			setting.skin=_
			changeBlockSkin(_)
			TEXT(skinName[_],850,475,28,"appear")
			end,nil,"back"),
		back=	newButton(1160,600,160,160,C.white,50,scene.back,nil,"sound"),
		},
	setting_sound={
		game=	newButton(200,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_game")end,							nil,"graphic"),
		graphic=newButton(1080,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_graphic")end,						nil,"sfx"),
		sfx=	newSlider(180,250,400,10,35,function()SFX("blip_1")end,						SETdisp("sfx"),		SETsto("sfx"),	nil,"bgm"),
		bgm=	newSlider(750,250,400,10,35,function()BGM(bgmPlaying or"blank")end,			SETdisp("bgm"),		SETsto("bgm"),	nil,"vib"),
		vib=	newSlider(180,440,400,5	,35,function()VIB(1)end,							SETdisp("vib"),		SETsto("vib"),	nil,"voc"),
		voc=	newSlider(750,440,400,10,35,function()VOICE("nya")end,						SETdisp("voc"),		SETsto("voc"),	nil,"stereo"),
		stereo=	newSlider(180,630,400,10,35,function()SFX("move",1,-1)SFX("lock",1,1)end,	SETdisp("stereo"),	SETsto("stereo"),function()return setting.sfx==0 end,"back"),
		back=newButton(1160,600,160,160,C.white,50,scene.back,nil,"game"),
	},
	setting_key={
		back=newButton(1140,650,200,80,C.white,45,scene.back),
	},
	setting_touch={
		default=newButton(520,80,170,80,C.white,35,function()
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
		snap=	newButton(760,80,170,80,C.white,35,function()
			snapLevel=snapLevel%6+1
			end),
		more=	newButton(520,180,170,80,C.white,40,function()
			scene.push()
			scene.swapTo("setting_touchSwitch")
			end),
		back=	newButton(760,180,170,80,C.white,40,scene.back),
		size=	newSlider(360,120,560,14,40,nil,function()
			return VK_org[sel].r/10-1
		end,
		function(v)
			if sel then
				VK_org[sel].r=10+v*10
			end
			end,
		function()return not sel end),
	},
	setting_touchSwitch={
		b1=		newSwitch(280,80,	35,VKAdisp(1),VKAcode(1)),
		b2=		newSwitch(280,140,	35,VKAdisp(2),VKAcode(2)),
		b3=		newSwitch(280,200,	35,VKAdisp(3),VKAcode(3)),
		b4=		newSwitch(280,260,	35,VKAdisp(4),VKAcode(4)),
		b5=		newSwitch(280,320,	35,VKAdisp(5),VKAcode(5)),
		b6=		newSwitch(280,380,	35,VKAdisp(6),VKAcode(6)),
		b7=		newSwitch(280,440,	35,VKAdisp(7),VKAcode(7)),
		b8=		newSwitch(280,500,	35,VKAdisp(8),VKAcode(8)),
		b9=		newSwitch(280,560,	35,VKAdisp(9),VKAcode(9)),
		b10=	newSwitch(280,620,	35,VKAdisp(10),VKAcode(10)),
		b11=	newSwitch(620,80,	35,VKAdisp(11),VKAcode(11)),
		b12=	newSwitch(620,140,	35,VKAdisp(12),VKAcode(12)),
		b13=	newSwitch(620,200,	35,VKAdisp(13),VKAcode(13)),
		b14=	newSwitch(620,260,	35,VKAdisp(14),VKAcode(14)),
		b15=	newSwitch(620,320,	35,VKAdisp(15),VKAcode(15)),
		b16=	newSwitch(620,380,	35,VKAdisp(16),VKAcode(16)),
		b17=	newSwitch(620,440,	35,VKAdisp(17),VKAcode(17)),
		b18=	newSwitch(620,500,	35,VKAdisp(18),VKAcode(18)),
		b19=	newSwitch(620,560,	35,VKAdisp(19),VKAcode(19)),
		b20=	newSwitch(620,620,	35,VKAdisp(20),VKAcode(20)),
		norm=	newButton(840,100,240,80,C.white,45,function()for i=1,20 do VK_org[i].ava=i<11 end end),
		pro=	newButton(1120,100,240,80,C.white,35,function()for i=1,20 do VK_org[i].ava=true end end),
		hide=	newSwitch(1170,200,40,SETdisp("VKSwitch"),SETrev("VKSwitch")),
		track=	newSwitch(1170,300,35,SETdisp("VKTrack"),SETrev("VKTrack")),
		icon=	newSwitch(850,300,40,SETdisp("VKIcon"),SETrev("VKIcon")),
		tkset=	newButton(1120,400,240,80,C.white,32,function()
			scene.push()
			scene.swapTo("setting_trackSetting")
			end,function()return not setting.VKTrack end),
		alpha=	newSlider(840,490,400,10,40,nil,SETdisp("VKAlpha"),SETsto("VKAlpha")),
		back=	newButton(1100,600,240,80,C.white,45,scene.back),
	},
	setting_trackSetting={
		VKDodge=newSwitch(400,200,	35,SETdisp("VKDodge"),SETrev("VKDodge")),
		VKTchW=	newSlider(140,310,1000,10,35,nil,SETdisp("VKTchW"),function(i)setting.VKTchW=i;setting.VKCurW=math.max(setting.VKCurW,i)end),
		VKCurW=	newSlider(140,370,1000,10,35,nil,SETdisp("VKCurW"),function(i)setting.VKCurW=i;setting.VKTchW=math.min(setting.VKTchW,i)end),
		back=	newButton(1080,600,240,80,C.white,45,scene.back),
	},
	help={
		his=	newButton(1050,520,230,60,C.white,35,function()scene.push()scene.swapTo("history")end,nil,"back"),
		qq=		newButton(1050,600,230,60,C.white,35,function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,	function()return mobile end,"his"),
		back=	newButton(640,	600,180,60,C.white,35,scene.back,nil,"qq"),
	},
	history={
		prev=	newButton(1155,170,180,180,C.white,65,pressKey("up"),function()return sel==1 end),
		next=	newButton(1155,400,180,180,C.white,65,pressKey("down"),function()return sel==#updateLog-22 end),
		back=	newButton(1155,600,180,90,C.white,35,scene.back),
	},
	stat={
		path=	newButton(980,620,250,60,C.white,25,function()love.system.openURL(love.filesystem.getSaveDirectory())end,function()return mobile end,"back"),
		back=	newButton(640,620,180,60,C.white,35,scene.back,nil,"path"),
	},
}
for _,L in next,Widget do
	for _,W in next,L do
		if W.next then
			W.next,L[W.next].prev=L[W.next],W
		end
	end
end
widget_sel=nil--selected widget object