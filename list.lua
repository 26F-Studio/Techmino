--[["four name"
	Techrash
	Zestris
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
PClist={--ZSLJTOI
	{7,7,4,5},{7,7,6,4},{7,7,2,4},{7,7,1,3},{7,7,5,6},{7,7,5,2},{7,7,5,4},{7,7,5,3},
	{7,4,1,2},{7,3,5,7},{7,5,4,3},{7,5,1,2},{7,1,4,2},{7,4,2,5},{7,6,4,5},{7,5,4,2},
	{7,5,6,4},{7,5,3,6},{7,2,5,6},{7,2,6,4},{7,2,1,3},{7,5,2,7},{7,5,7,2},{7,5,2,3},
	{7,5,3,2},{7,6,4,5},{7,6,5,4},{7,3,1,5},{7,3,2,5},{7,4,1,5},{7,4,5,2},{7,7,3,6},
	{7,3,7,6},{7,3,6,2},{7,3,7,1},{7,6,4,2},{3,2,7,6},{3,2,6,7},{7,7,4,5},{7,5,3,4},
	{7,3,6,5},{7,3,2,5},{7,4,6,5},{7,6,4,5},{7,5,2,3},{7,3,5,7},{7,3,2,5},{7,3,5,1},
	{7,5,2,3},{3,6,2,5},{3,1,2,5},{3,1,1,5},{3,1,5,2},{3,1,5,1},{3,5,1,2},{4,5,3,2},
	{4,2,6,5},{6,5,3,2},{1,4,2,5},{1,5,3,6},{5,2,6,3},{5,2,1,3},{5,2,7,4},{2,4,1,5},
	{2,4,5,1},{2,1,4,5},{2,5,4,3},{2,5,6,7},{7,5,4,2},
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
	{color.red,color.purple},
	{color.blue,color.white},
	animate={
		function(t)
			gc.setColor(1,t,0)
		end,
		function(t)
			gc.setColor(1,.3,.2+t*.8)
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
blockName={"Z","S","L","J","T","O","I"}
blockColor={
	color.red,
	color.green,
	color.orange,
	color.blue,
	color.purple,
	color.yellow,
	color.cyan,
}
clearName={"Single","Double","Triple"}
spinName={[0]={}}
for i=1,3 do
	spinName[i]={}
	for j=1,7 do
		spinName[i][j]=blockName[j].." spin "..clearName[i]
	end
end
for j=1,7 do
	spinName[0][j]=blockName[j].." spin"
end

miniTitle_pixel={
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
	"perfectclear",
}
bgm={
	"blank",
	"way",
	"race",
	"push",
	"reason",
	"infinite",
	"cruelty",
	"final",
}

prevMenu={
	load=love.event.quit,
	intro="quit",
	main="intro",
	mode="main",
	custom="mode",
	ready="mode",
	play=function()
		gotoScene(gameMode~="custom"and"mode"or"custom")
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
	sequence={1,2,3},
	visible={1,2,3},
	target={10,20,40,100,200,500,1000,1e99},
	freshLimit={0,8,15,1e99},
	opponent={0,60,30,20,15,10,7,5,4,3,2,1},
}

actName={"moveLeft","moveRight","rotRight","rotLeft","rotFlip","hardDrop","softDrop","hold","swap","restart","insLeft","insRight","insDown"}
actName_show={"Move Left:","Move Right:","Rotate Right:","Rotate Left:","Rotate Flip","Hard Drop:","Soft Drop:","Hold:","Swap:","Restart:","Instant Left:","Instant Right:","Ins Down:"}
blockPos={4,4,4,4,4,5,4}
renATK={[0]=0,0,0,1,1,2,2,3,3,4,4}--3 else
renName={nil,nil,"3 Combo","4 Combo","5 Combo","6 Combo","7 Combo","8 Combo","9 Combo","10 Combo!","11 Combo!","12 Combo!","13 Combo!","14 Combo!","15 Combo!","16 Combo!","17 Combo!","18 Combo!","19 Combo!","MEGACMB",}
b2bPoint={50,90,150}
b2bATK={3,5,8}
testScore={[0]=0,[-1]=1,[-2]=0,[-3]=1,2,2,2}

spin_n={"spin_1","spin_2","spin_3"}
clear_n={"clear_1","clear_2","clear_3","clear_4"}
ren_n={"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11"}
vibrateLevel={0,.02,.03,.04,.06,.08,.1}
atkModeName={"Random","Badges","K.O.s","Counters"}
up0to4={[0]="000%UP","025%UP","050%UP","075%UP","100%UP",}
percent0to5={[0]="0%","20%","40%","60%","80%","100%",}
snapLevelName={"Free pos","Snap-10","Snap-20","Snap-40","Snap-60","Snap-80"}
snapLevelValue={1,10,20,40,60,80}
reAtk={0,0,1,1,1,2,2,3,3}
reDef={0,1,1,2,3,3,4,4,5}

marathon_drop={[0]=60,48,40,30,24,18,15,12,10,8,7,6,5,4,3,2,1,1,0,0}
death_lock={12,11,10,9,8}
death_wait={9,8,7,6,5}
death_fall={10,9,8,7,6}
pc_drop={50,45,40,35,30,26,22,18,15,12}
pc_lock={55,50,45,40,36,32,30}
pc_fall={18,16,14,12,10,9,8,7,6}

defaultModeEnv={
	sprint={
		{
			drop=60,
			target=10,
			reach=Event.gameover.win,
		},
		{
			drop=60,
			target=20,
			reach=Event.gameover.win,
		},
		{
			drop=60,
			target=40,
			reach=Event.gameover.win,
		},
		{
			drop=60,
			target=100,
			reach=Event.gameover.win,
		},
		{
			drop=60,
			target=400,
			reach=Event.gameover.win,
		},
		{
			drop=60,
			target=1000,
			reach=Event.gameover.win,
		},
	},
	marathon={
		{
			drop=60,
			fall=20,
			target=10,
			reach=Event.marathon_reach,
		},
		{
			_20G=true,
			fall=20,
			target=200,
			reach=Event.marathon_reach,
		},
	},
	zen={
		{
			drop=1e99,
			lock=1e99,
			target=200,
			reach=Event.gameover.win,
		},
	},
	infinite={
		{
			drop=1e99,
			lock=1e99,
			oncehold=false,
		},
	},
	solo={
		{},
	},
	death={
		{
			_20G=true,
			drop=0,
			lock=death_lock[1],
			wait=death_wait[1],
			fall=death_fall[1],
			target=50,
			reach=Event.death_reach,
			arr=1,
		},	
	},
	tsd={
		{
			oncehold=false,
			drop=1e99,
			lock=1e99,
			target=1,
			reach=Event.tsd_reach,
		},
		{
			drop=60,
			lock=60,
			target=1,
			reach=Event.tsd_reach,
		},
	},
	blind={
		{
			drop=1e99,
			lock=1e99,
			visible=0,
		},
		{
			drop=15,
			lock=30,
			visible=0,
			freshLimit=10,
		},
		{
			_20G=true,
			lock=60,
			visible=0,
			freshLimit=15,
		},
	},
	sudden={
		{
			oncehold=false,
			drop=1e99,
			lock=1e99,
			target=0,
			reach=Event.sudden_reach,
		},
		{
			drop=30,
			lock=60,
			target=0,
			reach=Event.sudden_reach,
		},
		{
			drop=15,
			lock=60,
			target=0,
			reach=Event.sudden_reach_HARD,
		},
		{
			drop=5,
			lock=20,
			target=0,
			reach=Event.sudden_reach_HARD,
		},
	},
	pctrain={
		{
			next=4,
			hold=false,
			drop=120,
			lock=120,
			fall=20,
			sequence=4,
			target=0,
			freshLimit=1e99,
			reach=Event.newPC,
		},
		{
			next=4,
			hold=false,
			drop=60,
			lock=60,
			fall=15,
			sequence=4,
			target=0,
			reach=Event.newPC,
		},
	},
	pcchallenge={
		{
			oncehold=false,
			drop=300,
			lock=1e99,
			sequence=1,
			target=100,
			reach=Event.gameover.win,
			freshLimit=1e99,
		},
		{
			drop=60,
			lock=120,
			fall=10,
			sequence=1,
			target=100,
			reach=Event.gameover.win,
		},
		{
			drop=20,
			lock=60,
			fall=20,
			sequence=1,
			target=100,
			reach=Event.gameover.win,
		},
	},
	techmino41={
		{
			fall=20,
			royaleMode=true,
			royalePowerup={2,5,10,20},
			royaleRemain={30,20,15,10,5},
		},
	},
	techmino99={
		{
			fall=20,
			royaleMode=true,
			royalePowerup={2,6,14,30},
			royaleRemain={75,50,35,20,10},
		},
	},
	drought={
		{
			drop=20,
			lock=30,
			sequence=5,
			target=100,
			reach=Event.gameover.win,
		},
		{
			drop=20,
			lock=30,
			sequence=6,
			target=100,
			reach=Event.gameover.win,
		},
	},
	gmroll={
		{
			drop=0,
			lock=15,
			wait=10,
			fall=15,
			_20G=true,
			visible=0,
			arr=1,
		},
	},
	p2={
		{},
	},
	p3={
		{},
	},
	p4={
		{},
	},
	custom={
		{
			reach=Event.gameover.win
		},
	},
}
modeLevel={
	sprint={"10L","20L","40L","100L","400L","1000L"},
	marathon={"NORMAL","LUNATIC"},
	zen={"NORMAL"},
	infinite={"NORMAL"},
	solo={"EASY","NORMAL","HARD","LUNATIC"},
	death={"LUNATIC"},
	tsd={"NORMAL","HARD"},
	blind={"EASY","HARD","LUNATIC"},
	sudden={"EASY","NORMAL","HARD","LUNATIC"},
	pctrain={"HARD","LUNATIC"},
	pcchallenge={"NORMAL","HARD","LUNATIC"},
	techmino41={"EASY","NORMAL","HARD","LUNATIC","HELL"},
	techmino99={"EASY","NORMAL","HARD","LUNATIC","HELL"},
	drought={"NORMAL","MESS"},
	gmroll={"GM"},
	p2={"NORMAL"},
	p3={"NORMAL"},
	p4={"NORMAL"},
}
modeLevelColor={
	EASY=color.cyan,
	NORMAL=color.green,
	HARD=color.purple,
	LUNATIC=color.red,
	EXTRA=color.lightPurple,

	MESS=color.lightGrey,
	GM=color.blue,
	HELL=color.grey,
	["10L"]=color.cyan,
	["20L"]=color.lightBlue,
	["40L"]=color.green,
	["100L"]=color.orange,
	["400L"]=color.red,
	["1000L"]=color.darkRed,
}
modeID={
	"sprint","marathon","zen","infinite","solo","death","tsd","blind","sudden",
	"pctrain","pcchallenge","techmino41","techmino99","drought","gmroll","p2","p3","p4"
}
modeName={
	"Sprint","Marathon","Zen","Infinite","1v1","Death","TSD-only","Blind","Sudden",
	"PC Train","PC Challenge","Techmino41","Techmino99","Drought","GM roll","2P","3P","4P"
}
modeInfo={
	sprint="Speed run.",
	marathon="Clear 200 Lines",
	zen="Clear 200 Lines without gravity",
	infinite="Infinite game,infinite happiness",
	solo="Beat AI",
	death="Survive under terrible speed",
	tsd="try to make 20 T-spin-double",
	blind="Invisible board",
	sudden="Try to survive",
	pctrain="Let's learn some PCs",
	pcchallenge="Make PCs in 100 Lines",
	techmino41="Melee fight with 40 AIs",
	techmino99="Melee fight with 98 AIs",
	drought="ERRSEQ flood attack",
	gmroll="Who want to be the grand master?",
	p2="2 players game",
	p3="3 players game",
	p4="4 players game",
}

freshMethod={
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		if #P.nxt<6 then
			local bag={1,2,3,4,5,6,7}
			for i=1,7 do
				ins(P.nxt,rem(bag,rnd(8-i)))
				ins(P.nb,blocks[P.nxt[#P.nxt]][0])
			end
		end
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		local i,j=nil,0
		repeat
			i,j=rnd(7),j+1
		until not(i==P.his[1]or i==P.his[2]or i==P.his[3]or i==P.his[4])
		P.nxt[6],P.nb[6]=i,blocks[i][0]
		rem(P.his,1)ins(P.his,i)
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		repeat i=rnd(7)until i~=P.nxt[5]
		P.nxt[6],P.nb[6]=i,blocks[i][0]
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		if P.cstat.piece%4==0 then
			local r=rnd(#PClist)
			local P=players[1]
			local f=P.cstat.pc%2==0
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
		end
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		if #P.nxt<6 then
			local bag={1,2,3,4,5,6}
			for i=1,6 do
				ins(P.nxt,rem(bag,rnd(7-i)))
				ins(P.nb,blocks[P.nxt[#P.nxt]][0])
			end
		end
	end,
	function()
		P.bn,P.cb=rem(P.nxt,1),rem(P.nb,1)
		if #P.nxt<6 then
			local bag={1,1,1,2,2,2,3,3,3,4,4,4,6,6,6,5,7}
			repeat
				ins(P.nxt,rem(bag,rnd(#bag)))
				ins(P.nb,blocks[P.nxt[#P.nxt]][0])
			until not bag[1]
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
		[01]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2},{-1,-1},{0,1}},
		[10]={{0,0},{1,0},{1,-1},{0,2},{1,2},{0,-1},{1,1}},
		[12]={{0,0},{1,0},{1,-1},{0,-1},{0,2},{1,2},{-1,-1}},
		[21]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2},{1,1}},
		[23]={{0,0},{1,0},{1,1},{0,-2},{1,-2},{-1,1}},
		[32]={{0,0},{-1,0},{-1,-1},{0,-1},{0,2},{-1,2},{1,-1}},
		[30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2},{0,-1}},
		[03]={{0,0},{1,0},{1,1},{0,-2},{1,-2},{0,1}},
		[02]={{0,0},{-1,0},{1,0},{0,-1},{0,1}},
		[20]={{0,0},{1,0},{-1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,-1},{0,1},{1,0},{-1,0},{0,2}},
		[31]={{0,0},{0,-1},{0,1},{-1,0},{1,0},{0,2}},
	},
	[7]={
		[01]={{0,0},{1,0},{-2,0},{-2,-1},{1,2}},
		[10]={{0,0},{2,0},{-1,0},{2,1},{-1,-2}},
		[12]={{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
		[21]={{0,0},{-2,0},{1,0},{1,-2},{-2,1}},
		[23]={{0,0},{2,0},{-1,0},{-1,-2},{2,1}},
		[32]={{0,0},{-2,0},{1,0},{-2,-1},{1,2}},
		[30]={{0,0},{1,0},{-2,0},{1,-2},{-2,1}},
		[03]={{0,0},{-1,0},{2,0},{2,-1},{-1,2}},
		[02]={{0,0},{-1,0},{1,0},{0,-1},{0,1}},
		[20]={{0,0},{1,0},{-1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,-1},{-1,0},{1,0},{0,1}},
		[31]={{0,0},{0,-1},{1,0},{-1,0},{0,1}},
	}
}TRS[3],TRS[4]=TRS[2],TRS[1]

Buttons={
	load={},
	intro={},
	main={
		{x=250,y=250,w=350,h=100,rgb=color.red,f=55,t="Play",code=function()gotoScene("mode")end,down=2},
		{x=250,y=360,w=350,h=100,rgb=color.blue,f=50,t="Settings",code=function()gotoScene("setting")end,up=1,down=3},
		{x=160,y=470,w=170,h=100,rgb=color.yellow,f=50,t="Help",code=function()gotoScene("help")end,up=2,down=5,right=4},
		{x=340,y=470,w=170,h=100,rgb=color.cyan,f=40,t="Statistics",code=function()gotoScene("stat")end,up=2,down=5,left=3},
		{x=250,y=580,w=350,h=100,rgb=color.grey,f=40,t="Quit",code=back,up=3},
	},
	mode={
		{x=1000,y=210,w=200,h=140,rgb=color.white,hide=function()return modeSel==1 end,t="Λ",f=64,code=function()keyDown.mode("up")end},
		{x=1000,y=430,w=200,h=140,rgb=color.white,hide=function()return modeSel==#modeID end,t="v",f=80,code=function()keyDown.mode("down")end},
		{x=190,y=160,w=100,h=80,rgb=color.white,hide=function()return levelSel==1 end,t="<",code=function()keyDown.mode("left")end},
		{x=350,y=160,w=100,h=80,rgb=color.white,hide=function()return levelSel==#modeLevel[modeID[modeSel]] end,t=">",code=function()keyDown.mode("right")end},
		{x=1000,y=600,w=250,h=100,rgb=color.green,f=50,t="Start",code=function()loadGame(modeID[modeSel],levelSel)end},
		{x=270,y=540,w=190,h=85,rgb=color.yellow,t="Custom(c)",code=function()gotoScene("custom")end},
		{x=640,y=630,w=230,h=90,rgb=color.white,f=45,t="Back",code=back},
	},
	custom={
		{x=1000,y=200,w=100,h=100,rgb=color.white,t="Λ",f=40,code=function()optSel=(optSel-2)%#customID+1 end},
		{x=1000,y=440,w=100,h=100,rgb=color.white,t="v",f=50,code=function()optSel=optSel%#customID+1 end},
		{x=880,y=320,w=100,h=100,rgb=color.white,t="<",f=50,code=function()local k=customID[optSel]customSel[k]=(customSel[k]-2)%#customRange[k]+1 end},
		{x=1120,y=320,w=100,h=100,rgb=color.white,t=">",f=50,code=function()local k=customID[optSel]customSel[k]=customSel[k]%#customRange[k]+1 end},
		{x=1000,y=580,w=180,h=80,rgb=color.green,t="Start",code=function()loadGame("custom",levelSel)end},
		{x=640,y=630,w=180,h=60,rgb=color.white,t="Back",code=back},
	},
	play={
	},
	setting={--Normal setting
		{x=285,y=90,w=210,h=60,rgb=color.white,t=function()return setting.ghost and"Ghost ON"or"Ghost OFF"end,code=function()setting.ghost=not setting.ghost end,down=3,right=2},
		{x=505,y=90,w=210,h=60,rgb=color.white,t=function()return setting.center and"Center ON"or"Center OFF"end,code=function()setting.center=not setting.center end,down=5,left=1,right=11},
		--1,2
		{x=205,y=180,w=50,h=50,rgb=color.white,t="-",code=function()setting.das=(setting.das-1)%31 end,up=1,down=7,right=4},
		{x=370,y=180,w=50,h=50,rgb=color.white,t="+",code=function()setting.das=(setting.das+1)%31 end,up=1,down=8,left=3,right=5},
		{x=420,y=180,w=50,h=50,rgb=color.white,t="-",code=function()setting.arr=(setting.arr-1)%16 end,up=2,down=9,left=4,right=6},
		{x=585,y=180,w=50,h=50,rgb=color.white,t="+",code=function()setting.arr=(setting.arr+1)%16 end,up=2,down=10,left=5,right=13},
		--3~6
		{x=205,y=260,w=50,h=50,rgb=color.white,t="-",code=function()setting.sddas=(setting.sddas-1)%11 end,up=3,down=13,right=8},
		{x=370,y=260,w=50,h=50,rgb=color.white,t="+",code=function()setting.sddas=(setting.sddas+1)%11 end,up=4,down=13,left=7,right=9},
		{x=420,y=260,w=50,h=50,rgb=color.white,t="-",code=function()setting.sdarr=(setting.sdarr-1)%4 end,up=5,down=13,left=8,right=10},
		{x=585,y=260,w=50,h=50,rgb=color.white,t="+",code=function()setting.sdarr=(setting.sdarr+1)%4 end,up=6,down=13,left=9,right=14},
		--7~10
		{x=760,y=90,w=160,h=60,rgb=color.white,t=function()return setting.sfx and"SFX:on"or"SFX:off"end,code=function()setting.sfx=not setting.sfx end,down=13,left=2,right=12},
		{x=940,y=90,w=160,h=60,rgb=color.white,t=function()return setting.bgm and"BGM:on"or"BGM:off"end,code=function()
			BGM()
			setting.bgm=not setting.bgm
			BGM("blank")
		end,down=13,left=6},
		{x=850,y=160,w=340,h=60,rgb=color.white,t=function()return "Vibrate level:"..setting.vib end,code=function()
			setting.vib=(setting.vib+1)%5
			VIB(2)
		end,up=11,down=14,left=6},
		{x=850,y=230,w=340,h=60,rgb=color.white,t=function()return setting.fullscreen and"Fullscreen:on"or"Fullscreen:off"end,
			code=function()
				setting.fullscreen=not setting.fullscreen
				love.window.setFullscreen(setting.fullscreen)
				if not setting.fullscreen then
					love.resize(gc.getWidth(),gc.getHeight())
				end
			end,
			up=13,down=15,left=6
		},
		{x=850,y=300,w=340,h=60,rgb=color.white,t=function()return setting.bgblock and"BG animation:on"or"BG animation:off"end,
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
		{x=850,y=370,w=340,h=60,rgb=color.white,t=function()return"frameDraw:"..setting.frameMul.."%"end,code=function()
			setting.frameMul=setting.frameMul+(setting.frameMul<50 and 5 or 10)
			if setting.frameMul>100 then setting.frameMul=25 end
		end,up=15,down=17},
		--11~16
		{x=850,y=440,w=340,h=60,rgb=color.green,t="Control settings",code=function()gotoScene("setting2")end,up=16,down=18},
		{x=850,y=510,w=340,h=60,rgb=color.yellow,t="Touch settings",code=function()gotoScene("setting3")end,up=17,down=19},
		{x=640,y=620,w=300,h=70,rgb=color.white,t="Save&Back",code=back,up=18},
		--17~19
	},
	setting2={--Control setting
		{x=840,y=630,w=180,h=60,rgb=color.white,t="Back",code=back},
	},
	setting3={--Touch setting
		{x=640,y=410,w=170,h=80,t="Back",code=back},
		{x=640,y=210,w=500,h=80,t=function()return setting.virtualkeySwitch and"Hide Virtual Key"or"Show Virtual Key"end,code=function()
			setting.virtualkeySwitch=not setting.virtualkeySwitch
		end},
		{x=450,y=310,w=170,h=80,t="Defaults",code=function()
			for K=1,#virtualkey do
				local b,b0=virtualkey[K],virtualkeySet[defaultSel][K]
				b[1],b[2],b[3],b[4]=b0[1],b0[2],b0[3],b0[4]
			end--Default virtualkey
			defaultSel=defaultSel%5+1
		end},
		{x=640,y=310,w=170,h=80,t=function()return snapLevelName[snapLevel]end,code=function()
			snapLevel=snapLevel%6+1
		end},
		{x=830,y=310,w=170,h=80,t=function()return percent0to5[setting.virtualkeyAlpha]end,code=function()
			setting.virtualkeyAlpha=(setting.virtualkeyAlpha+1)%6
			--Adjust virtualkey alpha
		end},
		{x=450,y=410,w=170,h=80,t="Icon",code=function()
			setting.virtualkeyIcon=not setting.virtualkeyIcon
			--Switch virtualkey icon
		end},
		{x=830,y=410,w=170,h=80,t="Size",code=function()
			if sel then
				local b=virtualkey[sel]
				b[4]=b[4]+10
				if b[4]==150 then b[4]=40 end
				b[3]=b[4]^2
			end
		end},
	},
	help={
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=back,right=2},
		{x=980,y=590,w=230,h=60,rgb=color.white,t="Author's qq",code=function()sys.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,left=1},
	},
	stat={
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=back},
	},
	sel=nil,--selected button id(integer)
}
for k,v in pairs(Buttons)do
	for i=1,#v do
		v[i].alpha=0
	end
end

virtualkey={
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
	--[[
	{x=0,y=0,r=0},--toLeft
	{x=0,y=0,r=0},--toRight
	{x=0,y=0,r=0},--toDown
	]]
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
		{1280-360,40,1600,40},--moveLeft
		{1280-280,40,1600,40},--moveRight
		{1280-520,40,1600,40},--rotRight
		{1280-600,40,1600,40},--rotLeft
		{1280-440,40,1600,40},--rotFlip
		{1280-40,40,1600,40},--hardDrop
		{1280-120,40,1600,40},--softDrop
		{1280-200,40,1600,40},--hold
		{1280-680,40,1600,40},--swap
		{-10,-10,0,0},--restart
	},--PC key feedback
}

Text={
	load={"Loading textures","Loading BGM","Loading SFX","Finished",},
	tips={
		"The whole game is made by MrZ!",
		"Back to Back 8 combo Techrash PC!",
		"Techmino has a Nspire-CX edition!",
		"Is B2B2B2B possible?",
		"MrZ spin Penta!",
	},
	stat={
		"Games run:",
		"Games played:",
		"Game time:",
		"Total block used:",
		"Total rows cleared:",
		"Total lines sent:",
		"Total key pressed:",
		"Total rotate:",
		"Total hold:",
		"Total spin:",
	},
	help={
		"I think you don't need \"help\".",
		"THIS IS ONLY A SMALL BLOCK GAME",
		"But just play like playing TOP/C2/KOS/TGM3",
		"Game is not public now,so DO NOT DISTIRBUTE",
		"",
		"Powered by LOVE2D",
		"Author:MrZ   E-mail:1046101471@qq.com",
		"Programe:MrZ  Art:MrZ  Music:MrZ  SFX:MrZ",
		"Tool used:VScode,GFIE,Beepbox,Goldwave",
		"Special thanks:farter,teatube,flyz,t830,[all test staff] and YOU!!",
		"Any bugs/suggestions to my E-mail.",
	},
}