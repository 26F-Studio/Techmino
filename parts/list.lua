local sin,cos=math.sin,math.cos
title={
	{
		53,		60,
		1035,	0,
		964,	218,
		660,	218,
		391,	1300,
		231,	1154,
		415,	218,
		0,		218,
	},
	{
		716,	290,
		1429,	290,
		1312,	462,
		875,	489,
		821,	695,
		1148,	712,
		1017,	902,
		761,	924,
		707,	1127,
		1106,	1101,
		1198,	1300,
		465,	1300,
	},
	{
		1516,	287,
		2102,	290,
		2036,	464,
		1598,	465,
		1322,	905,
		1395,	1102,
		1819,	1064,
		1743,	1280,
		1286,	1310,
		1106,	902,
	},
	{
		2179,	290,
		2411,	290,
		2272,	688,
		2674,	666,
		2801,	290,
		3041,	290,
		2693,	1280,
		2464,	1280,
		2601,	879,
		2199,	897,
		2056,	1280,
		1828,	1280,
	},
	{
		3123,	290,
		3480,	290,
		3496,	480,
		3664,	290,
		4017,	294,
		3682,	1280,
		3453,	1280,
		3697,	578,
		3458,	843,
		3304,	842,
		3251,	561,
		3001,	1280,
		2779,	1280,
	},
	{
		4088,	290,
		4677,	290,
		4599,	501,
		4426,	502,
		4219,	1069,
		4388,	1070,
		4317,	1280,
		3753,	1280,
		3822,	1068,
		3978,	1068,
		4194,	504,
		4016,	504,
	},
	{
		4747,	290,
		4978,	295,
		4921,	464,
		5186,	850,
		5366,	290,
		5599,	295,
		5288,	1280,
		5051,	1280,
		5106,	1102,
		4836,	709,
		4641,	1280,
		4406,	1280,
	},
	{
		5814,	290,
		6370,	295,
		6471,	415,
		6238,	1156,
		6058,	1280,
		5507,	1280,
		5404,	1154,
		5635,	416,
	-- 	-- 5814,	290,
	-- 	-- 5878,	463,
		5770,	542,
		5617,	1030,
		5676,	1105,
		5995,	1106,
		6100,	1029,
		6255,	541,
		6199,	465,
		5878,	463,
	},
}
for _,C in next,title do
	for i=1,#C do
		C[i]=C[i]*.1626
	end
end
--[[
title2={}
for i=1,#title do title2[i]=title[i]end
title2[5]={
	3123,	290,
	3480,	290,
	3496,	480,
	3664,	290,
	4017,	294,
	3682,	1270,

	3652,	1270,
	3678,	1240,
	3682,	1230,
	3648,	1230,
	3644,	1240,
	3665,	1240,
	3631,	1280,

	3453,	1280,
	3697,	578,
	3458,	843,
	3304,	842,
	3251,	561,
	3001,	1280,
	2779,	1280,
}
]]
title_fan={}
for i=1,8 do
	local L={}
	title_fan[i]=L
		for j=1,#title[i]do
		L[j]=title[i][j]
	end
	for j=1,#L,2 do
		local x,y=L[j],L[j+1]--0<x<3041, 290<y<1280
		x,y=-(x+240+y*.3)*.002,(y-580)*.9
		x,y=y*cos(x),-y*sin(x)--Rec-Pol-Rec
		L[j],L[j+1]=x,y+300
	end
end

missionEnum={
	_1=01,_2=02,_3=03,_4=04,
	A1=05,A2=06,A3=07,A4=08,
	PC=09,
	Z1=11,Z2=12,Z3=13,
	S1=21,S2=22,S3=23,
	J1=31,J2=32,J3=33,
	L1=41,L2=42,L3=43,
	T1=51,T2=52,T3=53,
	O1=61,O2=62,O3=63,O4=64,
	I1=71,I2=72,I3=73,I4=74,
}
local _={}
for k,v in next,missionEnum do _[v]=k end
for k,v in next,_ do missionEnum[k]=v end

rankColor={
	COLOR.dRed,		--D
	COLOR.dOrange,	--C
	COLOR.lYellow,	--B
	COLOR.lBlue,	--A
	COLOR.lCyan,	--S
	COLOR.lGreen,	--Special
}

local function T(s,t)return love.graphics.newText(getFont(s),t)end
drawableTextLoad={
	"anykey",
	"replaying",
	"next","hold",
	"win","finish","gameover","pause",

	"speedLV",
	"line","atk","eff",
	"rpm","tsd",
	"grade","techrash",
	"wave","nextWave",
	"combo","maxcmb",
	"pc","ko",

	"VKTchW","VKOrgW","VKCurW",
	"noScore","highScore",
}
drawableText={
	question=T(100,"?"),
	small=T(30,"<"),large=T(30,">"),
	bpm=T(15,"BPM"),kpm=T(15,"KPM"),

	speedLV=T(20),
	line=T(25),atk=T(20),eff=T(20),
	rpm=T(35),tsd=T(35),
	grade=T(25),techrash=T(25),
	wave=T(30),nextWave=T(30),
	combo=T(20),maxcmb=T(20),
	pc=T(20),ko=T(25),


	modeName=T(30),levelName=T(30),


	anykey=T(40),
	replaying=T(20),
	next=T(40),hold=T(40),
	win=T(120),finish=T(120),
	gameover=T(100),pause=T(120),

	VKTchW=T(30),VKOrgW=T(30),VKCurW=T(30),
	noScore=T(45),highScore=T(30),
}

do
	local N1,N2,N3,N4={0,1},{1,0},{1,1},{.5,.5}
	local I1,I2,I3,I4={-.5,1.5},{1.5,-.5},{.5,1.5},{1.5,.5}
	local V4={1.5,1.5}
	local L1,L2={0,2},{2,0}
	spinCenters={
		--Tetramino
		{[0]=N1,N2,N3,N3},--Z
		{[0]=N1,N2,N3,N3},--S
		{[0]=N1,N2,N3,N3},--L
		{[0]=N1,N2,N3,N3},--J
		{[0]=N1,N2,N3,N3},--T
		{[0]=N4,N4,N4,N4},--O
		{[0]=I1,I2,I3,I4},--I

		--Pentomino
		{[0]=N3,N3,N3,N3},--Z
		{[0]=N3,N3,N3,N3},--S
		{[0]=N1,N2,N3,N3},--P
		{[0]=N1,N2,N3,N3},--Q
		{[0]=N3,N3,N3,N3},--F
		{[0]=N3,N3,N3,N3},--E
		{[0]=N3,N3,N3,N3},--T
		{[0]=N1,N2,N3,N3},--U
		{[0]=I3,N4,I4,V4},--V
		{[0]=N3,N3,N3,N3},--W
		{[0]=N3,N3,N3,N3},--X
		{[0]=I3,I4,I3,I4},--J
		{[0]=I3,I4,I3,I4},--L
		{[0]=I3,I4,I3,I4},--R
		{[0]=I3,I4,I3,I4},--Y
		{[0]=I3,I4,I3,I4},--N
		{[0]=I3,I4,I3,I4},--H
		{[0]=L1,L2,L1,L2},--I
	}
end