local gc=love.graphics
local kb=love.keyboard

local find,sub,byte=string.find,string.sub,string.byte

local scene={}

local reg--register
local val--value
local sym--symbol
local pass--if password correct

function scene.sceneInit()
	BG.set("none")
	reg=false
	val="0"
	sym=false
	pass=false
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
		local v=tonumber(val)
		if v==600+26 then pass=true
		elseif v==190000+6022 then
			pass,MARKING=true
			LOG.print("\68\69\86\58\87\97\116\101\114\109\97\114\107\32\82\101\109\111\118\101\100","message")
			SFX.play("clear")
		elseif v==72943816 then
			pass=true
			for name,M in next,MODES do
				if not RANKS[name]then
					RANKS[name]=M.score and 0 or 6
				end
			end
			FILE.save(RANKS,"conf/unlock")
			LOG.print("\68\69\86\58\85\78\76\79\67\75\65\76\76","message")
			SFX.play("clear_2")
		elseif v%1==0 and v>=8001 and v<=8012 then
			love.keypressed("f"..(v-8000))
		elseif v==123456 then
			gc.setWireframe(not gc.isWireframe())
			LOG.print("Wireframe: "..(gc.isWireframe()and"on"or"off"),"warn")
		elseif v==654321 then
			love._setGammaCorrect(not gc.isGammaCorrect())
			LOG.print("GammaCorrect: "..(gc.isGammaCorrect()and"on"or"off"),"warn")
		elseif v==114514 or v==1919810 or v==1145141919810 then
			error()
		elseif v==200 then
			loadGame("marathon_bfmax",true)
		elseif v==670 then
			SCR.print()
		end
	elseif k=="escape"then
		val,reg,sym="0"
	elseif k=="delete"then
		val="0"
	elseif k=="space"and pass then
		if LOADED then
			SCN.back()
		else
			SCN.swapTo("load","swipeD")
		end
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
	WIDGET.newKey{name="_1",x=150,y=300,w=90,				font=50,code=WIDGET.lnk_pressKey("1")},
	WIDGET.newKey{name="_2",x=250,y=300,w=90,				font=50,code=WIDGET.lnk_pressKey("2")},
	WIDGET.newKey{name="_3",x=350,y=300,w=90,				font=50,code=WIDGET.lnk_pressKey("3")},
	WIDGET.newKey{name="_4",x=150,y=400,w=90,				font=50,code=WIDGET.lnk_pressKey("4")},
	WIDGET.newKey{name="_5",x=250,y=400,w=90,				font=50,code=WIDGET.lnk_pressKey("5")},
	WIDGET.newKey{name="_6",x=350,y=400,w=90,				font=50,code=WIDGET.lnk_pressKey("6")},
	WIDGET.newKey{name="_7",x=150,y=500,w=90,				font=50,code=WIDGET.lnk_pressKey("7")},
	WIDGET.newKey{name="_8",x=250,y=500,w=90,				font=50,code=WIDGET.lnk_pressKey("8")},
	WIDGET.newKey{name="_9",x=350,y=500,w=90,				font=50,code=WIDGET.lnk_pressKey("9")},
	WIDGET.newKey{name="_0",x=150,y=600,w=90,				font=50,code=WIDGET.lnk_pressKey("0")},
	WIDGET.newKey{name=".",	x=250,y=600,w=90,color="lPurple",font=50,code=WIDGET.lnk_pressKey(".")},
	WIDGET.newKey{name="e",	x=350,y=600,w=90,color="lPurple",font=50,code=WIDGET.lnk_pressKey("e")},
	WIDGET.newKey{name="+",	x=450,y=300,w=90,color="lBlue",	font=50,code=WIDGET.lnk_pressKey("+")},
	WIDGET.newKey{name="-",	x=450,y=400,w=90,color="lBlue",	font=50,code=WIDGET.lnk_pressKey("-")},
	WIDGET.newKey{name="*",	x=450,y=500,w=90,color="lBlue",	font=50,code=WIDGET.lnk_pressKey("*")},
	WIDGET.newKey{name="/",	x=450,y=600,w=90,color="lBlue",	font=50,code=WIDGET.lnk_pressKey("/")},
	WIDGET.newKey{name="<",	x=550,y=300,w=90,color="lRed",	font=50,code=WIDGET.lnk_pressKey("backspace")},
	WIDGET.newKey{name="=",	x=550,y=400,w=90,color="lYellow",font=50,code=WIDGET.lnk_pressKey("return")},
	WIDGET.newButton{name="play",x=640,y=600,w=180,h=90,color="lGreen",font=40,code=WIDGET.lnk_pressKey("space"),hide=function()return not pass end},
}

return scene