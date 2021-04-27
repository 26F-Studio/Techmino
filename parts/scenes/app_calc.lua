local gc=love.graphics
local kb=love.keyboard

local find,sub,byte=string.find,string.sub,string.byte

local scene={}

local reg--register
local val--result value
local sym--symbol

function scene.sceneInit()
	BG.set("none")
	reg=false
	val="0"
	sym=false
end

scene.mouseDown=NULL
function scene.keyDown(k)
	if byte(k)>=48 and byte(k)<=57 then
		if sym=="="then
			val=k
			sym=false
		elseif sym and not reg then
			reg=val
			val=k
		else
			if #val<14 then
				if val=="0"then val=""end
				val=val..k
			end
		end
	elseif k:sub(1,2)=="kp"then
		scene.keyDown(k:sub(3))
	elseif k=="."then
		if not(find(val,".",nil,true)or find(val,"e"))then
			if sym and not reg then
				reg=val
				val="0."
			end
			val=val.."."
		end
	elseif k=="e"then
		if not find(val,"e")then
			val=val.."e"
		end
	elseif k=="backspace"then
		if sym=="="then
			val=""
		elseif sym then
			sym=false
		else
			val=sub(val,1,-2)
		end
		if val==""then val="0"end
	elseif k=="+"or k=="="and kb.isDown("lshift","rshift")then sym="+" reg=false
	elseif k=="*"or k=="8"and kb.isDown("lshift","rshift")then sym="*" reg=false
	elseif k=="-"then sym="-" reg=false
	elseif k=="/"then sym="/" reg=false
	elseif k=="return"then
		if byte(val,-1)==101 then val=sub(val,1,-2)end
		if sym and reg then
			if byte(reg,-1)==101 then reg=sub(reg,1,-2)end
			val=
				sym=="+"and (tonumber(reg)or 0)+tonumber(val)or
				sym=="-"and (tonumber(reg)or 0)-tonumber(val)or
				sym=="*"and (tonumber(reg)or 0)*tonumber(val)or
				sym=="/"and (tonumber(reg)or 0)/tonumber(val)or
				-1
		end
		sym="="
		reg=false
	elseif k=="escape"then
		if val~="0"then
			val,reg,sym="0"
		else
			SCN.back()
		end
	elseif k=="delete"then
		val="0"
	end
end

function scene.draw()
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",100,80,650,150)
	setFont(45)
	if reg then gc.printf(reg,0,100,720,"right")end
	if val then gc.printf(val,0,150,720,"right")end
	if sym then setFont(50)gc.print(sym,126,150)end
end

scene.widgetList={
	WIDGET.newKey{name="_1",x=150,y=300,w=90,fText="1",font=50,code=pressKey"1"},
	WIDGET.newKey{name="_2",x=250,y=300,w=90,fText="2",font=50,code=pressKey"2"},
	WIDGET.newKey{name="_3",x=350,y=300,w=90,fText="3",font=50,code=pressKey"3"},
	WIDGET.newKey{name="_4",x=150,y=400,w=90,fText="4",font=50,code=pressKey"4"},
	WIDGET.newKey{name="_5",x=250,y=400,w=90,fText="5",font=50,code=pressKey"5"},
	WIDGET.newKey{name="_6",x=350,y=400,w=90,fText="6",font=50,code=pressKey"6"},
	WIDGET.newKey{name="_7",x=150,y=500,w=90,fText="7",font=50,code=pressKey"7"},
	WIDGET.newKey{name="_8",x=250,y=500,w=90,fText="8",font=50,code=pressKey"8"},
	WIDGET.newKey{name="_9",x=350,y=500,w=90,fText="9",font=50,code=pressKey"9"},
	WIDGET.newKey{name="_0",x=150,y=600,w=90,fText="0",font=50,code=pressKey"0"},
	WIDGET.newKey{name=".",x=250,y=600,w=90,fText=".",color="lM",font=50,code=pressKey"."},
	WIDGET.newKey{name="e",x=350,y=600,w=90,fText="e",color="lM",font=50,code=pressKey"e"},
	WIDGET.newKey{name="+",x=450,y=300,w=90,fText="+",color="lB",font=50,code=pressKey"+"},
	WIDGET.newKey{name="-",x=450,y=400,w=90,fText="-",color="lB",font=50,code=pressKey"-"},
	WIDGET.newKey{name="*",x=450,y=500,w=90,fText="*",color="lB",font=50,code=pressKey"*"},
	WIDGET.newKey{name="/",x=450,y=600,w=90,fText="/",color="lB",font=50,code=pressKey"/"},
	WIDGET.newKey{name="<",x=550,y=300,w=90,fText="<",color="lR",font=50,code=pressKey"backspace"},
	WIDGET.newKey{name="=",x=550,y=400,w=90,fText="=",color="lY",font=50,code=pressKey"return"},
	WIDGET.newKey{name="back",x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene