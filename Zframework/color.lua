local COLOR={
	red=		{1.0,	0.0,	0.0},
	fire=		{1.0,	0.4,	0.0},
	orange=		{1.0,	0.6,	0.0},
	yellow=		{1.0,	1.0,	0.0},
	lime=		{0.7,	1.0,	0.0},
	jade=		{0.5,	1.0,	0.0},
	green=		{0.0,	1.0,	0.0},
	aqua=		{0.0,	1.0,	0.6},
	cyan=		{0.0,	1.0,	1.0},
	navy=		{0.0,	0.7,	1.0},
	sea=		{0.0,	0.4,	1.0},
	blue=		{0.2,	0.2,	1.0},
	violet=		{0.4,	0.0,	1.0},
	purple=		{0.7,	0.0,	1.0},
	magenta=	{1.0,	0.0,	1.0},
	wine=		{1.0,	0.0,	0.5},

	lRed=		{1.0,	0.5,	0.5},
	lFire=		{1.0,	0.7,	0.5},
	lOrange=	{1.0,	0.8,	0.3},
	lYellow=	{1.0,	1.0,	0.5},
	lLime=		{0.8,	1.0,	0.4},
	lJade=		{0.6,	1.0,	0.4},
	lGreen=		{0.5,	1.0,	0.5},
	lAqua=		{0.4,	1.0,	0.7},
	lCyan=		{0.5,	1.0,	1.0},
	lNavy=		{0.5,	0.8,	1.0},
	lSea=		{0.4,	0.7,	1.0},
	lBlue=		{0.7,	0.7,	1.0},
	lViolet=	{0.7,	0.4,	1.0},
	lPurple=	{0.8,	0.4,	1.0},
	lMagenta=	{1.0,	0.5,	1.0},
	lWine=		{1.0,	0.4,	0.7},

	dRed=		{0.6,	0.0,	0.0},
	dFire=		{0.6,	0.3,	0.0},
	dOrange=	{0.6,	0.4,	0.0},
	dYellow=	{0.6,	0.6,	0.0},
	dLime=		{0.5,	0.6,	0.0},
	dJade=		{0.3,	0.6,	0.0},
	dGreen=		{0.0,	0.6,	0.0},
	dAqua=		{0.0,	0.6,	0.4},
	dCyan=		{0.0,	0.6,	0.6},
	dNavy=		{0.0,	0.4,	0.6},
	dSea=		{0.0,	0.2,	0.6},
	dBlue=		{0.1,	0.1,	0.6},
	dViolet=	{0.2,	0.0,	0.6},
	dPurple=	{0.4,	0.0,	0.6},
	dMagenta=	{0.6,	0.0,	0.6},
	dWine=		{0.6,	0.0,	0.3},

	black=		{.05,	.05,	.05},
	dGray=		{0.3,	0.3,	0.3},
	gray=		{0.6,	0.6,	0.6},
	lGray=		{0.8,	0.8,	0.8},
	white=		{.97,	.97,	.97},
}
for k,v in next,{
	R='red',F='fire',O='orange',Y='yellow',L='lime',J='jade',G='green',A='aqua',C='cyan',N='navy',S='sea',B='blue',V='violet',P='purple',M='magenta',W='wine',
	lR='lRed',lF='lFire',lO='lOrange',lY='lYellow',lL='lLime',lJ='lJade',lG='lGreen',lA='lAqua',lC='lCyan',lN='lNavy',lS='lSea',lB='lBlue',lV='lViolet',lP='lPurple',lM='lMagenta',lW='lWine',
	dR='dRed',dF='dFire',dO='dOrange',dY='dYellow',dL='dLime',dJ='dJade',dG='dGreen',dA='dAqua',dC='dCyan',dN='dNavy',dS='dSea',dB='dBlue',dV='dViolet',dP='dPurple',dM='dMagenta',dW='dWine',
	D='black',dH='dGray',H='gray',lH='lGray',Z='white',
	--Remain letter: EIKQTUX
}do
	COLOR[k]=COLOR[v]
end
setmetatable(COLOR,{__index=function(_,k)
	error("No color: "..tostring(k))
end})


do--Random generators
	local rnd=math.random
	local list_norm={'red','fire','orange','yellow','lime','jade','green','aqua','cyan','navy','sea','blue','violet','purple','magenta','wine'}
	local len_list_norm=#list_norm
	function COLOR.random_norm()
		return COLOR[list_norm[rnd(len_list_norm)]]
	end

	local list_bright={'lRed','lFire','lOrange','lYellow','lLime','lJade','lGreen','lAqua','lCyan','lNavy','lSea','lBlue','lViolet','lPurple','lMagenta','lWine'}
	local len_list_bright=#list_bright
	function COLOR.random_bright()
		return COLOR[list_bright[rnd(len_list_bright)]]
	end

	local list_dark={'dRed','dFire','dOrange','dYellow','dLime','dJade','dGreen','dAqua','dCyan','dNavy','dSea','dBlue','dViolet','dPurple','dMagenta','dWine'}
	local len_list_dark=#list_dark
	function COLOR.random_dark()
		return COLOR[list_dark[rnd(len_list_dark)]]
	end
end

do--Rainbow generators
	local sin=math.sin
	function COLOR.rainbow(phase,a)
		return
			sin(phase)*.4+.6,
			sin(phase+2.0944)*.4+.6,
			sin(phase-2.0944)*.4+.6,
			a
	end
	function COLOR.rainbow_light(phase,a)
		return
			sin(phase)*.2+.7,
			sin(phase+2.0944)*.2+.7,
			sin(phase-2.0944)*.2+.7,
			a
	end
	function COLOR.rainbow_dark(phase,a)
		return
			sin(phase)*.2+.4,
			sin(phase+2.0944)*.2+.4,
			sin(phase-2.0944)*.2+.4,
			a
	end
	function COLOR.rainbow_gray(phase,a)
		return
			sin(phase)*.16+.5,
			sin(phase+2.0944)*.16+.5,
			sin(phase-2.0944)*.16+.5,
			a
	end
end

return COLOR