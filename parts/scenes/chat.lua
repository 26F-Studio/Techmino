local gc=love.graphics
local Timer=love.timer.getTime

local ins=table.insert
local max,min=math.max,math.min

local texts={}
local remain--People in chat room
local scroll--Bottom message no.
local newMessasge=false--If there is a new message
local heartBeatTimer

local function sendMessage()
	local W=WIDGET.active.text
	if #W.value>0 and wsWrite(W.value)then
		W.value=""
	end
end
local function clearHistory()
	if #texts>0 then
		texts={}
		scroll=0
		SFX.play("fall")
		collectgarbage()
	end
end

local scene={}

function scene.sceneInit()
	heartBeatTimer=0
	remain=nil

	scroll=#texts
	if scroll>0 then
		if texts[scroll][1]~=COLOR.green then
			ins(texts,{COLOR.green,text.chatHistory})
			scroll=scroll+1
		end
	end
	WIDGET.sel=WIDGET.active.text
	BG.set("none")
	wsConnect(
		TICK.wsCONN_connect,
		PATH.socket..PATH.chat.."?email="..urlEncode(ACCOUNT.email).."&access_token="..urlEncode(ACCOUNT.access_token)
	)
end
function scene.sceneBack()
	wsWrite("/quit")
	WSCONN=nil
	LOG.print(text.wsDisconnected,"warn")
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(k)
	if k=="up"then
		scroll=max(scroll-1,min(#texts,12))
	elseif k=="down"then
		scroll=min(scroll+1,#texts)
		if scroll==#texts then
			newMessasge=false
		end
	elseif k=="return"then
		sendMessage()
	elseif k=="escape"then
		SCN.back()
	else
		WIDGET.keyPressed(k)
	end
end

function scene.socketRead(mes)
	if mes:byte()==35 then--system message
		local sep=mes:find(":")
		local cmd=mes:sub(2,sep-1)
		local data=mes:sub(sep+1)
		if cmd=="J"then
			remain=tonumber(data)
			if remain<=10 then
				ins(texts,{COLOR.yellow,text.chatJoin..remain})
			end
		elseif cmd=="L"then
			remain=tonumber(data)
			if remain<=10 then
				ins(texts,{COLOR.yellow,text.chatLeave..remain})
			end
		end
	else--user message
		local sep=mes:find(":")
		local num=mes:find("#")
		ins(texts,{
			COLOR.white,mes:sub(1,num-1),
			COLOR.dY,mes:sub(num,sep-1).." ",
			COLOR.sky,mes:sub(sep+1),
		})
	end
	if scroll==#texts-1 then
		scroll=scroll+1
	else
		SFX.play("spin_0",.8)
		newMessasge=true
	end
end

function scene.update(dt)
	heartBeatTimer=heartBeatTimer+dt
	if heartBeatTimer>42 then
		heartBeatTimer=0
		wsWrite("/ping")
	end
end
function scene.draw()
	setFont(25)
	gc.setColor(1,1,1)
	gc.printf(text.chatRemain,800,10,400,"right")
	gc.print(remain or"?",1205,10)

	setFont(30)
	for i=max(scroll-11,1),scroll do
		gc.printf(texts[i],40,449-39*(scroll-i),1240)
	end

	--Slider
	if #texts>12 then
		gc.setLineWidth(2)
		gc.rectangle("line",10,30,20,450)
		local len=450*12/#texts
		gc.rectangle("fill",10,30+(450-len)*(scroll-12)/(#texts-12),20,len)
	end

	--Draw
	if scroll~=#texts then
		setFont(40)
		if newMessasge then
			gc.setColor(1,Timer()%.4<.2 and 1 or 0,0)
		else
			gc.setColor(1,1,1)
		end
		gc.print("v",8,480)
	end
end

scene.widgetList={
	WIDGET.newTextBox{name="text",	x=40,	y=500,w=980,h=180,font=40},
	WIDGET.newButton{name="clear",	x=1140,	y=440,w=170,h=80,font=40,code=clearHistory},
	WIDGET.newButton{name="send",	x=1140,	y=540,w=170,h=80,font=40,code=sendMessage},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene