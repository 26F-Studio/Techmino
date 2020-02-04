blockName={"Z","S","L","J","T","O","I"}
clearName={"Single","Double","Triple"}
color={
	red={1,0,0},
	green={0,1,0},
	blue={.2,.2,1},
	yellow={1,1,0},
	purple={1,0,1},
	cyan={0,1,1},

	lightRed={1,.5,.5},
	lightGreen={.5,1,.5},
	lightBlue={.6,.6,1},
	lightYellow={1,1,.5},
	lightPurple={1,.5,1},
	lightCyan={.5,1,1},

	white={1,1,1},
	grey={.6,.6,.6},
}
attackColor={
	{color.red,color.yellow},
	{color.red,color.purple},
	{color.blue,color.white},
	animate={
		function(t)
			gc.setColor(1,t,0)
		end,
		function(t)
			gc.setColor(1,0,t)
		end,
		function(t)
			gc.setColor(t,t,1)
		end,
	}--3 animation-colorsets of attack buffer bar
}

actName={"moveLeft","moveRight","rotRight","rotLeft","rotFlip","hardDrop","softDrop","hold","restart","toLeft","toRight","toDown"}
actName_show={"move left","move right","rotate right","rotate left","rotate flip","hard drop","soft drop","hold","restart","toLeft","toRight","toDown"}
blockPos={4,4,4,4,4,5,4}
renATK={[0]=0,0,0,1,1,2,2,3,3,4,4}--3 else
renName={
	[0]="","","",
	"Combo 3",
	"Combo 4",
	"Combo 5",
	"Combo 6",
	"Combo 7",
	"Combo 8",
	"Combo 9",
	"Combo 10 !",
	"Combo 11 !",
	"Combo 12 !",
	"Combo 13 !",
	"Combo 14 !",
	"Combo 15 !",
	"Combo 16 !",
	"Combo 17 !",
	"Combo 18 !",
	"Combo 19 !",
	"MEGACMB",
}
b2bATK={3,5,8}

marathon_drop={[0]=60,48,40,30,24,18,15,12,10,8,7,6,5,4,3,2,1,1,0,0}
death_lock={10,9,8,7,6}
death_wait={6,5,4,3,2}
death_fall={10,8,7,6,5}

percent0to5={[0]="0%","20%","40%","60%","80%","100%",}