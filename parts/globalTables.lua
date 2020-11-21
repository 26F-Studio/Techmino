local function disableKey(P,key)
	table.insert(P.gameEnv.keyCancel,key)
end
MODOPT={--Mod options
	noNext={id="NN",
		key="q",x=80,y=230,color=COLOR.red,
		conflict={"hideNext","fullNext"},
		func=function(P)P.gameEnv.nextCount=0 end,
	},
	fullNext={id="FN",
		key="w",x=200,y=230,color=COLOR.water,
		conflict={"noNext"},
		func=function(P)P.gameEnv.nextCount=6 end,
		unranked=true,
	},
	noHold={id="NH",
		key="e",x=320,y=230,color=COLOR.red,
		conflict={"multiHold"},
		func=function(P)P.gameEnv.holdCount=0 end,
	},
	multiHold={id="MH",
		key="r",x=440,y=230,color=COLOR.water,
		list={2,3,4,5,6},
		conflict={"noHold"},
		func=function(P,M)P.gameEnv.holdCount=M.list[M.sel] end,
		unranked=true,
	},
	hideNext={id="FL",
		key="y",x=680,y=230,color=COLOR.orange,
		list={1,2,3,4,5},
		conflict={"noNext"},
		func=function(P,M)P.gameEnv.nextStartPos=M.list[M.sel]+1 end,
	},
	hideBlock={id="HB",
		key="u",x=800,y=230,color=COLOR.orange,
		func=function(P)P.gameEnv.block=false end,
	},
	hideGhost={id="HG",
		key="i",x=920,y=230,color=COLOR.orange,
		func=function(P)P.gameEnv.ghost=false end,
	},
	hidden={id="HD",
		key="o",x=1040,y=230,color=COLOR.green,
		list={"time","fast","none"},
		conflict={"coverBoard"},
		func=function(P,M)P.gameEnv.visible=M.list[M.sel]end,
		unranked=true,
	},
	coverBoard={id="CB",
		key="p",x=1160,y=230,color=COLOR.green,
		list={"down","up","all"},
		conflict={"hidden"},
		func=function(P)LOG.print("该mod还没有做好!")end,
	},

	maxG={id="20G",
		key="a",x=140,y=350,color=COLOR.red,
		conflict={"minG","suddenLock"},
		func=function(P)P.gameEnv.drop=0 end,
		unranked=true,
	},
	suddenLock={id="SL",
		key="s",x=260,y=350,color=COLOR.red,
		conflict={"maxG","infLock"},
		func=function(P)P.gameEnv.lock=0 end,
		unranked=true,
	},
	oneLife={id="SD",
		key="d",x=380,y=350,color=COLOR.red,
		conflict={"infLife"},
		func=function(P)P.gameEnv.life=0 end,
		unranked=true,
	},
	noTele={id="NT",
		key="f",x=500,y=350,color=COLOR.red,
		conflict={"teleMove"},
		func=function(P)P.gameEnv.noTele=true end,
		unranked=true,
	},
	forceB2B={id="FB",
		key="h",x=740,y=350,color=COLOR.yellow,
		func=function(P)P.gameEnv.b2bKill=true end,
	},
	forceFinesse={id="PF",
		key="j",x=860,y=350,color=COLOR.yellow,
		func=function(P)P.gameEnv.fineKill=true end,
	},
	mirror={id="MR",
		key="k",x=980,y=350,color=COLOR.yellow,
		func=function(P)LOG.print("该mod还没有做好!")end,
	},
	flip={id="HR",
		key="l",x=1100,y=350,color=COLOR.yellow,
		func=function(P)LOG.print("该mod还没有做好!")end,
	},

	minG={id="0G",
		key="z",x=200,y=470,color=COLOR.cyan,
		conflict={"maxG"},
		func=function(P)P.gameEnv.drop=1e99 end,
		unranked=true,
	},
	infLock={id="IF",
		key="x",x=320,y=470,color=COLOR.cyan,
		conflict={"suddenLock"},
		func=function(P)P.gameEnv.lock=1e99 end,
		unranked=true,
	},
	infLife={id="NF",
		key="c",x=440,y=470,color=COLOR.cyan,
		conflict={"oneLife"},
		func=function(P)P.gameEnv.life=1e99 end,
		unranked=true,
	},
	teleMove={id="TL",
		key="v",x=560,y=470,color=COLOR.cyan,
		conflict={"noTele"},
		func=function(P)
			P.gameEnv.das,P.gameEnv.arr=0,0
			P.gameEnv.sddas,P.gameEnv.sdarr=0,0
			disableKey(P,14)
			disableKey(P,15)
			disableKey(P,16)
		end,
		unranked=true,
	},
	randSeq={id="RS",
		key="b",x=680,y=470,color=COLOR.purple,
		func=function(P)P.gameEnv.sequence="rnd"end,
		unranked=true,
	},
	noRotation={id="FX",
		key="n",x=800,y=470,color=COLOR.red,
		func=function(P)
			disableKey(P,3)
			disableKey(P,4)
			disableKey(P,5)
		end,
	},
	noMove={id="ST",
		key="m",x=920,y=470,color=COLOR.red,
		func=function(P)
			disableKey(P,1)disableKey(P,2)
			disableKey(P,11)disableKey(P,12)
			disableKey(P,17)disableKey(P,18)
			disableKey(P,19)disableKey(P,20)
		end,
	},
}for _,M in next,MODOPT do M.sel,M.time=0,0 end

CUSTOMENV={--gameEnv for cutsom game
	--Basic
	drop=60,
	lock=60,
	wait=0,
	fall=0,

	nextCount=6,
	nextStartPos=1,
	holdCount=1,
	infHold=false,

	--Visual
	block=true,
	ghost=.3,
	center=1,
	bagLine=false,
	highCam=false,
	nextPos=false,
	bone=false,

	--Rule
	mindas=0,
	minarr=0,
	minsdarr=0,
	sequence="bag",
	ospin=true,
	RS="TRS",

	noTele=false,
	fineKill=false,
	b2bKill=false,
	missionKill=false,
	easyFresh=true,
	visible="show",
	target=1e99,
	freshLimit=1e99,
	opponent=0,
	life=0,
	pushSpeed=3,

	--Else
	bg="none",
	bgm="race",
	noMod=true,
}

FIELD={}--Field(s) for custom game
BAG={}--Sequence for custom game
MISSION={}--Clearing mission for custom game

GAME={--Global game data
	init=false,			--If need initializing game when enter scene-play
	restartCount=0,		--Keep +=1 if player hold restart button after game start

	frame=0,			--Frame count
	result=false,		--Game result (string)
	pauseTime=0,		--Time paused
	pauseCount=0,		--Pausing count
	garbageSpeed=1,		--Garbage timing speed
	warnLVL0=0,			--Warning level
	warnLVL=0,			--Warning level (show)

	seed=1046101471,	--Game seed
	curMode=nil,		--Current gamemode object
	modeEnv=nil,		--Current gamemode environment
	setting={},			--Game settings
	rec={},				--Recording list, key,time,key,time...
	recording=false,	--If recording
	replaying=false,	--If replaying
	unranked=nil,		--unranked if specific mod is on
	rank=nil,			--Rank reached

	prevBG=nil,			--Previous background, for restore BG when quit setting page

	--Data for royale mode
	stage=nil,			--Game stage
	mostBadge=nil,		--Most badge owner
	secBadge=nil,		--Second badge owner
	mostDangerous=nil,	--Most dangerous player
	secDangerous=nil,	--Second dangerous player
}

PLAYERS={alive={}}--Players data

RANKS={sprint_10=0}

SETTING={
	--Game
	das=10,arr=2,
	sddas=0,sdarr=2,
	ihs=true,irs=true,ims=true,
	maxNext=6,
	RS="TRS",
	swap=true,

	--System
	reTime=4,
	autoPause=true,
	fine=false,
	appLock=false,
	lang=1,
	skinSet=1,
	skin={1,7,11,3,14,4,9,1,7,1,7,11,3,14,4,9,14,9,11,3,11,3,1,7,4},
	face={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},

	--Graphic
	block=true,ghost=.3,center=1,
	smooth=true,grid=false,
	bagLine=false,
	lockFX=2,
	dropFX=2,
	moveFX=2,
	clearFX=2,
	shakeFX=2,
	atkFX=3,
	frameMul=100,

	text=true,
	score=true,
	warn=true,
	highCam=false,
	nextPos=false,
	fullscreen=false,
	bg=true,
	powerInfo=false,

	--Sound
	sfx=1,
	spawn=0,
	bgm=.7,
	stereo=.6,
	vib=0,
	voc=0,
	cv="miya",

	--Virtualkey
	VKSFX=.2,--SFX volume
	VKVIB=0,--VIB
	VKSwitch=false,--If disp
	VKTrack=false,--If tracked
	VKDodge=false,--If dodge
	VKTchW=3,--Touch-Pos Weight
	VKCurW=4,--Cur-Pos Weight
	VKIcon=true,--If disp icon
	VKAlpha=.3,
}

STAT={
	version=VERSION,
	run=0,game=0,time=0,
	key=0,rotate=0,hold=0,
	extraPiece=0,finesseRate=0,
	piece=0,row=0,dig=0,
	atk=0,digatk=0,
	send=0,recv=0,pend=0,off=0,
	clear={},spin={},
	pc=0,hpc=0,b2b=0,b3b=0,score=0,
	lastPlay="sprint_10",--Last played mode ID
}
for i=1,25 do
	STAT.clear[i]={0,0,0,0,0,0}
	STAT.spin[i]={0,0,0,0,0,0,0}
end

keyMap={
	{"left","right","x","z","c","up","down","space","tab","r"},{},
	--Keyboard
	{"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","x","leftshoulder"},{},
	--Joystick
}
for i=1,#keyMap do for j=1,20 do
	if not keyMap[i][j]then keyMap[i][j]=""end
end end

VK_org={--Original virtualkey set,for restore VKs' position before each game
	{ava=true,	x=80,		y=720-200,	r=80},--moveLeft
	{ava=true,	x=320,		y=720-200,	r=80},--moveRight
	{ava=true,	x=1280-80,	y=720-200,	r=80},--rotRight
	{ava=true,	x=1280-200,	y=720-80,	r=80},--rotLeft
	{ava=true,	x=1280-200,	y=720-320,	r=80},--rot180
	{ava=true,	x=200,		y=720-320,	r=80},--hardDrop
	{ava=true,	x=200,		y=720-80,	r=80},--softDrop
	{ava=true,	x=1280-320,	y=720-200,	r=80},--hold
	{ava=true,	x=1280-80,	y=280,		r=80},--func
	{ava=true,	x=80,		y=280,		r=80},--restart
	{ava=false,	x=100,		y=50,		r=80},--insLeft
	{ava=false,	x=200,		y=50,		r=80},--insRight
	{ava=false,	x=300,		y=50,		r=80},--insDown
	{ava=false,	x=400,		y=50,		r=80},--down1
	{ava=false,	x=500,		y=50,		r=80},--down4
	{ava=false,	x=600,		y=50,		r=80},--down10
	{ava=false,	x=700,		y=50,		r=80},--dropLeft
	{ava=false,	x=800,		y=50,		r=80},--dropRight
	{ava=false,	x=900,		y=50,		r=80},--addToLeft
	{ava=false,	x=1000,		y=50,		r=80},--addToRight
}
virtualkey={}for i=1,#VK_org do virtualkey[i]={}end