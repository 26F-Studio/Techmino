--[["four name"
	Techrash
	Techmino
	Tequéno
	Zestris
	Quadruple
	Tequeno
	Techzino
	Tectris
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
			gc.setColor(1,0,t)
		end,
		function(t)
			gc.setColor(t,t,1)
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
}

prevMenu={
	load=love.event.quit,
	intro="quit",
	main="intro",
	mode="main",
	custom="mode",
	ready="mode",
	play=function()
		gotoScene(gamemode~="custom"and"mode"or"custom")
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

modeID={
	"sprint","marathon","zen","infinite","solo","death","tsd","blind",
	"pctrain","pcchallenge","techmino41","techmino99","gmroll","p2","p3","p4"
}
modeName={
	"Sprint","Marathon","Zen","Infinite","1v1","Death","TSD-only","Blind",
	"PC Train","PC Challenge","Techmino41","Techmino99","GM roll","2P","3P","4P"
}
modeInfo={
	sprint="Clear 40 Lines",
	marathon="Clear 200 Lines",
	zen="Clear 200 Lines without gravity",
	infinite="Infinite game,infinite happiness",
	solo="Beat AI",
	death="Survive under terrible speed",
	tsd="T-spin-double Only!",
	blind="Invisible board!",
	pctrain="Let's learn some PCs",
	pcchallenge="Make PCs in 100 Lines",
	techmino41="Melee fight with 40 AIs",
	techmino99="Melee fight with 98 AIs",
	gmroll="Who want to be the grand master?",
	p2="2 players game",
	p3="3 players game",
	p4="4 players game",
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
	sequence={"bag","his4","random"},
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
atkModeName={"Random","Badges","K.O.s","Counters"}
up0to4={[0]="000%UP","025%UP","050%UP","075%UP","100%UP",}
percent0to5={[0]="0%","20%","40%","60%","80%","100%",}
reAtk={0,0,1,1,1,2,2,3,3}
reDef={0,1,1,2,3,3,4,4,5}
marathon_drop={[0]=60,48,40,30,24,18,15,12,10,8,7,6,5,4,3,2,1,1,0,0}
death_lock={12,11,10,9,8}
death_wait={9,8,7,6,5}
death_fall={10,9,8,7,6}
pc_drop={50,45,40,35,30,26,22,18,15,12}
pc_lock={55,50,45,40,36,32,30}
pc_fall={18,16,14,12,10,9,8,7,6}
snapLevelName={"Free pos","Snap-10","Snap-20","Snap-40","Snap-60","Snap-80"}
snapLevelValue={1,10,20,40,60,80}

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
		{x=250,y=300,w=330,h=60,rgb=color.red,t="Play",code=function()gotoScene("mode")end,down=2},
		{x=250,y=380,w=330,h=60,rgb=color.blue,t="Settings",code=function()gotoScene("setting")end,up=1,down=3},
		{x=165,y=460,w=160,h=60,rgb=color.yellow,t="Help",code=function()gotoScene("help")end,up=2,down=5,right=4},
		{x=335,y=460,w=160,h=60,rgb=color.cyan,t="Statistics",code=function()gotoScene("stat")end,up=2,down=5,left=3},
		{x=250,y=540,w=330,h=60,rgb=color.grey,t="Quit",code=back,up=3},
	},
	mode={
		{x=1000,y=210,w=200,h=140,rgb=color.white,t="Λ",f=64,code=function()if modeSel>1 then modeSel=modeSel-1 end end},
		{x=1000,y=430,w=200,h=140,rgb=color.white,t="v",f=80,code=function()if modeSel<#modeID then modeSel=modeSel+1 end end},
		{x=1000,y=600,w=180,h=80,rgb=color.green,t="Start",code=function()startGame(modeID[modeSel])end},
		{x=400,y=150,w=180,h=80,rgb=color.yellow,t="Custom(c)",code=function()gotoScene("custom")end},
		{x=640,y=630,w=180,h=60,rgb=color.white,t="Back",code=back},
	},
	custom={
		{x=1000,y=200,w=100,h=100,rgb=color.white,t="Λ",f=40,code=function()optSel=(optSel-2)%#customID+1 end},
		{x=1000,y=440,w=100,h=100,rgb=color.white,t="v",f=50,code=function()optSel=optSel%#customID+1 end},
		{x=880,y=320,w=100,h=100,rgb=color.white,t="<",f=50,code=function()local k=customID[optSel]customSel[k]=(customSel[k]-2)%#customRange[k]+1 end},
		{x=1120,y=320,w=100,h=100,rgb=color.white,t=">",f=50,code=function()local k=customID[optSel]customSel[k]=customSel[k]%#customRange[k]+1 end},
		{x=1000,y=580,w=180,h=80,rgb=color.green,t="Start",code=function()startGame("custom")end},
		{x=640,y=630,w=180,h=60,rgb=color.white,t="Back",code=back},
	},
	play={
	},
	setting={--Normal setting
		{x=330,y=100,w=200,h=60,rgb=color.white,t=function()return setting.ghost and"Ghost ON"or"Ghost OFF"end,code=function()setting.ghost=not setting.ghost end,down=3,right=2},
		{x=540,y=100,w=200,h=60,rgb=color.white,t=function()return setting.center and"Center ON"or"Center OFF"end,code=function()setting.center=not setting.center end,down=5,left=1,right=11},
		--1,2
		{x=245,y=180,w=40,h=40,rgb=color.white,t="-",code=function()setting.das=(setting.das-1)%31 end,up=1,down=7,right=4},
		{x=410,y=180,w=40,h=40,rgb=color.white,t="+",code=function()setting.das=(setting.das+1)%31 end,up=1,down=8,left=3,right=5},
		{x=460,y=180,w=40,h=40,rgb=color.white,t="-",code=function()setting.arr=(setting.arr-1)%16 end,up=2,down=9,left=4,right=6},
		{x=625,y=180,w=40,h=40,rgb=color.white,t="+",code=function()setting.arr=(setting.arr+1)%16 end,up=2,down=10,left=5,right=13},
		--3~6
		{x=245,y=260,w=40,h=40,rgb=color.white,t="-",code=function()setting.sddas=(setting.sddas-1)%11 end,up=3,down=17,right=8},
		{x=410,y=260,w=40,h=40,rgb=color.white,t="+",code=function()setting.sddas=(setting.sddas+1)%11 end,up=4,down=17,left=7,right=9},
		{x=460,y=260,w=40,h=40,rgb=color.white,t="-",code=function()setting.sdarr=(setting.sdarr-1)%6 end,up=5,down=17,left=8,right=10},
		{x=625,y=260,w=40,h=40,rgb=color.white,t="+",code=function()setting.sdarr=(setting.sdarr+1)%4 end,up=6,down=17,left=9,right=14},
		--7~10
		{x=870-90,y=100,w=160,h=60,rgb=color.white,t=function()return setting.sfx and"SFX:on"or"SFX:off"end,code=function()setting.sfx=not setting.sfx end,down=13,left=2,right=12},
		{x=870+90,y=100,w=160,h=60,rgb=color.white,t=function()return setting.bgm and"BGM:on"or"BGM:off"end,code=function()BGM()setting.bgm=not setting.bgm;BGM("blank")end,down=13,left=11},
		{x=870,y=180,w=340,h=60,rgb=color.white,t=function()return setting.fullscreen and"Fullscreen:on"or"Fullscreen:off"end,
			code=function()
				setting.fullscreen=not setting.fullscreen
				love.window.setFullscreen(setting.fullscreen)
				if not setting.fullscreen then
					love.resize(gc.getWidth(),gc.getHeight())
				end
			end,
			up=11,down=14,left=6
		},
		{x=870,y=260,w=340,h=60,rgb=color.white,t=function()return setting.bgblock and"BG animation:on"or"BG animation:off"end,
			code=function()
				setting.bgblock=not setting.bgblock
				if not setting.bgblock then
					for i=1,16 do
						BGblockList[i].v=3*BGblockList[i].v
					end
				end
			end,
			up=12,down=15,left=10
		},

		--11~14
		{x=870,y=340,w=340,h=60,rgb=color.white,t=function()return"frameDraw:"..setting.frameMul.."%"end,code=function()
			setting.frameMul=setting.frameMul+(setting.frameMul<50 and 5 or 10)
			if setting.frameMul>100 then setting.frameMul=25 end
		end,up=14,down=16},
		{x=870,y=420,w=340,h=60,rgb=color.green,t="Control settings",code=function()gotoScene("setting2")end,up=15,down=17},
		{x=870,y=500,w=340,h=60,rgb=color.yellow,t="Touch settings",code=function()gotoScene("setting3")end,up=16,down=18},
		{x=640,y=640,w=210,h=60,rgb=color.white,t="Save&Back",code=back,up=17},
		--15~18
	},
	setting2={--Control setting
		{x=840,y=630,w=180,h=60,rgb=color.white,t="Back",code=back},
	},
	setting3={--Touch setting
		{x=640,y=410,w=170,h=80,t="Back",code=back},
		{x=640,y=210,w=500,h=80,t=function()return setting.virtualkeySwitch and"Hide Virtual Key"or"Show Virtual Key"end,code=function()
			setting.virtualkeySwitch=not setting.virtualkeySwitch
		end},
		{x=450,y=310,w=170,h=80,t="Reset",code=function()
			for K=1,#virtualkey do
				local b,b0=virtualkey[K],gameEnv0.virtualkey[K]
				b[1],b[2],b[3],b[4]=b0[1],b0[2],b0[3],b0[4]
			end--Reset virtualkey
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

Text={
	load={"Loading textures","Loading BGM","Loading SFX","Finished",},
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