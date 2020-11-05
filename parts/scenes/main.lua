local gc=love.graphics

function sceneInit.main()
	sceneTemp={
		tip=text.getTip(),
	}
	BG.set("space")

	modeEnv=NONE
	--Create demo player
	destroyPlayers()
	GAME.frame=0
	GAME.seed=math.random(2e6)
	PLY.newDemoPlayer(1,900,35,1.1)
end

function Tmr.main(dt)
	GAME.frame=GAME.frame+1
	PLAYERS[1]:update(dt)
end

function Pnt.main()
	gc.setColor(1,1,1)
	gc.draw(IMG.title_color,60,30,nil,1.3)
	setFont(30)
	gc.print(SYSTEM,610,50)
	gc.print(gameVersion,610,90)
	gc.print(sceneTemp.tip,50,660)
	local L=text.modes[STAT.lastPlay]
	setFont(25)
	gc.print(L[1],700,390)
	gc.print(L[2],700,420)
	PLAYERS[1]:draw()
end

WIDGET.init("main",{
	WIDGET.newButton({name="play",		x=150,y=220,w=200,h=140,color="lRed",	font=55,code=WIDGET.lnk.goScene("mode")}),
	WIDGET.newButton({name="setting",	x=370,y=220,w=200,h=140,color="sky",	font=45,code=WIDGET.lnk.goScene("setting_game")}),
	WIDGET.newButton({name="custom",	x=590,y=220,w=200,h=140,color="lPurple",font=45,code=WIDGET.lnk.goScene("customGame"),hide=function()return not RANKS.marathon_normal end}),
	WIDGET.newButton({name="help",		x=150,y=380,w=200,h=140,color="lYellow",font=50,code=WIDGET.lnk.goScene("help")}),
	WIDGET.newButton({name="stat",		x=370,y=380,w=200,h=140,color="lGreen",	font=40,code=WIDGET.lnk.goScene("stat")}),
	WIDGET.newButton({name="qplay",		x=590,y=380,w=200,h=140,color="white",	font=45,code=function()SCN.push()loadGame(STAT.lastPlay,true)end}),
	WIDGET.newButton({name="lang",		x=150,y=515,w=200,h=90,color="dYellow",	font=45,code=WIDGET.lnk.goScene("lang")}),
	WIDGET.newButton({name="music",		x=370,y=515,w=200,h=90,color="dGreen",	font=30,code=WIDGET.lnk.goScene("music")}),
	WIDGET.newButton({name="quit",		x=590,y=515,w=200,h=90,color="grey",	font=45,code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end}),
	WIDGET.newKey({name="account",		x=150,y=610,w=200,h=60,color="red",				code=function()SCN.go(LOGIN and"account"or"login")end}),
	WIDGET.newKey({name="sound",		x=370,y=610,w=200,h=60,color="green",			code=WIDGET.lnk.goScene("sound")}),
	WIDGET.newKey({name="minigame",		x=590,y=610,w=200,h=60,color="blue",			code=WIDGET.lnk.goScene("minigame")}),
})