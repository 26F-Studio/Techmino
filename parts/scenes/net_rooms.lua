local gc=love.graphics
local ms=love.mouse

local int,max,min=math.floor,math.max,math.min

local NET=NET
local scrollPos,selected
local fetchTimer

local function hidePW()
	local R=NET.roomList[selected]
	return not R or not R.private
end
local passwordBox=WIDGET.newInputBox{name="password",x=350,y=505,w=500,h=50,secret=true,hideF=hidePW}

local listBoxPos={
	x=50,y=90,
	w=800,h=400,
	x2=850,y2=510,
}
local function focusPWbox()
	passwordBox.value=""
	WIDGET.focus(passwordBox)
end

--[[NET.roomList[n]={
	rid="qwerty",
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
	scrollPos=0
	selected=1
	focusPWbox()
	fetchRoom()
end

function scene.wheelMoved(_,y)
	scrollPos=max(0,min(scrollPos-y,#NET.roomList-10))
end
function scene.keyDown(key)
	if key=="r"then
		if fetchTimer<=7 then
			fetchRoom()
		end
	elseif key=="s"then
		SCN.go('setting_game')
	elseif key=="n"then
		SCN.go('net_newRoom')
	elseif key=="escape"then
		SCN.back()
	elseif #NET.roomList>0 then
		if key=="down"then
			if selected<#NET.roomList then
				selected=selected+1
				focusPWbox()
				scrollPos=max(selected-10,min(scrollPos,selected-1))
			end
		elseif key=="up"then
			if selected>1 then
				selected=selected-1
				focusPWbox()
				scrollPos=max(selected-10,min(scrollPos,selected-1))
			end
		elseif key=="return"then
			if NET.getlock('fetchRoom')or not NET.roomList[selected]then return end
			local R=NET.roomList[selected]
			if R.roomInfo.version~=VERSION.short then MES.new('error',"Version doesn't match 版本不一致")return end
			NET.enterRoom(R,passwordBox.value)
		else
			WIDGET.keyPressed(key)
		end
	else
		WIDGET.keyPressed(key)
	end
end

function scene.mouseMove(x,y,_,dy)
	if ms.isDown(1)and x>listBoxPos.x and x<listBoxPos.x2 and y>listBoxPos.y and y<listBoxPos.y2 then
		scene.wheelMoved(0,dy/40)
	end
end
function scene.touchMove(x,y,_,dy)
	if x>listBoxPos.x and x<listBoxPos.x2 and y>listBoxPos.y and y<listBoxPos.y2 then
		scene.wheelMoved(0,dy/40)
	end
end
function scene.mouseClick(x,y)
	if x>listBoxPos.x and x<listBoxPos.x2 and y>listBoxPos.y and y<listBoxPos.y2 then
		y=int((y-listBoxPos.y)/40+scrollPos)+1
		if NET.roomList[y]then
			if selected~=y then
				selected=y
				focusPWbox()
				SFX.play('click',.4)
			else
				scene.keyDown("return")
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
	gc.rectangle('fill',1,1,listBoxPos.w-2,listBoxPos.h-2)
end
function scene.draw()
	--Fetching timer
	gc.setColor(1,1,1,.12)
	gc.arc('fill','pie',250,630,40,-1.5708,-1.5708-.6283*fetchTimer)

	--Room list
	gc.push('transform')
	gc.translate(listBoxPos.x,listBoxPos.y)
	gc.setColor(1,1,1)
	gc.setLineWidth(2)
	gc.rectangle('line',0,0,listBoxPos.w,listBoxPos.h)
	local roomCount=#NET.roomList
	if roomCount>0 then
		if roomCount>10 then
			local len=10*listBoxPos.h/roomCount
			gc.rectangle('fill',-15,(listBoxPos.h-len)*scrollPos/(roomCount-10),12,len)
		end
		gc.stencil(roomListStencil,'replace',1)
		gc.setStencilTest('equal',1)
		gc.translate(0,scrollPos%1*-40)
		setFont(35)
		local pos=int(scrollPos)
		for i=1,math.min(11,roomCount-pos)do
			local R=NET.roomList[pos+i]
			if pos+i==selected then
				gc.setColor(1,1,1,.3)
				gc.rectangle('fill',0,40*i-40,listBoxPos.w,40)
			end
			gc.setColor(1,1,1)
			if R.private then gc.draw(IMG.lock,10,40*i-35)end
			gc.print(R.count.."/"..R.capacity,670,40*i-44)

			gc.setColor(.9,.9,1)
			gc.print(pos+i,45,40*i-44)

			if R.start then
				gc.setColor(0,.4,.1)
			else
				gc.setColor(1,1,.7)
			end
			gc.print(R.roomInfo.name,200,40*i-44)
		end
		gc.setStencilTest()

		gc.translate(820,130+scrollPos%1*40)
		gc.setColor(1,1,1)
		gc.rectangle('line',0,0,385,335)
		if NET.roomList[selected]then
			local R=NET.roomList[selected]
			setFont(25)
			gc.print(R.roomInfo.type,10,25)
			gc.setColor(1,1,.7)
			gc.printf(R.roomInfo.name,10,0,365)
			setFont(20)
			gc.setColor(.8,.8,.8)
			gc.printf(R.roomInfo.description or"[No description]",10,55,365)
			if R.start then
				gc.setColor(0,1,.2)
				gc.print(text.started,10,300)
			end
			if R.roomInfo.version~=VERSION.short then
				gc.setColor(1,.2,0)
				gc.printf(R.roomInfo.version,10,300,365,'right')
			end
		end
	end
	gc.pop()

	--Profile
	drawSelfProfile()

	--Player count
	drawOnlinePlayerCount()
end

scene.widgetList={
	passwordBox,
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=pressKey"s"},
	WIDGET.newText{name="refreshing",x=450,y=255,font=45,hideF=function()return not NET.getlock('fetchRoom')end},
	WIDGET.newText{name="noRoom",	x=450,y=260,font=40,hideF=function()return #NET.roomList>0 or NET.getlock('fetchRoom')end},
	WIDGET.newKey{name="refresh",	x=250,y=630,w=140,h=120,font=35,code=fetchRoom,hideF=function()return fetchTimer>7 end},
	WIDGET.newKey{name="new",		x=510,y=630,w=260,h=120,font=30,code=pressKey"n"},
	WIDGET.newKey{name="join",		x=780,y=630,w=140,h=120,font=40,code=pressKey"return",hideF=function()return #NET.roomList==0 or NET.getlock('enterRoom')end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene