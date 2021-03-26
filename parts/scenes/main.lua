local gc=love.graphics

local scene={}

local tip=gc.newText(getFont(30),"")
local scrollX

function scene.sceneInit()
	tip:set(text.getTip())
	scrollX=1000

	BG.set()

	--Create demo player
	destroyPlayers()
	GAME.modeEnv=NONE
	GAME.frame=0
	GAME.seed=math.random(2e6)
	PLY.newDemoPlayer(1)
	PLAYERS[1]:setPosition(560,50,.95)
end

function scene.keyDown(key)
	if key=="q"then
		loadGame(STAT.lastPlay,true)
	elseif key=="p"then
		SCN.go("mode")
	elseif key=="m"then
		if not LATEST_VERSION then
			TEXT.show(text.notFinished,370,380,60,"flicker")
			SFX.play("finesseError")
		elseif LOGIN then
			--[[TODO
			if USER.accessToken then
				WS.send("app",JSON.encode{
					opration="access",
					email=USER.email,
					accessToken=USER.accessToken,
				})
			else
				WS.send("app",JSON.encode{
					opration="access",
					email=USER.email,
						authToken=USER.authToken,
				})
			end
			]]
		else
			SCN.go("login")
		end
	elseif key=="escape"then
		SCN.back()
	elseif key=="application"then
		SCN.go("dict")
	elseif key=="f1"then
		SCN.go("manual")
	elseif key=="c"then
		SCN.go("customGame")
	elseif key=="s"then
		SCN.go("setting_game")
	else
		WIDGET.keyPressed(key)
	end
end

function scene.update(dt)
	GAME.frame=GAME.frame+1
	PLAYERS[1]:update(dt)
	scrollX=scrollX-2.6
	if scrollX<-tip:getWidth()then
		scrollX=1000
		tip:set(text.getTip())
	end
end

local function tipStencil()
	gc.rectangle("fill",0,0,1000,42)
end
function scene.draw()
	gc.setColor(1,1,1)

	--Title
	gc.draw(TEXTURE.title_color,20,20,nil,.43)

	--Quick play
	setFont(30)
	local L=text.modes[STAT.lastPlay]
	gc.print(L[1],365,300)
	gc.print(L[2],365,340)

	--Tip
	gc.push("transform")
		gc.translate(40,650)
		gc.setLineWidth(2)
		gc.rectangle("line",0,0,1000,42)
		gc.stencil(tipStencil,"replace",1)
		gc.setStencilTest("equal",1)
		gc.draw(tip,0+scrollX,0)
		gc.setColor(1,1,1,.2)
		gc.setStencilTest()
	gc.pop()

	--Player
	PLAYERS[1]:draw()
end

scene.widgetList={
	WIDGET.newText{name="system",	x=1245,y=40,fText=SYSTEM,		color="white",	font=30,align="R"},
	WIDGET.newText{name="version",	x=1245,y=80,fText=VERSION_NAME,	color="white",	font=30,align="R"},
	WIDGET.newButton{name="offline",x=50,y=210,w=600,h=100,			color="lRed",	font=45,align="R",	code=pressKey"p"},
	WIDGET.newButton{name="qplay",	x=50,y=330,w=600,h=100,			color="lCyan",	font=45,align="R",	code=pressKey"q"},
	WIDGET.newButton{name="online",	x=50,y=450,w=600,h=100,			color="lBlue",	font=45,align="R",	code=pressKey"m"},
	WIDGET.newButton{name="custom",	x=50,y=570,w=600,h=100,			color="white",	font=45,align="R",	code=pressKey"c"},
	WIDGET.newButton{name="setting",x=1230,y=210,w=600,h=100,		color="lYellow",font=40,align="L",	code=pressKey"s"},
	WIDGET.newButton{name="stat",	x=1230,y=330,w=600,h=100,		color="lOrange",font=40,align="L",	code=goScene"stat"},
	WIDGET.newButton{name="music",	x=1290,y=450,w=480,h=100,		color="grape",	font=30,align="L",	code=goScene"music"},
	WIDGET.newButton{name="sound",	x=1290,y=570,w=480,h=100,		color="pink",	font=30,align="L",	code=goScene"sound"},
	WIDGET.newButton{name="help",	x=950,y=450,w=170,h=100,		color="blue",	font=35,			code=goScene"help"},
	WIDGET.newButton{name="lang",	x=950,y=570,w=170,h=100,		color="lCyan",	font=40,			code=goScene"lang"},
	WIDGET.newButton{name="quit",	x=1170,y=670,w=190,h=70,		color="grey",	font=40,			code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end},
}

return scene