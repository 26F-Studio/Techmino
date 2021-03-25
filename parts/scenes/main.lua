local gc=love.graphics

local scene={}

local tip=gc.newText(getFont(30),"")
local scrollX

function scene.sceneInit()
	tip:set(text.getTip())
	scrollX=640

	BG.set()

	--Create demo player
	destroyPlayers()
	GAME.modeEnv=NONE
	GAME.frame=0
	GAME.seed=math.random(2e6)
	PLY.newDemoPlayer(1)
	PLAYERS[1]:setPosition(900,30,1.1)
end

function scene.keyDown(key)
	if key=="q"then
		loadGame(STAT.lastPlay,true)
	elseif key=="p"then
		SCN.go("mode")
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
	if GAME.frame>=36000 and GAME.frame%300==0 then
		PLAYERS[1]:movePosition(math.random(800,1000),math.random(50,310),.6)
	end
	scrollX=scrollX-1.626
	if scrollX<-tip:getWidth()then
		scrollX=640
		tip:set(text.getTip())
	end
end

local function tipStencil()
	gc.rectangle("fill",0,0,640,42)
end
function scene.draw()
	gc.setColor(1,1,1)

	--Title
	gc.draw(TEXTURE.title_color,20,20,nil,.5)

	--Quick play
	setFont(30)
	local L=text.modes[STAT.lastPlay]
	gc.print(L[1],700,250)
	gc.print(L[2],700,290)

	--Tip
	gc.push("transform")
		gc.translate(50,660)
		gc.setLineWidth(2)
		gc.rectangle("line",0,0,640,42)
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
	WIDGET.newText{name="system",	x=610,y=50,fText=SYSTEM,		color="white",font=30,align="L"},
	WIDGET.newText{name="version",	x=610,y=90,fText=VERSION_NAME,	color="white",font=30,align="L"},
	WIDGET.newKey{name="offline",	x=150,y=260,w=200,h=160,color="lRed",	font=40,code=pressKey"p"},
	WIDGET.newKey{name="online",	x=370,y=260,w=200,h=160,color="lCyan",	font=40,code=function()
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
	end},
	WIDGET.newKey{name="qplay",		x=590,y=260,w=200,h=160,color="lBlue",	font=40,code=pressKey"q"},
	WIDGET.newKey{name="custom",	x=370,y=440,w=200,h=160,color="white",	font=40,code=pressKey"c"},
	WIDGET.newKey{name="setting",	x=150,y=490,w=200,h=110,color="lOrange",font=40,code=pressKey"s"},
	WIDGET.newKey{name="stat",		x=590,y=490,w=200,h=110,color="lGreen",	font=40,code=goScene"stat"},
	WIDGET.newKey{name="music",		x=150,y=600,w=200,h=60,color="red",				code=goScene"music"},
	WIDGET.newKey{name="sound",		x=370,y=600,w=200,h=60,color="grape",			code=goScene"sound"},
	WIDGET.newKey{name="help",		x=590,y=600,w=200,h=60,color="blue",			code=goScene"help"},
	WIDGET.newButton{name="lang",	x=795,y=560,w=170,h=80,color="white",	font=40,code=goScene"lang"},
	WIDGET.newButton{name="quit",	x=795,y=660,w=170,h=80,color="dGrey",	font=40,code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end},
}

return scene