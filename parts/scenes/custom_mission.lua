local gc,sys=love.graphics,love.system
local kb=love.keyboard
local Timer=love.timer.getTime

local setFont=setFont
local int,sin=math.floor,math.sin
local ins,rem=table.insert,table.remove
local sub=string.sub

function sceneInit.custom_mission()
	sceneTemp={
		input="",
		cur=#MISSION,
		sure=0,
	}
end

local missionEnum=missionEnum
local legalInput={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,A=true,_=true,P=true}
function keyDown.custom_mission(key)
	local S=sceneTemp
	local MISSION=MISSION
	if key=="left"then
		local p=S.cur
		if p==0 then
			S.cur=#MISSION
		else
			repeat
				p=p-1
			until MISSION[p]~=MISSION[S.cur]
			S.cur=p
		end
	elseif key=="right"then
		local p=S.cur
		if p==#MISSION then
			S.cur=0
		else
			repeat
				p=p+1
			until MISSION[p+1]~=MISSION[S.cur+1]
			S.cur=p
		end
	elseif key=="ten"then
		for _=1,10 do
			local p=S.cur
			if p==#MISSION then break end
			repeat
				p=p+1
			until MISSION[p+1]~=MISSION[S.cur+1]
			S.cur=p
		end
	elseif key=="backspace"then
		if #S.input>0 then
			S.input=""
		elseif S.cur>0 then
			rem(MISSION,S.cur)
			S.cur=S.cur-1
			if S.cur>0 and MISSION[S.cur]==MISSION[S.cur+1]then
				keyDown.custom_mission("right")
			end
		end
	elseif key=="delete"then
		if S.sure>20 then
			for _=1,#MISSION do
				rem(MISSION)
			end
			S.cur=0
			S.sure=0
			SFX.play("finesseError",.7)
		else
			S.sure=50
		end
	elseif key=="c"and kb.isDown("lctrl","rctrl")or key=="cC"then
		if #MISSION>0 then
			sys.setClipboardText("Techmino Target:"..copyMission())
			LOG.print(text.copySuccess,color.green)
		end
	elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
		local str=sys.getClipboardText()
		local p=string.find(str,":")--ptr*
		if p then str=sub(str,p+1)end
		if pasteMission(str)then
			LOG.print(text.pasteSuccess,color.green)
		else
			LOG.print(text.dataCorrupted,color.red)
		end
	elseif key=="escape"then
		SCN.back()
	elseif type(key)=="number"then
		local p=S.cur+1
		while MISSION[p]==key do p=p+1 end
		ins(MISSION,p,key)
		S.cur=p
	else
		if key=="space"then
			key="_"
		else
			key=string.upper(key)
		end

		local input=S.input
		input=input..key
		if missionEnum[input]then
			S.cur=S.cur+1
			ins(MISSION,S.cur,missionEnum[input])
			SFX.play("lock")
			input=""
		elseif #input>1 or not legalInput[input]then
			input=""
		end
		S.input=input
	end
end

function Tmr.custom_mission()
	if sceneTemp.sure>0 then sceneTemp.sure=sceneTemp.sure-1 end
end

function Pnt.custom_mission()
	local S=sceneTemp

	--Draw frame
	gc.setLineWidth(4)
	gc.setColor(1,1,1)
	gc.rectangle("line",60,110,1160,170)

	--Draw inputing target
	setFont(30)
	gc.setColor(.9,.9,.9)
	gc.print(S.input,1200,275)

	--Draw targets
	local libColor=SKIN.libColor
	local set=SETTING.skin
	local L=MISSION
	local x,y=100,136--Next block pos
	local cx,cy=100,136--Cursor-center pos
	local i,j=1,#L
	local count=1
	repeat
		if L[i]==L[i-1]then
			count=count+1
		else
			if count>1 then
				setFont(25)
				gc.setColor(1,1,1)
				gc.print("×",x-10,y-14)
				gc.print(count,x+5,y-13)
				x=x+(count<10 and 33 or 45)
				count=1
				if i==S.cur+1 then
					cx,cy=x,y
				end
			end
			if x>1140 then
				x,y=100,y+36
			end
			if i<=j then
				setFont(35)
				local N=int(L[i]*.1)
				if N>0 then
					gc.setColor(libColor[set[N]])
				elseif L[i]>4 then
					gc.setColor(color.rainbow(i+Timer()*6.26))
				else
					gc.setColor(color.grey)
				end
				gc.print(missionEnum[L[i]],x,y-25)
				x=x+56
			end
		end
		if i==S.cur then
			cx,cy=x,y
		end
		i=i+1
	until i>j+1

	--Draw cursor
	gc.setColor(1,1,.4,.6+.4*sin(Timer()*6.26))
	gc.line(cx-5,cy-20,cx-5,cy+20)

	--Confirm reset
	if S.sure>0 then
		gc.setColor(1,1,1,S.sure*.02)
		gc.draw(drawableText.question,980,570)
	end
end