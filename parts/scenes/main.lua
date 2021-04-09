local gc=love.graphics

local scene={}

local verName=SYSTEM.."  "..VERSION_NAME
local tipLength=760
local tip=gc.newText(getFont(30),"")
local scrollX--Tip scroll position

local widgetX0={
	-10,-10,-10,-10,
	1290,1290,1290,1290,
}

local cmdEntryThread=coroutine.wrap(function()
	while true do
		if
			YIELD()=="c"and(SFX.play("ren_6")or 1)and
			YIELD()=="m"and(SFX.play("ren_9")or 1)and
			YIELD()=="d"and(SFX.play("ren_11")or 1)
		then
			SCN.go("app_cmd")
		end
	end
end)
function scene.sceneInit()
	tip:set(text.getTip())
	scrollX=tipLength

	BG.set()
	cmdEntryThread()

	--Set quick-play-button text
	scene.widgetList[2].text=text.WidgetText.main.qplay..": "..text.modes[STAT.lastPlay][1]
	quickSure=false

	--Create demo player
	destroyPlayers()
	GAME.modeEnv=NONE
	GAME.frame=0
	GAME.seed=math.random(2e6)
	PLY.newDemoPlayer(1)
	PLAYERS[1]:setPosition(520,140,.8)
end

function scene.mouseDown(x,y)
	if x>=520 and x<=760 and y>=140 and y<=620 then
		cmdEntryThread(
			x<520+80 and y>620-80 and"c"or
			x>760-80 and y>620-80 and"m"or
			x<520+80 and y<140+80 and"d"
		)
	end
end
scene.touchDown=scene.mouseDown
local function testButton(n)
	if WIDGET.sel==scene.widgetList[n]then
		return true
	else
		WIDGET.sel=scene.widgetList[n]
	end
end
function scene.keyDown(key)
	if key=="1"then
		if testButton(1)then
			SCN.go("mode")
		end
	elseif key=="q"then
		if testButton(2)then
			loadGame(STAT.lastPlay,true)
		end
	elseif key=="a"then
		if testButton(3)then
			if WS.status("user")=="running"then
				if not NET.allow_online then
					TEXT.show(text.needUpdate,640,450,60,"flicker")
					SFX.play("finesseError")
				else
					NET.getAccessToken()
				end
			else
				SCN.go("login")
			end
		end
	elseif key=="z"then
		if testButton(4)then
			SCN.go("customGame")
		end
	elseif key=="-"then
		if testButton(5)then
			SCN.go("setting_game")
		end
	elseif key=="p"then
		if testButton(6)then
			SCN.go("stat")
		end
	elseif key=="l"then
		if testButton(7)then
			SCN.go("dict")
		end
	elseif key==","then
		if testButton(8)then
			SCN.go("manual")
		end
	elseif key=="2"then
		if testButton(9)then
			SCN.go("music")
		end
	elseif key=="0"then
		if testButton(10)then
			SCN.go("lang")
		end
	elseif key=="x"then
		if testButton(11)then
			SCN.go("about")
		end
	elseif key=="escape"then
		if testButton(12)then
			SCN.back()
		end
	else
		cmdEntryThread(key)
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
		L[i].x=L[i].x*.9+(widgetX0[i]-400+(WIDGET.sel==L[i]and(i<5 and 100 or -100)or 0))*.1
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
		gc.translate(260,650)
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
	WIDGET.newButton{name="offline",x=-1200,y=210,w=800,h=100,	color="lR",		font=45,align="R",edge=30,	code=pressKey"1"},
	WIDGET.newButton{name="qplay",	x=-1200,y=330,w=800,h=100,	color="lM",		font=40,align="R",edge=30,	code=pressKey"q"},
	WIDGET.newButton{name="online",	x=-1200,y=450,w=800,h=100,	color="lPurple",font=45,align="R",edge=30,	code=pressKey"a"},
	WIDGET.newButton{name="custom",	x=-1200,y=570,w=800,h=100,	color="lSea",	font=45,align="R",edge=30,	code=pressKey"z"},

	WIDGET.newButton{name="setting",x=2480,y=210,w=800,h=100,	color="lOrange",font=40,align="L",edge=30,	code=pressKey"-"},
	WIDGET.newButton{name="stat",	x=2480,y=330,w=800,h=100,	color="lLame",	font=40,align="L",edge=30,	code=pressKey"p"},
	WIDGET.newButton{name="dict",	x=2480,y=450,w=800,h=100,	color="lGreen",	font=40,align="L",edge=30,	code=pressKey"l"},
	WIDGET.newButton{name="manual",	x=2480,y=570,w=800,h=100,	color="lC",		font=40,align="L",edge=30,	code=pressKey","},

	WIDGET.newButton{name="music",	x=160,y=80,w=200,h=90,		color="lOrange",font=35,					code=pressKey"2"},
	WIDGET.newButton{name="lang",	x=1120,y=80,w=200,h=90,		color="lY",		font=40,					code=pressKey"0"},
	WIDGET.newButton{name="about",	x=-110,y=670,w=600,h=70,	color="lB",		font=35,align="R",edge=30,	code=pressKey"x"},
	WIDGET.newButton{name="quit",	x=1390,y=670,w=600,h=70,	color="lR",		font=40,align="L",edge=30,	code=function()VOC.play("bye")SCN.swapTo("quit","slowFade")end},
}

return scene