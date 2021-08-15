--Complex tables
local function disableKey(P,key)
	table.insert(P.gameEnv.keyCancel,key)
end
MODOPT={--Mod options
	{no=0,id="NX",name="next",
		key="q",x=80,y=230,color='lO',
		list={0,1,2,3,4,5,6},
		func=function(P,O)P.gameEnv.nextCount=O end,
		unranked=true,
	},
	{no=1,id="HL",name="hold",
		key="w",x=200,y=230,color='lO',
		list={0,1,2,3,4,5,6},
		func=function(P,O)P.gameEnv.holdCount=O end,
		unranked=true,
	},
	{no=2,id="FL",name="hideNext",
		key="e",x=320,y=230,color='lA',
		list={1,2,3,4,5},
		func=function(P,O)P.gameEnv.nextStartPos=O+1 end,
		unranked=true,
	},
	{no=3,id="IH",name="infHold",
		key="r",x=440,y=230,color='lA',
		func=function(P)P.gameEnv.infHold=true end,
		unranked=true,
	},
	{no=4,id="HB",name="hideBlock",
		key="y",x=680,y=230,color='lV',
		func=function(P)P.gameEnv.block=false end,
		unranked=true,
	},
	{no=5,id="HG",name="hideGhost",
		key="u",x=800,y=230,color='lV',
		func=function(P)P.gameEnv.ghost=false end,
		unranked=true,
	},
	{no=6,id="HD",name="hidden",
		key="i",x=920,y=230,color='lP',
		list={'easy','slow','medium','fast','none'},
		func=function(P,O)P.gameEnv.visible=O end,
		unranked=true,
	},
	{no=7,id="HB",name="hideBoard",
		key="o",x=1040,y=230,color='lP',
		list={'down','up','all'},
		func=function(P,O)P.gameEnv.hideBoard=O  end,
		unranked=true,
	},
	{no=8,id="FB",name="flipBoard",
		key="p",x=1160,y=230,color='lJ',
		list={'U-D','L-R','180'},
		func=function(P,O)P.gameEnv.flipBoard=O  end,
		unranked=true,
	},

	{no=9,id="DT",name="dropDelay",
		key="a",x=140,y=350,color='lR',
		list={0,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
		func=function(P,O)P.gameEnv.drop=O end,
		unranked=true,
	},
	{no=10,id="LT",name="lockDelay",
		key="s",x=260,y=350,color='lR',
		list={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
		func=function(P,O)P.gameEnv.lock=O end,
		unranked=true,
	},
	{no=11,id="ST",name="waitDelay",
		key="d",x=380,y=350,color='lR',
		list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
		func=function(P,O)P.gameEnv.wait=O end,
		unranked=true,
	},
	{no=12,id="CT",name="fallDelay",
		key="f",x=500,y=350,color='lR',
		list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
		func=function(P,O)P.gameEnv.fall=O end,
		unranked=true,
	},
	{no=13,id="LF",name="life",
		key="j",x=860,y=350,color='lY',
		list={0,1,2,3,5,10,15,26,42,87,500},
		func=function(P,O)P.gameEnv.life=O end,
		unranked=true,
	},
	{no=14,id="FB",name="forceB2B",
		key="k",x=980,y=350,color='lY',
		func=function(P)P.gameEnv.b2bKill=true end,
		unranked=true,
	},
	{no=15,id="PF",name="forceFinesse",
		key="l",x=1100,y=350,color='lY',
		func=function(P)P.gameEnv.fineKill=true end,
		unranked=true,
	},

	{no=16,id="TL",name="tele",
		key="z",x=200,y=470,color='lH',
		func=function(P)
			P.gameEnv.das,P.gameEnv.arr=0,0
			P.gameEnv.sddas,P.gameEnv.sdarr=0,0
		end,
		unranked=true,
	},
	{no=17,id="FX",name="noRotation",
		key="x",x=320,y=470,color='lH',
		func=function(P)
			disableKey(P,3)
			disableKey(P,4)
			disableKey(P,5)
		end,
		unranked=true,
	},
	{no=18,id="GL",name="noMove",
		key="c",x=440,y=470,color='lH',
		func=function(P)
			disableKey(P,1)disableKey(P,2)
			disableKey(P,11)disableKey(P,12)
			disableKey(P,17)disableKey(P,18)
			disableKey(P,19)disableKey(P,20)
		end,
		unranked=true,
	},
	{no=19,id="CS",name="customSeq",
		key="b",x=680,y=470,color='lB',
		list={'bag','his','hisPool','c2','rnd','mess','reverb'},
		func=function(P,O)P.gameEnv.sequence=O end,
		unranked=true,
	},
	{no=20,id="PS",name="pushSpeed",
		key="n",x=800,y=470,color='lB',
		list={.5,1,2,3,5,15,1e99},
		func=function(P,O)P.gameEnv.pushSpeed=O end,
		unranked=true,
	},
	{no=21,id="BN",name="boneBlock",
		key="m",x=920,y=470,color='lB',
		list={'on','off'},
		func=function(P,O)P.gameEnv.bone=O=='on'end,
		unranked=true,
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
FIELD={}--Field(s) for custom game
BAG={}--Sequence for custom game
MISSION={}--Clearing mission for custom game
GAME={--Global game data
	init=false,			--If need initializing game when enter scene-play
	net=false,			--If play net game

	result=false,		--Game result (string)
	rank=0,				--Rank reached
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
	statSaved=true,		--If recording saved
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
ROYALEDATA={
	powerUp=false,
	stage=false,
}
CUSTOMENV={}
ROOMENV={
	--Room config
	capacity=10,

	--Basic
	drop=30,
	lock=60,
	wait=0,
	fall=0,

	--Control
	nextCount=6,
	holdCount=1,
	infHold=false,
	phyHold=false,

	--Visual
	bone=false,

	--Rule
	life=0,
	pushSpeed=5,
	garbageSpeed=2,
	visible='show',
	freshLimit=15,

	fieldH=20,
	heightLimit=1e99,
	bufferLimit=1e99,

	ospin=true,
	fineKill=false,
	b2bKill=false,
	easyFresh=true,
	deepDrop=false,
}
REPLAY={}--Replay objects (not include stream data)

--Userdata tables
USER={--User infomation
	--Network infos
	uid=false,
	authToken=false,

	--Local data
	xp=0,lv=1,
}

SETTING={--Settings
	--Tuning
	das=10,arr=2,
	dascut=0,dropcut=0,
	sddas=0,sdarr=2,
	ihs=true,irs=true,ims=true,
	RS='TRS',
	swap=true,

	--System
	reTime=4,
	autoPause=true,
	menuPos='middle',
	fine=false,
	simpMode=false,
	lang=1,
	skinSet='crystal_scf',
	skin={
		1,7,11,3,14,4,9,
		1,7,2,6,10,2,13,5,9,15,10,11,3,12,2,16,8,4,
		10,13,2,8
	},
	face={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},

	--Graphic
	ghostType='gray',
	block=true,ghost=.3,center=1,
	smooth=true,grid=.16,lineNum=.5,
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
	blockSatur='normal',
	fieldSatur='normal',

	text=true,
	score=true,
	bufferWarn=true,
	showSpike=true,
	highCam=true,
	nextPos=true,
	fullscreen=true,
	bg=true,
	powerInfo=false,
	clickFX=true,
	warn=true,

	--Sound
	sfx=1,
	sfx_spawn=0,
	sfx_warn=.4,
	bgm=.7,
	stereo=.7,
	vib=0,
	voc=0,
	cv='miya',

	--Virtualkey
	VKSFX=.2,--SFX volume
	VKVIB=0,--VIB
	VKSwitch=false,--If disp
	VKSkin=1,--If disp
	VKTrack=false,--If tracked
	VKDodge=false,--If dodge
	VKTchW=.3,--Touch-Pos Weight
	VKCurW=.4,--Cur-Pos Weight
	VKIcon=true,--If disp icon
	VKAlpha=.3,
}
keyMap={--Key setting
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
VK_org={--Virtualkey layout, refresh all VKs' position with this before each game
	{ava=true,	x=80,		y=720-200,	r=80},--moveLeft
	{ava=true,	x=320,		y=720-200,	r=80},--moveRight
	{ava=true,	x=1280-80,	y=720-200,	r=80},--rotRight
	{ava=true,	x=1280-200,	y=720-80,	r=80},--rotLeft
	{ava=true,	x=1280-200,	y=720-320,	r=80},--rot180
	{ava=true,	x=200,		y=720-320,	r=80},--hardDrop
	{ava=true,	x=200,		y=720-80,	r=80},--softDrop
	{ava=true,	x=1280-320,	y=720-200,	r=80},--hold
	{ava=true,	x=1280-80,	y=280,		r=80},--func1
	{ava=true,	x=80,		y=280,		r=80},--func2
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
RANKS={sprint_10l=0}--Ranks of modes
STAT={
	version=VERSION.code,
	run=0,game=0,time=0,frame=0,
	key=0,rotate=0,hold=0,
	extraPiece=0,finesseRate=0,
	piece=0,row=0,dig=0,
	atk=0,digatk=0,
	send=0,recv=0,pend=0,off=0,
	clear=(function()local L={}for i=1,29 do L[i]={0,0,0,0,0,0}end return L end)(),
	spin=(function()local L={}for i=1,29 do L[i]={0,0,0,0,0,0,0}end return L end)(),
	pc=0,hpc=0,b2b=0,b3b=0,score=0,
	lastPlay='sprint_10l',--Last played mode ID
	date=false,
	todayTime=0,
}