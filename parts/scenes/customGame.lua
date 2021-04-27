local gc,sys=love.graphics,love.system
local kb=love.keyboard

local int=math.floor

local function notAir(L)
	for i=1,10 do
		if L[i]>0 then return true end
	end
end
local CUSTOMENV=CUSTOMENV

local scene={}

local initField
local function freshMiniFieldVisible()
	initField=false
	for y=1,20 do
		if notAir(FIELD[1][y])then
			initField=true
			return
		end
	end
end
function scene.sceneInit()
	destroyPlayers()
	BG.set(CUSTOMENV.bg)
	BGM.play(CUSTOMENV.bgm)
	freshMiniFieldVisible()
end
function scene.sceneBack()
	BGM.play()
end

function scene.keyDown(key)
	if key=="return"or key=="return2"then
		if CUSTOMENV.opponent~="X"then
			if CUSTOMENV.opponent:sub(1,2)=="CC"and CUSTOMENV.sequence=="fixed"then
				LOG.print(text.ai_fixed,"warn")
				return
			elseif #BAG>0 then
				LOG.print(text.ai_prebag,"warn")
				return
			elseif #MISSION>0 then
				LOG.print(text.ai_mission,"warn")
				return
			end
		end
		if key=="return2"or kb.isDown("lalt","lctrl","lshift")then
			if initField then
				FILE.save(CUSTOMENV,"conf/customEnv","q")
				loadGame("custom_puzzle",true)
			end
		else
			FILE.save(CUSTOMENV,"conf/customEnv","q")
			loadGame("custom_clear",true)
		end
	elseif key=="f"then
		SCN.go("custom_field","swipeD")
	elseif key=="s"then
		SCN.go("custom_sequence","swipeD")
	elseif key=="m"then
		SCN.go("custom_mission","swipeD")
	elseif key=="a"then
		SCN.go("custom_advance","swipeD")
	elseif key=="c"and kb.isDown("lctrl","rctrl")or key=="cC"then
		local str="Techmino Quest:"..DATA.copyQuestArgs().."!"
		if #BAG>0 then str=str..DATA.copySequence()end
		str=str.."!"
		if #MISSION>0 then str=str..DATA.copyMission()end
		sys.setClipboardText(str.."!"..DATA.copyBoards().."!")
		LOG.print(text.exportSuccess,COLOR.G)
	elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
		local str=sys.getClipboardText()
		local args=STRING.split(str:sub((str:find(":")or 0)+1),"!")
		if #args<4 then goto THROW_fail end
		if not(
			DATA.pasteQuestArgs(args[1])and
			DATA.pasteSequence(args[2])and
			DATA.pasteMission(args[3])
		)then goto THROW_fail end
		repeat table.remove(FIELD)until #FIELD==0
		FIELD[1]=DATA.newBoard()
		for i=4,#args do
			if args[i]:find"%S"and not DATA.pasteBoard(args[i],i-3)and i<#args then goto THROW_fail end
		end
		freshMiniFieldVisible()
		LOG.print(text.importSuccess,COLOR.G)
		do return end
		::THROW_fail::LOG.print(text.dataCorrupted,COLOR.R)
	elseif key=="escape"then
		FILE.save(CUSTOMENV,"conf/customEnv","q")
		SCN.back()
	else
		WIDGET.keyPressed(key)
	end
end

function scene.draw()
	--Field content
	if initField then
		gc.push("transform")
		gc.translate(95,290)
		gc.scale(.5)
		gc.setColor(1,1,1)
		gc.setLineWidth(3)
		gc.rectangle("line",-2,-2,304,604)
		local F=FIELD[1]
		local cross=TEXTURE.puzzleMark[-1]
		local texture=SKIN.curText
		for y=1,20 do for x=1,10 do
			local B=F[y][x]
			if B>0 then
				gc.draw(texture[B],30*x-30,600-30*y)
			elseif B==-1 then
				gc.draw(cross,30*x-30,600-30*y)
			end
		end end
		gc.pop()
	end

	--Field
	setFont(40)
	if initField and #FIELD>1 then
		gc.setColor(1,1,int(TIME()*6.26)%2)
		gc.print("+",275,300)
		gc.print(#FIELD-1,300,300)
	end

	--Sequence
	if #BAG>0 then
		gc.setColor(1,1,int(TIME()*6.26)%2)
		gc.print("#",330,545)
		gc.print(#BAG,360,545)
	end
	setFont(30)
	gc.setColor(1,1,1)
	gc.print(CUSTOMENV.sequence,330,510)

	--Sequence
	if #MISSION>0 then
		gc.setColor(1,CUSTOMENV.missionKill and 0 or 1,int(TIME()*6.26)%2)
		gc.print("#",610,545)
		gc.print(#MISSION,640,545)
	end
end

scene.widgetList={
	WIDGET.newText{name="title",	x=520,	y=5,font=70,align="R"},
	WIDGET.newText{name="subTitle",	x=530,	y=50,font=35,align="L",color="H"},
	WIDGET.newText{name="defSeq",	x=330,	y=550,align="L",color="H",hide=function()return BAG[1]end},
	WIDGET.newText{name="noMsn",	x=610,	y=550,align="L",color="H",hide=function()return MISSION[1]end},

	--Basic
	WIDGET.newSelector{name="drop",	x=170,	y=150,w=220,color="O",list={0,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},disp=CUSval("drop"),code=CUSsto("drop")},
	WIDGET.newSelector{name="lock",	x=170,	y=230,w=220,color="R",list={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},disp=CUSval("lock"),code=CUSsto("lock")},
	WIDGET.newSelector{name="wait",	x=410,	y=150,w=220,color="G",list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},disp=CUSval("wait"),code=CUSsto("wait")},
	WIDGET.newSelector{name="fall",	x=410,	y=230,w=220,color="Y",list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},disp=CUSval("fall"),code=CUSsto("fall")},

	--Else
	WIDGET.newSelector{name="bg",	x=1070,	y=150,w=250,color="Y",list=BG.getList(),disp=CUSval("bg"),code=function(i)CUSTOMENV.bg=i BG.set(i)end},
	WIDGET.newSelector{name="bgm",	x=1070,	y=230,w=250,color="Y",list=BGM.getList(),disp=CUSval("bgm"),code=function(i)CUSTOMENV.bgm=i BGM.play(i)end},

	--Copy/Paste/Start
	WIDGET.newButton{name="copy",	x=1070,	y=310,w=310,h=70,color="lR",font=25,code=pressKey"cC"},
	WIDGET.newButton{name="paste",	x=1070,	y=390,w=310,h=70,color="lB",font=25,code=pressKey"cV"},
	WIDGET.newButton{name="clear",	x=1070,	y=470,w=310,h=70,color="lY",font=35,code=pressKey"return"},
	WIDGET.newButton{name="puzzle",	x=1070,	y=550,w=310,h=70,color="lM",font=35,code=pressKey"return2",hide=function()return not initField end},

	--More
	WIDGET.newKey{name="advance",	x=730,	y=190,w=220,h=90,color="R",font=35,code=goScene"custom_advance"},
	WIDGET.newKey{name="mod",		x=730,	y=310,w=220,h=90,color="Z",font=35,code=goScene"mod"},
	WIDGET.newKey{name="field",		x=170,	y=640,w=240,h=80,color="A",font=25,code=goScene"custom_field"},
	WIDGET.newKey{name="sequence",	x=450,	y=640,w=240,h=80,color="W",font=25,code=goScene"custom_sequence"},
	WIDGET.newKey{name="mission",	x=730,	y=640,w=240,h=80,color="N",font=25,code=goScene"custom_mission"},

	WIDGET.newButton{name="back",	x=1140,	y=640,	w=170,h=80,font=40,code=pressKey"escape"},
}

return scene