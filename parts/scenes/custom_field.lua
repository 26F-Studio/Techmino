local gc,sys=love.graphics,love.system
local ms,kb=love.mouse,love.keyboard

local max,min,int=math.max,math.min,math.floor
local ins,rem=table.insert,table.remove
local sub=string.sub

local FIELD=FIELD
local scene={}

local sure
local pen--Pen type
local penX,penY--Pen position
local demo--If show x
local page

local penKey={
	["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,
	q=9,w=10,e=11,r=12,t=13,y=14,u=15,i=16,
	a=17,s=18,d=19,f=20,g=21,h=22,j=23,k=24,
	z=0,x=-1,
}
local minoPosCode={
	[102]=1,[1121]=1,--Z
	[195]=2,[610]=2,--S
	[39]=3,[1569]=3,[228]=3,[1091]=3,--J
	[135]=4,[547]=4,[225]=4,[1602]=4,--L
	[71]=5,[609]=5,[226]=5,[1122]=5,--T
	[99]=6,--O
	[15]=7,[4641]=7,--I
	[1606]=8,[2273]=8,--Z5
	[3139]=9,[740]=9,--S5
	[103]=10,[1633]=10,[230]=10,[1123]=10,--P
	[199]=11,[611]=11,[227]=11,[1634]=11,--Q
	[738]=12,[3170]=12,[1252]=12,[1219]=12,--F
	[2274]=13,[1126]=13,[1249]=13,[1730]=13,--E
	[1095]=14,[737]=14,[3650]=14,[2276]=14,--T5
	[167]=15,[1571]=15,[229]=15,[1603]=15,--U
	[2183]=16,[551]=16,[3617]=16,[3716]=16,--V
	[614]=17,[3169]=17,[1732]=17,[2243]=17,--W
	[1250]=18,--X
	[47]=19,[12833]=19,[488]=19,[9283]=19,--J5
	[271]=20,[4643]=20,[481]=20,[13378]=20,--L5
	[79]=21,[5665]=21,[484]=21,[9314]=21,--R
	[143]=22,[4705]=22,[482]=22,[9794]=22,--Y
	[110]=23,[9761]=23,[236]=23,[9313]=23,--N
	[391]=24,[4706]=24,[451]=24,[5698]=24,--H
	[31]=25,[21025]=25,--I5
	[7]=26,[545]=26,--I3
	[67]=27,[35]=27,[97]=27,[98]=27,--C
	[3]=28,[33]=28,--I2
	[1]=29,--O1
}
local SPmode
local SPlist={}--Smart pen path list
local function SPpath(x,y)
	for i=1,#SPlist do
		if x==SPlist[i][1]and y==SPlist[i][2]then
			return
		end
	end
	ins(SPlist,{x,y})
	if #SPlist==1 then
		local start=FIELD[page][y][x]
		SPmode=start==0 and 0 or 1
	end
end
local function SPdraw()
	local l=#SPlist
	local C--color
	if SPmode==0 then
		if l<=5 then
			local sum=0
			local x,y={},{}
			for i=1,l do
				ins(x,SPlist[i][1])
				ins(y,SPlist[i][2])
			end
			local minY,minX=min(unpack(y)),min(unpack(x))
			for i=1,#y do
				sum=sum+2^((11-(y[i]-minY))*(y[i]-minY)/2+(x[i]-minX))
			end
			if minoPosCode[sum]then
				C=SETTING.skin[minoPosCode[sum]]
			end
		else
			C=20
		end
	elseif SPmode==1 then
		C=0
	end

	if C then
		for i=1,l do
			FIELD[page][SPlist[i][2]][SPlist[i][1]]=C
		end
	end
	SPlist={}
end

function scene.sceneInit()
	sure=0
	pen=1
	penX,penY=1,1
	demo=false
	page=1
	love.keyboard.setKeyRepeat(false)
end
function scene.sceneBack()
	love.keyboard.setKeyRepeat(true)
end

function scene.mouseMove(x,y)
	local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	penX,penY=sx,sy
	if ms.isDown(1,2,3)then
		if sx and sy then
			if pen==-2 then
				if ms.isDown(1)then
					SPpath(sx,sy)
				else
					FIELD[page][sy][sx]=-1
				end
			else
				FIELD[page][sy][sx]=
					ms.isDown(1)and pen or
					ms.isDown(2)and -1
					or 0
			end
		end
	else
		if pen==-2 then SPdraw()end
	end
end
function scene.mouseDown(x,y,k)
	if k==2 and pen==-2 then
		SPlist={}
	else
		scene.mouseMove(x,y)
	end
end
scene.mouseUp=scene.mouseMove

function scene.wheelMoved(_,y)
	if y<0 then
		pen=pen+1
		if pen==25 then pen=1 end
	else
		pen=pen-1
		if pen==0 then pen=24 end
	end
end
function scene.touchDown(x,y)
	scene.mouseMove(x,y)
end
function scene.touchMove(x,y)
	local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	penX,penY=sx,sy
	if sx and sy then
		if pen==-2 then
			SPpath(sx,sy)
		else
			FIELD[page][sy][sx]=pen
		end
	end
end
scene.touchUp=scene.touchMove

function scene.keyDown(key)
	local sx,sy=penX,penY
	if key=="up"or key=="down"or key=="left"or key=="right"then
		if not sx then sx=1 end
		if not sy then sy=1 end
		if key=="up"and sy<20 then sy=sy+1
		elseif key=="down"and sy>1 then sy=sy-1
		elseif key=="left"and sx>1 then sx=sx-1
		elseif key=="right"and sx<10 then sx=sx+1
		end
		if kb.isDown("space")then
			FIELD[page][sy][sx]=pen
		end
	elseif key=="delete"then
		if sure>20 then
			for y=1,20 do for x=1,10 do FIELD[page][y][x]=0 end end
			sure=0
			SFX.play("finesseError",.7)
		else
			sure=50
		end
	elseif key=="space"then
		if sx and sy then
			if pen==-2 then
				SPpath(sx,sy)
			else
				FIELD[page][sy][sx]=pen
			end
		end
	elseif key=="escape"then
		SCN.back()
	elseif key=="j"then
		demo=not demo
	elseif key=="k"then
		ins(FIELD[page],1,{21,21,21,21,21,21,21,21,21,21})
		FIELD[page][21]=nil
		SFX.play("blip")
	elseif key=="l"then
		local F=FIELD[page]
		for i=20,1,-1 do
			for j=1,10 do
				if F[i][j]<=0 then goto L end
			end
			SYSFX.newShade(3,200,660-30*i,300,30)
			SYSFX.newRectRipple(3,200,660-30*i,300,30)
			rem(F,i)
			::L::
		end
		if #F~=20 then
			repeat
				F[#F+1]={0,0,0,0,0,0,0,0,0,0}
			until#F==20
			SFX.play("clear_3",.8)
			SFX.play("fall",.8)
		end
	elseif key=="c"and kb.isDown("lctrl","rctrl")or key=="cC"then
		sys.setClipboardText("Techmino Field:"..copyBoard(page))
		LOG.print(text.exportSuccess,COLOR.green)
	elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
		local str=sys.getClipboardText()
		local p=string.find(str,":")--ptr*
		if p then str=sub(str,p+1)end
		if pasteBoard(str,page)then
			LOG.print(text.importSuccess,COLOR.green)
		else
			LOG.print(text.dataCorrupted,COLOR.red)
		end
	elseif key=="tab"or key=="sTab"then
		if key=="sTab"or kb.isDown("lshift","rshift")then
			page=max(page-1,1)
		else
			page=min(page+1,#FIELD)
		end
	elseif key=="n"then
		ins(FIELD,page+1,newBoard(FIELD[page]))
		page=page+1
		SFX.play("blip_1",.8)
		SYSFX.newShade(3,200,60,300,600,.5,1,.5)
	elseif key=="m"then
		rem(FIELD,page)
		page=max(page-1,1)
		if not FIELD[1]then
			ins(FIELD,newBoard())
		end
		SYSFX.newShade(3,200,60,300,600,1,.5,.5)
		SFX.play("clear_4",.8)
		SFX.play("fall",.8)
	else
		pen=penKey[key]or pen
	end
	penX,penY,pen=sx,sy,pen
end
function scene.keyUp()
	if not kb.isDown("space")and pen==-2 then
		SPdraw()
	end
end

function scene.update()
	if sure>0 then sure=sure-1 end
end

function scene.draw()
	gc.translate(200,60)

	--Draw grid
	gc.setColor(1,1,1,.2)
	gc.setLineWidth(1)
	for x=1,9 do gc.line(30*x,0,30*x,600)end
	for y=0,19 do gc.line(0,30*y,300,30*y)end

	--Draw field
	gc.setColor(1,1,1)
	gc.setLineWidth(3)
	gc.rectangle("line",-2,-2,304,604)
	gc.setLineWidth(2)
	local cross=TEXTURE.puzzleMark[-1]
	local F=FIELD[page]
	local texture=SKIN.curText
	for y=1,20 do for x=1,10 do
		local B=F[y][x]
		if B>0 then
			gc.draw(texture[B],30*x-30,600-30*y)
		elseif B==-1 and not demo then
			gc.draw(cross,30*x-30,600-30*y)
		end
	end end

	--Draw pen
	if penX and penY then
		local x,y=30*penX,600-30*penY
		if kb.isDown("space")or ms.isDown(1)then
			gc.setLineWidth(5)
			gc.rectangle("line",x-30,y,30,30,4)
		elseif ms.isDown(3)then
			gc.setLineWidth(3)
			gc.line(x-15,y,x-30,y+15)
			gc.line(x,y,x-30,y+30)
			gc.line(x,y+15,x-15,y+30)
		else
			gc.setLineWidth(2)
			gc.rectangle("line",x-30,y,30,30,3)
			gc.setColor(1,1,1,.2)
			gc.rectangle("fill",x-30,y,30,30,3)
		end
	end

	--Draw smart pen path
	if #SPlist>0 then
		gc.setLineWidth(4)
		if SPmode==0 then
			if #SPlist<=5 then
				gc.setColor(COLOR.rainbow_light(TIME()*6.2))
			else
				gc.setColor(COLOR.grey)
			end
			for i=1,#SPlist do
				gc.rectangle("line",30*SPlist[i][1]-30+2,600-30*SPlist[i][2]+2,30-4,30-4,3)
			end
		elseif SPmode==1 then
			for i=1,#SPlist do
				gc.rectangle("line",30*SPlist[i][1]-30+2,600-30*SPlist[i][2]+2,30-4,30-4,3)
			end
		end
	end
	gc.translate(-200,-60)

	--Draw page
	setFont(55)
	gc.setColor(1,1,1)
	mStr(page,100,530)
	mStr(#FIELD,100,600)
	gc.rectangle("fill",50,600,100,6)

	--Draw pen color
	if pen>0 then
		gc.setLineWidth(13)
		gc.setColor(minoColor[pen])
		gc.rectangle("line",565,495,70,70)
	elseif pen==-1 then
		gc.setLineWidth(5)
		gc.setColor(.9,.9,.9)
		gc.line(575,505,625,555)
		gc.line(575,555,625,505)
	elseif pen==-2 then
		gc.setLineWidth(13)
		gc.setColor(COLOR.rainbow(TIME()*6.2))
		gc.rectangle("line",565,495,70,70)
	end

	--Confirm reset
	if sure>0 then
		gc.setColor(1,1,1,sure*.02)
		gc.draw(drawableText.question,1145,330)
	end

	--Block name
	setFont(55)
	gc.setColor(1,1,1)
	local _
	for i=1,7 do
		_=SETTING.skin[i]
		if _<=8 then
			mStr(text.block[i],500+80*_,90)
		else
			mStr(text.block[i],500+80*(_-8),170)
		end
	end
end

local function setPen(i)return function()pen=i end end
scene.widgetList={
	WIDGET.newText{name="title",	x=1020,y=5,font=70,align="R"},
	WIDGET.newText{name="subTitle",	x=1030,y=50,font=35,align="L",color="grey"},

	WIDGET.newButton{name="b1",		x=580,	y=130,w=75,fText="",color=COLOR.red,	code=setPen(1)},--B1
	WIDGET.newButton{name="b2",		x=660,	y=130,w=75,fText="",color=COLOR.fire,	code=setPen(2)},--B2
	WIDGET.newButton{name="b3",		x=740,	y=130,w=75,fText="",color=COLOR.orange,	code=setPen(3)},--B3
	WIDGET.newButton{name="b4",		x=820,	y=130,w=75,fText="",color=COLOR.yellow,	code=setPen(4)},--B4
	WIDGET.newButton{name="b5",		x=900,	y=130,w=75,fText="",color=COLOR.lame,	code=setPen(5)},--B5
	WIDGET.newButton{name="b6",		x=980,	y=130,w=75,fText="",color=COLOR.grass,	code=setPen(6)},--B6
	WIDGET.newButton{name="b7",		x=1060,	y=130,w=75,fText="",color=COLOR.green,	code=setPen(7)},--B7
	WIDGET.newButton{name="b8",		x=1140,	y=130,w=75,fText="",color=COLOR.water,	code=setPen(8)},--B8

	WIDGET.newButton{name="b9",		x=580,	y=210,w=75,fText="",color=COLOR.cyan,	code=setPen(9)},--B9
	WIDGET.newButton{name="b10",	x=660,	y=210,w=75,fText="",color=COLOR.sky,	code=setPen(10)},--B10
	WIDGET.newButton{name="b11",	x=740,	y=210,w=75,fText="",color=COLOR.sea,	code=setPen(11)},--B11
	WIDGET.newButton{name="b12",	x=820,	y=210,w=75,fText="",color=COLOR.blue,	code=setPen(12)},--B12
	WIDGET.newButton{name="b13",	x=900,	y=210,w=75,fText="",color=COLOR.purple,	code=setPen(13)},--B13
	WIDGET.newButton{name="b14",	x=980,	y=210,w=75,fText="",color=COLOR.grape,	code=setPen(14)},--B14
	WIDGET.newButton{name="b15",	x=1060,	y=210,w=75,fText="",color=COLOR.magenta,code=setPen(15)},--B15
	WIDGET.newButton{name="b16",	x=1140,	y=210,w=75,fText="",color=COLOR.pink,	code=setPen(16)},--B16

	WIDGET.newButton{name="b17",	x=580,	y=290,w=75,fText="[  ]",color="dGrey",	code=setPen(17)},--BONE
	WIDGET.newButton{name="b18",	x=660,	y=290,w=75,fText="N",	color="black",	code=setPen(18)},--HIDE
	WIDGET.newButton{name="b19",	x=740,	y=290,w=75,fText="B",	color="lYellow",code=setPen(19)},--BOMB
	WIDGET.newButton{name="b20",	x=820,	y=290,w=75,fText="_",	color="grey",	code=setPen(20)},--GB1
	WIDGET.newButton{name="b21",	x=900,	y=290,w=75,fText="_",	color="lGrey",	code=setPen(21)},--GB2
	WIDGET.newButton{name="b22",	x=980,	y=290,w=75,fText="_",	color="dPurple",code=setPen(22)},--GB3
	WIDGET.newButton{name="b23",	x=1060,	y=290,w=75,fText="_",	color="dRed",	code=setPen(23)},--GB4
	WIDGET.newButton{name="b24",	x=1140,	y=290,w=75,fText="_",	color="dGreen",	code=setPen(24)},--GB5

	WIDGET.newButton{name="any",		x=600,	y=400,w=120,color="lGrey",	font=40,code=setPen(0)},
	WIDGET.newButton{name="space",		x=730,	y=400,w=120,color="grey",	font=65,code=setPen(-1)},
	WIDGET.newButton{name="smartPen",	x=860,	y=400,w=120,color="lGreen",	font=30,code=setPen(-2)},
	WIDGET.newButton{name="pushLine",	x=990,	y=400,w=120,h=120,color="lYellow",font=20,code=pressKey"k"},
	WIDGET.newButton{name="delLine",	x=1120,	y=400,w=120,h=120,color="lYellow",font=20,code=pressKey"l"},

	WIDGET.newButton{name="copy",		x=730,	y=530,w=120,color="lRed",	font=35,code=pressKey"cC"},
	WIDGET.newButton{name="paste",		x=860,	y=530,w=120,color="lBlue",	font=35,code=pressKey"cV"},
	WIDGET.newButton{name="clear",		x=990,	y=530,w=120,color="white",	font=40,code=pressKey"delete"},
	WIDGET.newSwitch{name="demo",		x=755,	y=640,disp=function()return demo end,code=function()demo=not demo end},

	WIDGET.newButton{name="newPage",	x=100,	y=110,w=160,h=110,color="sky",font=20,code=pressKey"n"},
	WIDGET.newButton{name="delPage",	x=100,	y=230,w=160,h=110,color="lRed",font=20,code=pressKey"m"},
	WIDGET.newButton{name="prevPage",	x=100,	y=350,w=160,h=110,color="lGreen",font=20,code=pressKey"sTab",hide=function()return page==1 end},
	WIDGET.newButton{name="nextPage",	x=100,	y=470,w=160,h=110,color="lGreen",font=20,code=pressKey"tab",hide=function()return page==#FIELD end},

	WIDGET.newButton{name="back",		x=1140,	y=640,	w=170,h=80,font=40,code=backScene},
}

return scene