local s={
	--game
	das=10,arr=2,
	sddas=0,sdarr=2,
	ihs=true,irs=true,ims=true,
	reTime=4,
	maxNext=6,
	quickR=true,
	swap=true,
	fine=false,
	autoPause=true,
	lang=1,
	skinSet=1,
	skin={1,5,8,2,10,3,7,1,5,5,1,8,2,10,3,7,10,7,8,2,8,2,1,5,3},
	face={},

	--graphic
	ghost=true,center=true,
	smooth=true,grid=false,
	bagLine=false,
	lockFX=2,
	dropFX=3,
	clearFX=2,
	shakeFX=2,
	atkFX=3,
	frameMul=100,

	text=true,
	warn=true,
	fullscreen=false,
	bg=true,
	powerInfo=false,

	--sound
	sfx=10,bgm=7,
	vib=0,voc=0,
	stereo=6,

	--virtualkey
	VKSFX=3,--SFX volume
	VKVIB=0,--VIB
	VKSwitch=false,--if disp
	VKTrack=false,--if tracked
	VKDodge=false,--if dodge
	VKTchW=3,--Touch-Pos Weight
	VKCurW=4,--Cur-Pos Weight
	VKIcon=true,--if disp icon
	VKAlpha=3,
}
for i=1,25 do
	s.face[i]=0
end
setting=s

s={
	version=gameVersion,
	run=0,game=0,time=0,
	key=0,rotate=0,hold=0,
	extraPiece=0,extraRate=0,
	piece=0,row=0,dig=0,
	atk=0,digatk=0,send=0,recv=0,pend=0,
	clear={},clear_B={},clear_S={0,0,0,0,0},
	spin={},spin_B={},spin_S={0,0,0,0,0},
	pc=0,hpc=0,b2b=0,b3b=0,score=0,
	lastPlay=1,--last played mode ID
}
for i=1,25 do
	s.clear_B[i]=0
	s.spin_B[i]=0
	s.clear[i]={0,0,0,0,0}
	s.spin[i]={0,0,0,0,0}
end
stat=s

keyMap={
	{"left","right","x","z","c","up","down","space","tab","r"},{},
	--keyboard
	{"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","x","leftshoulder"},{},
	--joystick
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