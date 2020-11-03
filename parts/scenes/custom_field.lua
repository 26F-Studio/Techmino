local gc,sys=love.graphics,love.system
local ms,kb=love.mouse,love.keyboard

local max,min,int=math.max,math.min,math.floor
local ins,rem=table.insert,table.remove
local sub=string.sub



local FIELD=FIELD
function sceneInit.custom_field()
	sceneTemp={
		sure=0,
		pen=1,
		x=1,y=1,
		demo=false,
		page=1,
	}
end

local penKey={
	["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,
	q=9,w=10,e=11,r=12,t=13,y=14,u=15,i=16,
	a=17,s=18,d=19,f=20,g=21,h=22,j=23,k=24,
	z=0,x=-1,
}
function mouseDown.custom_field(x,y)
	mouseMove.custom_field(x,y)
end
function mouseMove.custom_field(x,y)
	local S=sceneTemp
	local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	S.x,S.y=sx,sy
	if sx and sy and ms.isDown(1,2,3)then
		FIELD[S.page][sy][sx]=ms.isDown(1)and S.pen or ms.isDown(2)and -1 or 0
	end
end
function wheelMoved.custom_field(_,y)
	local pen=sceneTemp.pen
	if y<0 then
		pen=pen+1
		if pen==25 then pen=1 end
	else
		pen=pen-1
		if pen==0 then pen=24 end
	end
	sceneTemp.pen=pen
end
function touchDown.custom_field(_,x,y)
	mouseMove.custom_field(x,y)
end
function touchMove.custom_field(_,x,y)
	local S=sceneTemp
	local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	S.x,S.y=sx,sy
	if sx and sy then
		FIELD[S.page][sy][sx]=S.pen
	end
end
function keyDown.custom_field(key)
	local S=sceneTemp
	local sx,sy,pen=S.x,S.y,S.pen
	if key=="up"or key=="down"or key=="left"or key=="right"then
		if not sx then sx=1 end
		if not sy then sy=1 end
		if key=="up"and sy<20 then sy=sy+1
		elseif key=="down"and sy>1 then sy=sy-1
		elseif key=="left"and sx>1 then sx=sx-1
		elseif key=="right"and sx<10 then sx=sx+1
		end
		if kb.isDown("space")then
			FIELD[S.page][sy][sx]=pen
		end
	elseif key=="delete"then
		if S.sure>20 then
			for y=1,20 do for x=1,10 do FIELD[S.page][y][x]=0 end end
			S.sure=0
			SFX.play("finesseError",.7)
		else
			S.sure=50
		end
	elseif key=="space"then
		if sx and sy then
			FIELD[S.page][sy][sx]=pen
		end
	elseif key=="escape"then
		SCN.back()
	elseif key=="j"then
		S.demo=not S.demo
	elseif key=="k"then
		ins(FIELD[S.page],1,{21,21,21,21,21,21,21,21,21,21})
		FIELD[S.page][21]=nil
		SFX.play("blip")
	elseif key=="l"then
		local F=FIELD[S.page]
		for i=20,1,-1 do
			for j=1,10 do
				if F[i][j]<=0 then goto L end
			end
			sysFX.newShade(.3,1,1,1,200,660-30*i,300,30)
			sysFX.newRectRipple(.3,200,660-30*i,300,30)
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
		sys.setClipboardText("Techmino Field:"..copyBoard(S.page))
		LOG.print(text.copySuccess,COLOR.green)
	elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
		local str=sys.getClipboardText()
		local p=string.find(str,":")--ptr*
		if p then str=sub(str,p+1)end
		if pasteBoard(str,S.page)then
			LOG.print(text.pasteSuccess,COLOR.green)
		else
			LOG.print(text.dataCorrupted,COLOR.red)
		end
	elseif key=="tab"or key=="sTab"then
		if key=="sTab"or kb.isDown("lshift","rshift")then
			S.page=max(S.page-1,1)
		else
			S.page=min(S.page+1,#FIELD)
		end
	elseif key=="n"then
		ins(FIELD,S.page+1,newBoard(FIELD[S.page]))
		S.page=S.page+1
		SFX.play("blip_1",.8)
		sysFX.newShade(.3,.5,1,.5,200,60,300,600)
	elseif key=="m"then
		rem(FIELD,S.page)
		S.page=max(S.page-1,1)
		if not FIELD[1]then
			ins(FIELD,newBoard())
		end
		sysFX.newShade(.3,1,.5,.5,200,60,300,600)
		SFX.play("clear_4",.8)
		SFX.play("fall",.8)
	else
		pen=penKey[key]or pen
	end
	S.x,S.y,S.pen=sx,sy,pen
end

function Tmr.custom_field()
	if sceneTemp.sure>0 then sceneTemp.sure=sceneTemp.sure-1 end
end

function Pnt.custom_field()
	local S=sceneTemp
	local sx,sy=S.x,S.y

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
	local cross=puzzleMark[-1]
	local F=FIELD[S.page]
	local texture=SKIN.curText
	for y=1,20 do for x=1,10 do
		local B=F[y][x]
		if B>0 then
			gc.draw(texture[B],30*x-30,600-30*y)
		elseif B==-1 and not S.demo then
			gc.draw(cross,30*x-30,600-30*y)
		end
	end end

	--Draw pen
	if sx and sy then
		gc.setLineWidth(2)
		gc.rectangle("line",30*sx-30,600-30*sy,30,30)
	end
	gc.translate(-200,-60)

	--Draw page
	setFont(55)
	mStr(S.page,100,510)
	mStr(#FIELD,100,600)
	gc.rectangle("fill",50,590,100,6)

	--Draw pen color
	local pen=S.pen
	if pen>0 then
		gc.setLineWidth(13)
		gc.setColor(SKIN.libColor[pen])
		gc.rectangle("line",545,495,70,70)
	elseif pen==-1 then
		gc.setLineWidth(5)
		gc.setColor(.9,.9,.9)
		gc.line(555,505,605,555)
		gc.line(555,555,605,505)
	end

	--Confirm reset
	if S.sure>0 then
		gc.setColor(1,1,1,S.sure*.02)
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

local function setPen(i)return function()sceneTemp.pen=i end end
WIDGET.init("custom_field",{
	WIDGET.newText({name="title",		x=1020,y=5,font=70,align="R"}),
	WIDGET.newText({name="subTitle",	x=1030,y=50,font=35,align="L",color="grey"}),

	WIDGET.newButton({name="b1",		x=580,	y=130,w=75,color={COLOR.rainbow( 1.471)},code=setPen(1)}),--B1
	WIDGET.newButton({name="b2",		x=660,	y=130,w=75,color={COLOR.rainbow( 1.078)},code=setPen(2)}),--B2
	WIDGET.newButton({name="b3",		x=740,	y=130,w=75,color={COLOR.rainbow( 0.685)},code=setPen(3)}),--B3
	WIDGET.newButton({name="b4",		x=820,	y=130,w=75,color={COLOR.rainbow( 0.293)},code=setPen(4)}),--B4
	WIDGET.newButton({name="b5",		x=900,	y=130,w=75,color={COLOR.rainbow(-0.100)},code=setPen(5)}),--B5
	WIDGET.newButton({name="b6",		x=980,	y=130,w=75,color={COLOR.rainbow(-0.493)},code=setPen(6)}),--B6
	WIDGET.newButton({name="b7",		x=1060,	y=130,w=75,color={COLOR.rainbow(-0.885)},code=setPen(7)}),--B7
	WIDGET.newButton({name="b8",		x=1140,	y=130,w=75,color={COLOR.rainbow(-1.278)},code=setPen(8)}),--B8

	WIDGET.newButton({name="b9",		x=580,	y=210,w=75,color={COLOR.rainbow(-1.671)},code=setPen(9)}),--B9
	WIDGET.newButton({name="b10",		x=660,	y=210,w=75,color={COLOR.rainbow(-2.063)},code=setPen(10)}),--B10
	WIDGET.newButton({name="b11",		x=740,	y=210,w=75,color={COLOR.rainbow(-2.456)},code=setPen(11)}),--B11
	WIDGET.newButton({name="b12",		x=820,	y=210,w=75,color={COLOR.rainbow(-2.849)},code=setPen(12)}),--B12
	WIDGET.newButton({name="b13",		x=900,	y=210,w=75,color={COLOR.rainbow(-3.242)},code=setPen(13)}),--B13
	WIDGET.newButton({name="b14",		x=980,	y=210,w=75,color={COLOR.rainbow(-3.634)},code=setPen(14)}),--B14
	WIDGET.newButton({name="b15",		x=1060,	y=210,w=75,color={COLOR.rainbow(-4.027)},code=setPen(15)}),--B15
	WIDGET.newButton({name="b16",		x=1140,	y=210,w=75,color={COLOR.rainbow(-4.412)},code=setPen(16)}),--B16

	WIDGET.newButton({name="b17",		x=580,	y=290,w=75,color="dGrey",	code=setPen(17)}),--BONE
	WIDGET.newButton({name="b18",		x=660,	y=290,w=75,color="black",	code=setPen(18)}),--HIDE
	WIDGET.newButton({name="b19",		x=740,	y=290,w=75,color="lYellow",	code=setPen(19)}),--BOMB
	WIDGET.newButton({name="b20",		x=820,	y=290,w=75,color="grey",	code=setPen(20)}),--GB1
	WIDGET.newButton({name="b21",		x=900,	y=290,w=75,color="lGrey",	code=setPen(21)}),--GB2
	WIDGET.newButton({name="b22",		x=980,	y=290,w=75,color="dPurple",	code=setPen(22)}),--GB3
	WIDGET.newButton({name="b23",		x=1060,	y=290,w=75,color="dRed",	code=setPen(23)}),--GB4
	WIDGET.newButton({name="b24",		x=1140,	y=290,w=75,color="dGreen",	code=setPen(24)}),--GB5

	WIDGET.newButton({name="any",		x=600,	y=400,w=120,color="lGrey",	font=40,code=setPen(0)}),
	WIDGET.newButton({name="space",		x=730,	y=400,w=120,color="grey",	font=65,code=setPen(-1)}),
	WIDGET.newButton({name="copy",		x=905,	y=400,w=120,color="lRed",	font=35,code=WIDGET.lnk.pressKey("cC")}),
	WIDGET.newButton({name="paste",		x=1035,	y=400,w=120,color="lBlue",	font=35,code=WIDGET.lnk.pressKey("cV")}),
	WIDGET.newButton({name="clear",		x=1165,	y=400,w=120,color="white",	font=40,code=WIDGET.lnk.pressKey("delete")}),

	WIDGET.newButton({name="newPage",	x=680,	y=530,w=90,h=90,color="sky",font=15,code=WIDGET.lnk.pressKey("n")}),
	WIDGET.newButton({name="delPage",	x=780,	y=530,w=90,h=90,color="lRed",font=15,code=WIDGET.lnk.pressKey("m")}),
	WIDGET.newButton({name="prevPage",	x=880,	y=530,w=90,h=90,color="lGreen",font=15,code=WIDGET.lnk.pressKey("sTab"),hide=WIDGET.lnk.STPeq("page",1)}),
	WIDGET.newButton({name="nextPage",	x=980,	y=530,w=90,h=90,color="lGreen",font=15,code=WIDGET.lnk.pressKey("tab"),hide=function()return sceneTemp.page==#FIELD end}),
	WIDGET.newButton({name="pushLine",	x=1080,	y=530,w=90,h=90,color="lYellow",font=20,code=WIDGET.lnk.pressKey("k")}),
	WIDGET.newButton({name="delLine",	x=1180,	y=530,w=90,h=90,color="lYellow",font=20,code=WIDGET.lnk.pressKey("l")}),
	WIDGET.newSwitch({name="demo",		x=755,	y=640,	disp=WIDGET.lnk.STPval("demo"),code=WIDGET.lnk.STPrev("demo")}),

	WIDGET.newButton({name="back",		x=1140,	y=640,	w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})