local gc=love.graphics
local data=love.data

local textBox=WIDGET.newTextBox{name="texts",x=40,y=50,w=1200,h=430}
local remain--People in chat room
local heartBeatTimer
local escapeTimer=0

local function _init()
	coroutine.yield()
	WIDGET.sel=WIDGET.active.input
end
local function sendMessage()
	local W=WIDGET.active.input
	if #W.value>0 and wsWrite("T"..data.encode("string","base64",W.value))then
		W.value=""
	end
end

local scene={}

function scene.sceneInit()
	heartBeatTimer=0
	remain=false

	local texts=textBox.texts
	if #texts==0 then
		textBox:push{COLOR.dG,text.chatStart}
	elseif #texts>1 and texts[#texts][1]~=COLOR.dG then
		textBox:push{COLOR.dG,text.chatHistory}
	end
	textBox:scroll(1)
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
		textBox:scroll(-1)
	elseif k=="down"then
		textBox:scroll(1)
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
	local args=splitStr(mes:sub(2),";")
	if cmd=="J"or cmd=="L"then
		textBox:push{
			COLOR.lR,args[1],
			COLOR.dY,"#"..args[2].." ",
			COLOR.Y,text[cmd=="J"and"joinRoom"or"leaveRoom"]
		}
		remain=tonumber(args[3])
	elseif cmd=="T"then
		textBox:push{
			COLOR.W,args[1],
			COLOR.dY,"#"..args[2].." ",
			data.decode("string","base64",COLOR.sky,args[3])
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
	textBox,
	WIDGET.newInputBox{name="input",x=40,	y=500,w=980,h=180,font=40},
	WIDGET.newButton{name="send",	x=1140,	y=540,w=170,h=80,font=40,code=sendMessage},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene