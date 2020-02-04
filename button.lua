Buttons={
	load={},
	intro={},
	main={
		{x=240,y=300,w=320,h=60,rgb=color.red,t="Play",code=function()gotoScene("mode")end},
		{x=240,y=380,w=320,h=60,rgb=color.blue,t="Settings",code=function()gotoScene("setting")end},
		{x=155,y=460,w=150,h=60,rgb=color.yellow,t="Help",code=function()gotoScene("help")end},
		{x=325,y=460,w=150,h=60,rgb=color.cyan,t="Statistics",code=function()gotoScene("stat")end},
		{x=240,y=540,w=320,h=60,rgb=color.grey,t="Quit",code=function()gotoScene("quit")end},
	},
	mode={
		{x=330,y=140,w=280,h=70,rgb=color.white,t="40 Lines",code=function()startGame("sprint")end},
		{x=640,y=140,w=280,h=70,rgb=color.white,t="Zen",code=function()startGame("zen")end},
		{x=950,y=140,w=280,h=70,rgb=color.white,t="GM Roll",code=function()startGame("gmroll")end},
		{x=330,y=250,w=280,h=70,rgb=color.white,t="Marathon",code=function()startGame("marathon")end},
		{x=330,y=360,w=280,h=70,rgb=color.white,t="Death",code=function()startGame("death")end},
		{x=640,y=250,w=280,h=70,rgb=color.white,t="Tetris 25",code=function()startGame("tetris25")end},
		{x=640,y=360,w=280,h=70,rgb=color.white,t="AI Solo",code=function()startGame("solo")end},
		{x=950,y=250,w=280,h=70,rgb=color.white,t="Blind",code=function()startGame("blind")end},
		{x=950,y=360,w=280,h=70,rgb=color.white,t="Asymmetry Solo",code=function()startGame("asymsolo")end},
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=function()gotoScene("main")end},
	},
	play={
		{x=1230,y=30,w=80,h=40,rgb=color.white,t="Back",code=function()gotoScene("mode")end},
	},
	setting={
		{x=330,y=100,w=200,h=60,rgb=color.white,t=function()return setting.ghost and"Ghost ON"or"Ghost OFF"end,code=function()setting.ghost=not setting.ghost end},
		{x=540,y=100,w=200,h=60,rgb=color.white,t=function()return setting.center and"Center ON"or"Center OFF"end,code=function()setting.center=not setting.center end},
		{x=870,y=100,w=340,h=60,rgb=color.white,t=function()return setting.sfx and"Disable SFX"or"Enable SFX"end,code=function()setting.sfx=not setting.sfx end},
		{x=870,y=180,w=340,h=60,rgb=color.white,t=function()return setting.bgm and"Disable BGM"or"Enable BGM"end,code=function()BGM()setting.bgm=not setting.bgmBGM("blank")end},
		{x=870,y=260,w=340,h=60,rgb=color.white,t=function()return setting.fullscreen and"Disable fullscreen"or"Enable fullscreen"end,
			code=function()
				setting.fullscreen=not setting.fullscreen
				love.window.setFullscreen(setting.fullscreen)
			end
		},
		{x=390,y=250,w=320,h=60,rgb=color.white,t="Advanced settings",code=function()gotoScene("setting2")end},
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=function()back()end},
	},
	setting2={
		{x=850,y=90,w=40,h=40,rgb=color.white,t="-",code=function()setting.das=(setting.das-1)%31 end,hold=true},
		{x=1210,y=90,w=40,h=40,rgb=color.white,t="+",code=function()setting.das=(setting.das+1)%31 end,hold=true},
		{x=1260,y=90,w=40,h=40,rgb=color.white,t="-",code=function()setting.arr=(setting.arr-1)%16 end,hold=true},
		{x=1430,y=90,w=40,h=40,rgb=color.white,t="+",code=function()setting.arr=(setting.arr+1)%16 end,hold=true},
		{x=420,y=70,w=190,h=45,rgb=color.white,t=function()return setting.key[1]end,code=function()keysetting=1 end},
		{x=420,y=130,w=190,h=45,rgb=color.white,t=function()return setting.key[2]end,code=function()keysetting=2 end},
		{x=420,y=190,w=190,h=45,rgb=color.white,t=function()return setting.key[3]end,code=function()keysetting=3 end},
		{x=420,y=250,w=190,h=45,rgb=color.white,t=function()return setting.key[4]end,code=function()keysetting=4 end},
		{x=420,y=310,w=190,h=45,rgb=color.white,t=function()return setting.key[5]end,code=function()keysetting=5 end},
		{x=420,y=370,w=190,h=45,rgb=color.white,t=function()return setting.key[6]end,code=function()keysetting=6 end},
		{x=420,y=430,w=190,h=45,rgb=color.white,t=function()return setting.key[7]end,code=function()keysetting=7 end},
		{x=420,y=490,w=190,h=45,rgb=color.white,t=function()return setting.key[8]end,code=function()keysetting=8 end},
		{x=420,y=550,w=190,h=45,rgb=color.white,t=function()return setting.key[9]end,code=function()keysetting=9 end},
		{x=420,y=630,w=120,h=55,rgb=color.white,t="Reset",code=function()setting.key={"left","right","x","z","c","up","down","space","r","LEFT","RIGHT"}end},
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=function()keysetting=nil;back()end},
	},
	help={
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=function()back()end},
	},
	stat={
		{x=640,y=590,w=180,h=60,rgb=color.white,t="Back",code=function()back()end},
	},
	sel=nil,--selected button Obj
	pressing=0,--pressing time
}
for k,v in pairs(Buttons)do
	if type(v)=="table"then
		for i=1,#v do
			v[i].alpha=0
		end
	end
end

gamePad={
	{x=0,y=0,r=60},--moveLeft
	{x=0,y=0,r=60},--moveRight
	{x=0,y=0,r=60},--rotLeft
	{x=0,y=0,r=60},--rotRight
	{x=0,y=0,r=60},--rotFlip
	{x=0,y=0,r=60},--hardDrop
	{x=0,y=0,r=60},--softDrop
	{x=0,y=0,r=60},--hold
	{x=0,y=0,r=60},--restart
	{x=0,y=0,r=60},--toLeft
	{x=0,y=0,r=60},--toRight
	{x=0,y=0,r=60},--toDown
}
for i=1,#gamePad do
	gamePad[i].press=false
	gamePad[i].r=gamePad[i].r^2
end