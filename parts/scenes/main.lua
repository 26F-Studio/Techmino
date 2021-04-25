local gc=love.graphics

local scene={}

local verName=("%s  %s  %s"):format(SYSTEM,VERSION.string,VERSION.name)
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
	scene.widgetList[2]:setObject(text.WidgetText.main.qplay..": "..text.modes[STAT.lastPlay][1])

	--Create demo player
	destroyPlayers()
	GAME.modeEnv=NONE
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
			if NET.connected then
				if NET.allow_online then
					if WS.status("user")=="running"then
						NET.getAccessToken()
					else
						SCN.go("login")
					end
				else
					TEXT.show(text.needUpdate,640,450,60,"flicker")
					SFX.play("finesseError")
				end
			else
				TEXT.show(text.noInternet,640,450,60,"flicker")
				NET.wsconn_app()
				SFX.play("finesseError")
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

	--Special area
	gc.setColor(1,1,1,.8)
	gc.setLineWidth(10)
	gc.line(515,215,515,135,595,135)
	gc.line(765,215,765,135,685,135)
	gc.line(515,545,515,625,595,625)
	gc.line(765,545,765,625,685,625)

	--Profile
	drawSelfProfile()
end

scene.widgetList={
	WIDGET.newButton{name="offline",x=-1200,y=210,w=800,h=100,	color="lR",font=45,align="R",edge=30,code=pressKey"1"},
	WIDGET.newButton{name="qplay",	x=-1200,y=330,w=800,h=100,	color="lM",font=40,align="R",edge=30,code=pressKey"q"},
	WIDGET.newButton{name="online",	x=-1200,y=450,w=800,h=100,	color="lV",font=45,align="R",edge=30,code=pressKey"a"},
	WIDGET.newButton{name="custom",	x=-1200,y=570,w=800,h=100,	color="lS",font=45,align="R",edge=30,code=pressKey"z"},

	WIDGET.newButton{name="setting",x=2480,y=210,w=800,h=100,	color="lO",font=40,align="L",edge=30,code=pressKey"-"},
	WIDGET.newButton{name="stat",	x=2480,y=330,w=800,h=100,	color="lL",font=40,align="L",edge=30,code=pressKey"p"},
	WIDGET.newButton{name="dict",	x=2480,y=450,w=800,h=100,	color="lG",font=40,align="L",edge=30,code=pressKey"l"},
	WIDGET.newButton{name="manual",	x=2480,y=570,w=800,h=100,	color="lC",font=40,align="L",edge=30,code=pressKey","},

	WIDGET.newButton{name="music",	x=130,y=80,w=200,h=90,		color="lO",font=35,code=pressKey"2"},
	WIDGET.newButton{name="lang",	x=300,y=80,w=90,h=90,		color="lN",font=40,code=pressKey"0",fText=DOGC{64,64,
		{"setLW",4},
		{"dCirc",32,32,30},
		{"dLine",2,31,62,31},
		{"dLine",31,2,31,62},
		{"dArc",10,31,40,-.8,.8},
		{"dArc",53,31,40,2.3,3.9},
		}},
	WIDGET.newButton{name="about",	x=-110,y=670,w=600,h=70,	color="lB",font=35,align="R",edge=30,code=pressKey"x"},
	WIDGET.newButton{name="back",	x=1390,y=670,w=600,h=70,	color="lR",font=40,align="L",edge=30,code=backScene},
}

return scene