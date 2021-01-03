local COLOR={
	red=		{1.0,	0.0,	0.0},
	fire=		{1.0,	0.4,	0.0},
	orange=		{1.0,	0.6,	0.0},
	yellow=		{1.0,	1.0,	0.0},
	lame=		{0.7,	1.0,	0.0},
	grass=		{0.5,	1.0,	0.0},
	green=		{0.0,	1.0,	0.0},
	water=		{0.0,	1.0,	0.6},
	cyan=		{0.0,	1.0,	1.0},
	sky=		{0.0,	0.7,	1.0},
	sea=		{0.0,	0.4,	1.0},
	blue=		{0.2,	0.2,	1.0},
	purple=		{0.4,	0.0,	1.0},
	grape=		{0.7,	0.0,	1.0},
	magenta=	{1.0,	0.0,	1.0},
	pink=		{1.0,	0.0,	0.5},

	lRed=		{1.0,	0.5,	0.5},
	lFire=		{1.0,	0.7,	0.5},
	lOrange=	{1.0,	0.8,	0.3},
	lYellow=	{1.0,	1.0,	0.5},
	lLame=		{0.8,	1.0,	0.4},
	lGrass=		{0.6,	1.0,	0.4},
	lGreen=		{0.5,	1.0,	0.5},
	lWater=		{0.4,	1.0,	0.7},
	lCyan=		{0.5,	1.0,	1.0},
	lSky=		{0.5,	0.8,	1.0},
	lSea=		{0.4,	0.7,	1.0},
	lBlue=		{0.7,	0.7,	1.0},
	lPurple=	{0.7,	0.4,	1.0},
	lGrape=		{0.8,	0.4,	1.0},
	lMagenta=	{1.0,	0.5,	1.0},
	lPink=		{1.0,	0.4,	0.7},

	dRed=		{0.6,	0.0,	0.0},
	dFire=		{0.6,	0.3,	0.0},
	dOrange=	{0.6,	0.4,	0.0},
	dYellow=	{0.6,	0.6,	0.0},
	dLame=		{0.5,	0.6,	0.0},
	dGrass=		{0.3,	0.6,	0.0},
	dGreen=		{0.0,	0.6,	0.0},
	dWater=		{0.0,	0.6,	0.4},
	dCyan=		{0.0,	0.6,	0.6},
	dSky=		{0.0,	0.4,	0.6},
	dSea=		{0.0,	0.2,	0.6},
	dBlue=		{0.1,	0.1,	0.6},
	dPurple=	{0.2,	0.0,	0.6},
	dGrape=		{0.4,	0.0,	0.6},
	dMagenta=	{0.6,	0.0,	0.6},
	dPink=		{0.6,	0.0,	0.3},

	black=		{0.0,	0.0,	0.0},
	dGrey=		{0.3,	0.3,	0.3},
	grey=		{0.6,	0.6,	0.6},
	lGrey=		{0.8,	0.8,	0.8},
	white=		{1.0,	1.0,	1.0},
}
local map={
	R="red",	G="green",	B="blue",	C="cyan",	Y="yellow",		M="magenta",
	lR="lRed",	lG="lGreen",lB="lBlue",	lC="lCyan",	lY="lYellow",	lM="lMagenta",
	dR="dRed",	dG="dGreen",dB="dBlue",	dC="dCyan",	dY="dYellow",	dM="dMagenta",
	W="white",
}for k,v in next,map do COLOR[k]=COLOR[v]end

local list_norm={"red","fire","orange","yellow","lame","grass","green","water","cyan","sky","sea","blue","purple","grape","magenta","pink"}
local len_list_norm=#list_norm
local rnd=math.random
function COLOR.random_norm()
	return COLOR[list_norm[rnd(len_list_norm)]]
end

local list_bright={"lRed","lFire","lOrange","lYellow","lLame","lGrass","lGreen","lWater","lCyan","lSky","lSea","lBlue","lPurple","lGrape","lMagenta","lPink"}
local len_list_bright=#list_bright
function COLOR.random_bright()
	return COLOR[list_bright[rnd(len_list_bright)]]
end

local list_dark={"dRed","dFire","dOrange","dYellow","dLame","dGrass","dGreen","dWater","dCyan","dSky","dSea","dBlue","dPurple","dGrape","dMagenta","dPink"}
local len_list_dark=#list_dark
function COLOR.random_dark()
	return COLOR[list_dark[rnd(len_list_dark)]]
end

local sin=math.sin
function COLOR.rainbow(phase)
	return
		sin(phase)*.4+.6,
		sin(phase+2.0944)*.4+.6,
		sin(phase-2.0944)*.4+.6
end
function COLOR.rainbow_light(phase)
	return
		sin(phase)*.2+.7,
		sin(phase+2.0944)*.2+.7,
		sin(phase-2.0944)*.2+.7
end
function COLOR.rainbow_dark(phase)
	return
		sin(phase)*.2+.4,
		sin(phase+2.0944)*.2+.4,
		sin(phase-2.0944)*.2+.4
end
function COLOR.rainbow_grey(phase)
	return
		sin(phase)*.16+.5,
		sin(phase+2.0944)*.16+.5,
		sin(phase-2.0944)*.16+.5
end

return COLOR