local gc=love.graphics
local kb=love.keyboard

local find,sub,byte=string.find,string.sub,string.byte

function sceneInit.calculator()
	BG.set("none")
	sceneTemp={
		reg=false,
		val="0",
		sym=false,
		pass=false,
	}
end

mouseDown.calculator=NULL
function keyDown.calculator(k)
	local S=sceneTemp
	if byte(k)>=48 and byte(k)<=57 then
		if S.sym=="="then
			S.val=k
			S.sym=false
		elseif S.sym and not S.reg then
			S.reg=S.val
			S.val=k
		else
			if #S.val<14 then
				if S.val=="0"then S.val=""end
				S.val=S.val..k
			end
		end
	elseif k:sub(1,2)=="kp"then
		keyDown.calculator(k:sub(3))
	elseif k=="."then
		if not(find(S.val,".",nil,true)or find(S.val,"e"))then
			if S.sym and not S.reg then
				S.reg=S.val
				S.val="0."
			end
			S.val=S.val.."."
		end
	elseif k=="e"then
		if not find(S.val,"e")then
			S.val=S.val.."e"
		end
	elseif k=="backspace"then
		if S.sym=="="then
			S.val=""
		elseif S.sym then
			S.sym=false
		else
			S.val=sub(S.val,1,-2)
		end
		if S.val==""then S.val="0"end
	elseif k=="+"or k=="="and kb.isDown("lshift","rshift")then
		S.sym="+"
		S.reg=false
	elseif k=="-"then
		S.sym="-"
		S.reg=false
	elseif k=="*"or k=="8"and kb.isDown("lshift","rshift")then
		S.sym="*"
		S.reg=false
	elseif k=="/"then
		S.sym="/"
		S.reg=false
	elseif k=="return"then
		if byte(S.val,-1)==101 then S.val=sub(S.val,1,-2)end
		if S.sym and S.reg then
			if byte(S.reg,-1)==101 then S.reg=sub(S.reg,1,-2)end
			S.val=
				S.sym=="+"and (tonumber(S.reg)or 0)+tonumber(S.val)or
				S.sym=="-"and (tonumber(S.reg)or 0)-tonumber(S.val)or
				S.sym=="*"and (tonumber(S.reg)or 0)*tonumber(S.val)or
				S.sym=="/"and (tonumber(S.reg)or 0)/tonumber(S.val)or
				-1
		end
		S.sym="="
		S.reg=false
		local v=tonumber(S.val)
		if v==600+26 then S.pass=true
		elseif v==190000+6022 then
			S.pass,MARKING=true
			LOG.print("\68\69\86\58\87\97\116\101\114\109\97\114\107\32\82\101\109\111\118\101\100","message")
			SFX.play("clear")
		elseif v==72943816 then
			S.pass=true
			for name,M in next,MODES do
				if not RANKS[name]then
					RANKS[name]=M.score and 0 or 6
				end
			end
			FILE.saveUnlock()
			LOG.print("\68\69\86\58\85\78\76\79\67\75\65\76\76","message")
			SFX.play("clear_2")
		elseif v==1379e8+2626e4+1379 then
			S.pass=true
			SCN.go("debug")
		elseif v%1==0 and v>=6001 and v<=6012 then
			love.keypressed("f"..(v-6000))
		end
	elseif k=="escape"then
		S.val,S.reg,S.sym="0"
	elseif k=="delete"then
		S.val="0"
	elseif k=="space"and S.pass then
		if LOADED then
			SCN.back()
		else
			SCN.swapTo("load","swipeD")
		end
	end
end

function Pnt.calculator()
	local S=sceneTemp
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",100,80,650,150)
	setFont(45)
	if S.reg then gc.printf(S.reg,0,100,720,"right")end
	if S.val then gc.printf(S.val,0,150,720,"right")end
	if S.sym then setFont(50)gc.print(S.sym,126,150)end
end

WIDGET.init("calculator",{
	WIDGET.newKey({name="_1",		x=150,y=300,w=90,						font=50,code=WIDGET.lnk.pressKey("1")}),
	WIDGET.newKey({name="_2",		x=250,y=300,w=90,						font=50,code=WIDGET.lnk.pressKey("2")}),
	WIDGET.newKey({name="_3",		x=350,y=300,w=90,						font=50,code=WIDGET.lnk.pressKey("3")}),
	WIDGET.newKey({name="_4",		x=150,y=400,w=90,						font=50,code=WIDGET.lnk.pressKey("4")}),
	WIDGET.newKey({name="_5",		x=250,y=400,w=90,						font=50,code=WIDGET.lnk.pressKey("5")}),
	WIDGET.newKey({name="_6",		x=350,y=400,w=90,						font=50,code=WIDGET.lnk.pressKey("6")}),
	WIDGET.newKey({name="_7",		x=150,y=500,w=90,						font=50,code=WIDGET.lnk.pressKey("7")}),
	WIDGET.newKey({name="_8",		x=250,y=500,w=90,						font=50,code=WIDGET.lnk.pressKey("8")}),
	WIDGET.newKey({name="_9",		x=350,y=500,w=90,						font=50,code=WIDGET.lnk.pressKey("9")}),
	WIDGET.newKey({name="_0",		x=150,y=600,w=90,						font=50,code=WIDGET.lnk.pressKey("0")}),
	WIDGET.newKey({name=".",		x=250,y=600,w=90,		color="lPurple",font=50,code=WIDGET.lnk.pressKey(".")}),
	WIDGET.newKey({name="e",		x=350,y=600,w=90,		color="lPurple",font=50,code=WIDGET.lnk.pressKey("e")}),
	WIDGET.newKey({name="+",		x=450,y=300,w=90,		color="lBlue",	font=50,code=WIDGET.lnk.pressKey("+")}),
	WIDGET.newKey({name="-",		x=450,y=400,w=90,		color="lBlue",	font=50,code=WIDGET.lnk.pressKey("-")}),
	WIDGET.newKey({name="*",		x=450,y=500,w=90,		color="lBlue",	font=50,code=WIDGET.lnk.pressKey("*")}),
	WIDGET.newKey({name="/",		x=450,y=600,w=90,		color="lBlue",	font=50,code=WIDGET.lnk.pressKey("/")}),
	WIDGET.newKey({name="<",		x=550,y=300,w=90,		color="lRed",	font=50,code=WIDGET.lnk.pressKey("backspace")}),
	WIDGET.newKey({name="=",		x=550,y=400,w=90,		color="lYellow",font=50,code=WIDGET.lnk.pressKey("return")}),
	WIDGET.newButton({name="play",	x=640,y=600,w=180,h=90,	color="lGreen",	font=40,code=WIDGET.lnk.pressKey("space"),hide=function()return not sceneTemp.pass end}),
})