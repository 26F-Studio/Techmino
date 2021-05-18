local gc=love.graphics
local ms,kb=love.mouse,love.keyboard

local int,max,min=math.floor,math.max,math.min

local NET=NET
local scrollPos,selected
local fetchTimer
local lastCreateRoomTime=0

--[[room={
	rid="qwe",
	roomInfo={
		name="MrZ's room",
		type="classic",
		version=1409,
	},
	private=false,
	start=false,
	count=4,
	capacity=5,
}]]
local function fetchRoom()
	fetchTimer=10
	NET.fetchRoom()
end

local scene={}

function scene.sceneInit()
	BG.set()
	NET.spectate=false
	NET.allReady=false
	NET.connectingStream=false
	NET.waitingStream=false
	scrollPos=0
	selected=1
	fetchRoom()
end

function scene.wheelMoved(_,y)
	scrollPos=max(0,min(scrollPos-y,#NET.roomList-10))
end
function scene.keyDown(k)
	if k=="r"then
		if fetchTimer<=7 then
			fetchRoom()
		end
	elseif k=="s"then
		SCN.go('setting_game')
	elseif k=="m"or k=="n"then
		if TIME()-lastCreateRoomTime>6.26 then
			local cap,roomType
			if k=="n"then
				cap,roomType=2,"solo"
			elseif kb.isDown("q")and tonumber(USER.uid)<100 then
				cap,roomType=17,"big"
			elseif kb.isDown("w")and tonumber(USER.uid)<100 then
				cap,roomType=31,"huge"
			elseif kb.isDown("e")and tonumber(USER.uid)<100 then
				cap,roomType=49,"T49"
			elseif kb.isDown("r")and tonumber(USER.uid)<100 then
				cap,roomType=99,"T99"
			else
				cap,roomType=5,"normal"
			end
			NET.createRoom(
				(USERS.getUsername(USER.uid)or"???").."'s room",
				cap,roomType
			)
			lastCreateRoomTime=TIME()
		else
			LOG.print(text.createRoomTooFast,'warn')
		end
	elseif k=="escape"then
		SCN.back()
	elseif #NET.roomList>0 then
		if k=="down"then
			if selected<#NET.roomList then
				selected=selected+1
				scrollPos=max(selected-10,min(scrollPos,selected-1))
			end
		elseif k=="up"then
			if selected>1 then
				selected=selected-1
				scrollPos=max(selected-10,min(scrollPos,selected-1))
			end
		elseif k=="return"then
			if NET.getlock('fetchRoom')or not NET.roomList[selected]then return end
			local R=NET.roomList[selected]
			if R.roomInfo.version~=VERSION.short then LOG.print("Version doesn't match",'message')return end
			if R.private then LOG.print("Can't enter private room now",'message')return end
			NET.enterRoom(R)--,password
		end
	end
end

function scene.mouseMove(x,y,_,dy)
	if ms.isDown(1)and x>50 and x<850 and y>110 and y<510 then
		scene.wheelMoved(0,dy/40)
	end
end
function scene.touchMove(x,y,_,dy)
	if x>50 and x<850 and y>110 and y<510 then
		scene.wheelMoved(0,dy/40)
	end
end
function scene.mouseClick(x,y)
	if x>50 and x<850 then
		y=int((y-70)/40)
		if y>=1 and y<=10 then
			local s=int(y+scrollPos)
			if NET.roomList[s]then
				if selected~=s then
					selected=s
					print(1)
					SFX.play('click',.4)
				else
					scene.keyDown("return")
				end
			end
		end
	end
end
scene.touchClick=scene.mouseClick

function scene.update(dt)
	if not NET.getlock('fetchRoom')then
		fetchTimer=fetchTimer-dt
		if fetchTimer<=0 then
			fetchRoom()
		end
	end
	if #NET.roomList>0 then
		selected=min(selected,#NET.roomList)
	end
end

local function roomListStencil()
	gc.rectangle('fill',50,110,1180,400)
end
function scene.draw()
	--Fetching timer
	gc.setColor(1,1,1,.12)
	gc.arc('fill','pie',300,620,60,-1.5708,-1.5708-.6283*fetchTimer)

	--Room list
	gc.setColor(1,1,1)
	gc.setLineWidth(2)
	gc.rectangle('line',50,110,800,400)
	local roomCount=#NET.roomList
	if roomCount>0 then
		if roomCount>10 then
			local len=400*10/roomCount
			gc.rectangle('fill',837,110+(400-len)*scrollPos/(roomCount-10),12,len)
		end
		gc.push('transform')
		gc.stencil(roomListStencil,'replace',1)
		gc.setStencilTest('equal',1)
		gc.translate(0,scrollPos%1*-40)
		setFont(35)
		local pos=int(scrollPos)
		for i=1,math.min(11,roomCount-pos)do
			local R=NET.roomList[pos+i]
			if pos+i==selected then
				gc.setColor(1,1,1,.3)
				gc.rectangle('fill',50,70+40*i,800,40)
			end
			gc.setColor(1,1,1)
			if R.private then gc.draw(IMG.lock,60,75+40*i)end
			gc.print(R.count.."/"..R.capacity,720,66+40*i)

			gc.setColor(.9,.9,1)
			gc.print(pos+i,95,66+40*i)

			if R.start then
				gc.setColor(0,.4,.1)
			else
				gc.setColor(1,1,.7)
			end
			gc.print(R.roomInfo.name,250,66+40*i)
		end
		gc.setStencilTest()
		gc.pop()

		gc.setColor(1,1,1)
		gc.rectangle('line',860,240,385,270)
		if NET.roomList[selected]then
			local R=NET.roomList[selected]
			setFont(25)
			gc.print(R.roomInfo.type,870,265)
			gc.setColor(1,1,.7)
			gc.printf(R.roomInfo.name,870,240,365)
			setFont(20)
			if R.start then
				gc.setColor(0,1,.2)
				gc.print(text.started,870,475)
			end
			if R.roomInfo.version~=VERSION.short then
				gc.setColor(1,.2,0)
				gc.printf(R.roomInfo.version,870,475,365,'right')
			end
		end
	end

	--Profile
	drawSelfProfile()

	--Player count
	drawOnlinePlayerCount()
end

scene.widgetList={
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=pressKey"s"},
	WIDGET.newText{name="refreshing",x=450,y=255,font=45,hideF=function()return not NET.getlock('fetchRoom')end},
	WIDGET.newText{name="noRoom",	x=450,y=260,font=40,hideF=function()return #NET.roomList>0 or NET.getlock('fetchRoom')end},
	WIDGET.newKey{name="refresh",	x=300,y=620,w=140,h=140,font=35,code=fetchRoom,hideF=function()return fetchTimer>7 end},
	WIDGET.newKey{name="new",		x=500,y=620,w=140,h=140,font=20,code=pressKey"n"},
	WIDGET.newKey{name="new2",		x=700,y=620,w=140,h=140,font=20,code=pressKey"m"},
	WIDGET.newKey{name="join",		x=900,y=620,w=140,h=140,font=40,code=pressKey"return",hideF=function()return #NET.roomList==0 or NET.getlock('enterRoom')end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene