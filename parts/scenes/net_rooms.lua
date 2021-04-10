local gc=love.graphics
local kb=love.keyboard

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
	BG.set("space")
	scrollPos=0
	selected=1
	fetchRoom()
end

function scene.wheelMoved(_,y)
	WHEELMOV(y)
end
function scene.keyDown(k)
	if k=="r"then
		if fetchTimer<=3.26 then
			fetchRoom()
		end
	elseif k=="n"then
		if TIME()-lastCreateRoomTime>16.2 then
			NET.createRoom(
				kb.isDown("1")and"solo"or
				kb.isDown("2")and"classic"or
				tonumber(USER.uid)<100 and(
					kb.isDown("3")and"r49"or
					kb.isDown("4")and"r99"or
					kb.isDown("5")and"unlimited"
				)or"solo",
				(USER.username or"???").."'s room"
			)
			lastCreateRoomTime=TIME()
		else
			LOG.print(text.createRoomTooFast,"warn")
		end
	elseif k=="escape"then
		SCN.back()
	elseif #NET.roomList>0 then
		if k=="down"then
			if selected<#NET.roomList then
				selected=selected+1
				if selected>scrollPos+10 then
					scrollPos=scrollPos+1
				end
			end
		elseif k=="up"then
			if selected>1 then
				selected=selected-1
				if selected<scrollPos+1 then
					scrollPos=scrollPos-1
				end
			end
		elseif k=="return"then
			if NET.getlock("fetchRoom")or not NET.roomList[selected]then return end
			if NET.roomList[selected].private then
				LOG.print("Can't enter private room now")
				return
			end
			if NET.roomList[selected].start then
				LOG.print("Can't enter room after start")
			end
			NET.enterRoom(NET.roomList[selected].rid)--,password
		end
	end
end

function scene.update(dt)
	if not NET.getlock("fetchRoom")then
		fetchTimer=fetchTimer-dt
		if fetchTimer<=0 then
			fetchRoom()
		end
	end
	if #NET.roomList>0 and not NET.roomList[selected]then
		selected=#NET.roomList
	end
end

function scene.draw()
	--Fetching timer
	gc.setColor(1,1,1,.26)
	gc.arc("fill","pie",240,620,60,-1.5708,-1.5708-1.2566*fetchTimer)

	--Room list
	gc.setColor(1,1,1)
	gc.setLineWidth(2)
	gc.rectangle("line",50,110,1180,400)
	if #NET.roomList>0 then
		gc.setColor(1,1,1,.3)
		gc.rectangle("fill",50,40*(1+selected-scrollPos)+30,1180,40)
		setFont(35)
		for i=1,math.min(10,#NET.roomList-scrollPos)do
			local R=NET.roomList[scrollPos+i]
			if R.private then
				gc.setColor(1,1,1)
				gc.draw(IMG.lock,59,75+40*i)
			end
			if R.start then
				gc.setColor(0,1,0)
				gc.print("S",800,66+40*i)
			end
			gc.setColor(.9,.9,1)
			gc.print(scrollPos+i,95,66+40*i)
			gc.setColor(1,1,.7)
			gc.print(R.name,250,66+40*i)
			gc.setColor(1,1,1)
			gc.printf(R.type,550,66+40*i,500,"right")
			gc.print(R.count.."/"..R.capacity,1100,66+40*i)
		end
	end
end

local function hide_noRoom()return #NET.roomList==0 end
scene.widgetList={
	WIDGET.newText{name="refreshing",x=640,y=255,font=45,hide=function()return not NET.getlock("fetchRoom")end},
	WIDGET.newText{name="noRoom",	x=640,y=260,font=40,hide=function()return #NET.roomList>0 or NET.getlock("fetchRoom")end},
	WIDGET.newKey{name="refresh",	x=240,y=620,w=140,h=140,font=35,code=fetchRoom,			hide=function()return fetchTimer>3.26 end},
	WIDGET.newKey{name="new",		x=440,y=620,w=140,h=140,font=25,code=pressKey"n"},
	WIDGET.newKey{name="join",		x=640,y=620,w=140,h=140,font=40,code=pressKey"return",	hide=hide_noRoom},
	WIDGET.newKey{name="up",		x=840,y=585,w=140,h=70,font=40,code=pressKey"up",		hide=hide_noRoom},
	WIDGET.newKey{name="down",		x=840,y=655,w=140,h=70,font=40,code=pressKey"down",		hide=hide_noRoom},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene