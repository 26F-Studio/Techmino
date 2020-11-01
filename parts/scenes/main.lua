local gc=love.graphics
local setFont=setFont

function sceneInit.main()
	sceneTemp={
		tip=text.getTip(),
	}
	BG.set("space")

	modeEnv={}
	--Create demo player
	destroyPlayers()
	GAME.frame=0
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