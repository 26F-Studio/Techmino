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

	darkGrey={.3,.3,.3},
	white={1,1,1},
	orange={1,.6,0}
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

prevMenu={
	load=love.event.quit,
	ready="mode",
	play="mode",
	mode="main",
	help="main",
	stat="main",
	setting="main",
	setting2="setting",
	setting3="setting",
	intro="quit",
	main="quit",
}

modeID={"sprint","marathon","zen","solo","death","blind","tetris41","asymsolo","gmroll",}
modeName={"Sprint","Marathon","Zen","Solo","Death","Blind","Tetris 41","Asymmetry solo","GM roll",}
modeInfo={
	sprint="Clear 40 Lines",
	marathon="Clear 200 Lines",
	zen="Clear 200 Lines without gravity",
	solo="Beat AI",
	death="Survive under terrible speed",
	blind="Invisible board!",
	tetris41="Melee fight with 40 AIs",
	asymsolo="             See-->",
	gmroll="Who want to be the grand master?",
}

actName={"moveLeft","moveRight","rotRight","rotLeft","rotFlip","hardDrop","softDrop","hold","restart","toLeft","toRight","toDown"}
actName_show={"move left","move right","rotate right","rotate left","rotate flip","hard drop","soft drop","hold","restart","toLeft","toRight","toDown"}
blockPos={4,4,4,4,4,5,4}
renATK={[0]=0,0,0,1,1,2,2,3,3,4,4}--3 else
renName={nil,nil,"3 Combo","4 Combo","5 Combo","6 Combo","7 Combo","8 Combo","9 Combo","10 Combo!","11 Combo!","12 Combo!","13 Combo!","14 Combo!","15 Combo!","16 Combo!","17 Combo!","18 Combo!","19 Combo!","MEGACMB",}
b2bATK={3,5,8}

spin_n={"spin_1","spin_2","spin_3"}
clear_n={"clear_1","clear_2","clear_3","clear_4"}
ren_n={"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11"}
percent0to5={[0]="0%","20%","40%","60%","80%","100%",}

marathon_drop={[0]=60,48,40,30,24,18,15,12,10,8,7,6,5,4,3,2,1,1,0,0}
death_lock={10,9,8,7,6}
death_wait={6,5,4,3,2}
death_fall={10,8,7,6,5}

act={
	moveLeft=function(auto)
		if not auto then P.moving=-1 end
		if not ifoverlap(cb,cx-1,cy)then
			P.cx=cx-1
			freshgho()
			freshLockDelay()
			if cy==y_img then SFX("move")end
			P.spinLast=false
		end
	end,
	moveRight=function(auto)
		if not auto then P.moving=1 end
		if not ifoverlap(cb,cx+1,cy)then
			P.cx=cx+1
			freshgho()
			freshLockDelay()
			if cy==y_img then SFX("move")end
			P.spinLast=false
		end
	end,
	hardDrop=function()
		if P.waiting<=0 then
			if cy~=y_img then
				P.cy=y_img
				P.spinLast=false
				SFX("drop")
			end
			drop()
			P.keyPressing[6]=false
		end
	end,
	softDrop=function()
		if cy~=y_img then P.cy=cy-1 end
		P.downing=1
	end,
	rotRight=function()spin(1)end,
	rotLeft=function()spin(-1)end,
	rotFlip=function()spin(2)end,
	hold=function()hold()end,
	--Player movements
	restart=function()
		resetGameData()
		count=60+26--Althour'z neim
	end,
	down1=function()if cy~=y_img then P.cy=cy-1 end end,
	down4=function()for i=1,4 do if cy~=y_img then P.cy=cy-1 else break end end end,
	toDown=function()if cy~= y_img then P.cy,P.lockDelay,P.spinLast=y_img,gameEnv.lock,false end end,
	toLeft=function()while not ifoverlap(cb,cx-1,cy)do P.cx,P.lockDelay=cx-1,gameEnv.lock;freshgho()end end,
	toRight=function()while not ifoverlap(cb,cx+1,cy)do P.cx,P.lockDelay=cx+1,gameEnv.lock;freshgho()end end,
	quit=function()Event.gameover.lose()end,
	--System movements
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
		[12]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
		[21]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
		[23]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},
		[32]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
		[30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
		[03]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},
		[02]={{0,0},{1,0},{-1,0},{0,-1},{0,1}},
		[20]={{0,0},{-1,0},{1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,1},{0,-1},{-1,0},{1,0},{0,2}},
		[31]={{0,0},{0,-1},{0,1},{1,0},{-1,0},{0,2}},
	},
	[2]={
		[01]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
		[10]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
		[12]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
		[21]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
		[23]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},
		[32]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
		[30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2},{0,-1}},
		[03]={{0,0},{1,0},{1,1},{0,-2},{1,-2},{0,1}},
		[02]={{0,0},{-1,0},{1,0},{0,-1},{0,1}},
		[20]={{0,0},{1,0},{-1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,-1},{0,1},{1,0},{-1,0},{0,2}},
		[31]={{0,0},{0,1},{0,-1},{-1,0},{1,0},{0,2}},
	},
	[5]={
		[01]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
		[10]={{0,0},{1,0},{1,-1},{0,2},{1,2},{0,-1}},
		[12]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
		[21]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
		[23]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},
		[32]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
		[30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2},{0,-1}},
		[03]={{0,0},{1,0},{1,1},{0,-2},{1,-2},{0,1}},
		[02]={{0,0},{-1,0},{1,0},{0,-1},{0,1}},
		[20]={{0,0},{1,0},{-1,0},{0,1},{0,-1}},
		[13]={{0,0},{0,-1},{0,1},{1,0},{-1,0},{0,2}},
		[31]={{0,0},{0,-1},{0,1},{-1,0},{1,0},{0,2}},
	},
	[7]={
		[01]={{0,0},{-2,0},{1,0},{-2,-1},{1,2}},
		[10]={{0,0},{2,0},{-1,0},{2,1},{-1,-2}},
		[12]={{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
		[21]={{0,0},{1,0},{-2,0},{1,-2},{-2,1}},
		[23]={{0,0},{2,0},{-1,0},{2,1},{-1,-2}},
		[32]={{0,0},{-2,0},{1,0},{-2,-1},{1,2}},
		[30]={{0,0},{1,0},{-2,0},{1,-2},{-2,1}},
		[03]={{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
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
		{x=250,y=540,w=330,h=60,rgb=color.grey,t="Quit",code=function()gotoScene("quit")end,up=3},
	},
	mode={
		{x=1000,y=210,w=200,h=140,rgb=color.white,hide=function()return not setting.virtualkeySwitch end,code=function()if modeSel>1 then modeSel=modeSel-1 end end},
		{x=1000,y=430,w=200,h=140,rgb=color.white,t="v",f=80,hide=function()return not setting.virtualkeySwitch end,code=function()if modeSel<#modeID then modeSel=modeSel+1 end end},
		{x=1000,y=600,w=180,h=80,rgb=color.green,t="Start",hide=function()return not setting.virtualkeySwitch end,code=function()startGame(modeID[modeSel])end},
		{x=640,y=630,w=180,h=60,rgb=color.white,t="Back",code=function()gotoScene("main")end},
	},
	play={
	},
	setting={--Normal setting
		{x=330,y=100,w=200,h=60,rgb=color.white,t=function()return setting.ghost and"Ghost ON"or"Ghost OFF"end,code=function()setting.ghost=not setting.ghost end,down=6,right=2},
		{x=540,y=100,w=200,h=60,rgb=color.white,t=function()return setting.center and"Center ON"or"Center OFF"end,code=function()setting.center=not setting.center end,down=6,left=1,right=3},
		{x=870,y=100,w=340,h=60,rgb=color.white,t=function()return setting.sfx and"Disable SFX"or"Enable SFX"end,code=function()setting.sfx=not setting.sfx end,down=4,left=2},
		{x=870,y=180,w=340,h=60,rgb=color.white,t=function()return setting.bgm and"Disable BGM"or"Enable BGM"end,code=function()BGM()setting.bgm=not setting.bgm;BGM("blank")end,up=3,down=5,left=2},
		{x=870,y=260,w=340,h=60,rgb=color.white,t=function()return setting.fullscreen and"Disable fullscreen"or"Enable fullscreen"end,
			code=function()
				setting.fullscreen=not setting.fullscreen
				love.window.setFullscreen(setting.fullscreen)
				if not setting.fullscreen then
					love.resize(gc.getWidth(),gc.getHeight())
				end
			end,
			up=4,down=7,left=6
		},
		{x=435,y=220,w=320,h=60,rgb=color.green,t="Advanced settings",code=function()gotoScene("setting2")end,up=1,down=7,right=5},
		{x=435,y=300,w=320,h=60,rgb=color.yellow,t="Touch settings",code=function()gotoScene("setting3")end,up=6,down=8,right=5},
		{x=640,y=590,w=210,h=60,rgb=color.white,t="Save&Back",code=function()saveSetting()back()end,up=6},
	},
	setting2={--Advanced setting
		{x=290,y=70 ,w=160,h=45,rgb=color.white,t=function()return setting.key[1]end,code=function()keysetting,gamepadsetting=1 end,up=1,down=2,right=10},
		{x=290,y=130,w=160,h=45,rgb=color.white,t=function()return setting.key[2]end,code=function()keysetting,gamepadsetting=2 end,up=1,down=3,right=11},
		{x=290,y=190,w=160,h=45,rgb=color.white,t=function()return setting.key[3]end,code=function()keysetting,gamepadsetting=3 end,up=2,down=4,right=12},
		{x=290,y=250,w=160,h=45,rgb=color.white,t=function()return setting.key[4]end,code=function()keysetting,gamepadsetting=4 end,up=3,down=5,right=13},
		{x=290,y=310,w=160,h=45,rgb=color.white,t=function()return setting.key[5]end,code=function()keysetting,gamepadsetting=5 end,up=4,down=6,right=14},
		{x=290,y=370,w=160,h=45,rgb=color.white,t=function()return setting.key[6]end,code=function()keysetting,gamepadsetting=6 end,up=5,down=7,right=15},
		{x=290,y=430,w=160,h=45,rgb=color.white,t=function()return setting.key[7]end,code=function()keysetting,gamepadsetting=7 end,up=6,down=8,right=16},
		{x=290,y=490,w=160,h=45,rgb=color.white,t=function()return setting.key[8]end,code=function()keysetting,gamepadsetting=8 end,up=7,down=9,right=17},
		{x=290,y=550,w=160,h=45,rgb=color.white,t=function()return setting.key[9]end,code=function()keysetting,gamepadsetting=9 end,up=8,down=28,right=18},
		--1~9
		{x=540,y=70 ,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[1]end,code=function()gamepadsetting,keysetting=1 end,up=10,down=11,left=1,right=19},
		{x=540,y=130,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[2]end,code=function()gamepadsetting,keysetting=2 end,up=10,down=12,left=2,right=23},
		{x=540,y=190,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[3]end,code=function()gamepadsetting,keysetting=3 end,up=11,down=13,left=3,right=27},
		{x=540,y=250,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[4]end,code=function()gamepadsetting,keysetting=4 end,up=12,down=14,left=4,right=27},
		{x=540,y=310,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[5]end,code=function()gamepadsetting,keysetting=5 end,up=13,down=15,left=5,right=27},
		{x=540,y=370,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[6]end,code=function()gamepadsetting,keysetting=6 end,up=14,down=16,left=6,right=29},
		{x=540,y=430,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[7]end,code=function()gamepadsetting,keysetting=7 end,up=15,down=17,left=7,right=29},
		{x=540,y=490,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[8]end,code=function()gamepadsetting,keysetting=8 end,up=16,down=18,left=8,right=29},
		{x=540,y=550,w=230,h=45,rgb=color.white,t=function()return setting.gamepad[9]end,code=function()gamepadsetting,keysetting=9 end,up=17,down=28,left=9,right=29},
		--10~18
		{x=745,y=90,w=40,h=40,rgb=color.white,t="-",code=function()setting.das=(setting.das-1)%31 end,left=10,right=20,down=23},
		{x=910,y=90,w=40,h=40,rgb=color.white,t="+",code=function()setting.das=(setting.das+1)%31 end,left=19,right=21,down=24},
		{x=960,y=90,w=40,h=40,rgb=color.white,t="-",code=function()setting.arr=(setting.arr-1)%16 end,left=20,right=22,down=25},
		{x=1125,y=90,w=40,h=40,rgb=color.white,t="+",code=function()setting.arr=(setting.arr+1)%16 end,left=21,down=26},
		--19~22
		{x=745,y=150,w=40,h=40,rgb=color.white,t="-",code=function()setting.sddas=(setting.sddas-1)%11 end,up=19,down=27,left=10,right=24},
		{x=910,y=150,w=40,h=40,rgb=color.white,t="+",code=function()setting.sddas=(setting.sddas+1)%11 end,up=20,down=27,left=23,right=25},
		{x=960,y=150,w=40,h=40,rgb=color.white,t="-",code=function()setting.sdarr=(setting.sdarr-1)%6 end,up=21,down=27,left=24,right=26},
		{x=1125,y=150,w=40,h=40,rgb=color.white,t="+",code=function()setting.sdarr=(setting.sdarr+1)%4 end,up=22,down=27,left=25},
		--23~26
		{x=935,y=220,w=320,h=65,rgb=color.white,t=function()return "frameDraw:"..setting.frameMul.."%"end,code=function()
			setting.frameMul=setting.frameMul+(setting.frameMul<50 and 5 or 10)
			if setting.frameMul>100 then setting.frameMul=25 end
		end,up=24,down=29,left=11},
		{x=405,y=630,w=130,h=60,rgb=color.white,t="Reset",code=function()for i=1,#setting.key do setting.key[i]=gameEnv0.key[i] end end,up=9,right=29},
		{x=840,y=630,w=180,h=60,rgb=color.white,t="Back",code=function()keysetting=nil;back()end,up=24,left=28},
		--27~29
	},
	setting3={--Touch setting
		{x=640,y=210,w=400,h=80,rgb=color.white,t=function()return setting.virtualkeySwitch and"Hide Virtual Key"or"Show Virtual Key"end,code=function()
			setting.virtualkeySwitch=not setting.virtualkeySwitch
		end},
		{x=500,y=310,w=120,h=80,rgb=color.white,t="Reset",code=function()
			for K=1,#virtualkey do
				local b,b0=virtualkey[K],gameEnv0.virtualkey[K]
				b[1],b[2],b[3],b[4]=b0[1],b0[2],b0[3],b0[4]
			end--Reset virtualkey
		end},
		{x=640,y=310,w=120,h=80,rgb=color.white,t="Snap",code=function()
			for K=1,#virtualkey do
				local b=virtualkey[K]
				b[1],b[2]=int(b[1]*.025+.5)*40,int(b[2]*.025+.5)*40
			end--Snap all keys
		end},
		{x=780,y=310,w=120,h=80,rgb=color.white,t=function()return percent0to5[setting.virtualkeyAlpha]end,code=function()
			setting.virtualkeyAlpha=(setting.virtualkeyAlpha+1)%6
			--Adjust virtualkey alpha
		end},
		{x=500,y=410,w=120,h=80,rgb=color.white,t="Icon",code=function()
			setting.virtualkeyIcon=not setting.virtualkeyIcon
			--Switch virtualkey icon
		end},
		{x=640,y=410,w=120,h=80,rgb=color.white,t="Back",code=function()back()end},
		{x=780,y=410,w=120,h=80,rgb=color.white,t="Size",code=function()
			for K=1,#virtualkey do
				local b=virtualkey[K]
				b[4]=b[4]+10
				if b[4]==150 then b[4]=40 end
				b[3]=b[4]^2
			end
		end},
	},
	help={
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=function()back()end},
	},
	stat={
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=function()back()end},
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
		"THIS IS NOT TETRIS,and SRS NOT USED.",
		"But just play like playing TOP/C2/KOS/TGM3",
		"Game is not public now,so DO NOT DISTIRBUTE",
		"",
		"Powered by LOVE2D",
		"Author:MrZ   E-mail:1046101471@qq.com",
		"Programe:MrZ  Art:MrZ  Music:MrZ  SFX:MrZ",
		"Tool used:VScode,GFIE,Beepbox,Goldwave",
		"Special thanks:farter,teatube,flyz,and YOU!!",
		"Any bugs/suggestions to my E-mail.",
	},
}