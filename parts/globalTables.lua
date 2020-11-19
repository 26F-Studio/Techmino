MODOPT={--Mod options
	{
		name="noRotation",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="noMove",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="suddenMove",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},

	{
		name="noNext",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="noHold",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="hideNext",
		list={0,1,2,3,4,5,6},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="hideBlock",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="hideGhost",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},

	{
		name="mirror",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="flip",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="hidden",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="hideUp",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="hideDown",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},

	{
		name="_20G",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="suddenLock",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
	{
		name="infLives",
		list={false,true},
		sel=1,
		code=function(P)end,
		time=0,
	},
}

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
	bgm="race"
}

FIELD={}--Field(s) for custom game

BAG={}--Sequence for custom game

MISSION={}--Clearing mission for custom game

GAME={--Global game data
	frame=0,			--Frame count
	result=false,		--Game result (string)
	pauseTime=0,		--Time paused
	pauseCount=0,		--Pausing count
	garbageSpeed=1,		--Garbage timing speed
	warnLVL0=0,			--Warning level
	warnLVL=0,			--Warning level (show)
	recording=false,	--If recording
	replaying=false,	--If replaying
	seed=math.random(2e6),--Game seed
	curMode=nil,		--Current gamemode object
	setting={},			--Game settings
	rec={},				--Recording list, key,time,key,time...
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