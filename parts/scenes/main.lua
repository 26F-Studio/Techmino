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
	gc.print(L[1],700,210)
	gc.print(L[2],700,250)

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
	WIDGET.newText{name="system",	x=610,y=50,fText=SYSTEM,color="white",font=30,align="L"},
	WIDGET.newText{name="version",	x=610,y=90,fText=VERSION_NAME,color="white",font=30,align="L"},
	WIDGET.newButton{name="offline",x=150,y=220,w=200,h=140,color="lRed",	font=40,code=goScene"mode"},
	WIDGET.newButton{name="online",	x=370,y=220,w=200,h=140,color="lCyan",	font=40,code=function()
		if LOGIN then
			--[[TODO
			if USER.accessToken then
				WS.send("app",json.encode{
					opration="access",
					email=USER.email,
					accessToken=USER.accessToken,
				})
			else
				WS.send("app",json.encode{
					opration="access",
					email=USER.email,
						authToken=USER.authToken,
				})
			end
			]]
		else
			SCN.go("login")
		end
	end,hide=function()return not LATEST_VERSION end},
	WIDGET.newButton{name="qplay",	x=590,y=220,w=200,h=140,color="lBlue",	font=40,code=function()loadGame(STAT.lastPlay,true)end},
	WIDGET.newButton{name="setting",x=150,y=380,w=200,h=140,color="lOrange",font=40,code=goScene"setting_game"},
	WIDGET.newButton{name="stat",	x=370,y=380,w=200,h=140,color="lGreen",	font=40,code=goScene"stat"},
	WIDGET.newButton{name="custom",	x=590,y=380,w=200,h=140,color="white",	font=40,code=goScene"customGame"},
	WIDGET.newButton{name="lang",	x=150,y=515,w=200,h=90,color="lYellow",	font=40,code=goScene"lang"},
	WIDGET.newButton{name="help",	x=370,y=515,w=200,h=90,color="dGreen",	font=40,code=goScene"help"},
	WIDGET.newButton{name="quit",	x=590,y=515,w=200,h=90,color="grey",	font=40,code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end},
	WIDGET.newKey{name="music",		x=150,y=610,w=200,h=60,color="red",				code=goScene"music"},
	WIDGET.newKey{name="sound",		x=590,y=610,w=200,h=60,color="grape",			code=goScene"sound"},
}

return scene