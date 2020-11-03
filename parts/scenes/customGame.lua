local gc,sys=love.graphics,love.system
local kb=love.keyboard
local Timer=love.timer.getTime

local int=math.floor
local find,sub=string.find,string.sub

local customEnv=customEnv
function sceneInit.customGame()
	destroyPlayers()
	BG.set(customEnv.bg)
	BGM.play(customEnv.bgm)
end

function keyDown.customGame(key)
	if key=="return"or key=="return2"then
		if customEnv.opponent>0 then
			if customEnv.opponent>5 and customEnv.sequence=="fixed"then
				LOG.print(text.ai_fixed,"warn")
				return
			elseif customEnv.opponent>0 and #BAG>0 then
				LOG.print(text.ai_prebag,"warn")
				return
			elseif customEnv.opponent>0 and #MISSION>0 then
				LOG.print(text.ai_mission,"warn")
				return
			end
		end
		SCN.push()
		loadGame((key=="return2"or kb.isDown("lalt","lctrl","lshift"))and"custom_puzzle"or"custom_clear",true)
	elseif key=="f"then
		SCN.go("custom_field","swipeD")
	elseif key=="s"then
		SCN.go("custom_sequence","swipeD")
	elseif key=="m"then
		SCN.go("custom_mission","swipeD")
	elseif key=="a"then
		SCN.go("custom_advance","swipeD")
	elseif key=="c"and kb.isDown("lctrl","rctrl")or key=="cC"then
		local str="Techmino Quest:"..copyQuestArgs().."!"
		if #BAG>0 then str=str..copySequence()end
		str=str.."!"..copyBoard().."!"
		if #MISSION>0 then str=str..copyMission()end
		sys.setClipboardText(str.."!")
		LOG.print(text.copySuccess,COLOR.green)
	elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
		local str=sys.getClipboardText()
		local p1,p2,p3,p4,p5--ptr*
		while true do
			p1=find(str,":")or 0
			p2=find(str,"!",p1+1)
			if not p2 then break end
			p3=find(str,"!",p2+1)
			if not p3 then break end
			p4=find(str,"!",p3+1)
			if not p4 then break end
			p5=find(str,"!",p4+1)or #str+1

			pasteQuestArgs(sub(str,p1+1,p2-1))
			if p2+1~=p3 then
				if not pasteSequence(sub(str,p2+1,p3-1))then
					break
				end
			end
			if not pasteBoard(sub(str,p3+1,p4-1))then
				break
			end
			if p4+1~=p5 then
				if not pasteMission(sub(str,p4+1,p5-1))then
					break
				end
			end
			LOG.print(text.pasteSuccess,COLOR.green)
			return
		end
		LOG.print(text.dataCorrupted,COLOR.red)
	elseif key=="escape"then
		SCN.back()
	else
		WIDGET.keyPressed(key)
	end
end

function Pnt.customGame()
	--Field content
	gc.push("transform")
	gc.translate(95,290)
	gc.scale(.5)
	gc.setColor(1,1,1)
	gc.setLineWidth(3)
	gc.rectangle("line",-2,-2,304,604)
	local F=FIELD[1]
	local cross=puzzleMark[-1]
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

	--Field
	setFont(40)
	if #FIELD>1 then
		gc.setColor(1,1,int(Timer()*6.26)%2)
		gc.print("+",275,300)
		gc.print(#FIELD-1,300,300)
	end

	--Sequence
	if #BAG>0 then
		gc.setColor(1,1,int(Timer()*6.26)%2)
		gc.print("#",330,545)
		gc.print(#BAG,360,545)
	end
	setFont(30)
	gc.print(customEnv.sequence,330,510)

	--Sequence
	if #MISSION>0 then
		gc.setColor(1,customEnv.missionKill and 0 or 1,int(Timer()*6.26)%2)
		gc.print("#",610,545)
		gc.print(#MISSION,640,545)
	end
end

WIDGET.init("customGame",{
	WIDGET.newText({name="title",	x=520,	y=5,font=70,align="R"}),
	WIDGET.newText({name="subTitle",x=530,	y=50,font=35,align="L",color="grey"}),
	WIDGET.newText({name="defSeq",	x=330,	y=550,align="L",color="grey",hide=function()return BAG[1]end}),
	WIDGET.newText({name="noMsn",	x=610,	y=550,align="L",color="grey",hide=function()return MISSION[1]end}),

	--Basic
	WIDGET.newSelector({name="drop",x=170,	y=150,w=220,color="orange",	list={0,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},disp=WIDGET.lnk.CUSval("drop"),code=WIDGET.lnk.CUSsto("drop")}),
	WIDGET.newSelector({name="lock",x=170,	y=230,w=220,color="red",	list={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},			disp=WIDGET.lnk.CUSval("lock"),code=WIDGET.lnk.CUSsto("lock")}),
	WIDGET.newSelector({name="wait",x=410,	y=150,w=220,color="green",	list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},									disp=WIDGET.lnk.CUSval("wait"),code=WIDGET.lnk.CUSsto("wait")}),
	WIDGET.newSelector({name="fall",x=410,	y=230,w=220,color="yellow",	list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},									disp=WIDGET.lnk.CUSval("fall"),code=WIDGET.lnk.CUSsto("fall")}),

	--Else
	WIDGET.newSelector({name="bg",
		x=1070,	y=150,w=250,color="yellow",
		list={"none","grey","glow","rgb","flink","wing","fan","badapple","welcome","aura","bg1","bg2","rainbow","rainbow2","lightning","lightning2","matrix","space"},
		disp=WIDGET.lnk.CUSval("bg"),
		code=function(i)customEnv.bg=i BG.set(i)end
	}),
	WIDGET.newSelector({name="bgm",	x=1070,	y=230,w=250,color="yellow",	list=BGM.list,	disp=WIDGET.lnk.CUSval("bgm"),	code=function(i)customEnv.bgm=i BGM.play(i)end}),

	--Copy/Paste/Start
	WIDGET.newButton({name="copy",	x=1070,	y=310,w=310,h=70,color="lRed",	font=25,code=WIDGET.lnk.pressKey("cC")}),
	WIDGET.newButton({name="paste",	x=1070,	y=390,w=310,h=70,color="lBlue",	font=25,code=WIDGET.lnk.pressKey("cV")}),
	WIDGET.newButton({name="clear",	x=1070,	y=470,w=310,h=70,color="lYellow",font=35,code=WIDGET.lnk.pressKey("return")}),
	WIDGET.newButton({name="puzzle",x=1070,	y=550,w=310,h=70,color="lMagenta",font=35,code=WIDGET.lnk.pressKey("return2")}),

	--More
	WIDGET.newKey({name="advance",	x=730,	y=190,w=220,h=90,color="red",	font=35,code=WIDGET.lnk.goScene("custom_advance")}),
	WIDGET.newKey({name="field",	x=170,	y=640,w=240,h=80,color="water",	font=25,code=WIDGET.lnk.goScene("custom_field")}),
	WIDGET.newKey({name="sequence",	x=450,	y=640,w=240,h=80,color="pink",	font=25,code=WIDGET.lnk.goScene("custom_sequence")}),
	WIDGET.newKey({name="mission",	x=730,	y=640,w=240,h=80,color="sky",	font=25,code=WIDGET.lnk.goScene("custom_mission")}),

	WIDGET.newButton({name="back",	x=1140,	y=640,	w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})