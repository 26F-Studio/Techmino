local gc,sys=love.graphics,love.system
local kb=love.keyboard
local Timer=love.timer.getTime

local setFont=setFont

local sin=math.sin
local ins,rem=table.insert,table.remove
local sub=string.sub

function sceneInit.custom_sequence()
	sceneTemp={cur=#BAG,sure=0}
end

local minoKey={
	["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,
	z=1,s=2,j=3,l=4,t=5,o=6,i=7,
	p=10,q=11,f=12,e=13,u=15,
	v=16,w=17,x=18,r=21,y=22,n=23,h=24,
}
local minoKey2={
	["1"]=8,["2"]=9,["3"]=19,["4"]=20,["5"]=14,["7"]=25,
	z=8,s=9,t=14,j=19,l=20,i=25
}
function keyDown.custom_sequence(key)
	local S=sceneTemp
	local BAG=BAG
	if key=="left"then
		local p=S.cur
		if p==0 then
			S.cur=#BAG
		else
			repeat
				p=p-1
			until BAG[p]~=BAG[S.cur]
			S.cur=p
		end
	elseif key=="right"then
		local p=S.cur
		if p==#BAG then
			S.cur=0
		else
			repeat
				p=p+1
			until BAG[p+1]~=BAG[S.cur+1]
			S.cur=p
		end
	elseif key=="ten"then
		for _=1,10 do
			local p=S.cur
			if p==#BAG then break end
			repeat
				p=p+1
			until BAG[p+1]~=BAG[S.cur+1]
			S.cur=p
		end
	elseif key=="backspace"then
		if S.cur>0 then
			rem(BAG,S.cur)
			S.cur=S.cur-1
			if S.cur>0 and BAG[S.cur]==BAG[S.cur+1]then
				keyDown.custom_mission("right")
			end
		end
	elseif key=="delete"then
		if S.sure>20 then
			for _=1,#BAG do
				rem(BAG)
			end
			S.cur=0
			S.sure=0
			SFX.play("finesseError",.7)
		else
			S.sure=50
		end
	elseif key=="c"and kb.isDown("lctrl","rctrl")or key=="cC"then
		if #BAG>0 then
			sys.setClipboardText("Techmino SEQ:"..copySequence())
			LOG.print(text.copySuccess,color.green)
		end
	elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
		local str=sys.getClipboardText()
		local p=string.find(str,":")--ptr*
		if p then str=sub(str,p+1)end
		if pasteSequence(str)then
			LOG.print(text.pasteSuccess,color.green)
		else
			LOG.print(text.dataCorrupted,color.red)
		end
	elseif key=="escape"then
		SCN.back()
	elseif type(key)=="number"then
		S.cur=S.cur+1
		ins(BAG,S.cur,key)
	elseif #key==1 then
		key=(kb.isDown("lshift","lalt","rshift","ralt")and minoKey2 or minoKey)[key]
		if key then
			local p=S.cur+1
			while BAG[p]==key do p=p+1 end
			ins(BAG,p,key)
			S.cur=p
			SFX.play("lock")
		end
	end
end

function Tmr.custom_sequence()
	if sceneTemp.sure>0 then sceneTemp.sure=sceneTemp.sure-1 end
end

function Pnt.custom_sequence()
	local S=sceneTemp

	--Draw frame
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",100,110,1080,260)

	--Draw sequence
	local miniBlock=TEXTURE.miniBlock
	local libColor=SKIN.libColor
	local set=SETTING.skin
	local L=BAG
	local x,y=120,136--Next block pos
	local cx,cy=120,136--Cursor-center pos
	local i,j=1,#L
	local count=1
	setFont(25)
	repeat
		if L[i]==L[i-1]then
			count=count+1
		else
			if count>1 then
				gc.setColor(1,1,1)
				gc.print("×",x-5,y-14)
				gc.print(count,x+10,y-13)
				x=x+(count<10 and 33 or 45)
				count=1
				if i==S.cur+1 then
					cx,cy=x,y
				end
			end
			if x>1060 then
				x,y=120,y+50
			end
			if i<=j then
				local B=miniBlock[L[i]]
				gc.setColor(libColor[set[L[i]]])
				gc.draw(B,x,y,nil,15,15,0,B:getHeight()*.5)
				x=x+B:getWidth()*15+10
			end
		end

		if i==S.cur then
			cx,cy=x,y
		end
		i=i+1
	until i>j+1

	--Draw lenth
	setFont(40)
	gc.setColor(1,1,1)
	gc.print(#L,120,310)

	--Draw cursor
	gc.setColor(.5,1,.5,.6+.4*sin(Timer()*6.26))
	gc.line(cx-5,cy-20,cx-5,cy+20)

	--Confirm reset
	if S.sure>0 then
		gc.setColor(1,1,1,S.sure*.02)
		gc.draw(drawableText.question,980,570)
	end
end

WIDGET.init("custom_sequence",{
	WIDGET.newText({name="title",	x=520,y=5,font=70,align="R"}),
	WIDGET.newText({name="subTitle",x=530,y=50,font=35,align="L",color="grey"}),

	WIDGET.newSelector({name="sequence",
		x=1080,y=60,w=200,color="yellow",
		list={"bag","his4","rnd","reverb","loop","fixed"},
		disp=WIDGET.lnk.CUSval("sequence"),
		code=WIDGET.lnk.CUSsto("sequence")
	}),

	WIDGET.newKey({name="Z",	x=100,y=440,w=90,font=50,code=WIDGET.lnk.pressKey(1)}),
	WIDGET.newKey({name="S",	x=200,y=440,w=90,font=50,code=WIDGET.lnk.pressKey(2)}),
	WIDGET.newKey({name="J",	x=300,y=440,w=90,font=50,code=WIDGET.lnk.pressKey(3)}),
	WIDGET.newKey({name="L",	x=400,y=440,w=90,font=50,code=WIDGET.lnk.pressKey(4)}),
	WIDGET.newKey({name="T",	x=500,y=440,w=90,font=50,code=WIDGET.lnk.pressKey(5)}),
	WIDGET.newKey({name="O",	x=600,y=440,w=90,font=50,code=WIDGET.lnk.pressKey(6)}),
	WIDGET.newKey({name="I",	x=700,y=440,w=90,font=50,code=WIDGET.lnk.pressKey(7)}),

	WIDGET.newKey({name="Z5",	x=100,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(8)}),
	WIDGET.newKey({name="S5",	x=200,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(9)}),
	WIDGET.newKey({name="P",	x=300,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(10)}),
	WIDGET.newKey({name="Q",	x=400,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(11)}),
	WIDGET.newKey({name="F",	x=500,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(12)}),
	WIDGET.newKey({name="E",	x=600,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(13)}),
	WIDGET.newKey({name="T5",	x=700,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(14)}),
	WIDGET.newKey({name="U",	x=800,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(15)}),
	WIDGET.newKey({name="V",	x=900,y=540,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(16)}),
	WIDGET.newKey({name="W",	x=100,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(17)}),
	WIDGET.newKey({name="X",	x=200,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(18)}),
	WIDGET.newKey({name="J5",	x=300,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(19)}),
	WIDGET.newKey({name="L5",	x=400,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(20)}),
	WIDGET.newKey({name="R",	x=500,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(21)}),
	WIDGET.newKey({name="Y",	x=600,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(22)}),
	WIDGET.newKey({name="N",	x=700,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(23)}),
	WIDGET.newKey({name="H",	x=800,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(24)}),
	WIDGET.newKey({name="I5",	x=900,y=640,w=90,color="grey",font=50,code=WIDGET.lnk.pressKey(25)}),

	WIDGET.newKey({name="left",		x=800,	y=440,w=90,		color="lGreen",	font=55,code=WIDGET.lnk.pressKey("left")}),
	WIDGET.newKey({name="right",	x=900,	y=440,w=90,		color="lGreen",	font=55,code=WIDGET.lnk.pressKey("right")}),
	WIDGET.newKey({name="ten",		x=1000,	y=440,w=90,		color="lGreen",	font=40,code=WIDGET.lnk.pressKey("ten")}),
	WIDGET.newKey({name="backsp",	x=1000,	y=540,w=90,		color="lYellow",font=50,code=WIDGET.lnk.pressKey("backspace")}),
	WIDGET.newKey({name="reset",	x=1000,	y=640,w=90,		color="lYellow",font=50,code=WIDGET.lnk.pressKey("delete")}),
	WIDGET.newButton({name="copy",	x=1140,	y=440,w=170,h=80,color="lRed",	font=40,code=WIDGET.lnk.pressKey("cC"),hide=function()return #BAG==0 end}),
	WIDGET.newButton({name="paste",	x=1140,	y=540,w=170,h=80,color="lBlue",	font=40,code=WIDGET.lnk.pressKey("cV")}),

	WIDGET.newButton({name="back",		x=1140,	y=640,	w=170,h=80,	font=40,code=WIDGET.lnk.BACK}),
})