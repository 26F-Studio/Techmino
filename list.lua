--[["four name"
	Techrash
 x	Zestris
 x	Quadruple
 x	Tequeno
 x	Techzino
 x	Tectris
	Techris

	Techmino
	Tequéno
]]

color={
	red={1,0,0},
	green={0,1,0},
	blue={.2,.2,1},
	yellow={1,1,0},
	magenta={1,0,1},
	cyan={0,1,1},
	grey={.6,.6,.6},

	lightRed={1,.5,.5},
	lightGreen={.5,1,.5},
	lightBlue={.6,.6,1},
	lightYellow={1,1,.5},
	lightMagenta={1,.5,1},
	lightCyan={.5,1,1},
	lightGrey={.8,.8,.8},

	darkRed={.6,0,0},
	darkGreen={0,.6,0},
	darkBlue={0,0,.6},
	darkYellow={.6,.6,0},
	darkMagenta={.6,0,.6},
	darkCyan={0,.6,.6},
	darkGrey={.3,.3,.3},

	white={1,1,1},
	orange={1,.6,0},
	lightOrange={1,.7,.3},
	purple={.5,0,1},
	lightPurple={.7,.3,1},
}
attackColor={
	{color.darkGrey,color.white},
	{color.grey,color.white},
	{color.lightPurple,color.white},
	{color.lightRed,color.white},
	{color.darkGreen,color.cyan},
}
frameColor={
	[0]=color.white,
	color.lightGreen,
	color.lightBlue,
	color.lightPurple,
	color.lightOrange,
}
blockColor={
	color.red,
	color.green,
	color.orange,
	color.blue,
	color.magenta,
	color.yellow,
	color.cyan,
}

miniTitle_rect={
	{2,0,5,1},{4,1,1,6},
	{9,0,4,1},{9,3,4,1},{9,6,4,1},{8,0,1,7},
	{15,0,3,1},{15,6,3,1},{14,0,1,7},
	{19,0,1,7},{23,0,1,7},{20,3,3,1},
	{0,8,1,6},{6,8,1,6},{1,9,1,1},{2,10,1,1},{3,11,1,1},{4,10,1,1},{5,9,1,1},
	{8,8,5,1},{8,13,5,1},{10,9,1,4},
	{14,8,1,6},{19,8,1,6},{15,9,1,1},{16,10,1,1},{17,11,1,1},{18,12,1,1},
	{21,8,5,1},{21,13,5,1},{21,9,1,4},{25,9,1,4},
}

sfx={
	"button",
	"ready","start","win","fail","collect",
	"move","rotate","rotatekick","hold",
	"prerotate","prehold",
	"lock","drop","fall",
	"reach",
	"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11",
	"clear_1","clear_2","clear_3","clear_4",
	"spin_0","spin_1","spin_2","spin_3",
	"emit","blip_1","blip_2",
	"perfectclear",
}
bgm={
	"blank",
	"way",
	"race",
	"newera",
	"push",
	"reason",
	"infinite",
	"cruelty",
	"final",
	"secret7th",
	"secret8th",
	"rockblock",
	"sores",
}

sceneInit={
	load=function()
		curBG="none"
		keeprun=true
		loading=1--Loading mode
		loadnum=1--Loading counter
		loadprogress=0--Loading bar(0~1)
	end,
	intro=function()
		curBG="none"
		count=0
		keeprun=true
	end,
	main=function()
		curBG="none"
		keeprun=true
		collectgarbage()
	end,
	mode=function()
		saveData()
		modeSel=modeSel or 1
		levelSel=levelSel or 3
		curBG="none"
		keeprun=true
	end,
	custom=function()
		optSel=optSel or 1
		curBG="matrix"
		keeprun=true
	end,
	play=function()
		keeprun=false
		resetGameData()
		sysSFX("ready")
		mouseShow=false
	end,
	setting=function()
		curBG="none"
		keeprun=true
	end,
	setting2=function()
		curBG="none"
		keeprun=true
			curBoard=1
			keyboardSet=1
			joystickSet=1
			keyboardSetting=false
			joystickSetting=false
	end,--Control settings
	setting3=function()
		curBG="game1"
		keeprun=true
		defaultSel=1
		sel=nil
		snapLevel=1
	end,--Touch setting
	help=function()
		curBG="none"
		keeprun=true
	end,
	stat=function()
		curBG="none"
		keeprun=true
	end,
	quit=function()
		love.event.quit()
	end,
}
prevMenu={
	load=love.event.quit,
	intro="quit",
	main="intro",
	mode="main",
	custom="mode",
	ready="mode",
	play=function()
		clearTask()
		gotoScene(curMode.id~="custom"and"mode"or"custom")
	end,
	help="main",
	stat="main",
	setting=function()
		saveSetting()
		gotoScene("main")
	end,
	setting2="setting",
	setting3="setting",
}

customID={
	"drop",
	"lock",
	"wait",
	"fall",
	"next",
	"hold",
	"sequence",
	"visible",
	"target",
	"freshLimit",
	"opponent",
}
customRange={
	drop={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99,-1},
	lock={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
	wait={1,3,5,7,10,15,20,30,60},
	fall={1,3,5,7,10,15,20,30,60},
	next={0,1,2,3,4,5,6},
	hold={true,false},
	sequence={"bag7","his4","rnd"},
	visible={"show","time","fast","none"},
	target={10,20,40,100,200,500,1000,1e99},
	freshLimit={0,8,15,1e99},
	opponent={0,60,30,20,15,10,7,5,4,3,2,1},
}

langName={"中文","English"}
langID={"chi","eng"}
actName={"moveLeft","moveRight","rotRight","rotLeft","rotFlip","hardDrop","softDrop","hold","swap","restart","insLeft","insRight","insDown"}
blockPos={4,4,4,4,4,5,4}
clearPoint={[0]=1,2,3,5,7}
renATK={[0]=0,0,0,1,1,2,2,3,3,4,4}--3 else
b2bPoint={50,120,200}
b2bATK={3,5,8}
testScore={[-1]=1,[-2]=0,[-3]=1,2,2,2}
visible_opt={show=1e99,time=300,fast=20,none=5}
reAtk={0,0,1,1,1,2,2,3,3}
reDef={0,1,1,2,3,3,4,4,5}

spin_n={"spin_1","spin_2","spin_3"}
clear_n={"clear_1","clear_2","clear_3","clear_4"}
ren_n={}for i=1,11 do ren_n[i]="ren_"..i end
vibrateLevel={0,0,.03,.04,.05,.07,.9}
snapLevelValue={1,10,20,40,60,80}

RCPB={10,33,200,33,105,5,105,60}
up0to4={[0]="000%UP","025%UP","050%UP","075%UP","100%UP",}
percent0to5={[0]="0%","20%","40%","60%","80%","100%",}

modeID={
	[0]="custom",
	"sprint","marathon","master","classic","zen","infinite","solo","tsd","blind","dig","survivor","tech",
	"pctrain","pcchallenge","techmino41","techmino99","drought","hotseat",
}
modeLevel={
	sprint={"10L","20L","40L","100L","400L","1000L"},
	marathon={"EASY","NORMAL","HARD"},
	master={"LUNATIC","ULTIMATE"},
	classic={"CTWC"},
	zen={"NORMAL"},
	infinite={"NORMAL"},
	solo={"EASY","NORMAL","HARD","LUNATIC"},
	tsd={"NORMAL","HARD"},
	blind={"EASY","HARD","LUNATIC","ULTIMATE","GM"},
	dig={"NORMAL","LUNATIC"},
	survivor={"EASY","NORMAL","HARD","LUNATIC"},
	tech={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	pctrain={"NORMAL","EXTRA"},
	pcchallenge={"NORMAL","HARD","LUNATIC"},
	techmino41={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	techmino99={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	drought={"NORMAL","MESS"},
	hotseat={"2P","3P","4P",},
	custom={""},
}
modeLevelColor={
	EASY=color.cyan,
	NORMAL=color.green,
	HARD=color.magenta,
	LUNATIC=color.red,
	EXTRA=color.lightMagenta,
	ULTIMATE=color.lightYellow,

	MESS=color.lightGrey,
	GM=color.blue,
	DEATH=color.lightRed,
	CTWC=color.lightBlue,
	["10L"]=color.cyan,
	["20L"]=color.lightBlue,
	["40L"]=color.green,
	["100L"]=color.orange,
	["400L"]=color.red,
	["1000L"]=color.darkRed,
}

blocks={
	{[0]={{0,1,1},{1,1,0}},{{1,0},{1,1},{0,1}}},
	{[0]={{1,1,0},{0,1,1}},{{0,1},{1,1},{1,0}}},
	{[0]={{1,1,1},{0,0,1}},{{1,1},{1,0},{1,0}},{{1,0,0},{1,1,1}},{{0,1},{0,1},{1,1}}},
	{[0]={{1,1,1},{1,0,0}},{{1,0},{1,0},{1,1}},{{0,0,1},{1,1,1}},{{1,1},{0,1},{0,1}}},
	{[0]={{1,1,1},{0,1,0}},{{1,0},{1,1},{1,0}},{{0,1,0},{1,1,1}},{{0,1},{1,1},{0,1}}},
	{[0]={{1,1},{1,1}},{{1,1},{1,1}}},
	{[0]={{1,1,1,1}},{{1},{1},{1},{1}}},
}
local l={1,2,6,7}for i=1,4 do blocks[l[i]][2],blocks[l[i]][3]=blocks[l[i]][0],blocks[l[i]][1]end
for i=1,7 do blocks[i+7]=blocks[i]end
scs={
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1.5,1.5},{1.5,1.5},{1.5,1.5},{1.5,1.5},},
	{[0]={0.5,2.5},{2.5,0.5},{1.5,2.5},{2.5,1.5}},
}
TRS={
	[1]={
		[01]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2},{0,1}},
		[10]={{0,0},{1,0},{1,-1},{0,2},{1,2},{0,-1}},
		[12]={{0,0},{1,0},{1,-1},{0,1},{-1,0},{0,2},{1,2}},
		[21]={{0,0},{-1,0},{-1,1},{1,0},{0,-2},{-1,-2}},
		[23]={{0,0},{1,0},{1,1},{1,-1},{0,-2},{1,-2}},
		[32]={{0,0},{-1,0},{-1,-1},{-1,1},{0,2},{-1,2}},
		[30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2},{0,-1}},
		[03]={{0,0},{1,0},{1,1},{1,-1},{0,-2},{1,-2},{0,1}},
		[02]={{0,0},{1,0},{-1,0},{0,-1},{0,1}},
		[20]={{0,0},{-1,0},{1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,-1},{0,1},{-1,0}},
		[31]={{0,0},{0,1},{0,-1},{1,0}},
	},--Z/J
	[2]={
		[01]={{0,0},{-1,0},{-1,1},{-1,-1},{0,-2},{-1,-2}},
		[10]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
		[12]={{0,0},{1,0},{1,-1},{1,1},{0,2},{1,2}},
		[21]={{0,0},{-1,0},{-1,1},{-1,-1},{0,-2},{-1,-2}},
		[23]={{0,0},{1,0},{1,1},{-1,0},{0,-2},{1,-2}},
		[32]={{0,0},{-1,0},{-1,-1},{0,1},{1,0},{0,2},{-1,2}},
		[30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2},{0,-1},{-1,1}},
		[03]={{0,0},{1,0},{1,1},{0,-2},{1,-2},{1,-1},{0,1}},
		[02]={{0,0},{-1,0},{1,0},{0,-1},{0,1}},
		[20]={{0,0},{1,0},{-1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,1},{0,-1},{1,0}},
		[31]={{0,0},{0,-1},{0,1},{-1,0}},
	},--S/L
	[5]={
		[01]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2},{-1,-1}},
		[10]={{0,0},{1,0},{1,-1},{0,2},{1,2},{0,-1},{1,1}},
		[12]={{0,0},{1,0},{1,-1},{0,-1},{0,2},{1,2},{-1,-1}},
		[21]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2},{1,1}},
		[23]={{0,0},{1,0},{1,1},{0,-2},{1,-2},{-1,1}},
		[32]={{0,0},{-1,0},{-1,-1},{0,-1},{0,2},{-1,2},{1,-1}},
		[30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2},{0,-1}},
		[03]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},
		[02]={{0,0},{-1,0},{1,0},{0,-1},{0,1}},
		[20]={{0,0},{1,0},{-1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,-1},{0,1},{1,0},{-1,0},{0,2}},
		[31]={{0,0},{0,-1},{0,1},{-1,0},{1,0},{0,2}},
	},
	[7]={
		[01]={{0,0},{0,1},{1,0},{-2,0},{-2,-1},{1,2}},
		[03]={{0,0},{0,1},{-1,0},{2,0},{2,-1},{-1,2}},
		[10]={{0,0},{2,0},{-1,0},{-1,-2},{2,1},{0,2}},
		[30]={{0,0},{-2,0},{1,0},{1,-2},{-2,1},{0,2}},
		[12]={{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
		[32]={{0,0},{1,0},{-2,0},{1,-2},{-2,-1}},
		[21]={{0,0},{-2,0},{1,0},{1,-2},{-2,1}},
		[23]={{0,0},{2,0},{-1,0},{-1,-2},{2,1}},
		[02]={{0,0},{-1,0},{1,0},{0,-1},{0,1}},
		[20]={{0,0},{1,0},{-1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,-1},{-1,0},{1,0},{0,1}},
		[31]={{0,0},{1,0},{-1,0}},
	}
}TRS[3],TRS[4]=TRS[2],TRS[1]

dataOpt={
	"run",
	"game",
	"gametime",
	"piece",
	"row",
	"atk",
	"key",
	"rotate",
	"hold",
	"spin",
}
saveOpt={
	"lang",
	"ghost",
	"center",
	"grid",
	"swap",
	"sfx",
	"bgm",
	"vib",
	"fullscreen",
	"bgblock",
	"das",
	"arr",
	"sddas",
	"sdarr",
	"virtualkeyAlpha",
	"virtualkeyIcon",
	"virtualkeySwitch",
	"frameMul",
}
virtualkeySet={
	{
		{80,720-200,6400,80},--moveLeft
		{320,720-200,6400,80},--moveRight
		{1280-80,720-200,6400,80},--rotRight
		{1280-200,720-80,6400,80},--rotLeft
		{1280-200,720-320,6400,80},--rotFlip
		{200,720-320,6400,80},--hardDrop
		{200,720-80,6400,80},--softDrop
		{1280-320,720-200,6400,80},--hold
		{1280-80,280,6400,80},--swap
		{80,280,6400,80},--restart
	},--Farter's set 3
	{
		{1280-320,720-200,6400,80},--moveLeft
		{1280-80,720-200,6400,80},--moveRight
		{200,720-80,6400,80},--rotRight
		{80,720-200,6400,80},--rotLeft
		{200,720-320,6400,80},--rotFlip
		{1280-200,720-320,6400,80},--hardDrop
		{1280-200,720-80,6400,80},--softDrop
		{320,720-200,6400,80},--hold
		{80,280,6400,80},--swap
		{1280-80,280,6400,80},--restart
	},--Mirrored farter's set 3
	{
		{80,720-80,6400,80},--moveLeft
		{240,720-80,6400,80},--moveRight
		{1280-240,720-80,6400,80},--rotRight
		{1280-400,720-80,6400,80},--rotLeft
		{1280-240,720-240,6400,80},--rotFlip
		{1280-80,720-80,6400,80},--hardDrop
		{1280-80,720-240,6400,80},--softDrop
		{1280-80,720-400,6400,80},--hold
		{80,360,6400,80},--swap
		{80,80,6400,80},--restart
	},--Author's set
	{
		{1280-400,720-80,6400,80},--moveLeft
		{1280-80,720-80,6400,80},--moveRight
		{240,720-80,6400,80},--rotRight
		{80,720-80,6400,80},--rotLeft
		{240,720-240,6400,80},--rotFlip
		{1280-240,720-240,6400,80},--hardDrop
		{1280-240,720-80,6400,80},--softDrop
		{1280-80,720-240,6400,80},--hold
		{80,720-240,6400,80},--swap
		{80,320,6400,80},--restart
	},--Keyboard set
	{
		{1200-360,40,0,40},--moveLeft
		{1200-280,40,0,40},--moveRight
		{1200-520,40,0,40},--rotRight
		{1200-600,40,0,40},--rotLeft
		{1200-440,40,0,40},--rotFlip
		{1200-40,40,0,40},--hardDrop
		{1200-120,40,0,40},--softDrop
		{1200-200,40,0,40},--hold
		{1200-680,40,0,40},--swap
		{1200-760,40,0,40},--restart
	},--PC key feedback
}
Buttons={
	load={},
	intro={},
	main={
		play={x=380,y=300,w=240,h=240,rgb=color.red,f=70,code=function()gotoScene("mode")end,down="stat",right="setting"},
		setting={x=640,y=300,w=240,h=240,rgb=color.lightBlue,f=55,code=function()gotoScene("setting")end,down="stat",left="play",right="help"},
		stat={x=640,y=560,w=240,h=240,rgb=color.cyan,f=55,code=function()gotoScene("stat")end,up="setting",left="play",right="help"},
		help={x=900,y=560,w=240,h=240,rgb=color.yellow,f=55,code=function()gotoScene("help")end,up="setting",left="stat",right="quit"},
		quit={x=1180,y=620,w=120,h=120,rgb=color.lightGrey,f=50,code=function()gotoScene("quit")end,up="setting",left="help"},
	},
	mode={
		up={x=1000,y=210,w=200,h=140,rgb=color.white,hide=function()return modeSel==1 end,f=64,code=function()keyDown.mode("up")end},
		down={x=1000,y=430,w=200,h=140,rgb=color.white,hide=function()return modeSel==#modeID end,f=80,code=function()keyDown.mode("down")end},
		left={x=190,y=160,w=100,h=80,rgb=color.white,hide=function()return levelSel==1 end,code=function()keyDown.mode("left")end},
		right={x=350,y=160,w=100,h=80,rgb=color.white,hide=function()return levelSel==#modeLevel[modeID[modeSel]] end,code=function()keyDown.mode("right")end},
		start={x=1000,y=600,w=250,h=100,rgb=color.green,f=50,code=function()loadGame(modeSel,levelSel)end},
		custom={x=270,y=540,w=190,h=85,rgb=color.yellow,code=function()gotoScene("custom")end},
		back={x=640,y=630,w=230,h=90,rgb=color.white,f=45,code=back},
	},
	custom={
		up={x=1000,y=200,w=100,h=100,rgb=color.white,code=function()optSel=(optSel-2)%#customID+1 end},
		down={x=1000,y=440,w=100,h=100,rgb=color.white,f=50,code=function()optSel=optSel%#customID+1 end},
		left={x=880,y=320,w=100,h=100,rgb=color.white,f=50,code=function()local k=customID[optSel]customSel[k]=(customSel[k]-2)%#customRange[k]+1 end},
		right={x=1120,y=320,w=100,h=100,rgb=color.white,f=50,code=function()local k=customID[optSel]customSel[k]=customSel[k]%#customRange[k]+1 end},
		start={x=1000,y=580,w=180,h=80,rgb=color.green,code=function()loadGame(0,1)end},
		back={x=640,y=630,w=180,h=60,rgb=color.white,code=back},
	},
	play={
		back={x=1235,y=45,w=80,h=80,rgb=color.white,code=back,f=35},
	},
	setting={--Normal setting
		ghost={x=290,y=90,w=210,h=60,rgb=color.white,code=function()setting.ghost=not setting.ghost end,down="grid",right="center"},
		center={x=505,y=90,w=210,h=60,rgb=color.white,code=function()setting.center=not setting.center end,down="swap",left="ghost",right="sfx"},
		grid={x=290,y=160,w=210,h=60,rgb=color.white,code=function()setting.grid=not setting.grid end,up="ghost",down="dasD",right="swap"},
		swap={x=505,y=160,w=210,h=60,f=28,rgb=color.white,code=function()setting.swap=not setting.swap end,up="center",down="arrD",left="grid",right="vib"},
		dasD={x=210,y=230,w=50,h=50,rgb=color.white,code=function()setting.das=(setting.das-1)%31 end,up="grid",down="sddasD",right="dasU"},
		dasU={x=370,y=230,w=50,h=50,rgb=color.white,code=function()setting.das=(setting.das+1)%31 end,up="grid",down="sddasU",left="dasD",right="arrD"},
		arrD={x=425,y=230,w=50,h=50,rgb=color.white,code=function()setting.arr=(setting.arr-1)%16 end,up="swap",down="sdarrD",left="dasU",right="arrU"},
		arrU={x=585,y=230,w=50,h=50,rgb=color.white,code=function()setting.arr=(setting.arr+1)%16 end,up="swap",down="sdarrU",left="arrD",right="fullscreen"},--3~6
		sddasD={x=210,y=300,w=50,h=50,rgb=color.white,code=function()setting.sddas=(setting.sddas-1)%11 end,up="dasD",down="lang",right="sddasU"},
		sddasU={x=370,y=300,w=50,h=50,rgb=color.white,code=function()setting.sddas=(setting.sddas+1)%11 end,up="dasU",down="lang",left="sddasD",right="sdarrD"},
		sdarrD={x=425,y=300,w=50,h=50,rgb=color.white,code=function()setting.sdarr=(setting.sdarr-1)%4 end,up="arrD",down="lang",left="sddasU",right="sdarrU"},
		sdarrU={x=585,y=300,w=50,h=50,rgb=color.white,code=function()setting.sdarr=(setting.sdarr+1)%4 end,up="arrU",down="lang",left="sdarrD",right="bgblock"},
		sfx={x=760,y=90,w=160,h=60,rgb=color.white,code=function()setting.sfx=not setting.sfx end,down="vib",left="center",right="bgm"},
		bgm={x=940,y=90,w=160,h=60,rgb=color.white,code=function()
			BGM()
			setting.bgm=not setting.bgm
			BGM("blank")
		end,down="vib",left="sfx"},
		vib={x=850,y=160,w=340,h=60,rgb=color.white,code=function()
			setting.vib=(setting.vib+1)%5
			VIB(2)
		end,up="sfx",down="fullscreen",left="swap"},
		fullscreen={x=850,y=230,w=340,h=60,rgb=color.white,code=function()
			setting.fullscreen=not setting.fullscreen
			love.window.setFullscreen(setting.fullscreen)
			if not setting.fullscreen then
				love.resize(gc.getWidth(),gc.getHeight())
			end
		end,up="vib",down="bgblock",left="arrU"},
		bgblock={x=850,y=300,w=340,h=60,rgb=color.white,code=function()
			setting.bgblock=not setting.bgblock
			if not setting.bgblock then
				for i=1,16 do
					BGblockList[i].v=3*BGblockList[i].v
				end
			end
		end,up="fullscreen",down="frame",left="sdarrU"},
		frame={x=850,y=370,w=340,h=60,rgb=color.white,code=function()
			setting.frameMul=setting.frameMul+(setting.frameMul<50 and 5 or 10)
			if setting.frameMul>100 then setting.frameMul=25 end
		end,up="bgblock",down="control",left="sdarrU"},
		control={x=850,y=440,w=340,h=60,rgb=color.green,code=function()gotoScene("setting2")end,up="frame",down="touch",left="lang"},
		touch={x=850,y=510,w=340,h=60,rgb=color.yellow,code=function()gotoScene("setting3")end,up="control",down="back",left="lang"},
		lang={x=280,y=510,w=200,h=60,rgb=color.red,code=function()
			setting.lang=setting.lang%#langName+1
			swapLanguage(setting.lang)
		end,up="sddasD",down="back",right="touch"},
		back={x=640,y=620,w=300,h=70,rgb=color.white,code=back,up="touch"},
	},
	setting2={--Control setting
		back={x=840,y=630,w=180,h=60,rgb=color.white,code=back},
	},
	setting3={--Touch setting
		back={x=640,y=410,w=170,h=80,f=45,code=back},
		hide={x=640,y=210,w=500,h=80,f=45,code=function()
			setting.virtualkeySwitch=not setting.virtualkeySwitch
		end},
		default={x=450,y=310,w=170,h=80,code=function()
			for K=1,#virtualkey do
				local b,b0=virtualkey[K],virtualkeySet[defaultSel][K]
				b[1],b[2],b[3],b[4]=b0[1],b0[2],b0[3],b0[4]
			end--Default virtualkey
			defaultSel=defaultSel%5+1
		end},
		snap={x=640,y=310,w=170,h=80,code=function()
			snapLevel=snapLevel%6+1
		end},
		alpha={x=830,y=310,w=170,h=80,f=45,code=function()
			setting.virtualkeyAlpha=(setting.virtualkeyAlpha+1)%6
			--Adjust virtualkey alpha
		end},
		icon={x=450,y=410,w=170,h=80,f=45,code=function()
			setting.virtualkeyIcon=not setting.virtualkeyIcon
			--Switch virtualkey icon
		end},
		size={x=830,y=410,w=170,h=80,f=45,code=function()
			if sel then
				local b=virtualkey[sel]
				b[4]=b[4]+10
				if b[4]==150 then b[4]=40 end
				b[3]=b[4]^2
			end
		end},
	},
	help={
		back={x=640,y=590,w=180,h=60,rgb=color.white,code=back,right="qq"},
		qq={x=980,y=590,w=230,h=60,rgb=color.white,code=function()sys.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,left="back"},
	},
	stat={
		back={x=640,y=590,w=180,h=60,rgb=color.white,code=back,right="path"},
		path={x=980,y=590,w=250,h=60,f=30,rgb=color.white,code=function()sys.openURL("C:/Users/MrZ/AppData/Roaming/LOVE/Techmino")end,left="back"},
	},
	sel=nil,--selected button id(integer)
}