--Complex tables
local function disableKey(P,key)
	table.insert(P.gameEnv.keyCancel,key)
end
MODOPT={--Mod options
	{no=0,id="NX",name="next",
		key="q",x=80,y=230,color="orange",
		list={0,1,2,3,4,5,6},
		func=function(P,O)P.gameEnv.nextCount=O end,
	},
	{no=1,id="HL",name="hold",
		key="w",x=200,y=230,color="orange",
		list={0,1,2,3,4,5,6},
		func=function(P,O)P.gameEnv.holdCount=O end,
		unranked=true,
	},
	{no=2,id="FL",name="hideNext",
		key="e",x=320,y=230,color="aqua",
		list={1,2,3,4,5},
		func=function(P,O)P.gameEnv.nextStartPos=O +1 end,
	},
	{no=3,id="IH",name="infHold",
		key="r",x=440,y=230,color="aqua",
		func=function(P)P.gameEnv.infHold=true end,
		unranked=true,
	},
	{no=4,id="HB",name="hideBlock",
		key="y",x=680,y=230,color="purple",
		func=function(P)P.gameEnv.block=false end,
	},
	{no=5,id="HG",name="hideGhost",
		key="u",x=800,y=230,color="purple",
		func=function(P)P.gameEnv.ghost=false end,
	},
	{no=6,id="HD",name="hidden",
		key="i",x=920,y=230,color="grape",
		list={"easy","slow","medium","fast","none"},
		func=function(P,O)P.gameEnv.visible=O end,
		unranked=true,
	},
	{no=7,id="HB",name="hideBoard",
		key="o",x=1040,y=230,color="grape",
		list={"down","up","all"},
		func=function(P,O)P.gameEnv.hideBoard=O  end,
	},
	{no=8,id="FB",name="flipBoard",
		key="p",x=1160,y=230,color="grass",
		list={"U-D","L-R","180"},
		func=function(P,O)P.gameEnv.flipBoard=O  end,
	},

	{no=9,id="DT",name="dropDelay",
		key="a",x=140,y=350,color="red",
		list={0,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
		func=function(P,O)P.gameEnv.drop=O end,
		unranked=true,
	},
	{no=10,id="LT",name="lockDelay",
		key="s",x=260,y=350,color="red",
		list={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
		func=function(P,O)P.gameEnv.lock=O end,
		unranked=true,
	},
	{no=11,id="ST",name="waitDelay",
		key="d",x=380,y=350,color="red",
		list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
		func=function(P,O)P.gameEnv.wait=O end,
		unranked=true,
	},
	{no=12,id="CT",name="fallDelay",
		key="f",x=500,y=350,color="red",
		list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
		func=function(P,O)P.gameEnv.fall=O end,
		unranked=true,
	},
	{no=13,id="LF",name="life",
		key="j",x=860,y=350,color="yellow",
		list={0,1,2,3,5,10,15,26,42,87,500},
		func=function(P,O)P.gameEnv.life=O end,
		unranked=true,
	},
	{no=14,id="FB",name="forceB2B",
		key="k",x=980,y=350,color="yellow",
		func=function(P)P.gameEnv.b2bKill=true end,
		unranked=true,
	},
	{no=15,id="PF",name="forceFinesse",
		key="l",x=1100,y=350,color="yellow",
		func=function(P)P.gameEnv.fineKill=true end,
		unranked=true,
	},

	{no=16,id="TL",name="tele",
		key="z",x=200,y=470,color="lGray",
		func=function(P)
			P.gameEnv.das,P.gameEnv.arr=0,0
			P.gameEnv.sddas,P.gameEnv.sdarr=0,0
		end,
		unranked=true,
	},
	{no=17,id="FX",name="noRotation",
		key="x",x=320,y=470,color="lGray",
		func=function(P)
			disableKey(P,3)
			disableKey(P,4)
			disableKey(P,5)
		end,
		unranked=true,
	},
	{no=18,id="GL",name="noMove",
		key="c",x=440,y=470,color="lGray",
		func=function(P)
			disableKey(P,1)disableKey(P,2)
			disableKey(P,11)disableKey(P,12)
			disableKey(P,17)disableKey(P,18)
			disableKey(P,19)disableKey(P,20)
		end,
		unranked=true,
	},
	{no=19,id="CS",name="customSeq",
		key="b",x=680,y=470,color="blue",
		list={"bag","his4","c2","rnd","mess","reverb"},
		func=function(P,O)P.gameEnv.sequence=O end,
		unranked=true,
	},
	{no=20,id="PS",name="pushSpeed",
		key="n",x=800,y=470,color="blue",
		list={.5,1,2,3,5,15,1e99},
		func=function(P,O)P.gameEnv.pushSpeed=O end,
		unranked=true,
	},
	{no=21,id="BN",name="boneBlock",
		key="m",x=920,y=470,color="blue",
		list={"on","off"},
		func=function(P,O)P.gameEnv.bone=O=="on"end,
	},
}
for i=1,#MODOPT do
	local M=MODOPT[i]
	M.sel,M.time=0,0
	M.color=COLOR[M.color]
end

--Game tables
PLAYERS={}--Players data
PLY_ALIVE={}
PLY_NET={}
FIELD={}--Field(s) for custom game
BAG={}--Sequence for custom game
MISSION={}--Clearing mission for custom game
GAME={--Global game data
	init=false,			--If need initializing game when enter scene-play
	net=false,			--If play net game

	result=false,		--Game result (string)
	rank=false,			--Rank reached
	pauseTime=0,		--Time paused
	pauseCount=0,		--Pausing count
	warnLVL0=0,			--Warning level
	warnLVL=0,			--Warning level (show)

	seed=1046101471,	--Game seed
	curMode=false,		--Current gamemode object
	mod={},				--List of loaded mods
	modeEnv=false,		--Current gamemode environment
	setting={},			--Game settings
	rep={},				--Recording list, key,time,key,time...
	recording=false,	--If recording
	replaying=false,	--If replaying
	saved=false,		--If recording saved

	prevBG=false,		--Previous background, for restore BG when quit setting page

	--Data for royale mode
	stage=false,		--Game stage
	mostBadge=false,	--Most badge owner
	secBadge=false,		--Second badge owner
	mostDangerous=false,--Most dangerous player
	secDangerous=false,	--Second dangerous player
}

--Userdata tables
RANKS=FILE.load("conf/unlock")or{sprint_10l=0}--Ranks of modes
USER=FILE.load("conf/user")or{--User infomation
	--Network infos
	uid=false,
	authToken=false,

	--Local data
	xp=0,lv=1,
}
CUSTOMENV=FILE.load("conf/customEnv")
if not CUSTOMENV or CUSTOMENV.version~=VERSION.code then CUSTOMENV={--gameEnv for cutsom game
	version=VERSION.code,

	--Basic
	drop=1e99,
	lock=1e99,
	wait=0,
	fall=0,

	--Control
	nextCount=6,
	holdCount=1,
	infHold=true,
	phyHold=false,

	--Visual
	bone=false,

	--Rule
	sequence="bag",
	fieldH=20,

	ospin=true,
	fineKill=false,
	b2bKill=false,
	easyFresh=true,
	deepDrop=false,
	visible="show",
	freshLimit=1e99,


	opponent="X",
	life=0,
	pushSpeed=3,
	missionKill=false,

	--Else
	bg="none",
	bgm="infinite",
}end
SETTING={--Settings
	--Tuning
	das=10,arr=2,dascut=0,
	sddas=0,sdarr=2,
	ihs=true,irs=true,ims=true,
	RS="TRS",
	swap=true,

	--System
	reTime=4,
	autoPause=true,
	fine=false,
	appLock=false,
	simpMode=false,
	lang=1,
	skinSet=1,
	skin={
		1,7,11,3,14,4,9,
		1,7,2,6,10,2,13,5,9,15,10,11,3,12,2,16,8,4,
		10,13,2,8
	},
	face={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	dataSaving=false,

	--Graphic
	block=true,ghost=.3,center=1,
	smooth=true,grid=.16,
	upEdge=true,
	bagLine=false,
	lockFX=2,
	dropFX=2,
	moveFX=2,
	clearFX=2,
	splashFX=2,
	shakeFX=2,
	atkFX=2,
	frameMul=100,
	cleanCanvas=false,

	text=true,
	score=true,
	warn=true,
	highCam=false,
	nextPos=false,
	fullscreen=true,
	bg=true,
	powerInfo=false,
	clickFX=true,

	--Sound
	sfx=1,
	sfx_spawn=.3,
	sfx_warn=.3,
	bgm=.7,
	stereo=.7,
	vib=0,
	voc=0,
	cv="miya",

	--Virtualkey
	VKSFX=.2,--SFX volume
	VKVIB=0,--VIB
	VKSwitch=false,--If disp
	VKTrack=false,--If tracked
	VKDodge=false,--If dodge
	VKTchW=.3,--Touch-Pos Weight
	VKCurW=.4,--Cur-Pos Weight
	VKIcon=true,--If disp icon
	VKAlpha=.3,
}
local S=FILE.load("conf/settings")
if S then TABLE.update(S,SETTING)end
S=FILE.load("conf/data")
if S then--Statistics
	STAT=S
else
	STAT={
		version=VERSION.code,
		run=0,game=0,time=0,frame=0,
		key=0,rotate=0,hold=0,
		extraPiece=0,finesseRate=0,
		piece=0,row=0,dig=0,
		atk=0,digatk=0,
		send=0,recv=0,pend=0,off=0,
		clear={},spin={},
		pc=0,hpc=0,b2b=0,b3b=0,score=0,
		lastPlay="sprint_10l",--Last played mode ID
		date=false,
		todayTime=0,
	}for i=1,29 do STAT.clear[i]={0,0,0,0,0,0}STAT.spin[i]={0,0,0,0,0,0,0}end
end
keyMap=FILE.load("conf/key")or{--Key setting
	keyboard={
		left=1,right=2,x=3,z=4,c=5,
		up=6,down=7,space=8,a=9,s=10,
		r=0,
	},
	joystick={
		dpleft=1,dpright=2,a=3,b=4,y=5,
		dpup=6,dpdown=7,rightshoulder=8,x=9,
		leftshoulder=0,
	},
}
VK_org=FILE.load("conf/virtualkey")or{--Virtualkey layout, refresh all VKs' position with this before each game
	{ava=true,	x=80,		y=720-200,	r=80,color=COLOR.lime},--moveLeft
	{ava=true,	x=320,		y=720-200,	r=80,color=COLOR.lime},--moveRight
	{ava=true,	x=1280-80,	y=720-200,	r=80,color=COLOR.red},--rotRight
	{ava=true,	x=1280-200,	y=720-80,	r=80,color=COLOR.orange},--rotLeft
	{ava=true,	x=1280-200,	y=720-320,	r=80,color=COLOR.magenta},--rot180
	{ava=true,	x=200,		y=720-320,	r=80,color=COLOR.cyan},--hardDrop
	{ava=true,	x=200,		y=720-80,	r=80,color=COLOR.sea},--softDrop
	{ava=true,	x=1280-320,	y=720-200,	r=80,color=COLOR.yellow},--hold
	{ava=true,	x=1280-80,	y=280,		r=80,color=COLOR.lRed},--func1
	{ava=true,	x=80,		y=280,		r=80,color=COLOR.lMagenta},--func2
	{ava=false,	x=100,		y=50,		r=80,color=COLOR.aqua},--insLeft
	{ava=false,	x=200,		y=50,		r=80,color=COLOR.aqua},--insRight
	{ava=false,	x=300,		y=50,		r=80,color={COLOR.rainbow(3.5)}},--insDown
	{ava=false,	x=400,		y=50,		r=80,color={COLOR.rainbow(3.3)}},--down1
	{ava=false,	x=500,		y=50,		r=80,color={COLOR.rainbow(3.1)}},--down4
	{ava=false,	x=600,		y=50,		r=80,color={COLOR.rainbow(2.9)}},--down10
	{ava=false,	x=700,		y=50,		r=80,color=COLOR.lLime},--dropLeft
	{ava=false,	x=800,		y=50,		r=80,color=COLOR.lLime},--dropRight
	{ava=false,	x=900,		y=50,		r=80,color=COLOR.laqua},--addToLeft
	{ava=false,	x=1000,		y=50,		r=80,color=COLOR.laqua},--addToRight
}
virtualkey={}for i=1,#VK_org do virtualkey[i]={}end--In-game virtualkey layout
REPLAY=FILE.load("conf/replay")or{}