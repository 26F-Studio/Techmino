local gc,sys=love.graphics,love.system
local ms,kb=love.mouse,love.keyboard

local setFont=setFont
local mStr=mStr

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
		LOG.print(text.copySuccess,color.green)
	elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
		local str=sys.getClipboardText()
		local p=string.find(str,":")--ptr*
		if p then str=sub(str,p+1)end
		if pasteBoard(str,S.page)then
			LOG.print(text.pasteSuccess,color.green)
		else
			LOG.print(text.dataCorrupted,color.red)
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
	for y=1,20 do for x=1,10 do
		local B=F[y][x]
		if B>0 then
			gc.draw(blockSkin[B],30*x-30,600-30*y)
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