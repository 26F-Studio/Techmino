local gc=love.graphics

local NET=NET
local fetchTimer

local roomList=WIDGET.newListBox{name="roomList",x=50,y=50,w=800,h=440,lineH=40,drawF=function(ifSel,id,item)
	if ifSel then
		gc.setColor(1,1,1,.3)
		gc.rectangle('fill',0,0,800,40)
	end
	gc.setColor(1,1,1)
	if item.private then gc.draw(IMG.lock,10,5)end
	gc.print(item.count.."/"..item.capacity,670,-4)

	gc.setColor(.9,.9,1)
	gc.print(id,45,-4)

	if item.start then
		gc.setColor(0,.4,.1)
	else
		gc.setColor(1,1,.7)
	end
	gc.print(item.roomInfo.name,200,-4)
end}
local function hidePW()
	local R=roomList:getSel()
	return not R or not R.private
end
local passwordBox=WIDGET.newInputBox{name="password",x=350,y=505,w=500,h=50,secret=true,hideF=hidePW}

--[[roomList[n]={
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
	fetchRoom()
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
	elseif roomList:getLen()>0 and key=="return"then
		local R=roomList:getSel()
		if NET.getlock('fetchRoom')or not R then return end
		if R.roomInfo.version:find("^V0%.15%.[234]$")then
			NET.enterRoom(R,passwordBox.value)
		else
			MES.new('error',"Version doesn't compatible 版本不兼容")
		end
	else
		WIDGET.keyPressed(key)
	end
end

function scene.update(dt)
	if not NET.getlock('fetchRoom')and hidePW()then
		fetchTimer=fetchTimer-dt
		if fetchTimer<=0 then
			fetchRoom()
		end
	end
end

function scene.draw()
	--Fetching timer
	gc.setColor(1,1,1,.12)
	gc.arc('fill','pie',250,630,40,-1.5708,-1.5708-.6283*fetchTimer)

	--Room list
	local R=roomList:getSel()
	if R then
		gc.translate(870,220)
		gc.setColor(1,1,1)
		gc.setLineWidth(3)
		gc.rectangle('line',0,0,385,335)
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
		gc.setColor(1,.2,0)
		gc.printf(R.roomInfo.version,10,300,365,'right')
		gc.translate(-870,-220)
	end

	--Profile
	drawSelfProfile()

	--Player count
	drawOnlinePlayerCount()
end

scene.widgetList={
	roomList,
	passwordBox,
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=pressKey"s"},
	WIDGET.newText{name="refreshing",x=450,y=255,font=45,hideF=function()return not NET.getlock('fetchRoom')end},
	WIDGET.newText{name="noRoom",	x=450,y=260,font=40,hideF=function()return roomList:getLen()>0 or NET.getlock('fetchRoom')end},
	WIDGET.newKey{name="refresh",	x=250,y=630,w=140,h=120,font=35,code=fetchRoom,hideF=function()return fetchTimer>7 end},
	WIDGET.newKey{name="new",		x=510,y=630,w=260,h=120,font=30,code=pressKey"n"},
	WIDGET.newKey{name="join",		x=780,y=630,w=140,h=120,font=40,code=pressKey"return",hideF=function()return roomList:getLen()==0 or NET.getlock('enterRoom')end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene