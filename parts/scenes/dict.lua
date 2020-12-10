local gc=love.graphics
local Timer=love.timer.getTime

local int,abs=math.floor,math.abs
local min,sin=math.min,math.sin
local ins,rem=table.insert,table.remove
local find,sub=string.find,string.sub

local scene={}

local dict--Dict list
local input--Input string
local result--Result Lable
local url

local waiting--Searching animation timer
local selected--Selected option
local scrollPos--Scroll down length

local lastSearch--Last searched string

function scene.sceneInit()
	BG.set("rainbow")
	local location=({"zh","zh","en","en","en","en","zh"})[SETTING.lang]
	dict=require("parts/language/dict_"..location)

	input=""
	result={}
	url=dict[1][5]

	waiting=0
	selected=1
	scrollPos=0

	lastSearch=false
end

local function clearResult()
	for _=1,#result do rem(result)end
	selected,scrollPos,waiting,lastSearch=1,0,0,false
end
local function search()
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
	if result[1]then
		SFX.play("reach")
	end
	url=(result[1]and result or dict)[selected][5]
	lastSearch=input
end

function scene.keyDown(key)
	if #key==1 then
		if #input<15 then
			input=input..key
			waiting=.8
		end
	elseif key=="up"then
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
		if #input>0 then
			clearResult()
			input=""
			SFX.play("hold")
		end
	elseif key=="backspace"then
		input=sub(input,1,-2)
		if #input==0 then
			clearResult()
		else
			waiting=.8
		end
	elseif key=="escape"then
		if #input>0 then
			clearResult()
			input=""
		else
			SCN.back()
		end
	end
	url=(result[1]and result or dict)[selected][5]
end

function scene.update(dt)
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
	help=COLOR.lGrey,
	other=COLOR.lOrange,
	game=COLOR.lCyan,
	term=COLOR.lRed,
	english=COLOR.green,
	name=COLOR.lPurple,
}
function scene.draw()

	gc.setLineWidth(4)
	gc.setColor(1,1,1)
	gc.rectangle("line",20,110,726,60)
	setFont(40)
	gc.print(input,35,110)

	local list=result[1]and result or dict
	gc.setColor(1,1,1)
	local text=list[selected][4]
	if #text>900 then
		setFont(15)
	elseif #text>600 then
		setFont(20)
	elseif #text>400 then
		setFont(25)
	else
		setFont(30)
	end
	gc.printf(text,306,180,950)

	setFont(30)
	gc.setColor(1,1,1,.4+.2*sin(Timer()*4))
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

	gc.setColor(1,1,1)
	gc.rectangle("line",300,180,958,526)
	gc.rectangle("line",20,180,280,526)

	if waiting>0 then
		local r=Timer()*2
		local R=int(r)%7+1
		gc.setColor(1,1,1,1-abs(r%1*2-1))
		gc.draw(TEXTURE.miniBlock[R],785,140,Timer()*10%6.2832,15,15,spinCenters[R][0][2]+.5,#BLOCKS[R][0]-spinCenters[R][0][1]-.5)
	end
end

scene.widgetList={
	WIDGET.newText{name="title",	x=20,	y=5,font=70,align="L"},
	WIDGET.newKey{name="keyboard",	x=960,	y=60,w=200,h=80,font=35,code=function()love.keyboard.setTextInput(true,0,0,1,1)end,hide=not MOBILE},
	WIDGET.newKey{name="link",		x=1140,	y=650,w=200,h=80,font=35,code=WIDGET.lnk_pressKey("link"),hide=function()return not url end},
	WIDGET.newKey{name="up",		x=1190,	y=440,w=100,h=100,font=35,code=WIDGET.lnk_pressKey("up"),hide=not MOBILE},
	WIDGET.newKey{name="down",		x=1190,	y=550,w=100,h=100,font=35,code=WIDGET.lnk_pressKey("down"),hide=not MOBILE},
	WIDGET.newButton{name="back",	x=1165,	y=60,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene