local gc=love.graphics
local min=math.min

local NET=NET
local scrollPos,selected
local lastfreshTime
local lastCreateRoomTime=0

local function freshRoomList()
	NET.roomList=nil
	lastfreshTime=TIME()
	NET.freshRoom()
end

local scene={}

function scene.sceneInit()
	BG.set("bg1")
	scrollPos=0
	selected=1
	freshRoomList()
end

function scene.wheelMoved(_,y)
	WHEELMOV(y)
end
function scene.keyDown(k)
	if k=="r"then
		if TIME()-lastfreshTime>1 then
			freshRoomList()
		end
	elseif k=="n"then
		if TIME()-lastCreateRoomTime>26 then
			NET.createRoom()
			lastCreateRoomTime=TIME()
		else
			LOG.print(text.createRoomTooFast,"warn")
		end
	elseif k=="escape"then
		SCN.back()
	elseif NET.roomList and #NET.roomList>0 then
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
			if NET.roomList[selected].private then
				LOG.print("Can't enter private room now")
				return
			end
			NET.enterRoom(NET.roomList[selected].id)--,password
		end
	end
end

function scene.update()
	if TIME()-lastfreshTime>5 then
		freshRoomList()
	end
end

function scene.draw()
	gc.setColor(1,1,1,.26)
	gc.arc("fill","pie",240,620,60,-1.5708,-1.5708+1.2566*(TIME()-lastfreshTime))
	if NET.roomList then
		gc.setColor(1,1,1)
		if #NET.roomList>0 then
			gc.setLineWidth(2)
			gc.rectangle("line",55,110,1100,400)
			gc.setColor(1,1,1,.3)
			gc.rectangle("fill",55,40*(1+selected-scrollPos)+30,1100,40)
			setFont(35)
			for i=1,min(10,#NET.roomList-scrollPos)do
				local R=NET.roomList[scrollPos+i]
				if R.private then
					gc.setColor(1,1,1)
					gc.draw(IMG.lock,64,75+40*i)
				end
				gc.setColor(.9,.9,1)
				gc.print(scrollPos+i,100,66+40*i)
				gc.setColor(1,1,.7)
				gc.print(R.name,200,66+40*i)
				gc.setColor(1,1,1)
				gc.printf(R.type,500,66+40*i,500,"right")
				gc.print(R.count.."/"..R.capacity,1050,66+40*i)
			end
		else
			setFont(60)
			mStr(text.noRooms,640,315)
		end
	end
end

scene.widgetList={
	WIDGET.newKey{name="fresh",		x=240,y=620,w=140,h=140,font=40,code=freshRoomList,hide=function()return TIME()-lastfreshTime<1.26 end},
	WIDGET.newKey{name="new",		x=440,y=620,w=140,h=140,font=25,code=pressKey"n"},
	WIDGET.newKey{name="join",		x=640,y=620,w=140,h=140,font=40,code=pressKey"return",hide=function()return not NET.roomList end},
	WIDGET.newKey{name="up",		x=840,y=585,w=140,h=70,font=40,code=pressKey"up",hide=function()return not NET.roomList end},
	WIDGET.newKey{name="down",		x=840,y=655,w=140,h=70,font=40,code=pressKey"down",hide=function()return not NET.roomList end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene