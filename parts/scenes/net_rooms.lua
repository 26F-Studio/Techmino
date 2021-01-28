local gc=love.graphics
local min=math.min

local rooms
local scrollPos,selected
local lastfreshTime

local function task_fetchRooms(task)
	local time=0
	while true do
		coroutine.yield()
		local response,request_error=client.poll(task)
		if response then
			if response.code==200 then
				local res=json.decode(response.body)
				if res.message=="OK"then
					rooms=res.room_list
				else
					LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
				end
			end
			return
		elseif request_error then
			LOG.print(text.roomsFetchFailed..": "..request_error,"warn")
			return
		end
		time=time+1
		if time>210 then
			LOG.print(text.roomsFetchFailed..": "..text.httpTimeout,"warn")
			return
		end
	end
end
local function task_enterRoom(task)
	local time=0
	while true do
		coroutine.yield()
		local wsconn,connErr=client.poll(task)
		if wsconn then
			WSCONN=wsconn
			loadGame("netBattle",true,true)
			LOG.print(text.wsSuccessed,"warn")
			return
		elseif connErr then
			LOG.print(text.wsFailed..": "..connErr,"warn")
			return
		end
		time=time+1
		if time>360 then
			LOG.print(text.wsFailed..": "..text.httpTimeout,"message")
			return
		end
	end
end
local function fresh()
	lastfreshTime=TIME()
	rooms=nil
	httpRequest(
		task_fetchRooms,
		PATH.api..PATH.rooms,
		"GET",
		{["Content-Type"]="application/json"},
		json.encode{
			email=USER.email,
			access_token=USER.access_token,
		}
	)
end

local scene={}

function scene.sceneInit()
	BG.set("bg1")
	scrollPos=0
	selected=1
	fresh()
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(k)
	if k=="r"then
		if TIME()-lastfreshTime>1 then
			fresh()
		end
	elseif k=="escape"then
		SCN.back()
	elseif rooms and #rooms>0 then
		if k=="down"then
			if selected<#rooms then
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
			if rooms[selected].private then
				LOG.print("Can't enter private room now")
				return
			end
			wsConnect(
				task_enterRoom,
				PATH.socket..PATH.play_room..
				"?email="..urlEncode(USER.email)..
				"&access_token="..urlEncode(USER.access_token)..
				"&id="..urlEncode(rooms[selected].id)
				-- "&password="..urlEncode(password),
			)
		end
	end
end

function scene.update()
	if TIME()-lastfreshTime>5 then
		fresh()
	end
end

function scene.draw()
	gc.setColor(1,1,1,.26)
	gc.arc("fill","pie",440,620,60,-1.5708,-1.5708+1.2566*(TIME()-lastfreshTime))
	if rooms then
		gc.setColor(1,1,1)
		if #rooms>0 then
			gc.setLineWidth(2)
			gc.rectangle("line",55,110,1100,400)
			gc.setColor(1,1,1,.3)
			gc.rectangle("fill",55,40*(1+selected-scrollPos)+30,1100,40)
			setFont(35)
			for i=1,min(10,#rooms-scrollPos)do
				local R=rooms[scrollPos+i]
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
	WIDGET.newKey{name="fresh",		x=440,y=620,w=140,h=140,font=40,code=fresh,hide=function()return TIME()-lastfreshTime<1.26 end},
	WIDGET.newKey{name="join",		x=640,y=620,w=140,h=140,font=40,code=pressKey"return",hide=function()return not rooms end},
	WIDGET.newKey{name="up",		x=840,y=585,w=140,h=70,font=40,code=pressKey"up",hide=function()return not rooms end},
	WIDGET.newKey{name="down",		x=840,y=655,w=140,h=70,font=40,code=pressKey"down",hide=function()return not rooms end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene