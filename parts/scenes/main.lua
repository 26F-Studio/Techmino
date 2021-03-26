local gc=love.graphics

local scene={}

local verName=SYSTEM.."  "..VERSION_NAME
local tipLength=540
local tip=gc.newText(getFont(30),"")
local scrollX--Tip scroll position

local cmdEntryThread=coroutine.create(function()
	while true do
		while true do
			if YIELD()~="c"then break end
			SFX.play("ren_6")
			if YIELD()~="m"then break end
			SFX.play("ren_9")
			if YIELD()~="d"then break end
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

	--Set quick-play-button text
	scene.widgetList[2].text=text.modes[STAT.lastPlay][1].."-"..text.modes[STAT.lastPlay][2]

	--Create demo player
	destroyPlayers()
	GAME.modeEnv=NONE
	GAME.frame=0
	GAME.seed=math.random(2e6)
	PLY.newDemoPlayer(1)
	PLAYERS[1]:setPosition(520,140,.8)
	love.keyboard.setKeyRepeat(false)
end
function scene.sceneBack()
	love.keyboard.setKeyRepeat(true)
end

function scene.mouseDown(x,y)
	if x>=520 and x<=760 and y>=140 and y<=620 then
		coroutine.resume(cmdEntryThread,
			x<520+80 and y>620-80 and"c"or
			x>760-80 and y>620-80 and"m"or
			x<520+80 and y<140+80 and"d"
		)
	end
end
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
	local L=scene.widgetList
	for i=1,8 do
		L[i].x=L[i].x*.9+((i<5 and 40 or 1240)-350+(WIDGET.sel==L[i]and(i<5 and 100 or -100)or 0))*.1
	end
end

local function tipStencil()
	gc.rectangle("fill",0,0,tipLength,42)
end
function scene.draw()
	--Version
	setFont(20)
	gc.setColor(.6,.6,.6)
	mStr(verName,640,110)

	--Title
	gc.setColor(1,1,1)
	mDraw(TEXTURE.title_color,640,60,nil,.43)

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
	WIDGET.newButton{name="offline",x=-1200,y=210,w=700,h=100,	color="lR",		font=45,align="R",edge=30,	code=pressKey"1"},
	WIDGET.newButton{name="qplay",	x=-1200,y=330,w=700,h=100,	color="lM",		font=40,align="R",edge=30,	code=pressKey"q"},
	WIDGET.newButton{name="online",	x=-1200,y=450,w=700,h=100,	color="lPurple",font=45,align="R",edge=30,	code=pressKey"a"},
	WIDGET.newButton{name="custom",	x=-1200,y=570,w=700,h=100,	color="lSea",	font=45,align="R",edge=30,	code=pressKey"z"},

	WIDGET.newButton{name="setting",x=2480,y=210,w=700,h=100,	color="lOrange",font=40,align="L",edge=30,	code=pressKey"-"},
	WIDGET.newButton{name="stat",	x=2480,y=330,w=700,h=100,	color="lLame",	font=40,align="L",edge=30,	code=pressKey"p"},
	WIDGET.newButton{name="music",	x=2480,y=450,w=700,h=100,	color="lGreen",	font=40,align="L",edge=30,	code=pressKey"l"},
	WIDGET.newButton{name="help",	x=2480,y=570,w=700,h=100,	color="lC",		font=40,align="L",edge=30,	code=pressKey","},

	WIDGET.newButton{name="lang",	x=720,y=680,w=200,h=100,	color="Y",		font=40,					code=goScene"lang"},
	WIDGET.newButton{name="dict",	x=940,y=680,w=200,h=100,	color="orange",	font=35,					code=goScene"dict"},
	WIDGET.newButton{name="quit",	x=1160,y=680,w=200,h=100,	color="R",		font=40,					code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end},
}

return scene