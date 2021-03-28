local gc=love.graphics
local data=love.data

local textBox=WIDGET.newTextBox{name="texts",x=40,y=50,w=1200,h=430}
local remain--People in chat room
local escapeTimer=0

local function sendMessage()
	local W=WIDGET.active.input
	if #W.value>0 then
		NET.sendChatMes(W.value)
		W.value=""
	end
end

local scene={}

function scene.sceneInit()
	remain=false

	local texts=textBox.texts
	if #texts==0 then
		textBox:push{COLOR.dG,text.chatStart}
	elseif #texts>1 and texts[#texts][1]~=COLOR.dG then
		textBox:push{COLOR.dG,text.chatHistory}
	end
	textBox:scroll(1)
	TASK.new(function()YIELD()WIDGET.sel=WIDGET.active.input end)
	BG.set("none")
end
function scene.sceneBack()
	NET.quitChat()
	LOG.print(text.wsDisconnected,"warn")
end

function scene.wheelMoved(_,y)
	WHEELMOV(y)
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
	local args=SPLITSTR(mes:sub(2),";")
	if cmd=="J"or cmd=="L"then
		textBox:push{
			COLOR.lR,args[1],
			COLOR.dY,"#"..args[2].." ",
			COLOR.Y,text[cmd=="J"and"joinRoom"or"leaveRoom"]
		}
		remain=tonumber(args[3])
	elseif cmd=="T"then
		local _,text=pcall(data.decode,"string","base64",args[3])
		if not _ then text=args[3]end
		textBox:push{
			COLOR.W,args[1],
			COLOR.dY,"#"..args[2].." ",
			COLOR.sky,text
		}
	else
		LOG.print("Illegal message: "..mes,30,COLOR.green)
		return
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