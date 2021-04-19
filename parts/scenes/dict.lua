local gc=love.graphics

local inputBox=WIDGET.newInputBox{name="input",x=20,y=110,w=726,h=60,font=40}
local int,abs=math.floor,math.abs
local min,sin=math.min,math.sin
local ins=table.insert
local find=string.find

local scene={}

local dict--Dict list
local result--Result Lable
local url

local lastTickInput
local waiting--Searching animation timer
local selected--Selected option
local scrollPos--Scroll down length

local lastSearch--Last searched string

local typeColor={
	help=COLOR.Y,
	other=COLOR.lOrange,
	game=COLOR.lC,
	term=COLOR.lR,
	setup=COLOR.lY,
	pattern=COLOR.lGrass,
	english=COLOR.B,
	name=COLOR.lPurple,
}
local function getList()return result[1]and result or dict end
local function clearResult()
	TABLE.clear(result)
	selected,scrollPos=1,0
	waiting,lastSearch=0,false
end
local function search()
	local input=inputBox.value:lower()
	clearResult()
	local first
	for i=1,#dict do
		local pos=find(dict[i][2],input,nil,true)
		if pos==1 and not first then
			ins(result,1,dict[i])
			first=true
		elseif pos then
			ins(result,dict[i])
		end
	end
	if #result>0 then
		SFX.play("reach")
	end
	url=getList()[selected][5]
	lastSearch=input
end

function scene.sceneInit()
	dict=require("parts.language.dict_"..({"zh","zh","zh","en","en","en","en","en"})[SETTING.lang])

	inputBox:clear()
	result={}
	url=dict[1][5]

	waiting=0
	selected=1
	scrollPos=0

	lastSearch=false
	TASK.new(function()YIELD()WIDGET.sel=inputBox end)
	BG.set("rainbow")
end

function scene.wheelMoved(_,y)
	WHEELMOV(y)
end
function scene.keyDown(key)
	if key=="up"then
		if selected and selected>1 then
			selected=selected-1
			if selected<scrollPos+1 then
				scrollPos=scrollPos-1
			end
		end
	elseif key=="down"then
		if selected and selected<#getList()then
			selected=selected+1
			if selected>scrollPos+15 then
				scrollPos=selected-15
			end
		end
	elseif key=="left"or key=="pageup"then
		for _=1,12 do scene.keyDown("up")end
	elseif key=="right"or key=="pagedown"then
		for _=1,12 do scene.keyDown("down")end
	elseif key=="link"then
		love.system.openURL(url)
	elseif key=="delete"then
		if #inputBox.value>0 then
			clearResult()
			inputBox:clear()
			SFX.play("hold")
		end
	elseif key=="backspace"then
		WIDGET.keyPressed("backspace")
	elseif key=="escape"then
		if #inputBox.value>0 then
			scene.keyDown("delete")
		else
			SCN.back()
		end
	end
	url=getList()[selected][5]
end

function scene.update(dt)
	local input=inputBox.value
	if input~=lastTickInput then
		if #input==0 then
			clearResult()
		else
			waiting=.8
		end
		lastTickInput=input
	end
	if waiting>0 then
		waiting=waiting-dt
		if waiting<=0 then
			if #input>0 and input~=lastSearch then
				search()
			end
		end
	end
end

function scene.draw()
	local list=getList()
	gc.setColor(1,1,1)
	local t=list[selected][4]
	if #t>900 then
		setFont(15)
	elseif #t>600 then
		setFont(20)
	elseif #t>400 then
		setFont(25)
	else
		setFont(30)
	end
	gc.printf(t,306,180,950)

	setFont(30)
	gc.setColor(1,1,1,.4+.2*sin(TIME()*4))
	gc.rectangle("fill",20,143+35*(selected-scrollPos),280,35)

	setFont(30)
	for i=1,min(#list,15)do
		local y=142+35*i
		i=i+scrollPos
		local item=list[i]
		gc.setColor(0,0,0)
		gc.print(item[1],29,y-1)
		gc.print(item[1],29,y+1)
		gc.print(item[1],31,y-1)
		gc.print(item[1],31,y+1)
		gc.setColor(typeColor[item[3]])
		gc.print(item[1],30,y)
	end

	gc.setLineWidth(4)
	gc.setColor(1,1,1)
	gc.rectangle("line",300,180,958,526)
	gc.rectangle("line",20,180,280,526)

	if waiting>0 then
		local r=TIME()*2
		local R=int(r)%7+1
		gc.setColor(1,1,1,1-abs(r%1*2-1))
		gc.draw(TEXTURE.miniBlock[R],785,140,TIME()*10%6.2832,15,15,SCS[R][0][2]+.5,#BLOCKS[R][0]-SCS[R][0][1]-.5)
	end
end

scene.widgetList={
	WIDGET.newText{name="title",	x=20,	y=5,font=70,align="L"},
	inputBox,
	WIDGET.newKey{name="link",		x=1150,	y=655,w=200,h=80,font=35,code=pressKey"link",hide=function()return not url end},
	WIDGET.newKey{name="up",		x=1130,	y=460,w=60,h=90,font=35,code=pressKey"up",hide=not MOBILE},
	WIDGET.newKey{name="down",		x=1130,	y=560,w=60,h=90,font=35,code=pressKey"down",hide=not MOBILE},
	WIDGET.newKey{name="pageup",	x=1210,	y=460,w=80,h=90,font=35,code=pressKey"pageup",hide=not MOBILE},
	WIDGET.newKey{name="pagedown",	x=1210,	y=560,w=80,h=90,font=35,code=pressKey"pagedown",hide=not MOBILE},
	WIDGET.newButton{name="back",	x=1165,	y=60,w=170,h=80,font=40,code=backScene},
}

return scene