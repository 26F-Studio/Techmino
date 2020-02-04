setting={
	das=10,arr=2,
	sddas=0,sdarr=2,
	quickR=true,swap=true,
	fine=false,
	--game

	ghost=true,center=true,
	smo=true,grid=false,
	dropFX=3,
	shakeFX=3,
	atkFX=3,
	frameMul=100,
	--
	fullscreen=false,
	bg=true,
	bgblock=true,
	lang=1,
	skin=1,
	--graphic

	sfx=10,bgm=7,
	vib=3,voc=0,
	stereo=6,
	--sound

	keyMap={
		{"left","right","x","z","c","up","down","space","tab","r"},
		{},{},{},{},{},{},{},
		--keyboard
		{"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","x","leftshoulder"},
		{},{},{},{},{},{},{},
		--joystick
	},
	VKSwitch=true,
	VKTrack=true,--If tracked
	VKTchW=3,--Touch Weight
	VKCurW=4,--CurPos Weight
	VKIcon=true,
	VKAlpha=3,
	--control
}
local L=setting.keyMap
for i=1,#L do
	for j=1,20 do
		if not L[i][j]then
			L[i][j]=""
		end
	end
end
stat={
	run=0,game=0,time=0,
	extraPiece=0,extraRate=0,
	key=0,rotate=0,hold=0,piece=0,row=0,
	atk=0,send=0,recv=0,pend=0,
	clear_1=0,clear_2=0,clear_3=0,clear_4=0,
	spin_0=0,spin_1=0,spin_2=0,spin_3=0,
	b2b=0,b3b=0,pc=0,score=0,
}
--Things related to virtualkey
function restoreVirtualKey()
	for i=1,#VK_org do
		local B,O=virtualkey[i],VK_org[i]
		B.ava=O.ava
		B.x=O.x
		B.y=O.y
		B.r=O.r
	end
end
local O,_=true,false
VK_org={--Original set,for restore VK' position
	{ava=O,x=80,		y=720-200,	r=80},--moveLeft
	{ava=O,x=320,		y=720-200,	r=80},--moveRight
	{ava=O,x=1280-80,	y=720-200,	r=80},--rotRight
	{ava=O,x=1280-200,	y=720-80,	r=80},--rotLeft
	{ava=O,x=1280-200,	y=720-320,	r=80},--rotFlip
	{ava=O,x=200,		y=720-320,	r=80},--hardDrop
	{ava=O,x=200,		y=720-80,	r=80},--softDrop
	{ava=O,x=1280-320,	y=720-200,	r=80},--hold
	{ava=O,x=1280-80,	y=280,		r=80},--func
	{ava=O,x=80,		y=280,		r=80},--restart
	{ava=_,x=100,		y=50,		r=80},--insLeft
	{ava=_,x=200,		y=50,		r=80},--insRight
	{ava=_,x=300,		y=50,		r=80},--insDown
	{ava=_,x=400,		y=50,		r=80},--down1
	{ava=_,x=500,		y=50,		r=80},--down4
	{ava=_,x=600,		y=50,		r=80},--down10
	{ava=_,x=700,		y=50,		r=80},--dropLeft
	{ava=_,x=800,		y=50,		r=80},--dropRight
	{ava=_,x=900,		y=50,		r=80},--addToLeft
	{ava=_,x=1000,		y=50,		r=80},--addToRight
}
virtualkey={}
for i=1,#VK_org do
	virtualkey[i]={}
end