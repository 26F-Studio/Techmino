Buttons={
	load={},
	intro={},
	main={
		{x=500,y=300,w=320,h=60,rgb={1,0,0},alpha=0,t="Play",code=function()gotoScene("mode")end},
		{x=500,y=380,w=320,h=60,rgb={0,0,1},alpha=0,t="Settings",code=function()gotoScene("setting")end},
		{x=415,y=460,w=150,h=60,rgb={1,1,0},alpha=0,t="Help",code=function()gotoScene("help")end},
		{x=585,y=460,w=150,h=60,rgb={0,1,1},alpha=0,t="Statistics",code=function()gotoScene("stat")end},
		{x=500,y=540,w=320,h=60,rgb={.5,.5,.5},alpha=0,t="Quit",code=function()gotoScene("quit")end},
	},
	mode={
		{x=350,y=200,w=220,h=70,rgb={1,1,1},alpha=0,t="Marathon",code=function()startGame("marathon")end},
		{x=350,y=300,w=220,h=70,rgb={1,1,1},alpha=0,t="40 Lines",code=function()startGame("sprint")end},
		{x=650,y=200,w=220,h=70,rgb={1,1,1},alpha=0,t="Zen",code=function()startGame("zen")end},
		{x=650,y=300,w=220,h=70,rgb={1,1,1},alpha=0,t="Battle",code=function()startGame("battle")end},
		{x=500,y=520,w=350,h=80,rgb={1,1,1},alpha=0,t="Back",code=function()gotoScene("main")end},
	},
	play={
		{x=950,y=30,w=80,h=40,rgb={1,1,1},alpha=0,t="Back",code=function()gotoScene("mode")end},
	},
	setting={
		{x=120,y=80,w=30,h=30,rgb={1,1,1},alpha=0,t="-",code=function()setting.das=(setting.das-1)%41 end,hold=true},
		{x=280,y=80,w=30,h=30,rgb={1,1,1},alpha=0,t="+",code=function()setting.das=(setting.das+1)%41 end,hold=true},
		{x=320,y=80,w=30,h=30,rgb={1,1,1},alpha=0,t="-",code=function()setting.arr=(setting.arr-1)%21 end,hold=true},
		{x=480,y=80,w=30,h=30,rgb={1,1,1},alpha=0,t="+",code=function()setting.arr=(setting.arr+1)%21 end,hold=true},
		{x=200,y=200,w=190,h=40,rgb={1,1,1},alpha=0,t=function()return setting.ghost and"Ghost ON"or"Ghost OFF"end,code=function()setting.ghost=not setting.ghost end},
		{x=400,y=200,w=190,h=40,rgb={1,1,1},alpha=0,t=function()return setting.center and"Center ON"or"Center OFF"end,code=function()setting.center=not setting.center end},
		
		
		{x=700,y=80,w=280,h=50,rgb={1,1,1},alpha=0,t=function()return setting.sfx and"Disable SFX"or"Enable SFX"end,code=function()setting.sfx=not setting.sfx end},
		{x=700,y=150,w=280,h=50,rgb={1,1,1},alpha=0,t=function()return setting.bgm and"Disable BGM"or"Enable BGM"end,
			code=function()
				setting.bgm=not setting.bgm
				if setting.bgm then BGM("blank")else BGM()end
			end
		},
		{x=700,y=220,w=280,h=50,rgb={1,1,1},alpha=0,t=function()return setting.fullscreen and"Disable fullscreen"or"Enable fullscreen"end,
			code=function()
				setting.fullscreen=not setting.fullscreen
				love.window.setFullscreen(setting.fullscreen)
			end
		},
		
		{x=300,y=400,w=230,h=50,rgb={1,1,1},alpha=0,t="More settings",code=function()gotoScene("setting2")end},
		{x=500,y=500,w=100,h=50,rgb={1,1,1},alpha=0,t="Back",code=function()back()end},
	},
	setting2={
		{x=350,y=70,w=210,h=43,rgb={1,1,1},alpha=0,t=function()return setting.key[1]end,code=function()keysetting=1 end},
		{x=350,y=120,w=210,h=43,rgb={1,1,1},alpha=0,t=function()return setting.key[2]end,code=function()keysetting=2 end},
		{x=350,y=170,w=210,h=43,rgb={1,1,1},alpha=0,t=function()return setting.key[3]end,code=function()keysetting=3 end},
		{x=350,y=220,w=210,h=43,rgb={1,1,1},alpha=0,t=function()return setting.key[4]end,code=function()keysetting=4 end},
		{x=350,y=270,w=210,h=43,rgb={1,1,1},alpha=0,t=function()return setting.key[5]end,code=function()keysetting=5 end},
		{x=350,y=320,w=210,h=43,rgb={1,1,1},alpha=0,t=function()return setting.key[6]end,code=function()keysetting=6 end},
		{x=350,y=370,w=210,h=43,rgb={1,1,1},alpha=0,t=function()return setting.key[7]end,code=function()keysetting=7 end},
		{x=350,y=420,w=210,h=43,rgb={1,1,1},alpha=0,t=function()return setting.key[8]end,code=function()keysetting=8 end},
		{x=320,y=500,w=130,h=43,rgb={1,1,1},alpha=0,t="Reset",code=function()setting.key={"left","right","x","z","c","up","down","space","LEFT","RIGHT"}end},
		{x=500,y=500,w=100,h=50,rgb={1,1,1},alpha=0,t="Back",code=function()back()end},
	},
	help={
		{x=500,y=500,w=200,h=60,rgb={1,1,1},alpha=0,t="Back",code=function()back()end},
	},
	stat={
		{x=500,y=500,w=200,h=60,rgb={1,1,1},alpha=0,t="Back",code=function()back()end},
	},
	sel=nil,--selected button Obj
	pressing=0,--pressing time
}