local gc,sys=love.graphics,love.system
local kb=love.keyboard
local Timer=love.timer.getTime

local setFont=setFont
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
		LOG.print(text.copySuccess,color.green)
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
			LOG.print(text.pasteSuccess,color.green)
			return
		end
		LOG.print(text.dataCorrupted,color.red)
	elseif key=="escape"then
		SCN.back()
	else
		WIDGET.keyPressed(key)
	end
end

local FIELD=FIELD
function Pnt.customGame()
	--Field
	gc.push("transform")
	gc.translate(95,290)
	gc.scale(.5)
	gc.setColor(1,1,1)
	gc.setLineWidth(3)
	gc.rectangle("line",-2,-2,304,604)
	local cross=puzzleMark[-1]
	for y=1,20 do for x=1,10 do
		local B=FIELD[y][x]
		if B>0 then
			gc.draw(blockSkin[B],30*x-30,600-30*y)
		elseif B==-1 then
			gc.draw(cross,30*x-30,600-30*y)
		end
	end end
	gc.pop()

	--Sequence
	setFont(30)
	gc.print(customEnv.sequence,330,510)
	setFont(40)
	if #BAG>0 then
		gc.setColor(1,1,int(Timer()*6.26)%2)
		gc.print("#",330,545)
		gc.print(#BAG,360,545)
	end

	--Sequence
	if #MISSION>0 then
		gc.setColor(1,customEnv.missionKill and 0 or 1,int(Timer()*6.26)%2)
		gc.print("#",610,545)
		gc.print(#MISSION,640,545)
	end
end