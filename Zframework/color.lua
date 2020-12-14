local rnd=math.random
local sin=math.sin
local color={
	red={1,0,0},
	green={0,1,0},
	blue={.2,.2,1},
	yellow={1,1,0},
	magenta={1,0,1},
	cyan={0,1,1},
	purple={.5,0,1},
	orange={1,.6,0},
	grey={.6,.6,.6},

	lRed={1,.5,.5},
	lGreen={.5,1,.5},
	lBlue={.6,.6,1},
	lYellow={1,1,.5},
	lMagenta={1,.5,1},
	lCyan={.5,1,1},
	lPurple={.8,.4,1},
	lOrange={1,.7,.3},
	lGrey={.8,.8,.8},

	dRed={.6,0,0},
	dGreen={0,.6,0},
	dBlue={0,0,.6},
	dYellow={.6,.6,0},
	dMagenta={.6,0,.6},
	dCyan={0,.6,.6},
	dPurple={.3,0,.6},
	dOrange={.6,.4,0},
	dGrey={.3,.3,.3},

	pink={1,0,.6},
	grass={.6,1,0},
	water={0,1,.6},
	sky={.6,.75,1},

	black={0,0,0},
	white={1,1,1},
}
local list_norm={"red","green","blue","yellow","magenta","cyan","purple","orange","pink","grass"}
local len_list_norm=#list_norm
function color.random_norm()
	return color[list_norm[rnd(len_list_norm)]]
end

local list_bright={"lRed","lGreen","lBlue","lYellow","lMagenta","lCyan","lPurple","lOrange"}
local len_list_bright=#list_bright
function color.random_bright()
	return color[list_bright[rnd(len_list_bright)]]
end

local list_dark={"dRed","dGreen","dBlue","dYellow","dMagenta","dCyan","dPurple","dOrange"}
local len_list_dark=#list_dark
function color.random_bright()
	return color[list_dark[rnd(len_list_dark)]]
end

function color.rainbow(phase)
	return
		sin(phase)*.4+.6,
		sin(phase+2.0944)*.4+.6,
		sin(phase-2.0944)*.4+.6
end

return color