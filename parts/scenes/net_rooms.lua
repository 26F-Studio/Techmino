local gc=love.graphics
local max,min=math.max,math.min

local rooms
local scrollPos,curPos
local lastfreshTime

local function task_fetchRooms(task)
	local time=0
	while true do
		coroutine.yield()
		local response,request_error=client.poll(task)
		if response then
			local res=json.decode(response.body)
			if res then
				if response.code==200 then
					rooms=res.rooms
					curPos=1
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
local function fresh()
	lastfreshTime=TIME()
	rooms=nil
	httpRequest(
		task_fetchRooms,
		PATH.api..PATH.access,
		"GET"
	)
end

local scene={}

function scene.sceneInit()
	BG.set("bg1")
	scrollPos=0
	curPos=0
	fresh()
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(k)
	if rooms then
		if k=="down"then
			curPos=min(curPos+1,#rooms)
		elseif k=="up"then
			curPos=max(curPos-1,1)
		elseif k=="r"then
			fresh()
		end
	end
end

function scene.update()
	if TIME()-lastfreshTime>5 then
		fresh()
	end
end

function scene.draw()
	if rooms then
		setFont(40)
		for i=scrollPos,min(scrollPos+9,#rooms)do
			local R=rooms[i+1]
			gc.setColor(.7,.7,1)
			gc.print(i,50,100+50*i)
			gc.setColor(1,1,.7)
			gc.print(R.name,130,100+50*i)
		end
		gc.print("→",20,50+50*curPos)
	end
end

scene.widgetList={
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene