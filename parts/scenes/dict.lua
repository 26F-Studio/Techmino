local gc=love.graphics

local int,abs=math.floor,math.abs
local min,sin=math.min,math.sin
local ins,rem=table.insert,table.remove
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

local function _init()
	YIELD()
	WIDGET.sel=WIDGET.active.input
end
function scene.sceneInit()
	dict=require("parts/language/dict_"..({"zh","zh","zh","en","en","en","en","en"})[SETTING.lang])

	WIDGET.active.input:clear()
	result={}
	url=dict[1][5]

	waiting=0
	selected=1
	scrollPos=0

	lastSearch=false
	TASK.new(_init)
	BG.set("rainbow")
end

local function clearResult()
	for _=1,#result do rem(result)end
	selected,scrollPos=1,0
	waiting,lastSearch=0,false
end
local eggInput={
	["15p"]=goScene"mg_15p",
	grid=goScene"mg_schulteG",
	pong=goScene"mg_pong",
	atoz=goScene"mg_AtoZ",
	uttt=goScene"mg_UTTT",
	cube=goScene"mg_cubefield",
	["2048"]=goScene"mg_2048",
	ten=goScene"mg_ten",
	tap=goScene"mg_tap",
	dtw=goScene"mg_dtw",
	can=goScene"mg_cannon",
	drp=goScene"mg_dropper",
	calc=goScene"mg_calc",
	flag=function()
		BG.setDefault("none")
		BGM.setDefault(false)
		BG.set("none")
		BGM.stop()
		SFX.play("clear_4")
		LOG.print("What are you looking for?",COLOR.G)
	end,
	classic=function()
		FESTIVAL=false
		BG.setDefault("space")
		BGM.setDefault("blank")
		BGM.play()
	end,
	normal="classic",
	xmas=function()
		FESTIVAL="xMas"
		BG.setDefault("snow")
		BGM.setDefault("mXmas")
		BGM.play()
	end,
	sprfes=function()
		FESTIVAL="sprFes"
		BG.setDefault("firework")
		BGM.setDefault("spring festival")
		BGM.play()
	end,
	spring="sprfes",
	zday=function()
		FESTIVAL="zDay"
		BG.setDefault("lanterns")
		BGM.setDefault("overzero")
		BGM.play()
	end,
}for k,v in next,eggInput do if type(v)=="string"then eggInput[k]=eggInput[v]end end
local function search()
	local input=WIDGET.active.input.value
	if eggInput[input]then
		eggInput[input]()
	else
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
		url=(result[1]and result or dict)[selected][5]
		lastSearch=input
	end
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
		if selected and selected<#(result[1]and result or dict)then
			selected=selected+1
			if selected>scrollPos+15 then
				scrollPos=selected-15
			end
		end
	elseif key=="link"then
		love.system.openURL(url)
	elseif key=="delete"then
		if #WIDGET.active.input.value>0 then
			clearResult()
			WIDGET.active.input:clear()
			SFX.play("hold")
		end
	elseif key=="backspace"then
		WIDGET.keyPressed("backspace")
	elseif key=="escape"then
		if #WIDGET.active.input.value>0 then
			scene.keyDown("delete")
		else
			SCN.back()
		end
	end
	url=(result[1]and result or dict)[selected][5]
end

function scene.update(dt)
	local input=WIDGET.active.input.value
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

local typeColor={
	help=COLOR.yellow,
	other=COLOR.lOrange,
	game=COLOR.lCyan,
	term=COLOR.lRed,
	setup=COLOR.lYellow,
	pattern=COLOR.lGrass,
	english=COLOR.blue,
	name=COLOR.lPurple,
}
function scene.draw()
	local list=result[1]and result or dict
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
	WIDGET.newInputBox{name="input",x=20,	y=110,w=726,h=60,font=40},
	WIDGET.newKey{name="link",		x=1140,	y=650,w=200,h=80,font=35,code=pressKey"link",hide=function()return not url end},
	WIDGET.newKey{name="up",		x=1190,	y=440,w=100,h=100,font=35,code=pressKey"up",hide=not MOBILE},
	WIDGET.newKey{name="down",		x=1190,	y=550,w=100,h=100,font=35,code=pressKey"down",hide=not MOBILE},
	WIDGET.newButton{name="back",	x=1165,	y=60,w=170,h=80,font=40,code=backScene},
}

return scene