local gc=love.graphics
local ms,kb=love.mouse,love.keyboard

local int,max,min=math.floor,math.max,math.min

local NET=NET
local scrollPos,selected
local fetchTimer
local lastCreateRoomTime=0

local function fetchRoom()
	fetchTimer=5
	NET.fetchRoom()
end

local scene={}

function scene.sceneInit()
	BG.set()
	NET.allReady=false
	NET.connectingStream=false
	scrollPos=0
	selected=1
	fetchRoom()
end

function scene.wheelMoved(_,y)
	scrollPos=max(0,min(scrollPos-y,#NET.roomList-10))
end
function scene.keyDown(k)
	if k=="r"then
		if fetchTimer<=3.26 then
			fetchRoom()
		end
	elseif k=="s"then
		SCN.go('setting_game')
	elseif k=="m"or k=="n"then
		if TIME()-lastCreateRoomTime>6.26 then
			NET.createRoom(
				k=="m"and"classic"or
				tonumber(USER.uid)<100 and(
					kb.isDown"q"and"r49"or
					kb.isDown"w"and"r99"or
					kb.isDown"e"and"unlimited"
				)or"solo",
				(USERS.getUsername(USER.uid)or"???").."'s room"
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
			if NET.roomList[selected].private then
				LOG.print("Can't enter private room now")
				return
			end
			NET.enterRoom(NET.roomList[selected])--,password
		end
	end
end

function scene.mouseMove(x,y,_,dy)
	if ms.isDown(1)and x>50 and x<1110 and y>110 and y<510 then
		scene.wheelMoved(0,dy/40)
	end
end
function scene.touchMove(x,y,_,dy)
	if x>50 and x<1110 and y>110 and y<510 then
		scene.wheelMoved(0,dy/40)
	end
end
function scene.mouseClick(x,y)
	if x>50 and x<1110 then
		y=int((y-70)/40)
		if y>=1 and y<=10 then
			local s=int(y+scrollPos)
			if NET.roomList[s]then
				if selected~=s then
					selected=s
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
	gc.arc('fill','pie',300,620,60,-1.5708,-1.5708-1.2566*fetchTimer)

	--Room list
	gc.setColor(1,1,1)
	gc.setLineWidth(2)
	gc.rectangle('line',50,110,1060,400)
	local roomCount=#NET.roomList
	if roomCount>0 then
		setFont(35)
		gc.push('transform')
		gc.stencil(roomListStencil,'replace',1)
		gc.setStencilTest('equal',1)
		gc.translate(0,scrollPos%1*-40)
		local pos=int(scrollPos)
		for i=1,math.min(11,roomCount-pos)do
			local R=NET.roomList[pos+i]
			if pos+i==selected then
				gc.setColor(1,1,1,.3)
				gc.rectangle('fill',50,70+40*i,1060,40)
			end
			if R.start then
				gc.setColor(0,1,0)
				gc.print(text.started,660,66+40*i)
			end
			gc.setColor(.9,.9,1)
			gc.print(pos+i,95,66+40*i)
			gc.setColor(1,1,.7)
			gc.print(R.name,250,66+40*i)
			gc.setColor(1,1,1)
			gc.printf(R.type,430,66+40*i,500,'right')
			gc.print(R.count.."/"..R.capacity,980,66+40*i)
			if R.private then
				gc.draw(IMG.lock,59,75+40*i)
			end
		end
		gc.setStencilTest()
		gc.pop()
		if roomCount>10 then
			local len=400*10/roomCount
			gc.rectangle('fill',1218,110+(400-len)*scrollPos/(roomCount-10),12,len)
		end
	end

	--Profile
	drawSelfProfile()

	--Player count
	drawOnlinePlayerCount()
end

scene.widgetList={
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=pressKey"s"},
	WIDGET.newText{name="refreshing",x=580,y=255,font=45,hide=function()return not NET.getlock('fetchRoom')end},
	WIDGET.newText{name="noRoom",	x=580,y=260,font=40,hide=function()return #NET.roomList>0 or NET.getlock('fetchRoom')end},
	WIDGET.newKey{name="refresh",	x=300,y=620,w=140,h=140,font=35,code=fetchRoom,hide=function()return fetchTimer>3.26 end},
	WIDGET.newKey{name="new",		x=500,y=620,w=140,h=140,font=20,code=pressKey"n"},
	WIDGET.newKey{name="new2",		x=700,y=620,w=140,h=140,font=20,code=pressKey"m"},
	WIDGET.newKey{name="join",		x=900,y=620,w=140,h=140,font=40,code=pressKey"return",hide=function()return #NET.roomList==0 or NET.getlock('enterRoom')end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene