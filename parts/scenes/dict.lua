local gc=love.graphics
local Timer=love.timer.getTime

local int,abs=math.floor,math.abs
local min,sin=math.min,math.sin
local ins,rem=table.insert,table.remove
local find,sub=string.find,string.sub

function sceneInit.dict()
	local location=({"zh","zh","en","en","en","en","zh"})[SETTING.lang]
	sceneTemp={
		dict=require("LANG/dict_"..location),

		input="",
		result={},
		url=nil,

		waiting=0,
		select=1,
		scroll=0,

		lastSearch=false,
	}
	local S=sceneTemp
	S.url=(S.result[1]and S.result or S.dict)[S.select][5]
	BG.set("rainbow")
end

local function clearResult()
	local S=sceneTemp
	local result=S.result
	for _=1,#result do rem(result)end
	S.select,S.scroll,S.waiting,S.lastSearch=1,0,0,false
end
local function search()
	clearResult()
	local S=sceneTemp
	local dict=S.dict
	local result=S.result
	local first
	for i=1,#dict do
		local pos=find(dict[i][2],S.input,nil,true)
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
	S.url=(S.result[1]and S.result or S.dict)[S.select][5]
	S.lastSearch=S.input
end

function keyDown.dict(key)
	local S=sceneTemp
	if #key==1 then
		if #S.input<15 then
			S.input=S.input..key
			S.waiting=.8
		end
	elseif key=="up"then
		if S.select and S.select>1 then
			S.select=S.select-1
			if S.select<S.scroll+1 then
				S.scroll=S.scroll-1
			end
		end
	elseif key=="down"then
		if S.select and S.select<#(S.result[1]and S.result or S.dict)then
			S.select=S.select+1
			if S.select>S.scroll+15 then
				S.scroll=S.select-15
			end
		end
	elseif key=="link"then
		love.system.openURL(S.url)
	elseif key=="delete"then
		if #S.input>0 then
			clearResult()
			S.input=""
			SFX.play("hold")
		end
	elseif key=="backspace"then
		S.input=sub(S.input,1,-2)
		if #S.input==0 then
			clearResult()
		else
			S.waiting=.8
		end
	elseif key=="escape"then
		if #S.input>0 then
			clearResult()
			S.input=""
		else
			SCN.back()
		end
	end
	S.url=(S.result[1]and S.result or S.dict)[S.select][5]
end

function Tmr.dict(dt)
	local S=sceneTemp
	if S.waiting>0 then
		S.waiting=S.waiting-dt
		if S.waiting<=0 then
			if #S.input>0 and S.input~=S.lastSearch then
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
function Pnt.dict()
	local S=sceneTemp

	gc.setLineWidth(4)
	gc.setColor(1,1,1)
	gc.rectangle("line",20,110,726,60)
	setFont(40)
	gc.print(S.input,35,110)

	local list=S.result[1]and S.result or S.dict
	gc.setColor(1,1,1)
	local text=list[S.select][4]
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
	gc.rectangle("fill",20,143+35*(S.select-S.scroll),280,35)

	setFont(30)
	for i=1,min(#list,15)do
		local y=142+35*i
		i=i+S.scroll
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

	if S.waiting>0 then
		local r=Timer()*2
		local R=int(r)%7+1
		gc.setColor(1,1,1,1-abs(r%1*2-1))
		gc.draw(TEXTURE.miniBlock[R],785,140,Timer()*10%6.2832,15,15,spinCenters[R][0][2]+.5,#BLOCKS[R][0]-spinCenters[R][0][1]-.5)
	end
end

WIDGET.init("dict",{
	WIDGET.newText({name="title",	x=20,	y=5,font=70,align="L"}),
	WIDGET.newKey({name="keyboard",	x=960,	y=60,w=200,h=80,font=35,code=function()love.keyboard.setTextInput(true,0,0,1,1)end,hide=not MOBILE}),
	WIDGET.newKey({name="link",		x=1140,	y=650,w=200,h=80,font=35,code=WIDGET.lnk.pressKey("link"),hide=function()return not sceneTemp.url end}),
	WIDGET.newKey({name="up",		x=1190,	y=440,w=100,h=100,font=35,code=WIDGET.lnk.pressKey("up"),hide=not MOBILE}),
	WIDGET.newKey({name="down",		x=1190,	y=550,w=100,h=100,font=35,code=WIDGET.lnk.pressKey("down"),hide=not MOBILE}),
	WIDGET.newButton({name="back",	x=1165,	y=60,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})