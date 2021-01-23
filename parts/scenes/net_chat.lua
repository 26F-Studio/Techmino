local gc=love.graphics

local chatBox=WIDGET.newChatBox{name="texts",x=50,y=50,w=1200,h=430}
local remain--People in chat room
local heartBeatTimer
local escapeTimer=0

local function _init()
	coroutine.yield()
	WIDGET.sel=WIDGET.active.text
	local texts=chatBox.texts
	if #texts==0 then
		chatBox:push{COLOR.dG,text.chatStart}
	elseif #texts>1 and texts[#texts][1]~=COLOR.dG then
		chatBox:push{COLOR.dG,text.chatHistory}
	end
	chatBox:scroll(1)
end
local function sendMessage()
	local W=WIDGET.active.text
	if #W.value>0 and wsWrite("T"..W.value)then
		W.value=""
	end
end

local scene={}

function scene.sceneInit()
	heartBeatTimer=0
	remain=false

	TASK.new(_init)--Widgets are not initialized, so active after 1 frame
	TASK.new(TICK_wsRead)
	BG.set("none")
end
function scene.sceneBack()
	wsWrite("Q")
	WSCONN=false
	LOG.print(text.wsDisconnected,"warn")
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(k)
	if k=="up"then
		chatBox:scroll(-1)
	elseif k=="down"then
		chatBox:scroll(1)
	elseif k=="return"then
		sendMessage()
	elseif k=="escape"then
		if TIME()-escapeTimer<.6 then
			SCN.back()
		else
			escapeTimer=TIME()
			LOG.print(text.sureQuit,COLOR.orange)
		end
	else
		WIDGET.keyPressed(k)
	end
end

function scene.socketRead(mes)
	local cmd=mes:sub(1,1)
	local args=splitStr(mes:sub(2),":")
	if cmd=="J"or cmd=="L"then
		chatBox:push{
			COLOR.lR,args[1],
			COLOR.dY,args[2].." ",
			COLOR.Y,text[cmd=="J"and"chatJoin"or"chatLeave"]
		}
		remain=tonumber(args[3])
	elseif cmd=="T"then
		chatBox:push{
			COLOR.W,args[1],
			COLOR.dY,args[2].." ",
			COLOR.sky,args[3]
		}
	else
		LOG.print("Illegal message: "..mes,30,COLOR.green)
		return
	end
end

function scene.update(dt)
	heartBeatTimer=heartBeatTimer+dt
	if heartBeatTimer>42 then
		heartBeatTimer=0
		wsWrite("P")
	end
end
function scene.draw()
	setFont(25)
	gc.setColor(1,1,1)
	gc.printf(text.chatRemain,800,10,400,"right")
	gc.print(remain or"?",1205,10)
end

scene.widgetList={
	chatBox,
	WIDGET.newButton{name="send",	x=1140,	y=540,w=170,h=80,font=40,code=sendMessage},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene