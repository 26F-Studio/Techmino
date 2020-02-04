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
PCbase={
	{3,3,3,0,0,0,0,0,2,2},
	{3,6,6,0,0,0,0,2,2,5},
	{4,6,6,0,0,0,1,1,5,5},
	{4,4,4,0,0,0,0,1,1,5},
	{1,1,0,0,0,0,0,3,3,3},
	{5,1,1,0,0,0,0,6,6,3},
	{5,5,2,2,0,0,0,6,6,4},
	{5,2,2,0,0,0,0,4,4,4},
}
PClist={
	{7,7,4,5},{7,7,6,4},{7,7,2,4},{7,7,1,3},{7,7,5,6},{7,7,5,2},{7,7,5,4},{7,7,5,3},
	{7,4,1,2},{7,3,5,7},{7,5,4,3},{7,5,1,2},{7,1,4,2},{7,4,2,5},{7,6,4,5},{7,5,4,2},
	{7,5,6,4},{7,5,3,6},{7,2,5,6},{7,2,6,4},{7,2,1,3},{7,5,2,7},{7,5,7,2},{7,5,2,3},
	{7,5,3,2},{7,6,5,4},{7,3,1,5},{7,3,2,5},{7,4,1,5},{7,4,5,2},{7,7,3,6},{7,3,7,6},
	{7,3,6,2},{7,3,7,1},{7,6,4,2},{3,2,7,6},{3,2,6,7},{7,7,4,5},{7,5,3,4},{7,3,6,5},
	{7,3,2,5},{7,4,6,5},{7,5,2,3},{7,3,5,7},{7,3,2,5},{7,3,5,1},{7,5,2,3},{3,6,2,5},
	{3,1,2,5},{3,1,1,5},{3,1,5,2},{3,1,5,1},{3,5,1,2},{4,5,3,2},{4,2,6,5},{6,5,3,2},
	{1,4,2,5},{1,5,3,6},{5,2,6,3},{5,2,1,3},{5,2,7,4},{2,4,1,5},{2,4,5,1},{2,1,4,5},
	{2,5,4,3},{2,5,6,7},{7,5,4,2},{4,5,3,5},
}
color={
	red={1,0,0},
	green={0,1,0},
	blue={.2,.2,1},
	yellow={1,1,0},
	purple={1,0,1},
	cyan={0,1,1},
	grey={.6,.6,.6},

	lightRed={1,.5,.5},
	lightGreen={.5,1,.5},
	lightBlue={.6,.6,1},
	lightYellow={1,1,.5},
	lightPurple={1,.5,1},
	lightCyan={.5,1,1},
	lightGrey={.8,.8,.8},

	darkRed={.6,0,0},
	darkGreen={0,.6,0},
	darkBlue={0,0,.6},
	darkYellow={.6,.6,0},
	darkPurple={.6,0,.6},
	darkCyan={0,.6,.6},
	darkGrey={.3,.3,.3},

	white={1,1,1},
	orange={1,.6,0},
}
attackColor={
	{color.red,color.yellow},
	{color.purple,color.white},
	{color.blue,color.white},
	animate={
		function(t)
			gc.setColor(1,t,0)
		end,
		function(t)
			gc.setColor(1,.5+t*.5,1)
		end,
		function(t)
			gc.setColor(.2+t*.8,.2+t*.8,1)
		end,
	}--3 animation-colorsets of attack buffer bar
}
frameColor={
	[0]=color.white,
	color.green,
	color.blue,
	color.purple,
	color.orange,
}
blockColor={
	color.red,
	color.green,
	color.orange,
	color.blue,
	color.purple,
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
	"ready","start","win","fail",
	"move","rotate","rotatekick","hold",
	"prerotate","prehold",
	"drop","fall",
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
}

prevMenu={
	load=love.event.quit,
	intro="quit",
	main="intro",
	mode="main",
	custom="mode",
	ready="mode",
	play=function()
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
}--Order
customOption={
	drop="Drop delay:",
	lock="Lock delay:",
	wait="Next piece delay:",
	fall="Clear row delay:",
	next="Next count:",
	hold="Hold:",
	sequence="Sequence:",
	visible="Visible:",
	target="Line limit:",
	freshLimit="Lock fresh limit:",
	opponent="Opponent speed:",
}--Key str
customVal={
	drop={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,"∞","[20G]"},
	lock={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,"∞"},
	wait=nil,
	fall=nil,
	next=nil,
	hold={"on","off"},
	sequence={"bag7","his4","random"},
	visible={"normal","time","invisible"},
	target={10,20,40,100,200,500,1000,"∞"},
	freshLimit={0,8,15,"∞"},
	opponent={"No CPU",1,2,3,4,5,6,7,8,9,10,11},
}--number-Val str
customRange={
	drop={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99,-1},
	lock={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
	wait={1,3,5,7,10,15,20,30,60},
	fall={1,3,5,7,10,15,20,30,60},
	next={0,1,2,3,4,5,6},
	hold={true,false},
	sequence={"bag7","his4","rnd"},
	visible={1,2,3},
	target={10,20,40,100,200,500,1000,1e99},
	freshLimit={0,8,15,1e99},
	opponent={0,60,30,20,15,10,7,5,4,3,2,1},
}

langName={"中文","English"}
langID={"chi","eng"}
actName={"moveLeft","moveRight","rotRight","rotLeft","rotFlip","hardDrop","softDrop","hold","swap","restart","insLeft","insRight","insDown"}
blockPos={4,4,4,4,4,5,4}
renATK={[0]=0,0,0,1,1,2,2,3,3,4,4}--3 else
b2bPoint={50,90,150}
b2bATK={3,5,8}
testScore={[0]=0,[-1]=1,[-2]=0,[-3]=1,2,2,2}

spin_n={"spin_1","spin_2","spin_3"}
clear_n={"clear_1","clear_2","clear_3","clear_4"}
ren_n={"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11"}
vibrateLevel={0,.02,.03,.04,.06,.08,.1}
snapLevelValue={1,10,20,40,60,80}
reAtk={0,0,1,1,1,2,2,3,3}
reDef={0,1,1,2,3,3,4,4,5}

marathon_drop={[0]=60,48,40,30,24,18,15,12,10,8,7,6,5,4,3,2,1,1,0,0}
rush_lock={20,18,16,14,12}
rush_wait={12,10,9,8,7}
rush_fall={12,11,10,9,8}
death_lock={12,11,10,9,8}
death_wait={9,8,7,6,5}
death_fall={10,9,8,7,6}
pc_drop={50,45,40,35,30,26,22,18,15,12}
pc_lock={55,50,45,40,36,32,30}
pc_fall={18,16,14,12,10,9,8,7,6}

atkModeName={"Random","Badges","K.O.s","Counters"}
up0to4={[0]="000%UP","025%UP","050%UP","075%UP","100%UP",}
percent0to5={[0]="0%","20%","40%","60%","80%","100%",}
snapLevelName={"Free pos","Snap-10","Snap-20","Snap-40","Snap-60","Snap-80"}

defaultModeEnv={
	sprint={
		{
			drop=60,
			target=10,
			reach=Event.gameover.win,
			bg="strap",
			bgm="race",
		},
		{
			drop=60,
			target=20,
			reach=Event.gameover.win,
			bg="strap",
			bgm="race",
		},
		{
			drop=60,
			target=40,
			reach=Event.gameover.win,
			bg="strap",
			bgm="race",
		},
		{
			drop=60,
			target=100,
			reach=Event.gameover.win,
			bg="strap",
			bgm="race",
		},
		{
			drop=60,
			target=400,
			reach=Event.gameover.win,
			bg="strap",
			bgm="push",
		},
		{
			drop=60,
			target=1000,
			reach=Event.gameover.win,
			bg="strap",
			bgm="push",
		},
	},
	marathon={
		{
			drop=60,
			lock=60,
			fall=30,
			target=200,
			reach=Event.marathon_reach,
			bg="strap",
			bgm="way",
		},
		{
			drop=60,
			fall=20,
			target=10,
			reach=Event.marathon_reach,
			bg="strap",
			bgm="way",
		},
		{
			_20G=true,
			fall=15,
			target=200,
			reach=Event.marathon_reach,
			bg="strap",
			bgm="race",
		},
		{
			_20G=true,
			drop=0,
			lock=rush_lock[1],
			wait=rush_wait[1],
			fall=rush_fall[1],
			target=50,
			reach=Event.marathon_reach_lunatic,
			arr=2,
			bg="game2",
			bgm="secret8th",
		},
		{
			_20G=true,
			drop=0,
			lock=death_lock[1],
			wait=death_wait[1],
			fall=death_fall[1],
			target=50,
			reach=Event.marathon_reach_ultimate,
			arr=1,
			bg="game2",
			bgm="secret7th",
		},
	},
	zen={
		{
			drop=1e99,
			lock=1e99,
			target=200,
			reach=Event.gameover.win,
			bg="strap",
			bgm="infinite",
		},
	},
	infinite={
		{
			drop=1e99,
			lock=1e99,
			oncehold=false,
			bg="glow",
			bgm="infinite",
		},
	},
	solo={
		{
			bg="game2",
			bgm="race",
		},
	},
	tsd={
		{
			oncehold=false,
			drop=1e99,
			lock=1e99,
			target=1,
			reach=Event.tsd_reach,
			ospin=false,
			bg="matrix",
			bgm="reason",
		},
		{
			drop=60,
			lock=60,
			target=1,
			reach=Event.tsd_reach,
			ospin=false,
			bg="matrix",
			bgm="reason",
		},
	},
	blind={
		{
			drop=30,
			lock=60,
			visible=2,
			bg="glow",
			bgm="newera",
		},
		{
			drop=15,
			lock=60,
			visible=0,
			freshLimit=10,
			bg="glow",
			bgm="reason",
		},
		{
			_20G=true,
			lock=60,
			visible=0,
			freshLimit=15,
			bg="glow",
			bgm="reason",
		},
		{
			_20G=true,
			drop=0,
			lock=15,
			wait=10,
			fall=15,
			visible=0,
			arr=1,
			bg="game3",
			bgm="secret8th",
		},
	},
	dig={
		{
			drop=60,
			lock=120,
			fall=20,
			bg="game2",
			bgm="push",
		},
		{
			drop=10,
			lock=30,
			bg="game2",
			bgm="secret7th",
		},
	},
	survivor={
		{
			drop=60,
			lock=120,
			fall=30,
			bg="game2",
			bgm="push",
		},
		{
			drop=30,
			lock=60,
			fall=20,
			bg="game2",
			bgm="newera",
		},
		{
			drop=10,
			lock=60,
			fall=15,
			bg="game2",
			bgm="secret8th",
		},
		{
			drop=5,
			lock=60,
			fall=10,
			bg="game3",
			bgm="secret7th",
		},
	},
	tech={
		{
			oncehold=false,
			drop=1e99,
			lock=1e99,
			target=0,
			reach=Event.tech_reach,
			bg="matrix",
			bgm="way",
		},
		{
			drop=30,
			lock=60,
			target=0,
			reach=Event.tech_reach,
			bg="matrix",
			bgm="way",
		},
		{
			drop=15,
			lock=60,
			target=0,
			reach=Event.tech_reach_hard,
			bg="matrix",
			bgm="way",
		},
		{
			drop=5,
			lock=40,
			target=0,
			reach=Event.tech_reach_hard,
			bg="matrix",
			bgm="way",
		},
		{
			drop=1,
			lock=40,
			target=0,
			reach=Event.tech_reach_hard,
			bg="matrix",
			bgm="secret7th",
		},
	},
	pctrain={
		{
			next=4,
			hold=false,
			drop=120,
			lock=120,
			fall=20,
			sequence="pc",
			target=0,
			freshLimit=1e99,
			reach=Event.newPC,
			ospin=false,
			bg="rgb",
			bgm="newera",
		},
		{
			next=4,
			hold=false,
			drop=60,
			lock=60,
			fall=20,
			sequence="pc",
			target=0,
			reach=Event.newPC,
			ospin=false,
			bg="rgb",
			bgm="newera",
		},
	},
	pcchallenge={
		{
			oncehold=false,
			drop=300,
			lock=1e99,
			target=100,
			reach=Event.gameover.win,
			freshLimit=1e99,
			ospin=false,
			bg="rgb",
			bgm="newera",
		},
		{
			drop=60,
			lock=120,
			fall=10,
			target=100,
			reach=Event.gameover.win,
			ospin=false,
			bg="rgb",
			bgm="infinite",
		},
		{
			drop=20,
			lock=60,
			fall=20,
			target=100,
			reach=Event.gameover.win,
			ospin=false,
			bg="rgb",
			bgm="infinite",
		},
	},
	techmino41={
		{
			fall=20,
			royaleMode=true,
			royalePowerup={2,5,10,20},
			royaleRemain={30,20,15,10,5},
			pushSpeed=2,
			bg="game3",
			bgm="race",
		},
	},
	techmino99={
		{
			fall=20,
			royaleMode=true,
			royalePowerup={2,6,14,30},
			royaleRemain={75,50,35,20,10},
			pushSpeed=2,
			bg="game3",
			bgm="race",
		},
	},
	drought={
		{
			drop=20,
			lock=60,
			sequence="drought1",
			target=100,
			reach=Event.gameover.win,
			ospin=false,
			bg="glow",
			bgm="reason",
		},
		{
			drop=20,
			lock=60,
			sequence="drought2",
			target=100,
			reach=Event.gameover.win,
			ospin=false,
			bg="glow",
			bgm="reason",
		},
	},
	hotseat={
		{
			bg="none",
			bgm="way",
		},
	},
	custom={
		{
			bg="none",
			bgm="reason",
			reach=Event.gameover.win,
		},
	},
}
modeLevel={
	sprint={"10L","20L","40L","100L","400L","1000L"},
	marathon={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	zen={"NORMAL"},
	infinite={"NORMAL"},
	solo={"EASY","NORMAL","HARD","LUNATIC"},
	tsd={"NORMAL","HARD"},
	blind={"EASY","HARD","LUNATIC","GM"},
	dig={"NORMAL","LUNATIC"},
	survivor={"EASY","NORMAL","HARD","LUNATIC"},
	tech={"EASY","NORMAL","HARD","LUNATIC","ULTIMATE"},
	pctrain={"NORMAL","LUNATIC"},
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
	HARD=color.purple,
	LUNATIC=color.red,
	EXTRA=color.lightPurple,

	MESS=color.lightGrey,
	GM=color.blue,
	ULTIMATE=color.lightYellow,
	DEATH=color.lightRed,
	["10L"]=color.cyan,
	["20L"]=color.lightBlue,
	["40L"]=color.green,
	["100L"]=color.orange,
	["400L"]=color.red,
	["1000L"]=color.darkRed,
}
modeID={
	[0]="custom",
	"sprint","marathon","zen","infinite","solo","tsd","blind","dig","survivor","tech",
	"pctrain","pcchallenge","techmino41","techmino99","drought","hotseat",
}

freshMethod={
	bag7=function()
		if #P.nxt<6 then
			local bag={1,2,3,4,5,6,7}
			for i=1,7 do
				ins(P.nxt,rem(bag,rnd(8-i)))
				ins(P.nb,blocks[P.nxt[#P.nxt]][0])
			end
		end
	end,
	his4=function()
		if #P.nxt<6 then
			local j,i=0
			::L::
				i,j=rnd(7),j+1
			if(i==P.his[1]or i==P.his[2]or i==P.his[3]or i==P.his[4])then goto L end
			P.nxt[6],P.nb[6]=i,blocks[i][0]
			rem(P.his,1)ins(P.his,i)
		end
	end,
	rnd=function()
		local i
		::L::
			i=rnd(7)
		if i==P.nxt[5]then goto L end
		P.nxt[6],P.nb[6]=i,blocks[i][0]
	end,--random
	pc=function()
		if P.cstat.piece%4==0 then
			local r=rnd(#PClist)
			local f=P.cstat.event==1
			for i=1,4 do
				local b=PClist[r][i]
				if f then
					if b<3 then b=3-b
					elseif b<5 then b=7-b
					end
				end
				ins(P.nxt,b)
				ins(P.nb,blocks[b][0])
			end
			P.cstat.event=(P.cstat.event+1)%2
		end
	end,
	drought1=function()
		if #P.nxt<6 then
			local bag={1,2,3,4,5,6}
			for i=1,6 do
				ins(P.nxt,rem(bag,rnd(7-i)))
				ins(P.nb,blocks[P.nxt[#P.nxt]][0])
			end
		end
	end,
	drought2=function()
		if #P.nxt<6 then
			local bag={1,1,1,2,2,2,3,3,3,4,4,4,6,6,6,5,7}
			::L::
				ins(P.nxt,rem(bag,rnd(#bag)))
				ins(P.nb,blocks[P.nxt[#P.nxt]][0])
			if bag[1]then goto L end
		end
	end,
}
blocks={
	{[0]={{0,1,1},{1,1,0}},{{1,0},{1,1},{0,1}},{{0,1,1},{1,1,0}},{{1,0},{1,1},{0,1}}},
	{[0]={{1,1,0},{0,1,1}},{{0,1},{1,1},{1,0}},{{1,1,0},{0,1,1}},{{0,1},{1,1},{1,0}}},
	{[0]={{1,1,1},{0,0,1}},{{1,1},{1,0},{1,0}},{{1,0,0},{1,1,1}},{{0,1},{0,1},{1,1}}},
	{[0]={{1,1,1},{1,0,0}},{{1,0},{1,0},{1,1}},{{0,0,1},{1,1,1}},{{1,1},{0,1},{0,1}}},
	{[0]={{1,1,1},{0,1,0}},{{1,0},{1,1},{1,0}},{{0,1,0},{1,1,1}},{{0,1},{1,1},{0,1}}},
	{[0]={{1,1},{1,1}},{{1,1},{1,1}},{{1,1},{1,1}},{{1,1},{1,1}}},
	{[0]={{1,1,1,1}},{{1},{1},{1},{1}},{{1,1,1,1}},{{1},{1},{1},{1}}},
}
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
		[12]={{0,0},{1,0},{1,-1},{-1,0},{0,2},{1,2}},
		[21]={{0,0},{-1,0},{-1,1},{1,0},{0,-2},{-1,-2}},
		[23]={{0,0},{1,0},{1,1},{1,-1},{0,-2},{1,-2}},
		[32]={{0,0},{-1,0},{-1,-1},{-1,1},{0,2},{-1,2}},
		[30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2},{0,-1}},
		[03]={{0,0},{1,0},{1,1},{0,-2},{1,-2},{0,1}},
		[02]={{0,0},{1,0},{-1,0},{0,-1},{0,1}},
		[20]={{0,0},{-1,0},{1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,-1},{0,1},{-1,0}},
		[31]={{0,0},{0,1},{0,-1},{1,0}},
	},--Z/J
	[2]={
		[01]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
		[10]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
		[12]={{0,0},{1,0},{1,-1},{1,1},{0,2},{1,2}},
		[21]={{0,0},{-1,0},{-1,1},{-1,-1},{0,-2},{-1,-2}},
		[23]={{0,0},{1,0},{1,1},{-1,0},{0,-2},{1,-2}},
		[32]={{0,0},{-1,0},{-1,-1},{1,0},{0,2},{-1,2}},
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
		[01]={{0,0},{1,0},{-2,0},{-2,-1},{1,2}},
		[03]={{0,0},{-1,0},{2,0},{2,-1},{-1,2}},
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
		{1280-360,40,0,40},--moveLeft
		{1280-280,40,0,40},--moveRight
		{1280-520,40,0,40},--rotRight
		{1280-600,40,0,40},--rotLeft
		{1280-440,40,0,40},--rotFlip
		{1280-40,40,0,40},--hardDrop
		{1280-120,40,0,40},--softDrop
		{1280-200,40,0,40},--hold
		{1280-680,40,0,40},--swap
		{1280-760,40,0,40},--restart
	},--PC key feedback
}
Buttons={
	load={},
	intro={},
	main={
		{x=250,y=250,w=350,h=100,rgb=color.red,f=55,code=function()gotoScene("mode")end,down=2},
		{x=250,y=360,w=350,h=100,rgb=color.blue,f=55,code=function()gotoScene("setting")end,up=1,down=3},
		{x=160,y=470,w=170,h=100,rgb=color.yellow,f=55,code=function()gotoScene("help")end,up=2,down=5,right=4},
		{x=340,y=470,w=170,h=100,rgb=color.cyan,f=40,code=function()gotoScene("stat")end,up=2,down=5,left=3},
		{x=250,y=580,w=350,h=100,rgb=color.grey,f=50,code=function()gotoScene("quit")end,up=3},
	},
	mode={
		{x=1000,y=210,w=200,h=140,rgb=color.white,hide=function()return modeSel==1 end,f=64,code=function()keyDown.mode("up")end},
		{x=1000,y=430,w=200,h=140,rgb=color.white,hide=function()return modeSel==#modeID end,f=80,code=function()keyDown.mode("down")end},
		{x=190,y=160,w=100,h=80,rgb=color.white,hide=function()return levelSel==1 end,code=function()keyDown.mode("left")end},
		{x=350,y=160,w=100,h=80,rgb=color.white,hide=function()return levelSel==#modeLevel[modeID[modeSel]] end,code=function()keyDown.mode("right")end},
		{x=1000,y=600,w=250,h=100,rgb=color.green,f=50,code=function()loadGame(modeSel,levelSel)end},
		{x=270,y=540,w=190,h=85,rgb=color.yellow,code=function()gotoScene("custom")end},
		{x=640,y=630,w=230,h=90,rgb=color.white,f=45,code=back},
	},
	custom={
		{x=1000,y=200,w=100,h=100,rgb=color.white,f=40,code=function()optSel=(optSel-2)%#customID+1 end},
		{x=1000,y=440,w=100,h=100,rgb=color.white,f=50,code=function()optSel=optSel%#customID+1 end},
		{x=880,y=320,w=100,h=100,rgb=color.white,f=50,code=function()local k=customID[optSel]customSel[k]=(customSel[k]-2)%#customRange[k]+1 end},
		{x=1120,y=320,w=100,h=100,rgb=color.white,f=50,code=function()local k=customID[optSel]customSel[k]=customSel[k]%#customRange[k]+1 end},
		{x=1000,y=580,w=180,h=80,rgb=color.green,code=function()loadGame(0,1)end},
		{x=640,y=630,w=180,h=60,rgb=color.white,code=back},
	},
	play={
	},
	setting={--Normal setting
		{x=285,y=90,w=210,h=60,rgb=color.white,code=function()setting.ghost=not setting.ghost end,down=3,right=2},
		{x=505,y=90,w=210,h=60,rgb=color.white,code=function()setting.center=not setting.center end,down=5,left=1,right=11},
		--1,2
		{x=205,y=180,w=50,h=50,rgb=color.white,code=function()setting.das=(setting.das-1)%31 end,up=1,down=7,right=4},
		{x=370,y=180,w=50,h=50,rgb=color.white,code=function()setting.das=(setting.das+1)%31 end,up=1,down=8,left=3,right=5},
		{x=420,y=180,w=50,h=50,rgb=color.white,code=function()setting.arr=(setting.arr-1)%16 end,up=2,down=9,left=4,right=6},
		{x=585,y=180,w=50,h=50,rgb=color.white,code=function()setting.arr=(setting.arr+1)%16 end,up=2,down=10,left=5,right=13},
		--3~6
		{x=205,y=260,w=50,h=50,rgb=color.white,code=function()setting.sddas=(setting.sddas-1)%11 end,up=3,down=19,right=8},
		{x=370,y=260,w=50,h=50,rgb=color.white,code=function()setting.sddas=(setting.sddas+1)%11 end,up=4,down=19,left=7,right=9},
		{x=420,y=260,w=50,h=50,rgb=color.white,code=function()setting.sdarr=(setting.sdarr-1)%4 end,up=5,down=19,left=8,right=10},
		{x=585,y=260,w=50,h=50,rgb=color.white,code=function()setting.sdarr=(setting.sdarr+1)%4 end,up=6,down=19,left=9,right=14},
		--7~10
		{x=760,y=90,w=160,h=60,rgb=color.white,code=function()setting.sfx=not setting.sfx end,down=13,left=2,right=12},
		{x=940,y=90,w=160,h=60,rgb=color.white,code=function()
			BGM()
			setting.bgm=not setting.bgm
			BGM("blank")
		end,down=13,left=6},
		{x=850,y=160,w=340,h=60,rgb=color.white,code=function()
			setting.vib=(setting.vib+1)%5
			VIB(2)
		end,up=11,down=14,left=6},
		{x=850,y=230,w=340,h=60,rgb=color.white,
			code=function()
				setting.fullscreen=not setting.fullscreen
				love.window.setFullscreen(setting.fullscreen)
				if not setting.fullscreen then
					love.resize(gc.getWidth(),gc.getHeight())
				end
			end,
			up=13,down=15,left=6
		},
		{x=850,y=300,w=340,h=60,rgb=color.white,
			code=function()
				setting.bgblock=not setting.bgblock
				if not setting.bgblock then
					for i=1,16 do
						BGblockList[i].v=3*BGblockList[i].v
					end
				end
			end,
			up=14,down=16,left=10
		},
		{x=850,y=370,w=340,h=60,rgb=color.white,code=function()
			setting.frameMul=setting.frameMul+(setting.frameMul<50 and 5 or 10)
			if setting.frameMul>100 then setting.frameMul=25 end
		end,up=15,down=17},
		--11~16
		{x=850,y=440,w=340,h=60,rgb=color.green,code=function()gotoScene("setting2")end,up=16,down=18},
		{x=850,y=510,w=340,h=60,rgb=color.yellow,code=function()gotoScene("setting3")end,up=17,down=20},
		{x=280,y=510,w=200,h=60,rgb=color.red,code=function()
			setting.lang=setting.lang%#langName+1
			swapLanguage(setting.lang)
		end,up=10,down=20,right=18},
		{x=640,y=620,w=300,h=70,rgb=color.white,code=back,up=19},
		--17~19
	},
	setting2={--Control setting
		{x=840,y=630,w=180,h=60,rgb=color.white,code=back},
	},
	setting3={--Touch setting
		{x=640,y=410,w=170,h=80,code=back},
		{x=640,y=210,w=500,h=80,code=function()
			setting.virtualkeySwitch=not setting.virtualkeySwitch
		end},
		{x=450,y=310,w=170,h=80,code=function()
			for K=1,#virtualkey do
				local b,b0=virtualkey[K],virtualkeySet[defaultSel][K]
				b[1],b[2],b[3],b[4]=b0[1],b0[2],b0[3],b0[4]
			end--Default virtualkey
			defaultSel=defaultSel%5+1
		end},
		{x=640,y=310,w=170,h=80,code=function()
			snapLevel=snapLevel%6+1
		end},
		{x=830,y=310,w=170,h=80,code=function()
			setting.virtualkeyAlpha=(setting.virtualkeyAlpha+1)%6
			--Adjust virtualkey alpha
		end},
		{x=450,y=410,w=170,h=80,code=function()
			setting.virtualkeyIcon=not setting.virtualkeyIcon
			--Switch virtualkey icon
		end},
		{x=830,y=410,w=170,h=80,code=function()
			if sel then
				local b=virtualkey[sel]
				b[4]=b[4]+10
				if b[4]==150 then b[4]=40 end
				b[3]=b[4]^2
			end
		end},
	},
	help={
		{x=640,y=590,w=180,h=60,rgb=color.white,code=back,right=2},
		{x=980,y=590,w=230,h=60,rgb=color.white,code=function()sys.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,left=1},
	},
	stat={
		{x=640,y=590,w=180,h=60,rgb=color.white,code=back},
	},
	sel=nil,--selected button id(integer)
}