local gc=love.graphics

local scene={}

local tipLength=540
local tip=gc.newText(getFont(30),"")
local scrollX

local cmdEntryThread=coroutine.create(function()
	while true do
		while true do
			if YIELD()~="c"then break end
			SFX.play("ren_6")
			if YIELD()~="m"then break end
			SFX.play("ren_9")
			if YIELD()~="d"then break end
			SFX.play("ren_10")
			if YIELD()~="k"then break end
			SFX.play("ren_11")
			SCN.go("app_cmd")
		end
	end
end)
function scene.sceneInit()
	tip:set(text.getTip())
	scrollX=tipLength

	BG.set()
	coroutine.resume(cmdEntryThread)

	--Create demo player
	destroyPlayers()
	GAME.modeEnv=NONE
	GAME.frame=0
	GAME.seed=math.random(2e6)
	PLY.newDemoPlayer(1)
	PLAYERS[1]:setPosition(600,165,.75)
end

function scene.mouseDown(x,y)
	if x>=600 and x<=825 and y>=165 and y<=615 then
		coroutine.resume(cmdEntryThread,
			x<680 and y>535 and"c"or
			x>745 and y>535 and"m"or
			x<680 and y<245 and"d"
		)
	end
end
scene.touchDown=scene.mouseDown
function scene.keyDown(key)
	if key=="1"then
		SCN.go("mode")
	elseif key=="q"then
		loadGame(STAT.lastPlay,true)
	elseif key=="a"then
		if not LATEST_VERSION then
			TEXT.show(text.notFinished,640,450,60,"flicker")
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
	elseif key=="z"then
		SCN.go("customGame")
	elseif key=="-"then
		SCN.go("setting_game")
	elseif key=="p"then
		SCN.go("stat")
	elseif key=="l"then
		SCN.go("music")
	elseif key==","then
		SCN.go("help")
	elseif key=="application"then
		SCN.go("dict")
	elseif key=="ralt"then
		SCN.go("lang")
	elseif key=="f1"then
		SCN.go("manual")
	elseif key=="escape"then
		SCN.back()
	else
		coroutine.resume(cmdEntryThread,key)
	end
end

function scene.update(dt)
	GAME.frame=GAME.frame+1
	PLAYERS[1]:update(dt)
	scrollX=scrollX-2.6
	if scrollX<-tip:getWidth()then
		scrollX=tipLength
		tip:set(text.getTip())
	end
end

local function tipStencil()
	gc.rectangle("fill",0,0,tipLength,42)
end
function scene.draw()
	--Version
	setFont(30)
	gc.setColor(.6,.6,.6)
	gc.print(SYSTEM,535,40)
	gc.print(VERSION_NAME,535,80)

	--Title
	gc.setColor(1,1,1)
	gc.draw(TEXTURE.title_color,20,20,nil,.43)

	--Quick play
	local L=text.modes[STAT.lastPlay]
	gc.print(L[1],365,300)
	gc.print(L[2],365,340)

	--Tip
	gc.push("transform")
		gc.translate(40,650)
		gc.setLineWidth(2)
		gc.rectangle("line",0,0,tipLength,42)
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
	WIDGET.newButton{name="offline",x=20,y=210,w=600,h=100,		color="lR",		font=45,align="R",edge=30,	code=pressKey"1"},
	WIDGET.newButton{name="qplay",	x=50,y=330,w=600,h=100,		color="lM",		font=45,align="R",edge=30,	code=pressKey"q"},
	WIDGET.newButton{name="online",	x=80,y=450,w=600,h=100,		color="lPurple",font=45,align="R",edge=30,	code=pressKey"a"},
	WIDGET.newButton{name="custom",	x=110,y=570,w=600,h=100,	color="lSea",	font=45,align="R",edge=30,	code=pressKey"z"},

	WIDGET.newButton{name="setting",x=1170,y=210,w=600,h=100,	color="lOrange",font=40,align="L",edge=30,	code=pressKey"-"},
	WIDGET.newButton{name="stat",	x=1200,y=330,w=600,h=100,	color="lLame",	font=40,align="L",edge=30,	code=pressKey"p"},
	WIDGET.newButton{name="music",	x=1230,y=450,w=600,h=100,	color="lGreen",	font=40,align="L",edge=30,	code=pressKey"l"},
	WIDGET.newButton{name="help",	x=1260,y=570,w=600,h=100,	color="lC",		font=40,align="L",edge=30,	code=pressKey","},

	WIDGET.newButton{name="lang",	x=720,y=670,w=200,h=70,		color="Y",		font=40,					code=goScene"lang"},
	WIDGET.newButton{name="dict",	x=940,y=670,w=200,h=70,		color="orange",	font=35,					code=goScene"dict"},
	WIDGET.newButton{name="quit",	x=1160,y=670,w=200,h=70,	color="R",		font=40,					code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end},
}

return scene